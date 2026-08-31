function x = remove_dc(x)
%REMOVE_DC Remove the mean value from each column.

x = x - mean(x);

end
