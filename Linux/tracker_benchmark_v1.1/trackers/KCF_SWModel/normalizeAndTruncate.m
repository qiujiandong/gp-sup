function [pNorm] = normalizeAndTruncate(map)
pPartOfNorm_ref = zeros([1024 1]);
for i = 1:1024
    for j = 1:9
        pPartOfNorm_ref(i) = pPartOfNorm_ref(i) + map(i, j) * map(i, j);
    end
end
pSqr_ref = zeros([900 4]);
rszPartOfNorm = reshape(pPartOfNorm_ref, [32 32])';
for i = 2:31
    for j = 2:31
        pSqr_ref((i-2)*30 + j-1, 1) = rszPartOfNorm(i-1, j-1) + ...
                                    rszPartOfNorm(i-1, j) + ...
                                    rszPartOfNorm(i, j-1) + ...
                                    rszPartOfNorm(i, j);
        pSqr_ref((i-2)*30 + j-1, 2) = rszPartOfNorm(i-1, j) + ...
                                    rszPartOfNorm(i-1, j+1) + ...
                                    rszPartOfNorm(i, j) + ...
                                    rszPartOfNorm(i, j+1);
        pSqr_ref((i-2)*30 + j-1, 3) = rszPartOfNorm(i, j-1) + ...
                                    rszPartOfNorm(i, j) + ...
                                    rszPartOfNorm(i+1, j-1) + ...
                                    rszPartOfNorm(i+1, j);
        pSqr_ref((i-2)*30 + j-1, 4) = rszPartOfNorm(i, j) + ...
                                    rszPartOfNorm(i, j+1) + ...
                                    rszPartOfNorm(i+1, j) + ...
                                    rszPartOfNorm(i+1, j+1);
    end
end
pSqrt_ref = sqrt(pSqr_ref) + 1.192092896E-07;
pNorm = zeros([1024 108]);
for i = 1:30
    for j = 1:30
        ind = i*32 + j + 1;
        sqrt_ind = (i-1)*30 + j - 1 + 1;
        pNorm(ind, :) = [map(ind, :) ./ pSqrt_ref(sqrt_ind, 1), ...
                         map(ind, :) ./ pSqrt_ref(sqrt_ind, 2), ...
                         map(ind, :) ./ pSqrt_ref(sqrt_ind, 3), ...
                         map(ind, :) ./ pSqrt_ref(sqrt_ind, 4)];
    end
end

for i = 1:1024
    for j = 1:108
        if(pNorm(i, j) > 0.2)
            pNorm(i, j) = 0.2;
        end
    end
end

end