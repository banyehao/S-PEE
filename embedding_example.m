function [psnr, markedI] = embedding_example(I, msg, alpha, a1, b1)
% -------------------------------------------------------------------------
% embedding_example.m
%
% Example of two-layer reversible data hiding.
%
% First layer:
%   Embeds the entire message `msg` using the proposed general distortion 
%   embedding method (Manner).
%
% Second layer:
%   If reconstruction information `clm` is generated, it is further embedded 
%   using an alternative RDH method (MHM2015 by Li et al.).
%
% Inputs:
%   I     - Original grayscale image (double)
%   msg   - Binary message sequence to embed (1D vector)
%   alpha - Embedding parameter for matrix embedding
%   a1    - Lower expansion bin
%   b1    - Upper expansion bin
%
% Outputs:
%   psnr      - PSNR value (dB) of the final marked image
%   markedI   - Marked image after two-layer embedding
% -------------------------------------------------------------------------

[A, B] = size(I);               % Image dimensions
markedI = I;

% First layer embedding using the proposed method (Manner)
tic;
[watermarked, ~, clm] = Manner(I, msg, 0, alpha, a1, b1);
toc;

% If embedding failed, return zero PSNR
if isequal(watermarked, -1)
    psnr = 0;
    return;
end

% Calculate PSNR after first layer embedding
mse1 = mean((watermarked(:) - I(:)).^2);
psnr1 = 10 * log10(255^2 / mse1);

% If no reconstruction info is generated, no second layer needed
if isempty(clm)
    psnr = psnr1;
    return;
end

% Second layer embedding using MHM2015 (Li et al.)
[watermarked, ~, ~] = MHM2015(watermarked, clm, 1);
markedI = watermarked;

% If embedding failed, return zero PSNR
if isequal(watermarked, -1)
    psnr = 0;
    return;
end

% Calculate final PSNR after second layer embedding
mse2 = mean((watermarked(:) - I(:)).^2);
psnr = 10 * log10(255^2 / mse2);

end
