function validate_config(config)
% Simülasyon için gerekli tüm config alanlarının var olduğunu doğrular.

required_fields = { ...
    "N", "fs", "A", "f0", "settling_samples", ...
    "lpf_cutoff", "lpf_order", "phase_rms_dut", ...
    "phase_rms_ref1", "phase_rms_ref2", ...
    "number_of_iterations", "number_of_log_bins"};

% Her zorunlu alanı tek tek kontrol et, eksikse hata ver.
for field_index = 1:numel(required_fields)
    field_name = required_fields{field_index};
    if ~isfield(config, field_name)
        error("Eksik parametre: config.%s", field_name);
    end
end

end