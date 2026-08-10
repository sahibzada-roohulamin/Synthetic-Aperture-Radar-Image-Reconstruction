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

%% Range Compression of Raw SAR Data
rangeCompressedSAR = zeros(size(rawData));

for k = 1:size(rawData,1)
    rangeCompressedSAR(k,:) = ...
        rangeCompression(tx, rawData(k,:));
end

%% Azimuth Compression

focusedSAR = azimuthCompression( ...
    rangeCompressedSAR, radar, platform, targets);

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

%% ==========================================================
%% Figure 7 : Range-Compressed SAR Data
%% ==========================================================
figure;
imagesc(20*log10(abs(rangeCompressedSAR) + eps));
xlabel('Fast-Time Samples');
ylabel('Pulse Number');
title('Range-Compressed SAR Data (dB)');
colorbar;
axis xy;
%% ==========================================================
%% Figure 8 : Focused SAR Image
%% ==========================================================
figure;
imagesc(20*log10(abs(focusedSAR) + eps));
xlabel('Fast-Time Samples');
ylabel('Pulse Number');
title('Focused SAR Image (dB)');
colorbar;
axis xy;

%% ==========================================================
%% Physical Coordinates for Focused SAR Image
%% ==========================================================

% Number of fast-time samples
Nrange = size(focusedSAR,2);

% Number of azimuth samples
Nazimuth = size(focusedSAR,1);

% Matched-filter length
L = length(tx);

% Range axis correction for 'same' convolution
sampleIndex = 0:Nrange-1;

rangeAxis = ...
    (sampleIndex - floor((L-1)/2)) / radar.fs * radar.c/2;

% Along-track axis
azimuthAxis = platform.x;

%% ==========================================================
%% Figure 9 : Focused SAR Image in Physical Coordinates
%% ==========================================================

focusedDB = 20*log10( ...
    abs(focusedSAR) / max(abs(focusedSAR(:))) + eps);

figure;

imagesc(rangeAxis, azimuthAxis, focusedDB);

xlabel('Slant Range (m)');
ylabel('Along-Track Position (m)');
title('Focused SAR Image in Physical Coordinates');

colorbar;
caxis([-40 0]);
axis xy;

%% ==========================================================
%% Physical Target Location Verification
%% ==========================================================

[maxFocused, linearIndex] = max(abs(focusedSAR(:)));

[peakAzimuth, peakRange] = ind2sub( ...
    size(focusedSAR), linearIndex);

fprintf('\n===== PHYSICAL SAR TARGET LOCATION =====\n');
fprintf('Peak azimuth sample = %d\n', peakAzimuth);
fprintf('Peak range sample   = %d\n', peakRange);

fprintf('Peak along-track position = %.6f m\n', ...
    azimuthAxis(peakAzimuth));

fprintf('Peak slant range = %.6f m\n', ...
    rangeAxis(peakRange));

% Calculate theoretical target range directly
R_theoretical = sqrt( ...
    (platform.x - targets.x).^2 + ...
    targets.y^2 + ...
    radar.H^2);

fprintf('Theoretical minimum target range = %.6f m\n', ...
    min(R_theoretical));

%% ==========================================================
%% Azimuth Compression Verification
%% ==========================================================
[maxFocused, linearIndex] = max(abs(focusedSAR(:)));

[peakAzimuth, peakRange] = ind2sub( ...
    size(focusedSAR), linearIndex);

fprintf('\n===== SAR IMAGE FOCUSING RESULTS =====\n');
fprintf('Maximum focused magnitude = %.6f\n', maxFocused);
fprintf('Peak azimuth sample       = %d\n', peakAzimuth);
fprintf('Peak range sample         = %d\n', peakRange);

%% ==========================================================
%% Azimuth Resolution Measurement
%% ==========================================================

azimuthResponse = abs(focusedSAR(:,peakRange));
azimuthResponse = azimuthResponse / max(azimuthResponse);

% Find samples above -3 dB
azimuth3dB = azimuthResponse >= 10^(-3/20);

azimuthIndices = find(azimuth3dB);

azimuthWidthSamples = ...
    azimuthIndices(end) - azimuthIndices(1);

azimuthResolutionMeasured = ...
    azimuthWidthSamples * platform.pulseSpacing;

