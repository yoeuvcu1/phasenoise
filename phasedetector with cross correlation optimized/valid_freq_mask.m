function mask = valid_freq_mask(f, f_max, f_min)
% (f_min, f_max] aralığındaki frekanslar için mantıksal maske döndürür.

if nargin < 3
    f_min = 0;
end

mask = (f > f_min) & (f <= f_max);

end