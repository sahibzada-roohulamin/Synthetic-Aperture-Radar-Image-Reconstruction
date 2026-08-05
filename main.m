clear;
clc;
close all;

addpath(genpath('src'));

radar = initRadarParameters();
[t, tx] = generateChirp(radar);
targets = generateTargetScene();
[rx, delay] = simulateEcho(radar, targets, tx);

fprintf('Round-trip Delay = %.6f microseconds\n', delay*1e6);
figure;

plot(t*1e6, real(rx), 'LineWidth',1.5);

xlabel('Time (\mus)');
ylabel('Amplitude');

title('Received Echo');

grid on;

disp('Target Scene');
disp(targets);
figure;

plot(t*1e6, real(tx), 'LineWidth', 1.5);

xlabel('Time (\mus)');
ylabel('Amplitude');
title('Transmitted LFM Chirp');
grid on;
N = length(tx);

f = (-N/2:N/2-1)*(radar.fs/N);

TX = fftshift(abs(fft(tx)));

figure;

plot(f/1e6, TX, 'LineWidth', 1.5);

xlabel('Frequency (MHz)');
ylabel('Magnitude');
title('Spectrum of LFM Chirp');
grid on;
disp('Radar Parameters');
disp(radar);