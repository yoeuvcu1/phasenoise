function bands = decade_band_errors(frequency_cross, level_cross, ...
    frequency_dut, level_dut, points_per_decade)
% Cross-PSD ve DUT egrileri arasindaki mutlak dB farkini dekad bantlarinda
% ayri ayri ortalar.
%
% Tam bant MAE bütün offset bölgesini tek sayiya indirger; LPF geçis bandindaki
% uyum ile kesim frekansi üstündeki artik ayrisma ayni ortalamada karisir. Bu
% fonksiyon ayni farki dekad dekad raporlayarak hangi offset bölgesinin hataya
% katki yaptigini gösterir.
%
% Girdiler run_simulation.m çiktisindaki log-binlenmis egrilerdir. Ortak frekans
% araligi ve dogrusal interpolasyon kurali tam bant MAE ile aynidir; tek fark,
% sabit yogunluklu tek bir logaritmik izgaranin noktalarinin ait olduklari dekad
% bandina atanmasidir. Bu nedenle bant MAE degerlerinin nokta sayisiyla
% agirlikli ortalamasi ayni izgarada hesaplanan tam bant MAE'ye esittir. Tek
% istisna, bir dekadin yarisindan dar kalan uç bantlardir: bunlar dekad olarak
% yorumlanamayacagi için raporlanmaz.
%
% Girdiler:
%   frequency_cross, level_cross : Cross-PSD binlenmis frekans (Hz) ve dBc/Hz
%   frequency_dut, level_dut     : DUT periodogrami binlenmis frekans ve dBc/Hz
%   points_per_decade            : Dekad basina interpolasyon noktasi (bos ise 40)
%
% Çikti alanlari: frequency_low, frequency_high, mean_absolute_error_db,
% number_of_points, label.

%% ---------------- INTERPOLATION GRID ----------------
if nargin < 5 || isempty(points_per_decade)
    points_per_decade = 40;
end

frequency_cross = frequency_cross(:);
level_cross = level_cross(:);
frequency_dut = frequency_dut(:);
level_dut = level_dut(:);

% MAE yalniz iki egrinin de veri içerdigi ortak aralikta tanimlidir.
frequency_min_common = max(min(frequency_cross), min(frequency_dut));
frequency_max_common = min(max(frequency_cross), max(frequency_dut));
if ~isfinite(frequency_min_common) || ~isfinite(frequency_max_common) || ...
        frequency_min_common >= frequency_max_common
    error("Dekad hatasi icin ortak frekans araligi bulunamadi.");
end

% Nokta sayisini aralik genisligiyle olçekle; boylece her dekad esit temsil edilir.
decade_span = log10(frequency_max_common) - log10(frequency_min_common);
point_count = max(2, round(points_per_decade * decade_span));
frequency_common = logspace(log10(frequency_min_common), ...
    log10(frequency_max_common), point_count);
% Uç noktadaki kayar nokta tasmasini onlemek için araliga kistir.
frequency_common = min(max(frequency_common, frequency_min_common), ...
    frequency_max_common);

level_cross_interp = interp1( ...
    log10(frequency_cross), level_cross, log10(frequency_common), "linear");
level_dut_interp = interp1( ...
    log10(frequency_dut), level_dut, log10(frequency_common), "linear");
absolute_difference = abs(level_cross_interp - level_dut_interp);
valid_points = isfinite(absolute_difference);

%% ---------------- DECADE EDGES ----------------
% Ondalik dekad kenarlarini kur, ortak araligin disinda kalanlari at ve aralik
% uçlarini ekle. Ilk ve son bant, olçum izgarasinin uçlarinda kaldigi için tam
% dekad olmayabilir.
decade_edges = 10.^(floor(log10(frequency_min_common)): ...
    ceil(log10(frequency_max_common)));
interior_edges = decade_edges(decade_edges > frequency_min_common & ...
    decade_edges < frequency_max_common);
band_edges = unique([frequency_min_common, interior_edges, frequency_max_common]);

% Çok dar kalan uç bantlar dekad olarak yorumlanamaz; tek bir bin dizisinden
% gelen bu kirintilar raporlanmaz. Esik bir dekadin yarisidir: orn. 0.48 - 1 Hz
% (0.32 dekad) atilirken 100 - 467 kHz (0.67 dekad) korunur. Atilan bant
% ortalamaya girmedigi için tam bant MAE ile birebir esitlik aranmaz.
minimum_edge_band_decades = 0.5;
if numel(band_edges) > 2
    if log10(band_edges(2)/band_edges(1)) < minimum_edge_band_decades
        band_edges(1) = [];
    end
end
if numel(band_edges) > 2
    if log10(band_edges(end)/band_edges(end-1)) < minimum_edge_band_decades
        band_edges(end) = [];
    end
end

%% ---------------- PER BAND MEAN ABSOLUTE ERROR ----------------
number_of_bands = numel(band_edges) - 1;
bands = struct("frequency_low", {}, "frequency_high", {}, ...
    "mean_absolute_error_db", {}, "number_of_points", {}, "label", {});
for band_index = 1:number_of_bands
    frequency_low = band_edges(band_index);
    frequency_high = band_edges(band_index + 1);
    % Her nokta tek bir banda girer; son bant sag ucu da kapsar.
    if band_index == number_of_bands
        in_band = frequency_common >= frequency_low & ...
            frequency_common <= frequency_high;
    else
        in_band = frequency_common >= frequency_low & ...
            frequency_common < frequency_high;
    end
    in_band = in_band & valid_points;
    if ~any(in_band)
        % Çok dar kalan uç bantlarda hiç geçerli nokta olmayabilir.
        continue;
    end
    bands(end+1) = struct( ...
        "frequency_low", frequency_low, ...
        "frequency_high", frequency_high, ...
        "mean_absolute_error_db", mean(absolute_difference(in_band)), ...
        "number_of_points", sum(in_band), ...
        "label", decade_band_label(frequency_low, frequency_high)); %#ok<AGROW>
end

if isempty(bands)
    error("Dekad bantlarinda gecerli fark noktasi bulunamadi.");
end

end

function label = decade_band_label(frequency_low, frequency_high)
% Bant sinirlarini grafik kutusuna sigacak kisa bir etikete çevirir.
% Birim bandin üst sinirina göre seçilir; boylece "100-1000 Hz" yerine
% "0.1-1 kHz" yazilir.
if frequency_high >= 1000
    label = sprintf("%s-%s kHz", format_bound(frequency_low/1000), ...
        format_bound(frequency_high/1000));
else
    label = sprintf("%s-%s Hz", format_bound(frequency_low), ...
        format_bound(frequency_high));
end
end

function text_value = format_bound(value)
% Tam dekad sinirlari ondaliksiz yazilir. Ilk ve son bandin sinirlari ölçüm
% izgarasindan geldigi için kesirli olabilir; bu degerler üstel gosterime
% kaymadan büyüklügüne göre kisaltilir.
if abs(value - round(value)) < 1e-9
    text_value = sprintf("%d", round(value));
elseif value >= 10
    text_value = sprintf("%.0f", value);
elseif value >= 1
    text_value = sprintf("%.1f", value);
else
    text_value = sprintf("%.2g", value);
end
end
