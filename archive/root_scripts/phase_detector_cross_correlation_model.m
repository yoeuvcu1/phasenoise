%% Phase detector with cross-correlation
% Equivalent-baseband MATLAB model of Rohde & Schwarz Fig. 2-8.
%
% The two phase-detector channels are
%
%   e_i(t) = H_PLL * [phi_DUT(t) - phi_REF_i(t)]
%   v_i(t) = G * [LPF{Kd*sin(e_i(t))} + Kd*n_i(t)] + ADC noise
%
% Around quadrature, |e_i| << 1 rad, so sin(e_i) ~= e_i. After calibration,
%
%   x_1(t) ~= H_PLL * [phi_DUT(t)-phi_REF1(t)] + n_1(t)
%   x_2(t) ~= H_PLL * [phi_DUT(t)-phi_REF2(t)] + n_2(t)
%
% If REF1, REF2, n1 and n2 are mutually uncorrelated and uncorrelated with
% the DUT, the ensemble cross-PSD becomes
%
%   S_12(f) = E{X_1(f) conj(X_2(f))}
%           = |H_PLL(f) H_LPF(f)|^2 S_phi,DUT(f).
%
% Therefore the PLL-corrected DUT phase-noise estimate is
%
%   L_DUT(f) = 10*log10( |S_12(f)| /
%              (2*|H_PLL(f)H_LPF(f)|^2) ) dBc/Hz.
%
% IMPORTANT: Complex cross spectra are averaged first. Taking abs() on each
% individual record before averaging prevents uncorrelated noise cancellation.
%
% This script uses only base MATLAB functions. Local helper functions at the
% end implement colored-noise generation, the PLL error transfer function,
% ADC quantization and one-sided Welch auto/cross PSD estimates.

clear;
close all;
clc;
rng(7, "twister");

%% User-adjustable model parameters
fs            = 20e3;       % Baseband ADC sample rate [Hz]
nfft          = 2^14;       % Welch segment/FFT length
overlapRatio  = 0.50;       % Hann-window overlap
nAverages     = 200;        % Requested Welch cross-spectrum averages
fPll          = 20;         % First-order PLL bandwidth [Hz]
fLpf          = 8e3;        % Baseband anti-alias LPF bandwidth [Hz]
Kd            = 0.30;       % Calibrated detector slope near quadrature [V/rad]
lnaGain       = 1e3;        % Voltage gain after the detector [V/V]
adcBits       = 16;         % ADC resolution
adcFullScale  = 1.0;        % Bipolar ADC range is +/-adcFullScale [V]
includeSpurs  = true;        % Add common and channel-specific deterministic spurs

noverlap = round(overlapRatio*nfft);
hop      = nfft-noverlap;
N        = nfft + (nAverages-1)*hop;
t        = (0:N-1)'/fs;

fprintf("Number of samples       : %d\n", N);
fprintf("Record duration         : %.2f s\n", N/fs);
fprintf("Welch bin spacing       : %.3f Hz\n", fs/nfft);
fprintf("Hann ENBW (approx.)     : %.3f Hz\n", 1.5*fs/nfft);
fprintf("Requested averages      : %d\n\n", nAverages);

%% Define the input phase-noise spectra
% Linear L(f) is the single-sideband phase-noise ratio [1/Hz].
% For small phase modulation, the one-sided phase PSD is S_phi(f)=2*L(f).
fGen = (0:floor(N/2))'*fs/N;
[LDutLinGen, LRefLinGen, LElecLinGen] = phaseNoiseModels(fGen);

SphiDutGen  = 2*LDutLinGen;       % [rad^2/Hz], one-sided
SphiRefGen  = 2*LRefLinGen;       % each reference has the same PSD shape
SphiElecGen = 2*LElecLinGen;      % input-referred detector/LNA noise

%% Generate common DUT noise and independent channel noises
% All sequences are random realizations with the requested one-sided PSD.
phiDut  = realNoiseFromOneSidedPSD(SphiDutGen,  fs, N);
phiRef1 = realNoiseFromOneSidedPSD(SphiRefGen,  fs, N);
phiRef2 = realNoiseFromOneSidedPSD(SphiRefGen,  fs, N);
nElec1  = realNoiseFromOneSidedPSD(SphiElecGen, fs, N);
nElec2  = realNoiseFromOneSidedPSD(SphiElecGen, fs, N);

