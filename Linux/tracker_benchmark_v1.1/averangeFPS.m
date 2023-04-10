clc;
clear;

addpath('./util');
dataSetSetting;

trackers=configTrackers;

numSeq=length(seqs);
numTrk=length(trackers);

for i = 1:numTrk
    
    fpsSum = 0;
    for j = 1:numSeq
        s = seqs{j};
        t = trackers{i};
        load([rpAll s.name '_' t.name '.mat'])
        res = results{1};
%         disp([num2str(j) ': ' num2str(res.fps)]);
        fpsSum = fpsSum + res.fps;
    end

    disp([t.name ' averange fps: ' num2str(fpsSum / numSeq)])
    
end
