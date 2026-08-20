function focusedSAR = azimuthCompression(rangeCompressedSAR, radar, platform, targets)

% ==========================================================
% Multi-Target Azimuth Compression
% ==========================================================

[Naz, Nrange] = size(rangeCompressedSAR);

% Initialize focused SAR image
focusedSAR = zeros(Naz, Nrange);

% ==========================================================
% Process each target
% ==========================================================

for k = 1:targets.numTargets

    % Target coordinates
    xt = targets.x(k);
    yt = targets.y(k);

    % ------------------------------------------------------
    % Slant-range history for this target
    % ------------------------------------------------------

    R = sqrt((platform.x - xt).^2 + ...
             yt^2 + ...
             radar.H^2);

    % ------------------------------------------------------
    % Corresponding range-bin history
    % ------------------------------------------------------

    tau = 2 * R / radar.c;

    rangeBins = round(tau * radar.fs) + 1;

    % ------------------------------------------------------
    % Azimuth phase history
    % ------------------------------------------------------

    phaseHistory = exp( ...
        -1j * 4 * pi * radar.fc * R / radar.c);

    % Matched filter
    matchedFilter = conj(phaseHistory(:));

    % ------------------------------------------------------
    % Extract target azimuth signal
    % ------------------------------------------------------

    targetSignal = zeros(Naz,1);

    for p = 1:Naz

        bin = rangeBins(p);

        if bin >= 1 && bin <= Nrange
            targetSignal(p) = ...
                rangeCompressedSAR(p,bin);
        end

    end

    % ------------------------------------------------------
    % Azimuth compression
    % ------------------------------------------------------

    targetFocused = conv( ...
        targetSignal, ...
        matchedFilter, ...
        'same');

    % ------------------------------------------------------
    % Determine target's nominal range bin
    % ------------------------------------------------------

    R0 = sqrt(xt^2 + yt^2 + radar.H^2);

    nominalBin = round( ...
        (2 * R0 / radar.c) * radar.fs) + 1;

    % ------------------------------------------------------
    % Place focused response into image
    % ------------------------------------------------------

    if nominalBin >= 1 && nominalBin <= Nrange

        focusedSAR(:,nominalBin) = ...
            focusedSAR(:,nominalBin) + ...
            targets.rcs(k) * targetFocused;

    end

end

end