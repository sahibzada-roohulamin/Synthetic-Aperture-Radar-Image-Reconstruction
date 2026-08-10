function platform = generatePlatformTrajectory(radar)

% Number of transmitted pulses
platform.numPulses = 256;

% Platform displacement between successive pulses
platform.pulseSpacing = radar.v / radar.PRF;

% Total synthetic aperture length
platform.apertureLength = ...
    (platform.numPulses - 1) * platform.pulseSpacing;

% Along-track positions
platform.x = ...
    ((0:platform.numPulses-1) - (platform.numPulses-1)/2) ...
    * platform.pulseSpacing;

% Constant altitude
platform.z = radar.H * ones(1, platform.numPulses);

end