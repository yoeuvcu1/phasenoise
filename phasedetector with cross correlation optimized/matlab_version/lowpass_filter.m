function filtered_signal = lowpass_filter( ...
    input_signal, fs, cutoff_frequency, filter_order)
%LOWPASS_FILTER Butterworth alçak geçiren filtreyi tasarlar ve uygular.
%   FILTERED_SIGNAL = LOWPASS_FILTER(INPUT_SIGNAL, FS, CUTOFF_FREQUENCY,
%   FILTER_ORDER), mixer çıkışındaki toplam-frekans bileşenini bastırır.
%
%   Katsayılar aynı ayarlarla yapılan sonraki çağrılar için önbellekte tutulur.
%   Böylece iterasyonlar boyunca butter tasarımı tekrarlanmaz; filter işlemi
%   giriş matrisinin her kolonuna ayrı bir ölçüm kanalı olarak uygulanır.

%% ---------------- LP FILTER INPUT CHECKS ----------------
% Fonksiyon tek başına kullanıldığında da fiziksel olmayan filtre ayarlarını
% butter çağrısından önce anlaşılır bir mesajla reddet.
if cutoff_frequency <= 0 || cutoff_frequency >= fs/2
    error("cutoff_frequency, (0, fs/2) araliginda olmalidir.");
end
if filter_order <= 0 || filter_order ~= fix(filter_order)
    error("filter_order pozitif bir tamsayi olmalidir.");
end

%% ---------------- LP FILTER COEFFICIENTS ----------------
% Butterworth katsayıları yalnız fs, cutoff veya order değiştiğinde yeniden
% tasarlanır. Asıl Butter filtre ayarları bu bölümde bulunur.
persistent cached_fs cached_cutoff cached_order cached_b cached_a;
settings_changed = isempty(cached_b) || cached_fs ~= fs || ...
    cached_cutoff ~= cutoff_frequency || cached_order ~= filter_order;

if settings_changed
    normalized_cutoff = cutoff_frequency / (fs/2);
    [cached_b, cached_a] = butter( ...
        filter_order, normalized_cutoff, "low");
    cached_fs = fs;
    cached_cutoff = cutoff_frequency;
    cached_order = filter_order;
end

%% ---------------- LP FILTER APPLICATION ----------------
% filter, iki kolonlu mixer çıkışını kolon bazında tek çağrıda işler.
filtered_signal = filter(cached_b, cached_a, input_signal);

end
