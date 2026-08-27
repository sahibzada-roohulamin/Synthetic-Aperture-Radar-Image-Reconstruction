# SAR-CEP — SAR Image Reconstruction

MATLAB implementation of a **Synthetic Aperture Radar (SAR) image reconstruction** system developed as a Complex Engineering Problem (CEP).

The project simulates SAR data for multiple point targets, performs range compression, focuses the SAR image using backprojection, and evaluates image quality and resolution.

## 1. Objectives

- Generate an LFM radar chirp.
- Simulate SAR platform motion and target echoes.
- Generate multi-target raw SAR data.
- Perform pulse-by-pulse range compression.
- Perform azimuth focusing using backprojection.
- Reconstruct the focused SAR image.
- Verify target location and estimate range/azimuth resolution.
- Calculate PSLR and ISLR performance metrics.

## 2. Repository Structure

```text
SAR_CEP/
├── main.m
├── src/
│   ├── simulation/
│   │   ├── initRadarParameters.m
│   │   ├── generateChirp.m
│   │   ├── generateTargetScene.m
│   │   ├── generatePlatformTrajectory.m
│   │   ├── generateRawSARData.m
│   │   └── simulateEcho.m
│   └── processing/
│       ├── rangeCompression.m
│       └── azimuthCompression.m
└── README.md
```

## 3. Main Configuration

| Parameter | Value |
|---|---:|
| Carrier frequency | 5.3 GHz |
| Bandwidth | 20 MHz |
| Pulse duration | 10 µs |
| Sampling frequency | 30 MHz |
| PRF | 1000 Hz |
| Platform velocity | 150 m/s |
| Platform altitude | 5000 m |
| Number of pulses | 256 |
| Fast-time samples | 1600 |
| Theoretical range resolution | 7.5 m |

Current target scene:

```text
Target 1: x = -15 m, y = 1000 m
Target 2: x =   0 m, y = 1500 m
Target 3: x = +15 m, y = 1000 m
RCS:      1, 1, 1
```

## 4. Processing Flow

```text
Radar Parameters
      ↓
LFM Chirp
      ↓
Target Scene
      ↓
Platform Trajectory
      ↓
Raw SAR Data
      ↓
Range Compression
      ↓
Backprojection / Azimuth Focusing
      ↓
Focused SAR Image
      ↓
Resolution & Image-Quality Verification
```

## 5. Requirements

- MATLAB (developed/tested with MATLAB 2024)
- No external toolbox or hardware is required for the basic simulation.

## 6. How to Run

Clone the repository:

```bash
git clone https://github.com/sahibzada-roohulamin/SAR_CEP.git
cd SAR_CEP
```

Open the repository root in MATLAB and run:

```matlab
clear;
clc;
close all;
main
```

`main.m` automatically adds the `src` directory and its subdirectories to the MATLAB path:

```matlab
addpath(genpath('src'));
```

## 7. Expected Output

Running `main.m` generates:

- LFM chirp and spectrum
- Received echo
- Range-compressed signal
- SAR platform trajectory
- Raw SAR data matrix
- Range-compressed SAR data
- Focused SAR image
- Focused image in physical coordinates
- Range and azimuth response plots
- Equal-range target azimuth analysis

The principal SAR matrices are:

```text
Raw SAR Data          : 256 × 1600
Range-Compressed Data : 256 × 1600
Focused SAR Image     : 256 × 1600
```

## 8. Verification

The implementation automatically reports:

- Focused-image peak location
- Physical slant range and along-track position
- Theoretical and measured range resolution
- Theoretical and measured azimuth resolution
- Range PSLR
- Azimuth PSLR
- Range ISLR
- Azimuth ISLR
- Equal-range target separation

The theoretical range resolution is:

```text
ΔR = c / (2B) = 7.5 m
```

## 9. Reproducibility

For reproducible results:

1. Use the repository's committed source files.
2. Run MATLAB from the repository root.
3. Execute `main.m` without modifying the source files.
4. Record the Git commit hash, MATLAB version, and reported performance metrics.

Results should be regenerated from the code rather than relying on previously saved figures or numerical output.



