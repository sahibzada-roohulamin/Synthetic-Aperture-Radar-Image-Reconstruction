function platform = generatePlatformTrajectory(radar)

% Number of transmitted pulses
platform.numPulses = 256;

% Aperture length
platform.apertureLength = radar.La;

% Along-track positions
platform.x = linspace(...
    -platform.apertureLength/2,...
     platform.apertureLength/2,...
     platform.numPulses);

% Constant altitude
platform.z = radar.H * ones(1,platform.numPulses);

end