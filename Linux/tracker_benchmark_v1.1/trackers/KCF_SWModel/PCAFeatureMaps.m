function [pca] = PCAFeatureMaps(norm)
pca = zeros([1024 31]);
for i = 1:1024
    pca(i, 1:27) = (norm(i, 1:27) + ...
                    norm(i, 28:54) + ...
                    norm(i, 55:81) + ...
                    norm(i, 82:108)) * 0.5;
    pca(i, 28) = sum(norm(i, 1:9)) * 0.2357;
    pca(i, 29) = sum(norm(i, 28:36)) * 0.2357;
    pca(i, 30) = sum(norm(i, 55:63)) * 0.2357;
    pca(i, 31) = sum(norm(i, 82:90)) * 0.2357;
end
end