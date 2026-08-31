function mixed_signals = mixer(dut_signal, reference_signals)
% DUT taşıyıcısını bağımsız referans taşıyıcılarıyla çarpar.
dut_signal = dut_signal(:);
if size(reference_signals, 1) ~= length(dut_signal)
    error("DUT ve referans sinyalleri ayni ornek sayisina sahip olmalidir.");
end
mixed_signals = bsxfun(@times, dut_signal, reference_signals);
end
