clear;
clc;
close all;

%% Add project folders to MATLAB path
addpath(genpath('src'));

%% Initialize Radar Parameters
radar = initRadarParameters();

%% Generate Transmitted LFM Chirp
[t, tx] = generateChirp(radar);

%% Generate Target Scene
targets = generateTargetScene();

%% Simulate Received Echo
[rx, delay] = simulateEcho(radar, targets, tx);

%% Range Compression
compressed = rangeCompression(tx, rx);

%% Display Information
disp('Radar Parameters');
disp(radar);

disp('Target Scene');
disp(targets);

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