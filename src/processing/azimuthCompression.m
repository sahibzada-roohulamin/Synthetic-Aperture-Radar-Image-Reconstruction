function focusedSAR = azimuthCompression( ...
    rangeCompressedSAR, radar, platform, targets, tx)

% ==========================================================
% 2-D SAR Image Formation using Optimized Backprojection
% ==========================================================

[Naz, Nrange] = size(rangeCompressedSAR);

% Initialize focused SAR image
focusedSAR = zeros(Naz, Nrange);

% ==========================================================
% Range-compression alignment
% ==========================================================

Ntx = length(tx);

compressionOffset = floor((Ntx - 1)/2);

% ==========================================================
% Physical range axis
% ==========================================================

sampleIndex = 0:Nrange-1;

rangeAxis = ...
    (sampleIndex - compressionOffset) / ...
    radar.fs * radar.c/2;

% ==========================================================
% Image formation range region
% ==========================================================

Rtarget = sqrt( ...
    targets.x.^2 + ...
    targets.y.^2 + ...
    radar.H^2);

minRange = min(Rtarget) - 100;
maxRange = max(Rtarget) + 100;

validRange = ...
    rangeAxis >= minRange & ...
    rangeAxis <= maxRange;

rangeIndices = find(validRange);

% ==========================================================
% Create image only over required range region
% ==========================================================

imageData = zeros(Naz, length(rangeIndices));

% ==========================================================
% Backprojection
% ==========================================================

for ia = 1:Naz

    % Current image azimuth position
    xImage = platform.x(ia);

    % Current range coordinates
    R0 = rangeAxis(rangeIndices);

    % ------------------------------------------------------
    % Convert slant range to ground range
    % ------------------------------------------------------

    ySquared = ...
        R0.^2 - xImage^2 - radar.H^2;

    valid = ySquared > 0;

    yImage = zeros(size(R0));

    yImage(valid) = sqrt(ySquared(valid));

    % ------------------------------------------------------
    % Calculate range history for every platform position
    % and every image range point
    %
    % Matrix:
    %     Naz × NimageRange
    % ------------------------------------------------------

    dx = platform.x(:) - xImage;

    R = sqrt( ...
        dx.^2 + ...
        yImage.^2 + ...
        platform.z(:).^2);

    % ------------------------------------------------------
    % Convert range history to compressed range bins
    % ------------------------------------------------------

    compressedBins = ...
        (2 * R / radar.c) * radar.fs + ...
        1 + compressionOffset;

    % ------------------------------------------------------
    % Coherent accumulation
    % ------------------------------------------------------

    pixelData = zeros(1,length(rangeIndices));

    for p = 1:Naz

        bins = compressedBins(p,:);

        validBins = ...
            bins >= 1 & bins <= Nrange;

        if any(validBins)

            % Interpolate the complete pulse at once
            signalValues = interp1( ...
                1:Nrange, ...
                rangeCompressedSAR(p,:), ...
                bins(validBins), ...
                'linear', ...
                0);

            % Phase compensation
            phaseCorrection = exp( ...
                1j * 4 * pi * radar.fc * R(p,validBins) / radar.c);

            % Coherent accumulation
            pixelData(validBins) = ...
                pixelData(validBins) + ...
                signalValues .* phaseCorrection;

        end

    end

    imageData(ia,:) = pixelData;

end

% ==========================================================
% Insert image into full SAR matrix
% ==========================================================

focusedSAR(:,rangeIndices) = imageData;

% ==========================================================
% Normalize focused image
% ==========================================================

maxValue = max(abs(focusedSAR(:)));

if maxValue > 0

    focusedSAR = ...
        focusedSAR / maxValue;

end

end