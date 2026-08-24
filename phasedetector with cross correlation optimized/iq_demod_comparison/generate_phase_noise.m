function phase_noise = generate_phase_noise(N, phase_rms)
%GENERATE_PHASE_NOISE Generate the same 1/f^3 noise as the active project.

if mod(N, 2) ~= 0
    error("N cift sayi olmalidir.");
end

seed = mod(173*floor(time()*1e6), 100000);
rng(seed);
white = randn(N, 1);
X_white = fft(white);

f_bin = [0:N/2, N/2-1:-1:1]';
f_bin(1) = 1;
phase_noise_filter = 1 ./ sqrt(f_bin.^3);
phase_noise_filter(1) = 0;
unit_phase_noise = real(ifft(X_white .* phase_noise_filter));
unit_phase_noise = remove_dc(unit_phase_noise);
unit_phase_noise = unit_phase_noise / sqrt(mean(unit_phase_noise.^2));
phase_noise = phase_rms * unit_phase_noise;

end
