% -------------------------------------------------------------------------
% Steganography Enhanced Prediction Error Expansion (S+PEE)
% X. Li, X. Li, S. Hu, and Y. Zhao
% “Steganography Enhanced Prediction Error Expansion: A Novel Reversible Data Hiding Framework”
% IEEE Transactions on Circuits and Systems for Video Technology, vol. 35, no. 3, pp. 2701-2711, 2025
% -------------------------------------------------------------------------

%% Main Function for Reversible Data Hiding
dbstop if error;                  % Stop if error occurs
format shortg;                    % Display format
beep off;
clear; clc;
warning('off', 'all');            % Disable all warnings

%% Image List Preparation
imgPath = './image/';
imgList = [dir(fullfile(imgPath, '*.bmp')); dir(fullfile(imgPath, '*.png'))];
imgNum  = length(imgList);
pro     = zeros(imgNum, 4);        % Result storage: [Capacity, PSNR, alpha, b1]

%% Embedding Parameters (for Airplane @ 10000 bits)
parameters = [0.65, 2];           % [alpha, b1]

%% Embedding Process for Each Image
for testi = 1:imgNum
    imgName = imgList(testi).name;
    fprintf('Testing image: %s\n', imgName);
    
    % Read and preprocess image (convert to grayscale if necessary)
    img = imread(fullfile(imgPath, imgName));
    if ndims(img) == 3
        img = rgb2gray(img);
    end
    I = double(img);
    
    % Embedding for given payload capacity
    Capacity = 10000;
    rng(0);                         % Set random seed for reproducibility
    msg = round(rand(1, Capacity)); % Random binary message

    % Initialize best performance tracker
    p_max      = 0;
    best_alpha = 0;
    
    fprintf('---------- First layer embedding ----------\n');
    
    % Test different alpha and b1 values (here fixed, but structure retained for flexibility)
    for alpha = parameters(1)
        fprintf('Testing alpha: %.2f\n', alpha);
        for b1 = parameters(2)
            fprintf('Testing expansion bin: %d\n', b1);
            a1 = 1 - b1;
            
            % Perform embedding and calculate PSNR
            [psnrVal, markedI] = embedding_example(I, msg, alpha, a1, b1);
            fprintf('PSNR: %.2f dB\n', psnrVal);
            
            % Update best result
            if psnrVal > p_max
                p_max = psnrVal;
                best_alpha = alpha;
                pro(testi, :) = [Capacity, p_max, best_alpha, b1];
            end
        end
    end
    
    % Report result for current image
    fprintf('Image: %s, alpha: %.2f, b1: %d, PSNR: %.2f dB\n', ...
            imgName, best_alpha, b1, p_max);
end
