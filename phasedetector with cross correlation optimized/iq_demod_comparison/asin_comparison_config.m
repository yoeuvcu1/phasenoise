function settings = asin_comparison_config()
%ASIN_COMPARISON_CONFIG Settings for the six-panel asin comparison.
% Edit these values, then press Run in run_asin_realization_comparison.m.

settings.base_config = comparison_config();
settings.random_seed = 24082026;
settings.realization_count = 3;

% Each panel is one record; base_config.number_of_iterations is not used here.

% Row 1: DUT 0.2 rad, both references 0.5 rad.
% Row 2: DUT 0.02 rad, both references 0.05 rad.
settings.dut_rms_by_row = [0.2, 0.02];
settings.ref_rms_by_row = [0.5, 0.05];

end
