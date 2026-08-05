function radar = initRadarParameters()

% Speed of light
radar.c = 3e8;

% Carrier Frequency (5.3 GHz)
radar.fc = 5.3e9;

% Wavelength
radar.lambda = radar.c/radar.fc;

% Bandwidth
radar.B = 20e6;

% Pulse Duration
radar.Tp = 10e-6;

% Sampling Frequency
radar.fs = 30e6;

% Chirp Rate
radar.K = radar.B/radar.Tp;

% PRF
radar.PRF = 1000;

% Platform Velocity
radar.v = 150;

% Platform Altitude
radar.H = 5000;

% Synthetic Aperture Length
radar.La = 300;

% Range Resolution
radar.rangeResolution = radar.c/(2*radar.B);

% Azimuth Resolution (approx.)
radar.azimuthResolution = radar.La/2;

end