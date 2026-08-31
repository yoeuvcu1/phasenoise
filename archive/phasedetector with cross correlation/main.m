function results = main(config)

if nargin == 0
    config.N = 100000;
    config.fs = 1e6;
    config.A = 1;
    config.f0 = 50e3;
    config.settling_samples = 100;
    config.lpf_cutoff = 25e3;
    config.lpf_order = 4;
    config.phase_rms_dut = 0.2;
    config.phase_rms_ref1 = 0.05;
    config.phase_rms_ref2 = 0.05;
    config.number_of_iterations = 100;
    config.number_of_log_bins = 50;
    config.show_plot = true;
end

results = step01_sources(config);

end
