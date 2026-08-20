function rawData = generateRawSARData(radar, platform, targets, tx)

% ==========================================================
% Generate Multi-Target Raw SAR Data
% ==========================================================

% Number of azimuth positions
Naz = length(platform.x);

% Number of fast-time samples
Nfast = length(radar.tFast);

% Initialize raw SAR data
rawData = zeros(Naz, Nfast);

% Length of transmitted chirp
Ntx = length(tx);

% ==========================================================
% Loop over platform positions
% ==========================================================

for n = 1:Naz

    % Radar platform position
    xr = platform.x(n);
    zr = platform.z(n);

    % ======================================================
    % Loop over targets
    % ======================================================

    for k = 1:targets.numTargets

        % Target coordinates
        xt = targets.x(k);
        yt = targets.y(k);

        % --------------------------------------------------
        % Slant range
        % --------------------------------------------------

        R = sqrt( ...
            (xr - xt)^2 + ...
            yt^2 + ...
            zr^2);

        % --------------------------------------------------
        % Two-way propagation delay
        % --------------------------------------------------

        tau = 2 * R / radar.c;

        % --------------------------------------------------
        % Convert delay to samples
        % --------------------------------------------------

        delaySamples = round(tau * radar.fs);

        startIndex = delaySamples + 1;
        endIndex = startIndex + Ntx - 1;

        % --------------------------------------------------
        % Propagation phase
        % --------------------------------------------------

        phase = exp( ...
            -1j * 4 * pi * radar.fc * R / radar.c);

        % --------------------------------------------------
        % Add delayed LFM chirp
        % --------------------------------------------------

        if startIndex <= Nfast && endIndex >= 1

            txStart = max(1, 2 - startIndex);
            txEnd = min(Ntx, Nfast - startIndex + 1);

            rawStart = max(1, startIndex);
            rawEnd = min(Nfast, endIndex);

            if txStart <= txEnd && rawStart <= rawEnd

                rawData(n,rawStart:rawEnd) = ...
                    rawData(n,rawStart:rawEnd) + ...
                    targets.rcs(k) * ...
                    phase * ...
                    tx(txStart:txEnd);

            end

        end

    end

end

end