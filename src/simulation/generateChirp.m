function [t, tx] = generateChirp(radar)

% Time vector
t = -radar.Tp/2 : 1/radar.fs : radar.Tp/2;

% Linear Frequency Modulated (LFM) Chirp
tx = exp(1j*pi*radar.K*t.^2);

end