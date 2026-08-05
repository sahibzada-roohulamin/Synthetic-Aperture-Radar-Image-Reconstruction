function [rx, delay] = simulateEcho(radar, targets, tx)

% Distance to target
R = sqrt(targets.x^2 + targets.y^2);

% Round-trip delay
delay = 2*R/radar.c;

% Delay in samples
delaySamples = round(delay * radar.fs);

% Fast-time observation window
rx = zeros(1, radar.Nfast);

% Length of transmitted pulse
L = length(tx);

% Insert delayed echo
if (delaySamples + L - 1) <= radar.Nfast

    rx(delaySamples+1 : delaySamples+L) = ...
        targets.rcs * tx;

end

end