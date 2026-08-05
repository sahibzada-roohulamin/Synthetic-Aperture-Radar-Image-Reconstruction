function rawData = generateRawSARData(radar, platform, targets, tx)

rawData = zeros(platform.numPulses, radar.Nfast);

for k = 1:platform.numPulses

    % Radar position
    xr = platform.x(k);

    % Distance from radar to target
    R = sqrt((xr - targets.x)^2 + ...
             targets.y^2 + ...
             radar.H^2);

    % Round-trip delay
    delay = 2*R/radar.c;

    % Delay in samples
    delaySamples = round(delay*radar.fs);

    L = length(tx);

    if (delaySamples + L - 1) <= radar.Nfast

        rawData(k, delaySamples+1:delaySamples+L) = ...
            targets.rcs * tx;

    end

end

end