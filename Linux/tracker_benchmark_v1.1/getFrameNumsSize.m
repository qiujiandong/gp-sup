clc;
clear;

addpath('./util');
dataSetSetting;

frameLen = zeros([length(seqs) 1]);
frameSize = zeros([length(seqs) 3]);

for idxSeq=1:length(seqs)
    s = seqs{idxSeq};
    frameLen(idxSeq) = s.endFrame - s.startFrame + 1;
    
    format = string(['%0' num2str(seqs{idxSeq}.nz) 'd']);
    fileName = sprintf(format, seqs{idxSeq}.startFrame);
    frameFullName = [seqs{idxSeq}.path char(fileName) '.' seqs{idxSeq}.ext];
    img = imread(frameFullName);
    imgSize = size(img);
    frameSize(idxSeq, 1:2) = imgSize(1:2);
end

disp(['max frame length: ' num2str(max(frameLen))]);

frameSize(:, 3) = frameSize(:, 1) .* frameSize(:, 2);

disp(['max frame Size: ' num2str(max(frameSize(:, 3)))]);
