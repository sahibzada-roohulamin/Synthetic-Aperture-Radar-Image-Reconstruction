function [rx, delay] = simulateEcho(radar, targets, tx)

% Distance from radar to target
R = sqrt(targets.x^2 + targets.y^2);

% Round-trip delay
delay = 2*R/radar.c;

% Convert delay to samples
delaySamples = round(delay * radar.fs);

% Initialize received signal
rx = zeros(size(tx));

% Add delayed echo
if delaySamples < length(tx)

    rx(delaySamples+1:end) = ...
        targets.rcs * tx(1:end-delaySamples);

end

end