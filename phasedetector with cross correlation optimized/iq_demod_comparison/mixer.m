function mixed_signals = mixer(dut_signal, reference_signals)
%MIXER Multiply the DUT by each reference channel.

dut_signal = dut_signal(:);
if size(reference_signals, 1) ~= length(dut_signal)
    error("DUT ve referans sinyalleri ayni ornek sayisina sahip olmalidir.");
end
mixed_signals = bsxfun(@times, dut_signal, reference_signals);

end