fprintf('\n===== AZIMUTH RESOLUTION =====\n');
fprintf('3-dB width = %d samples\n', azimuthWidthSamples);
fprintf('Measured azimuth resolution = %.6f m\n', ...
    azimuthResolutionMeasured);

%% ==========================================================
%% Range Resolution Measurement
%% ==========================================================

rangeResponse = abs(focusedSAR(peakAzimuth,:));
rangeResponse = rangeResponse / max(rangeResponse);

% Interpolation factor
interpFactor = 20;

% Original number of range samples
Nrange = length(rangeResponse);

% Interpolated range response
rangeResponseInterp = interpft( ...
    rangeResponse, ...
    Nrange * interpFactor);

% Original range sample spacing
rangeStep = radar.c / (2 * radar.fs);

% Interpolated physical range axis
rangeAxisInterp = linspace( ...
    rangeAxis(1), ...
    rangeAxis(end), ...
    Nrange * interpFactor);

% Normalize interpolated response
rangeResponseInterp = ...
    rangeResponseInterp / max(rangeResponseInterp);

% 3-dB amplitude threshold
threshold3dB = 10^(-3/20);

% Find samples above -3 dB
range3dB = rangeResponseInterp >= threshold3dB;

rangeIndices = find(range3dB);

fprintf('\n===== RANGE RESOLUTION =====\n');

if ~isempty(rangeIndices)

    rangeWidth = ...
        rangeAxisInterp(rangeIndices(end)) - ...
        rangeAxisInterp(rangeIndices(1));

    fprintf('Interpolated 3-dB width = %.6f m\n', ...
        rangeWidth);

else

    fprintf('3-dB crossings could not be detected.\n');

end

fprintf('Theoretical range resolution = %.6f m\n', ...
    radar.c/(2*radar.B));


%% ==========================================================
%% Figure 10 : Interpolated Range Response
%% ==========================================================

figure;

plot(rangeAxisInterp, ...
     20*log10(abs(rangeResponseInterp) + eps), ...
     'LineWidth',1.5);

xlabel('Slant Range (m)');
ylabel('Normalized Magnitude (dB)');
title('Focused Range Response - Interpolated');

grid on;
ylim([-40 5]);

%% ==========================================================
%% Figure 11 : Measured Azimuth Resolution
%% ==========================================================

figure;

plot(azimuthAxis, ...
     20*log10(azimuthResponse + eps), ...
     'LineWidth',1.5);

xlabel('Along-Track Position (m)');
ylabel('Normalized Magnitude (dB)');
title('Focused Azimuth Response');
grid on;

ylim([-40 5]);

%% ==========================================================
%% Refined Peak Sidelobe Ratio (PSLR)
%% ==========================================================

%% ----------------------------------------------------------
%% Range PSLR
%% ----------------------------------------------------------

rangeMagnitude = abs(focusedSAR(peakAzimuth,:));
rangeMagnitude = rangeMagnitude / max(rangeMagnitude);

% Find local minima
rangeMinima = islocalmin(rangeMagnitude);

% Index of target peak
[~, rangePeakIndex] = max(rangeMagnitude);

% Find minima to the left of the peak
leftMinima = find(rangeMinima(1:rangePeakIndex-1));

% Find minima to the right of the peak
rightMinima = find(rangeMinima(rangePeakIndex+1:end)) ...
              + rangePeakIndex;

if ~isempty(leftMinima) && ~isempty(rightMinima)

    % Nearest minima surrounding the mainlobe
    leftNull = leftMinima(end);
    rightNull = rightMinima(1);

    % Sidelobe regions
    rangeSidelobes = rangeMagnitude;

    rangeSidelobes(leftNull:rightNull) = 0;

    % Highest sidelobe
    rangeHighestSidelobe = max(rangeSidelobes);

    rangePSLR = ...
        20*log10(rangeHighestSidelobe);

    fprintf('\n===== REFINED RANGE PSLR =====\n');
    fprintf('Mainlobe boundaries = samples %d to %d\n', ...
        leftNull, rightNull);
    fprintf('Highest sidelobe = %.6f\n', ...
        rangeHighestSidelobe);
    fprintf('Range PSLR = %.2f dB\n', ...
        rangePSLR);

else

    fprintf('\n===== REFINED RANGE PSLR =====\n');
    fprintf('Could not identify surrounding nulls.\n');

end


