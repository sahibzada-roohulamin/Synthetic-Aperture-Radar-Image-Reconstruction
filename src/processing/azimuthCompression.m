function focusedSAR = azimuthCompression(rangeCompressedSAR, radar, platform, targets)

% Number of pulses
numPulses = platform.numPulses;

% ==========================================================
% Azimuth phase history
% ==========================================================

R = sqrt((platform.x - targets.x).^2 + ...
         targets.y^2 + ...
         radar.H^2);

azimuthReference = exp( ...
    -1j * 4 * pi * radar.fc * R / radar.c);

% ==========================================================
% Azimuth matched filter
% ==========================================================

matchedFilter = conj(fliplr(azimuthReference));

% ==========================================================
% Azimuth compression
% ==========================================================

focusedSAR = zeros(size(rangeCompressedSAR));

for n = 1:size(rangeCompressedSAR,2)

    focusedSAR(:,n) = ...
        conv(rangeCompressedSAR(:,n), ...
             matchedFilter, ...
             'same');

end

end