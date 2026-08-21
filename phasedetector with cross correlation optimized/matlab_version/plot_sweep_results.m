function plot_sweep_results(sweep_name, values, run_results, label_fmt, ...
    default_value, out_png, show_figure)
% Bir taramadaki her bağımsız koşuyu ayrı subplot'ta çizer. Her subplot
% yalnızca o koşunun Cross-PSD tahminini ve filtrelenmemiş DUT
% periodogramını içerir.
%
% run_results sırası values sırasıyla eşleşmelidir. label_fmt subplot başlığında
% test değerini biçimlendirir; default_value eşleşmesi "(orig)" olarak işaretlenir.

% Değer sayısına yakın kare biçimli bir subplot matrisi seç.
number_of_values = numel(values);
number_of_columns = ceil(sqrt(number_of_values));
number_of_rows = ceil(number_of_values / number_of_columns);

% Her axes kendi otomatik limitini kullansaydı küçük farklar olduğundan büyük
% görünebilirdi; bu nedenle bütün subplot'lar için ortak X/Y sınırı hesapla.
frequency_min = Inf;
frequency_max = -Inf;
level_min = Inf;
level_max = -Inf;
for value_index = 1:number_of_values
    current_results = run_results{value_index};
    if isfield(current_results, "dut_fft_unfiltered")
        dut_plot = current_results.dut_fft_unfiltered;
    else
        % Eski MAT sonuçlarında yalnızca filtreli DUT alanı bulunur.
        dut_plot = current_results.dut_fft;
    end
    frequencies = [current_results.cross.frequency_binned(:); ...
        dut_plot.frequency_binned(:)];
    levels = [current_results.cross.phase_noise_binned(:); ...
        dut_plot.phase_noise_binned(:)];
    valid_frequencies = frequencies(isfinite(frequencies) & frequencies > 0);
    valid_levels = levels(isfinite(levels));
    if ~isempty(valid_frequencies)
        frequency_min = min(frequency_min, min(valid_frequencies));
        frequency_max = max(frequency_max, max(valid_frequencies));
    end
    if ~isempty(valid_levels)
        level_min = min(level_min, min(valid_levels));
        level_max = max(level_max, max(valid_levels));
    end
end
if ~isfinite(frequency_min) || ~isfinite(frequency_max) || ...
        ~isfinite(level_min) || ~isfinite(level_max)
    error("Karsilastirma grafigi icin sonlu veri bulunamadi.");
end
% Eğrilerin çerçeveye yapışmaması için en az 1 dB dikey boşluk bırak.
level_padding = max(1, 0.05*(level_max - level_min));

% Kaydetme tamamlanana kadar pencereyi gizli tut; bu, sweep sırasında GUI
% pencerelerinin art arda öne gelmesini önler.
fig = figure("visible", "off", "position", ...
    [50, 50, 520*number_of_columns, 360*number_of_rows]);

for value_index = 1:number_of_values
    % Her subplot tek bir bağımsız run içerir; farklı test değerleri üst üste çizilmez.
    ax = subplot(number_of_rows, number_of_columns, value_index, ...
        "Parent", fig);
    current_results = run_results{value_index};
    if isfield(current_results, "dut_fft_unfiltered")
        dut_plot = current_results.dut_fft_unfiltered;
        if isfield(dut_plot, "number_of_averages")
            dut_display_name = "Averaged unfiltered DUT periodogram";
        else
            dut_display_name = "Unfiltered DUT periodogram";
        end
    else
        % Kayıtlı eski sonuçların yeniden çizilebilmesini sürdür.
        dut_plot = current_results.dut_fft;
        dut_display_name = "DUT periodogram (saved result)";
    end
    current_label = sprintf(label_fmt, values(value_index));
    if values(value_index) == default_value
        current_label = sprintf("%s (orig)", current_label);
    end

    % Aynı run'ın ölçüm tahmini ve DUT referansı iki farklı çizgi stiliyle gösterilir.
    semilogx(ax, current_results.cross.frequency_binned, ...
        current_results.cross.phase_noise_binned, ...
        "b-", "LineWidth", 2, ...
        "DisplayName", "Cross-PSD estimate");
    hold(ax, "on");
    semilogx(ax, dut_plot.frequency_binned, ...
        dut_plot.phase_noise_binned, ...
        "r--", "LineWidth", 1.5, ...
        "DisplayName", dut_display_name);

    grid(ax, "on");
    xlabel(ax, "Offset Frequency (Hz)");
    ylabel(ax, "Phase Noise (dBc/Hz)");
    xlim(ax, [frequency_min, frequency_max]);
    ylim(ax, [level_min - level_padding, level_max + level_padding]);
    % Başlıkta hem fiziksel config hem de o run'a ait sonuç metrikleri yer alır.
    cfg = current_results.config;
    config_details = sprintf( ...
        "f_c %.1f kHz | DUT %.2f rad | Ref %.2f/%.2f rad", ...
        cfg.lpf_cutoff/1e3, cfg.phase_rms_dut, ...
        cfg.phase_rms_ref1, cfg.phase_rms_ref2);
    run_details = sprintf( ...
        "%d iter | %d bins | MAE %.3f dB | correction %.4f", ...
        cfg.number_of_iterations, cfg.number_of_log_bins, ...
        current_results.mean_absolute_error_fft_db, ...
        current_results.correction_factor);
    title(ax, {sprintf("%s | %s", sweep_name, current_label), ...
        config_details, run_details}, "Interpreter", "none");
    legend(ax, "location", "southwest", "FontSize", 7);
    hold(ax, "off");
end

% Figürü MATLAB'in güncel grafik dışa aktarıcısıyla 150 DPI PNG olarak kaydet.
% Grafik backend'i kaydedemezse simülasyon sonuçlarını kaybetmeden uyarı ver.
try
    exportgraphics(fig, out_png, "Resolution", 150);
catch err
    warning("phaseNoise:PlotExportFailed", ...
        "PNG kaydedilemedi: %s", err.message);
end

% Batch modunda figürü kapat; GUI incelemesi istenmişse görünür yapıp açık bırak.
if show_figure
    set(fig, "visible", "on");
else
    close(fig);
end

end