%% ----------------------------------------------------------
%% Azimuth PSLR
%% ----------------------------------------------------------

azimuthMagnitude = abs(focusedSAR(:,peakRange));
azimuthMagnitude = azimuthMagnitude / max(azimuthMagnitude);

% Find local minima
azimuthMinima = islocalmin(azimuthMagnitude);

% Index of target peak
[~, azimuthPeakIndex] = max(azimuthMagnitude);

% Find minima to the left
leftMinima = find(azimuthMinima(1:azimuthPeakIndex-1));

% Find minima to the right
rightMinima = find(azimuthMinima(azimuthPeakIndex+1:end)) ...
              + azimuthPeakIndex;

if ~isempty(leftMinima) && ~isempty(rightMinima)

    % Nearest minima surrounding mainlobe
    leftNull = leftMinima(end);
    rightNull = rightMinima(1);

    % Sidelobe regions
    azimuthSidelobes = azimuthMagnitude;

    azimuthSidelobes(leftNull:rightNull) = 0;

    % Highest sidelobe
    azimuthHighestSidelobe = ...
        max(azimuthSidelobes);

    azimuthPSLR = ...
        20*log10(azimuthHighestSidelobe);

    fprintf('\n===== REFINED AZIMUTH PSLR =====\n');
    fprintf('Mainlobe boundaries = samples %d to %d\n', ...
        leftNull, rightNull);
    fprintf('Highest sidelobe = %.6f\n', ...
        azimuthHighestSidelobe);
    fprintf('Azimuth PSLR = %.2f dB\n', ...
        azimuthPSLR);

else

    fprintf('\n===== REFINED AZIMUTH PSLR =====\n');
    fprintf('Could not identify surrounding nulls.\n');

end

%% ==========================================================
%% PSLR Mainlobe Boundary Verification
%% ==========================================================

%% ----------------------------------------------------------
%% Range boundary verification
%% ----------------------------------------------------------

rangeMagnitude = abs(focusedSAR(peakAzimuth,:));
rangeMagnitude = rangeMagnitude / max(rangeMagnitude);

rangeMinima = islocalmin(rangeMagnitude);

[~, rangePeakIndex] = max(rangeMagnitude);

leftRangeMinima = find( ...
    rangeMinima(1:rangePeakIndex-1));

rightRangeMinima = find( ...
    rangeMinima(rangePeakIndex+1:end)) ...
    + rangePeakIndex;

fprintf('\n===== RANGE NULL VERIFICATION =====\n');

fprintf('Peak sample = %d\n', ...
    rangePeakIndex);

fprintf('Local minima to LEFT of peak:\n');
disp(leftRangeMinima);

fprintf('Local minima to RIGHT of peak:\n');
disp(rightRangeMinima);

if ~isempty(leftRangeMinima) && ~isempty(rightRangeMinima)

    leftNull = leftRangeMinima(end);
    rightNull = rightRangeMinima(1);

    fprintf('Selected first left null  = %d\n', ...
        leftNull);

    fprintf('Selected first right null = %d\n', ...
        rightNull);

    fprintf('Null-to-null width = %d samples\n', ...
        rightNull-leftNull);

end


%% ----------------------------------------------------------
%% Azimuth boundary verification
%% ----------------------------------------------------------

azimuthMagnitude = abs(focusedSAR(:,peakRange));
azimuthMagnitude = ...
    azimuthMagnitude / max(azimuthMagnitude);

azimuthMinima = islocalmin(azimuthMagnitude);

[~, azimuthPeakIndex] = max(azimuthMagnitude);

leftAzimuthMinima = find( ...
    azimuthMinima(1:azimuthPeakIndex-1));

rightAzimuthMinima = find( ...
    azimuthMinima(azimuthPeakIndex+1:end)) ...
    + azimuthPeakIndex;

fprintf('\n===== AZIMUTH NULL VERIFICATION =====\n');

fprintf('Peak sample = %d\n', ...
    azimuthPeakIndex);

fprintf('Local minima to LEFT of peak:\n');
disp(leftAzimuthMinima);

fprintf('Local minima to RIGHT of peak:\n');
disp(rightAzimuthMinima);