if includeSpurs
    % The 500 Hz DUT spur is common and should remain after correlation.
    % The 900/1300 Hz reference spurs exist in only one channel and should
    % largely disappear from the cross spectrum.
    phiDut  = phiDut  + 3e-5*sin(2*pi*500*t);
    phiRef1 = phiRef1 + 8e-5*sin(2*pi*900*t + 0.3);
    phiRef2 = phiRef2 + 8e-5*sin(2*pi*1300*t - 0.7);
end

%% Two independent PLL + phase-detector + LNA + ADC channels
% A first-order loop makes the residual phase detector error high-pass:
%
%                    s
%   H_PLL(s) = --------------- .
%                s + 2*pi*fPll
%
% Below the loop bandwidth the reference tracks DUT phase changes, so the
% detector output is suppressed. A phase-noise analyzer corrects this known
% response after PSD estimation.
e1 = applyPllErrorTransfer(phiDut-phiRef1, fs, fPll);
e2 = applyPllErrorTransfer(phiDut-phiRef2, fs, fPll);

% Nonlinear phase-detector characteristic at quadrature.
vPd1 = Kd*sin(e1);
vPd2 = Kd*sin(e2);

% The RF sum-frequency mixer product is absent from an equivalent-baseband
% model. This explicit LPF represents the finite baseband/anti-alias response.
vPd1 = applyBasebandLowpass(vPd1, fs, fLpf);
vPd2 = applyBasebandLowpass(vPd2, fs, fLpf);

% Detector/LNA noise is represented as an equivalent input phase noise added
% after the LPF. Moving this noise injection point lets other stages be tested.
vAdc1 = lnaGain*(vPd1 + Kd*nElec1);
vAdc2 = lnaGain*(vPd2 + Kd*nElec2);

% Independent ADC quantization in each channel.
vAdc1 = quantizeBipolar(vAdc1, adcBits, adcFullScale);
vAdc2 = quantizeBipolar(vAdc2, adcBits, adcFullScale);

% Detector gain calibration converts volts back to measured phase [rad].
x1 = vAdc1/(lnaGain*Kd);
x2 = vAdc2/(lnaGain*Kd);

fprintf("RMS PLL error, channel 1: %.3e rad\n", rmsLocal(e1));
fprintf("RMS PLL error, channel 2: %.3e rad\n", rmsLocal(e2));
fprintf("Peak ADC voltage, ch. 1 : %.3f V\n", max(abs(vAdc1)));
fprintf("Peak ADC voltage, ch. 2 : %.3f V\n\n", max(abs(vAdc2)));

%% Complex Welch cross-spectrum
[S12, S11, S22, f, averagesUsed] = welchCrossPSD(...
    x1, x2, fs, nfft, noverlap);

Hpll       = 1i*f./(fPll + 1i*f);
Hlpf       = fLpf./(fLpf + 1i*f);
chainGainSq = abs(Hpll.*Hlpf).^2;
chainGainSq(1) = NaN;  % DC is fully suppressed and cannot be corrected.

% abs() is intentionally applied only AFTER the complex S12 records have
% been averaged inside welchCrossPSD().
Lcross = 10*log10(abs(S12)./(2*chainGainSq));
Lauto1 = 10*log10(S11./(2*chainGainSq));
Lauto2 = 10*log10(S22./(2*chainGainSq));

[LDutLin, LRefLin, ~] = phaseNoiseModels(f);
LdutTargetDb = 10*log10(LDutLin);
LrefTargetDb = 10*log10(LRefLin);

fprintf("Actual Welch averages   : %d\n", averagesUsed);
fprintf("Ideal floor reduction   : %.2f dB (5*log10(M))\n\n", ...
    5*log10(averagesUsed));

%% Figure 1 - phase detector linearization around quadrature
dphi = linspace(-0.5, 0.5, 1001);
figure("Color", "w", "Name", "Phase detector characteristic");
plot(dphi, Kd*sin(dphi), "LineWidth", 1.8);
hold on;
plot(dphi, Kd*dphi, "--", "LineWidth", 1.5);
grid on;
xlabel("Phase error, \Delta\phi [rad]");
ylabel("Phase detector output [V]");
title("Quadrature phase detector: K_d sin(\Delta\phi) \approx K_d\Delta\phi");
legend("Nonlinear detector", "Small-angle model", "Location", "northwest");

