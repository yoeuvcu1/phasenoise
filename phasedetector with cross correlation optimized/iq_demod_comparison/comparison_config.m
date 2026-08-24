function config = comparison_config()
%COMPARISON_CONFIG Settings used by run_iq_comparison.m.
% Edit only the values here, then press Run in run_iq_comparison.m.

config = struct();
config.N = 10000;                 % Sample count
config.fs = 1e6;                   % Sample rate [Hz]
config.A = 1;                      % Carrier amplitude
config.f0 = 200e3;                  % Carrier frequency [Hz]
config.settling_samples = 100;     % Discarded LPF transient samples
config.lpf_cutoff = 50e3;           % LPF cutoff [Hz]
config.lpf_order = 4;              % Butterworth order
config.phase_rms_dut = 0.1;        % DUT phase-noise RMS [rad]
config.phase_rms_ref1 = 0.2;       % Reference 1 RMS [rad]
config.phase_rms_ref2 = 0.2;       % Reference 2 RMS [rad]
config.number_of_iterations = 200; % Cross-PSD average count
config.number_of_log_bins = 100;   % Logarithmic bin count

end
