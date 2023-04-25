function [rects, time] = tracker(video_path, img_files, initRect)
%TRACKER Kernelized/Dual Correlation Filter (KCF/DCF) tracking.
%   This function implements the KCF
%
%   It is meant to be called by the interface function RUN_TRACKER, which
%   sets up the parameters and loads the video information.
%
%   Parameters:
%     VIDEO_PATH is the location of the image files (must end with a slash '/' or '\').
%     INIT_RECT is [x, y, width, height] format

    learningRate = 0.012;
    m_roi.x = initRect(1);
    m_roi.y = initRect(2);
    m_roi.width = initRect(3);
    m_roi.height = initRect(4);

    % init output
    time = 0;
    rects = zeros(numel(img_files), 4);

    for frame = 1:numel(img_files)
        % load image
        im = imread([video_path img_files{frame}]);
        if size(im,3) > 1
			im = rgb2gray(im);
        end

        tic()

        % detect
        if frame > 1
            [m_roi, ~] = update(im, m_roi, m_pTmpl, m_pAlpha);
        end

        % train
        [x, ~] = getFeatures(im, 1.0, m_roi); 
        [pAlpha] = train(x);

        % update
        if frame == 1
            m_pTmpl = x;
            m_pAlpha = pAlpha;
        else
            m_pTmpl = m_pTmpl * (1 - learningRate) + x * learningRate;
            m_pAlpha = m_pAlpha * (1 - learningRate) + pAlpha * learningRate;
        end

        rects(frame, :) = [m_roi.x, m_roi.y, m_roi.width, m_roi.height];
        time = time + toc();
    end
end