%% Figure 2 - single-channel versus cross-correlated measurement
fMinPlot = max(2*fs/nfft, 1);
valid = f >= fMinPlot & f <= 0.95*(fs/2);

figure("Color", "w", "Name", "Cross-correlated phase noise");
semilogx(f(valid), Lauto1(valid), "Color", [0.82 0.42 0.12], ...
    "LineWidth", 0.8);
hold on;
semilogx(f(valid), Lauto2(valid), "Color", [0.15 0.55 0.78], ...
    "LineWidth", 0.8);
semilogx(f(valid), Lcross(valid), "k", "LineWidth", 1.35);
semilogx(f(valid), LdutTargetDb(valid), "--", "Color", [0.10 0.60 0.20], ...
    "LineWidth", 1.8);
semilogx(f(valid), LrefTargetDb(valid), ":", "Color", [0.55 0.20 0.65], ...
    "LineWidth", 1.5);
grid on;
xlabel("Offset frequency [Hz]");
ylabel("L(f) [dBc/Hz]");
title(sprintf("Phase-detector cross correlation, M = %d", averagesUsed));
legend("Channel 1 auto-PSD", "Channel 2 auto-PSD", ...
    "Cross-PSD estimate", "True DUT model", "Each reference model", ...
    "Location", "southwest");
ylim([-190 -65]);

%% Figure 3 - why more correlations lower the uncorrelated floor
M = logspace(0, 4, 401);
idealReductionDb = 5*log10(M);

figure("Color", "w", "Name", "Cross-correlation averaging law");
semilogx(M, idealReductionDb, "LineWidth", 2);
hold on;
plot([100 1e4], [10 20], "o", "MarkerSize", 8, ...
    "MarkerFaceColor", [0.15 0.55 0.78]);
grid on;
xlabel("Number of independent cross-spectrum averages, M");
ylabel("Uncorrelated floor reduction [dB]");
title("Ideal cross-correlation sensitivity improvement: 5 log_{10}(M)");
legend("5 log_{10}(M)", "R&S examples: (100,10 dB), (10000,20 dB)", ...
    "Location", "northwest");

%% Numerical spot-noise comparison
spotFrequencies = [10 100 1e3 5e3];
fprintf("Spot-noise comparison after PLL correction\n");
fprintf(" Offset   True DUT    Ch1 auto    Cross PSD\n");
fprintf("   [Hz]   [dBc/Hz]   [dBc/Hz]    [dBc/Hz]\n");
for k = 1:numel(spotFrequencies)
    [~, idx] = min(abs(f-spotFrequencies(k)));
    fprintf("%7.0f   %9.2f   %9.2f   %10.2f\n", f(idx), ...
        LdutTargetDb(idx), Lauto1(idx), Lcross(idx));
end

%% Local functions
function [LDutLin, LRefLin, LElecLin] = phaseNoiseModels(f)
% Return linear single-sideband phase-noise spectra L(f) [1/Hz].
% Values are illustrative, not specifications for a particular oscillator.
    fSafe = max(f, 1);

    % DUT: close-in 1/f^3 region plus 1/f and white PM floor.
    LDutLin = 1e-8./fSafe.^3 + 1e-13./fSafe + 1e-15;

    % Each independent reference: quieter close-in than the DUT, but with a
    % -140 dBc/Hz far-out floor that hides the -150 dBc/Hz DUT in a
    % single channel but can be reduced by cross-spectrum averaging.
    LRefLin = 1e-10./fSafe.^2 + 1e-14;

    % Independent detector/LNA equivalent input noise, -160 dBc/Hz.
    LElecLin = 1e-16*ones(size(f));
end

