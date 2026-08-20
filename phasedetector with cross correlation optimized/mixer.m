function mixed_signals = mixer(dut_signal, reference_signals)
%MIXER DUT taşıyıcısını bağımsız referans taşıyıcılarıyla çarpar.
%   MIXED_SIGNALS = MIXER(DUT_SIGNAL, REFERENCE_SIGNALS), DUT_SIGNAL'i her
%   reference_signals kolonuyla örnek örnek çarpar. Her çıkış kolonu ayrı bir
%   faz detektörü ölçüm kanalıdır.

%% ---------------- MIXER INPUT SHAPES ----------------
% DUT sinyalini kolon yap; referans matrisinin her satırı aynı zaman örneğine
% karşılık gelmelidir.
dut_signal = dut_signal(:);
if size(reference_signals, 1) ~= length(dut_signal)
    error("DUT ve referans sinyalleri ayni ornek sayisina sahip olmalidir.");
end

%% ---------------- SIGNAL MULTIPLICATION ----------------
% bsxfun, DUT kolonunu bütün referans kanallarına ek kopya oluşturmadan uygular.
mixed_signals = bsxfun(@times, dut_signal, reference_signals);

end
