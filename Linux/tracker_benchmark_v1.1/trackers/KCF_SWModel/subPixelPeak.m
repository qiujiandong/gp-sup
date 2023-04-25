function [delta] = subPixelPeak(left, center, right)
den = center * 2 - left - right;
if(den == 0)
    delta = 0;
else
    delta = 0.5 *(right - left) / den;
end
end