function [map] = getFeatureMaps(subw)
%UNTITLED4 此处提供此函数的摘要
%   此处提供详细说明

resized = imresize(subw, [136 136], "bilinear");

H = [-1 0 1];
dx = filter2(H, resized);
dx(:, 1) = 0;
dx(:, 136) = 0;
H = [-1; 0; 1];
dy = filter2(H, resized);
dy(1, :) = 0;
dy(136, :) = 0;

amp = sqrt(dx .* dx + dy .* dy);

bdx = [1.000000E00, 9.396926E-01, 7.660444E-01, 5.000000E-01, 1.736482E-01, -1.736482E-01, -5.000000E-01, -7.660444E-01, -9.396926E-01];
bdy = [0.000000E00, 3.420201E-01, 6.427876E-01, 8.660254E-01, 9.848078E-01, 9.848078E-01, 8.660254E-01, 6.427876E-01, 3.420201E-01];

ori0 = zeros([136 136]);
ori1 = zeros([136 136]);

for i = 1: 136
    for j = 1:136
        ori0(i, j) = 0;
        if(dx(i, j) > 0)
            ori1(i, j) = 0;
            fDotProduct = dx(i, j);
        else
            ori1(i, j) = 9;
            fDotProduct = -dx(i, j);
        end

        for k = 0:8
            fTemp = bdx(k + 1) * dx(i, j) + bdy(k + 1) * dy(i, j);
            if(fTemp > fDotProduct)
                fDotProduct = fTemp;
                ori0(i, j) = k;
                ori1(i, j) = k;
            end
            if(fTemp + fDotProduct< 0)
                fDotProduct = -fTemp;
                ori0(i, j) = k;
                ori1(i, j) = k + 9;
            end
        end
    end
end

factors = [1.56250e-02, 4.68750e-02, 7.81250e-02, 1.09375e-01, 1.09375e-01, 7.81250e-02, 4.68750e-02, 1.56250e-02; ...
        4.68750e-02, 1.40625e-01, 2.34375e-01, 3.28125e-01, 3.28125e-01, 2.34375e-01, 1.40625e-01, 4.68750e-02; ...
        7.81250e-02, 2.34375e-01, 3.90625e-01, 5.46875e-01, 5.46875e-01, 3.90625e-01, 2.34375e-01, 7.81250e-02; ...
        1.09375e-01, 3.28125e-01, 5.46875e-01, 7.65625e-01, 7.65625e-01, 5.46875e-01, 3.28125e-01, 1.09375e-01; ...
        1.09375e-01, 3.28125e-01, 5.46875e-01, 7.65625e-01, 7.65625e-01, 5.46875e-01, 3.28125e-01, 1.09375e-01; ...
        7.81250e-02, 2.34375e-01, 3.90625e-01, 5.46875e-01, 5.46875e-01, 3.90625e-01, 2.34375e-01, 7.81250e-02; ...
        4.68750e-02, 1.40625e-01, 2.34375e-01, 3.28125e-01, 3.28125e-01, 2.34375e-01, 1.40625e-01, 4.68750e-02; ...
        1.56250e-02, 4.68750e-02, 7.81250e-02, 1.09375e-01, 1.09375e-01, 7.81250e-02, 4.68750e-02, 1.56250e-02];
map = zeros([1024 27]);
cellInd = 1;
for i = 3:4:127
    for j = 3:4:127
        for m = 1:8
            for n = 1:8
                fAmp = factors(m, n) * amp(i + m - 1, j + n - 1);
                map(cellInd, ori0(i + m - 1, j + n - 1) + 1) = map(cellInd, ori0(i + m - 1, j + n - 1) + 1) + fAmp;
                map(cellInd, ori1(i + m - 1, j + n - 1) + 1 + 9) = map(cellInd, ori1(i + m - 1, j + n - 1) + 1 + 9) + fAmp;
            end
        end
        cellInd = cellInd + 1;
    end
end

end