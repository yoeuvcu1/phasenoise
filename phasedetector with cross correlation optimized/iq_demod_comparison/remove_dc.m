function x = remove_dc(x)
%REMOVE_DC Remove the mean of each input column.

x = x - mean(x);

end