if ~isempty(leftAzimuthMinima) && ...
        ~isempty(rightAzimuthMinima)

    leftNull = leftAzimuthMinima(end);
    rightNull = rightAzimuthMinima(1);

    fprintf('Selected first left null  = %d\n', ...
        leftNull);

    fprintf('Selected first right null = %d\n', ...
        rightNull);

    fprintf('Null-to-null width = %d samples\n', ...
        rightNull-leftNull);

end

%% ==========================================================
%% Integrated Sidelobe Ratio (ISLR)
%% ==========================================================

%% ----------------------------------------------------------
%% Range ISLR
%% ----------------------------------------------------------

rangeMagnitude = abs(focusedSAR(peakAzimuth,:));

% Normalize
rangeMagnitude = ...
    rangeMagnitude / max(rangeMagnitude);

% Peak location
[~, rangePeakIndex] = max(rangeMagnitude);

% Find local minima
rangeMinima = islocalmin(rangeMagnitude);

% Find minima surrounding mainlobe
leftMinima = find( ...
    rangeMinima(1:rangePeakIndex-1));

rightMinima = find( ...
    rangeMinima(rangePeakIndex+1:end)) ...
    + rangePeakIndex;

if ~isempty(leftMinima) && ~isempty(rightMinima)

    leftNull = leftMinima(end);
    rightNull = rightMinima(1);

    % Mainlobe energy
    rangeMainlobeEnergy = sum( ...
        rangeMagnitude(leftNull:rightNull).^2);

    % Total energy
    rangeTotalEnergy = sum( ...
        rangeMagnitude.^2);

    % Sidelobe energy
    rangeSidelobeEnergy = ...
        rangeTotalEnergy - rangeMainlobeEnergy;

    % ISLR
    rangeISLR = 10*log10( ...
        rangeSidelobeEnergy / ...
        rangeMainlobeEnergy);

    fprintf('\n===== RANGE ISLR =====\n');
    fprintf('Mainlobe boundaries = samples %d to %d\n', ...
        leftNull, rightNull);

    fprintf('Mainlobe energy = %.6f\n', ...
        rangeMainlobeEnergy);

    fprintf('Sidelobe energy = %.6f\n', ...
        rangeSidelobeEnergy);

    fprintf('Range ISLR = %.2f dB\n', ...
        rangeISLR);

else

    fprintf('\n===== RANGE ISLR =====\n');
    fprintf('Could not identify mainlobe boundaries.\n');

end


%% ----------------------------------------------------------
%% Azimuth ISLR
%% ----------------------------------------------------------

azimuthMagnitude = ...
    abs(focusedSAR(:,peakRange));

% Normalize
azimuthMagnitude = ...
    azimuthMagnitude / max(azimuthMagnitude);

% Peak location
[~, azimuthPeakIndex] = ...
    max(azimuthMagnitude);

% Find local minima
azimuthMinima = ...
    islocalmin(azimuthMagnitude);

% Find minima surrounding mainlobe
leftMinima = find( ...
    azimuthMinima(1:azimuthPeakIndex-1));

rightMinima = find( ...
    azimuthMinima(azimuthPeakIndex+1:end)) ...
    + azimuthPeakIndex;

if ~isempty(leftMinima) && ~isempty(rightMinima)

    leftNull = leftMinima(end);
    rightNull = rightMinima(1);

    % Mainlobe energy
    azimuthMainlobeEnergy = sum( ...
        azimuthMagnitude(leftNull:rightNull).^2);

    % Total energy
    azimuthTotalEnergy = sum( ...
        azimuthMagnitude.^2);

    % Sidelobe energy
    azimuthSidelobeEnergy = ...
        azimuthTotalEnergy - ...
        azimuthMainlobeEnergy;

    % ISLR
    azimuthISLR = 10*log10( ...
        azimuthSidelobeEnergy / ...
        azimuthMainlobeEnergy);

    fprintf('\n===== AZIMUTH ISLR =====\n');
    fprintf('Mainlobe boundaries = samples %d to %d\n', ...
        leftNull, rightNull);

    fprintf('Mainlobe energy = %.6f\n', ...
        azimuthMainlobeEnergy);

    fprintf('Sidelobe energy = %.6f\n', ...
        azimuthSidelobeEnergy);

    fprintf('Azimuth ISLR = %.2f dB\n', ...
        azimuthISLR);

else

    fprintf('\n===== AZIMUTH ISLR =====\n');
    fprintf('Could not identify mainlobe boundaries.\n');

end