function x = realNoiseFromOneSidedPSD(S1, fs, N)
% Generate a real, zero-mean Gaussian sequence having the requested
% one-sided PSD samples S1 at f=(0:floor(N/2))*fs/N.
    nPositive = floor(N/2)+1;
    if numel(S1) ~= nPositive
        error("PSD length must equal floor(N/2)+1.");
    end

    S1 = max(real(S1(:)), 0);
    X = zeros(N, 1);

    if rem(N, 2) == 0
        positiveInterior = (2:nPositive-1).';
    else
        positiveInterior = (2:nPositive).';
    end

    z = (randn(numel(positiveInterior),1) + ...
         1i*randn(numel(positiveInterior),1))/sqrt(2);
    X(positiveInterior) = z .* sqrt(S1(positiveInterior)*fs*N/2);

    % Conjugate symmetry creates a real time-domain sequence.
    negativeIndices = N-positiveInterior+2;
    X(negativeIndices) = conj(X(positiveInterior));

    % Phase-noise fluctuations are modeled with no DC component. The
    % Nyquist bin is also set to zero because it is not important here.
    X(1) = 0;
    if rem(N, 2) == 0
        X(nPositive) = 0;
    end

    x = real(ifft(X));
end

function y = applyPllErrorTransfer(x, fs, fPll)
% Apply H_PLL(s)=s/(s+2*pi*fPll) using a conjugate-symmetric FFT response.
    N = numel(x);
    if rem(N,2) == 0
        fSigned = [0:N/2 -N/2+1:-1]'*(fs/N);
    else
        fSigned = [0:(N-1)/2 -(N-1)/2:-1]'*(fs/N);
    end
    H = 1i*fSigned./(fPll + 1i*fSigned);
    if rem(N,2) == 0
        H(N/2+1) = abs(H(N/2+1));
    end
    y = real(ifft(fft(x).*H));
end

function y = applyBasebandLowpass(x, fs, fLpf)
% Apply a first-order baseband LPF, H(s)=2*pi*fLpf/(s+2*pi*fLpf).
    N = numel(x);
    if rem(N,2) == 0
        fSigned = [0:N/2 -N/2+1:-1]'*(fs/N);
    else
        fSigned = [0:(N-1)/2 -(N-1)/2:-1]'*(fs/N);
    end
    H = fLpf./(fLpf + 1i*fSigned);
    if rem(N,2) == 0
        H(N/2+1) = abs(H(N/2+1));
    end
    y = real(ifft(fft(x).*H));
end

function y = quantizeBipolar(x, nBits, fullScale)
% Uniform mid-tread quantizer with clipping to +/-fullScale volts.
    q = 2*fullScale/(2^nBits-1);
    xClipped = min(max(x, -fullScale), fullScale);
    y = q*round(xClipped/q);
end

function [S12, S11, S22, f, M] = welchCrossPSD(x1, x2, fs, nfft, noverlap)
% One-sided Welch auto/cross PSDs. Cross spectra remain complex throughout
% accumulation and are divided by M before the caller takes abs().
    x1 = x1(:);
    x2 = x2(:);
    if numel(x1) ~= numel(x2)
        error("Input records must have equal length.");
    end
    if noverlap >= nfft
        error("Overlap must be smaller than nfft.");
    end

    hop = nfft-noverlap;
    starts = 1:hop:(numel(x1)-nfft+1);
    M = numel(starts);

    n = (0:nfft-1)';
    w = 0.5 - 0.5*cos(2*pi*n/nfft);  % periodic Hann window
    U = sum(w.^2);
    nOneSided = floor(nfft/2)+1;

    S12 = zeros(nOneSided,1);
    S11 = zeros(nOneSided,1);
    S22 = zeros(nOneSided,1);

    for m = 1:M
        idx = starts(m):(starts(m)+nfft-1);
        a = x1(idx)-mean(x1(idx));
        b = x2(idx)-mean(x2(idx));
        A = fft(a.*w, nfft);
        B = fft(b.*w, nfft);

        P12 = A(1:nOneSided).*conj(B(1:nOneSided))/(fs*U);
        P11 = abs(A(1:nOneSided)).^2/(fs*U);
        P22 = abs(B(1:nOneSided)).^2/(fs*U);

        if rem(nfft,2) == 0
            doubleBins = 2:nOneSided-1;
        else
            doubleBins = 2:nOneSided;
        end
        P12(doubleBins) = 2*P12(doubleBins);
        P11(doubleBins) = 2*P11(doubleBins);
        P22(doubleBins) = 2*P22(doubleBins);

        S12 = S12 + P12;
        S11 = S11 + P11;
        S22 = S22 + P22;
    end

    S12 = S12/M;
    S11 = S11/M;
    S22 = S22/M;
    f = (0:nOneSided-1)'*fs/nfft;
end

function value = rmsLocal(x)
    value = sqrt(mean(abs(x).^2));
end
