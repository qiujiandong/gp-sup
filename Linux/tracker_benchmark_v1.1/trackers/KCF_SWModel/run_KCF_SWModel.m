function results=run_KCF_SWModel(seq, res_path, bSaveImage)
    % target_sz = seq.init_rect(1,[4,3]);
    % pos = seq.init_rect(1,[2,1]) + floor(target_sz/2);
    initRect = seq.init_rect;
    img_files = seq.s_frames;
    video_path = [];

    %call tracker function with all the relevant parameters
    [rects, time] = tracker(video_path, img_files, initRect);
    
    fps = numel(seq.s_frames) / time;
    disp(['fps: ' num2str(fps)])
    results.type = 'rect';
    results.res = rects;
    results.fps = fps;
end