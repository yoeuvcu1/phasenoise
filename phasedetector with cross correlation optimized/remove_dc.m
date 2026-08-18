function x = remove_dc(x)
% Her kolonun ortalamasını çıkararak DC bileşenini temizler.
% Vektörde tek ortalama, iki kanallı matriste her kanal için ayrı ortalama alınır.

x = x - mean(x);

end
