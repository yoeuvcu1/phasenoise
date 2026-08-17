function x = remove_dc(x)
% Her kolonun ortalamasını çıkararak DC bileşenini temizler.

x = x - mean(x);

end