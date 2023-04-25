function [pca, m_fScaleW, m_fScaleH] = getFeatures(src, fScaleAdj, roi)

fCx = roi.x + (roi.width-1) * 0.5;
fCy = roi.y + (roi.height-1) * 0.5;

paddingRows = 0;
paddingCols = 0;

nWidth = round(roi.width * 2.5 * fScaleAdj);
nHeight = round(roi.height * 2.5 * fScaleAdj);
[r, c] = size(src);

maxHeight = min((fCy-1)*2+1, (r-fCy)*2+1);
maxWidth = min((fCx-1)*2+1, (c-fCx)*2+1);

if nHeight > maxHeight
    paddingRows = ceil((nHeight - maxHeight) * 0.5);
end
if nWidth > maxWidth
    paddingCols = ceil((nWidth - maxWidth) * 0.5);
end

m_fScaleW = nWidth / 136;
m_fScaleH = nHeight / 136;

src = padarray(src, [paddingRows paddingCols], 0, 'pre');
src = padarray(src, [paddingRows paddingCols], 0, 'post');
fCy = fCy + paddingRows;
fCx = fCx + paddingCols;
rH = (nHeight - 1) * 0.5;
nY = floor(fCy - rH);
nHeight = (fCy - nY) * 2 + 1;
rW = (nWidth - 1) * 0.5;
nX = floor(fCx - rW);
nWidth = (fCx - nX) * 2 + 1;

subw = src(nY : nY + nHeight - 1, nX : nX + nWidth - 1);

resized = imresize(subw, [136 136], "bilinear");

featureMap = HOG_model_quantify(resized, 10);

% map = getFeatureMaps(subw);
% norm = normalizeAndTruncate(map);
% pca = PCAFeatureMaps(norm);

% w = hann(32, "symmetric");
% pHann = w .* w';
% rszHann = pHann(:)';
% pca = pca';
% for i = 1:31
%     pca(i, :) = pca(i, :) .* rszHann;
% end

pca = zeros([31 1024]);

for i = 1:31
    tmp = featureMap(:,:,i)';
    pca(i, :) = tmp(:)';
end

end