function summary = test_rms_runs()
%TEST_RMS_RUNS Average FFT errors over repeated DUT RMS tests.

dut_rms_values = [0.5, 0.2];
number_of_runs = 20;

base_config.N = 10000;
base_config.fs = 1e6;
base_config.A = 1;
base_config.f0 = 50e3;
base_config.settling_samples = 100;
base_config.lpf_cutoff = 25e3;
base_config.lpf_order = 4;
base_config.phase_rms_ref1 = 0.1;
base_config.phase_rms_ref2 = 0.1;
base_config.number_of_iterations = 500;
base_config.number_of_log_bins = 50;
base_config.show_plot = false;

number_of_rms_values = numel(dut_rms_values);
absolute_errors_db = zeros(number_of_rms_values, number_of_runs);

for rms_index = 1:number_of_rms_values
    dut_rms = dut_rms_values(rms_index);
    fprintf("\n=== DUT RMS: %.3f rad ===\n", dut_rms);

    for run_index = 1:number_of_runs
        fprintf("Run %d/%d\n", run_index, number_of_runs);

        config = base_config;
        config.phase_rms_dut = dut_rms;
        run_results = main(config);

        absolute_errors_db(rms_index, run_index) = ...
            run_results.mean_absolute_error_fft_db;
    end

    fprintf("DUT RMS %.3f rad icin ortalama mutlak hata: %.3f dB\n", ...
        dut_rms, mean(absolute_errors_db(rms_index, :)));
end

summary.dut_rms_values = dut_rms_values;
summary.absolute_errors_db = absolute_errors_db;
summary.mean_absolute_errors_db = mean(absolute_errors_db, 2);
summary.number_of_runs = number_of_runs;

fprintf("\n=== TEST OZETI ===\n");
for rms_index = 1:number_of_rms_values
    fprintf("DUT RMS %.3f rad: %.3f dB ortalama mutlak hata (%d run)\n", ...
        dut_rms_values(rms_index), ...
        summary.mean_absolute_errors_db(rms_index), ...
        number_of_runs);
end

end
