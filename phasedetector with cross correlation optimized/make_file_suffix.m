function suffix = make_file_suffix(value)
% Bir değerden dosya adına uygun, noktasız (rakam/alt çizgi) son ek üretir.
% Ornek: 0.05 -> "0p05", 25000 -> "25000"

suffix = strrep(sprintf("%g", value), ".", "p");

end
