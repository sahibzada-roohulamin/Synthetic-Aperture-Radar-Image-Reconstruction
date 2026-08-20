function [rx, delay] = simulateEcho(radar, targets, tx)

% Number of fast-time samples
Nfast = radar.Nfast;

% Initialize received signal
rx = zeros(1, Nfast);

% Initialize target delays
delay = zeros(targets.numTargets, 1);

% ==========================================================
% Simulate echo from each target
% ==========================================================

for k = 1:targets.numTargets

    % Target coordinates
    xt = targets.x(k);
    yt = targets.y(k);

    % Slant range
    R = sqrt(xt^2 + yt^2 + radar.H^2);

    % Two-way propagation delay
    delay(k) = 2 * R / radar.c;

    % Corresponding fast-time sample
    delaySamples = round(delay(k) * radar.fs) + 1;

    % Add target echo
    if delaySamples >= 1 && delaySamples <= Nfast

        % Use transmitted signal at the corresponding sample
        if delaySamples <= length(tx)
            rx(delaySamples) = rx(delaySamples) + ...
                targets.rcs(k) * tx(delaySamples);
        end

    end

end

end