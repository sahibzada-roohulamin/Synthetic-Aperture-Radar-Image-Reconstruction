clear;
clc;
close all;
disp('*** NEW MAIN IS RUNNING ***');

%% Add project folders to MATLAB path
addpath(genpath('src'));

%% Initialize Radar Parameters
radar = initRadarParameters();

%% Generate Transmitted LFM Chirp
[t, tx] = generateChirp(radar);

%% Generate Target Scene
targets = generateTargetScene();

%% Generate Platform Trajectory
platform = generatePlatformTrajectory(radar);

%% Generate Raw SAR data
rawData = generateRawSARData(radar, platform, targets, tx);

%% Simulate Received Echo
[rx, delay] = simulateEcho(radar, targets, tx);

%% Range Compression
compressed = rangeCompression(tx, rx);

%% Display Information
disp('Radar Parameters');
disp(radar);

disp('Target Scene');
disp(targets);

disp('Platform Information');
disp(platform);

disp('Raw SAR Data Generated');
disp(size(rawData));

fprintf('Round-trip Delay = %.6f microseconds\n', delay*1e6);

%% ==========================================================
%% Figure 1 : Transmitted LFM Chirp
%% ==========================================================

figure;

plot(t*1e6, real(tx), 'LineWidth',1.5);

xlabel('Time (\mus)');
ylabel('Amplitude');
title('Transmitted LFM Chirp');

grid on;

%% ==========================================================
%% Figure 2 : Spectrum of LFM Chirp
%% ==========================================================

N = length(tx);

f = (-N/2:N/2-1)*(radar.fs/N);

TX = fftshift(abs(fft(tx)));

figure;

plot(f/1e6, TX, 'LineWidth',1.5);

xlabel('Frequency (MHz)');
ylabel('Magnitude');

title('Spectrum of LFM Chirp');

grid on;

%% ==========================================================
%% Figure 3 : Received Echo
%% ==========================================================

figure;

plot(radar.tFast*1e6, real(rx), 'LineWidth',1.5);

xlabel('Fast Time (\mus)');
ylabel('Amplitude');

title('Received Echo');

grid on;

%% ==========================================================
%% Figure 4 : Range Compressed Signal
%% ==========================================================

figure;

plot(abs(compressed), 'LineWidth',1.5);

xlabel('Fast-Time Sample');
ylabel('Magnitude');

title('Range Compressed Signal');

grid on;

%% ==========================================================
%% Figure 5 : Platform Trajectory
%% ==========================================================

figure;

plot(platform.x,...
     platform.z,...
     'LineWidth',2);

xlabel('Along Track Position (m)');
ylabel('Altitude (m)');

title('Radar Platform Trajectory');

grid on;

%% ==========================================================
%% Figure 6 : Raw SAR Data Matrix
%% ==========================================================

figure;

imagesc(20*log10(abs(rawData) + eps));

xlabel('Fast-Time Samples');
ylabel('Pulse Number');
title('Raw SAR Data Matrix (dB)');

colorbar;
axis xy;