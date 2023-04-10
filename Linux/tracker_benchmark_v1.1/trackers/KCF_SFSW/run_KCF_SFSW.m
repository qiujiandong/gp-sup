function results=run_KCF_SFSW(seq, res_path, bSaveImage)
    % target_sz = seq.init_rect(1,[4,3]);
    % pos = seq.init_rect(1,[2,1]) + floor(target_sz/2);
    initRect = seq.init_rect;
    img_files = seq.s_frames;
    video_path = [];

    fParam = fopen("param.txt", 'w');
    fprintf(fParam, "%d %d %d %d %d\n", initRect(1), initRect(2), initRect(3), initRect(4), numel(img_files));
    for i = 1:numel(img_files)
        fprintf(fParam, "%s\n", img_files{i,1});
    end
    fclose(fParam); 
    
    %call tracker function with all the relevant parameters
    system("../KCF_DSP/build/kcf_dsp < param.txt ");

    fResults = fopen("results.txt", 'r');
    time = str2double(fgetl(fResults));
    rects = fscanf(fResults, "%f,%f,%f,%f", [4, Inf])';

    fps = numel(seq.s_frames) / time;
    disp(['fps: ' num2str(fps)])
    results.type = 'rect';
    results.res = rects;
    results.fps = fps;
end
