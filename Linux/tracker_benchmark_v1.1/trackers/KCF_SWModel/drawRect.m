function [src] = drawRect(src, rect)
x = rect(1);
y = rect(2);
width = rect(3);
height = rect(4);

for i = x + 1 : x + width
    src(y+1, i) = uint8(255);
    src(y+height, i) = uint8(255);
end

for i = y+1:y+height
    src(i, x+1) = uint8(255);
    src(i, x+width) = uint8(255);
end
