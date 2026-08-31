function mask = valid_freq_mask(f, f_max, f_min)
%VALID_FREQ_MASK Select frequencies in the interval (f_min, f_max].

if nargin < 3
    f_min = 0;
end

mask = (f > f_min) & (f <= f_max);

end
