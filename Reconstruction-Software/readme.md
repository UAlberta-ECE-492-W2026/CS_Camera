# Compressive Sensing Camera — MATLAB Reconstruction Software

**Author:** Cole Mckay (cdmckay1@ualberta.ca)  
**Capstone Project — University of Alberta**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Repository Structure](#2-repository-structure)
3. [Mathematical Background](#3-mathematical-background)
   - [3.1 Walsh-Hadamard Basis & Compressive Sensing](#31-walsh-hadamard-basis--compressive-sensing)
   - [3.2 Simple Back-Projection Reconstruction](#32-simple-back-projection-reconstruction)
   - [3.3 Edge-Preserving Total Variation Reconstruction](#33-edge-preserving-total-variation-reconstruction)
4. [CNN Enhancement Architecture](#4-cnn-enhancement-architecture)
   - [4.1 Motivation](#41-motivation)
   - [4.2 Network Architecture (ResNet-style)](#42-network-architecture-resnet-style)
   - [4.3 Training Pipeline](#43-training-pipeline)
5. [Camera Emulation](#5-camera-emulation)
6. [MATLAB Apps](#6-matlab-apps)
7. [Configuration](#7-configuration)
8. [Getting Started](#8-getting-started)
9. [Dependencies](#9-dependencies)

---

## 1. Project Overview

This repository folder contains the MATLAB software layer for a **single-pixel compressive sensing (CS) camera** capstone project. Rather than capturing a full image on a conventional sensor array, the hardware captures a scene through a sequence of structured **Walsh-Hadamard binary masks** and records a single scalar measurement (ADC value) per mask. The software then reconstructs a full 2D image from this heavily undersampled measurement set using one of three algorithms:

| Algorithm | Speed | Quality | Notes |
|---|---|---|---|
| Simple Back-Projection | Fast | Moderate | Linear; good baseline |
| Total Variation (TV) | Slow | High | Edge-preserving, iterative |
| CNN Enhancement | Fast (inference) | Highest | Requires pre-trained model |

---

## 2. Repository Structure

```
project_root/
│
├── +reco/                          # Reconstruction algorithms
│   ├── simpleReconstruction.m      # Linear back-projection
│   ├── tvReconstruction.m          # TV-minimization solver
│   └── cnnReconstruction.m         # CNN-enhanced reconstruction
│
├── +utils/                         # Core utility functions
│   ├── emulateCameraCapture.m      # Hardware emulation
│   ├── generateWalshMask.m         # Walsh-Hadamard mask generation
│   ├── getOptimalCore.m            # Optimal low-frequency mask selection
│   ├── loadConfig.m                # JSON config loader
│   ├── selectMaskIndexes.m         # Sampling strategy selector
│   └── simulateCapture.m          # ADC capture simulation
│
├── +models/                        # Trained CNN model files (.mat)
│   ├── cs_enhancement_net_ResNet.mat
│   └── cs_enhancement_net_ResNet_50p.mat
│
├── +tools/                         # Standalone scripts & tools
│   ├── train_CS_Enhancement_CNN.m  # CNN training script
│   ├── test_emulateCameraCapture.m # Integration test
│   ├── generate_training_data.m    # Dataset generation
│   └── ...
│
├── configs/
│   └── camera_settings.json        # Resolution, sampling %, noise params
│
├── data/                           # Training datasets and capture CSVs
├── images/                         # Test images (BSDS300, tiny-imagenet)
├── mask_firmware/                  # Embedded C++ mask generator for hardware
│   ├── main.cpp
│   ├── WalshMaskGenerator.cpp
│   └── WalshMaskGenerator.h
│
├── assets/
│   └── eng_logo.png
│
├── Emulation_app.mlapp             # MATLAB App: camera emulation UI
└── Reconstruction_app.mlapp        # MATLAB App: reconstruction UI
```

---

## 3. Mathematical Background

### 3.1 Walsh-Hadamard Basis & Compressive Sensing

The system measures a scene $\mathbf{x} \in \mathbb{R}^{N}$ (a vectorized $\sqrt{N} \times \sqrt{N}$ image) using $M \ll N$ linear measurements. Each measurement $y_i$ is the inner product of the scene with a binary Walsh-Hadamard mask $\mathbf{\phi}_i \in \{0, 1\}^N$:

$$y_i = \mathbf{\phi}_i^T \mathbf{x} + \eta_i, \quad i = 1, \ldots, M$$

where $\eta_i$ is additive noise. Stacking all measurements:

$$\mathbf{y} = \mathbf{\Phi} \mathbf{x} + \mathbf{\eta}$$

where $\mathbf{\Phi} \in \mathbb{R}^{M \times N}$ is the **sensing matrix**, with each row being a flattened Walsh mask. Because Walsh-Hadamard functions form an orthonormal basis ordered by **sequency** (the number of zero-crossings, analogous to frequency), the system preferentially captures low-sequency masks — which carry the most image energy — enabling meaningful reconstruction even at aggressive undersampling ratios (e.g., 50%).

A DC baseline is removed before reconstruction to center the measurements:

$$\mathbf{y}_{AC} = \mathbf{y} - \bar{y}\mathbf{1}$$

---

### 3.2 Simple Back-Projection Reconstruction

The simplest reconstruction is a **linear back-projection** (pseudo-inverse approximation):

$$\hat{\mathbf{x}} = \mathbf{\Phi}^T \mathbf{y}_{AC}$$

In practice, this is computed mask-by-mask without explicitly forming $\mathbf{\Phi}$:

$$\hat{\mathbf{x}} = \sum_{i=1}^{M} y_{AC,i} \cdot \mathbf{\phi}_i$$

Each Walsh mask is weighted by its AC measurement value and accumulated into the image. The result is normalized to $[0, 1]$:

$$\hat{x}_{norm} = \frac{\hat{\mathbf{x}} - \min(\hat{\mathbf{x}})}{\max(\hat{\mathbf{x}}) - \min(\hat{\mathbf{x}})}$$

**Complexity:** $O(M \cdot N)$ — fast, but produces visible Walsh-Hadamard ringing artifacts at low sampling rates because the unmeasured basis components implicitly contribute zero energy.

> **Implemented in:** `+reco/simpleReconstruction.m`

---

### 3.3 Edge-Preserving Total Variation Reconstruction

To suppress ringing artifacts while preserving sharp edges, the system solves a **Total Variation (TV) minimization** problem:

$$\hat{\mathbf{x}} = \arg\min_{\mathbf{x}} \underbrace{\|\mathbf{\Phi}\mathbf{x} - \mathbf{y}\|_2^2}_{\text{data fidelity}} + \lambda \underbrace{\text{TV}_w(\mathbf{x})}_{\text{regularization}}$$

where $\lambda$ is a regularization weight (set to 50 in the current configuration).

#### Isotropic TV with Perona-Malik Edge Weighting

Standard isotropic TV uses the image gradient magnitude:

$$\text{TV}(\mathbf{x}) = \sum_{p} \sqrt{(\nabla_x \mathbf{x}_p)^2 + (\nabla_y \mathbf{x}_p)^2}$$

This implementation extends TV with **Perona-Malik edge weights** $w_p$ to be less penalizing at strong edges:

$$w_p = \frac{1}{1 + \left(\|\nabla \mathbf{x}_p\| / \sigma\right)^2}$$

where $\sigma$ is an adaptive edge-stopping threshold set to $0.25 \cdot \max(|\mathbf{y}|)$. The weighted TV gradient (used in the gradient descent update) becomes the divergence of the weighted normalized gradient field:

$$\nabla_\mathbf{x} \text{TV}_w = -\text{div}\left( w_p \cdot \frac{\nabla \mathbf{x}}{\|\nabla \mathbf{x}\| + \epsilon} \right)$$

where $\epsilon = 10^{-5}$ prevents division by zero.

#### Gradient Descent Solver

The full gradient descent update at iteration $k$ is:

$$\mathbf{x}^{(k+1)} = \mathbf{x}^{(k)} - \alpha \left[ \mathbf{\Phi}^T(\mathbf{\Phi}\mathbf{x}^{(k)} - \mathbf{y}) + \lambda \nabla_\mathbf{x} \text{TV}_w(\mathbf{x}^{(k)}) \right]$$

The step size $\alpha$ is set using the **Lipschitz-stable** rule:

$$\alpha = \frac{1.9}{\|\mathbf{\Phi}\|_2^2}$$

The solver runs for 300 iterations, printing progress every 50. The initial state is seeded with the linear back-projection $\mathbf{x}^{(0)} = \mathbf{\Phi}^T \mathbf{y}_{AC}$.

> **Implemented in:** `+reco/tvReconstruction.m`

---

## 4. CNN Enhancement Architecture

### 4.1 Motivation

The simple back-projection reconstruction is fast but suffers from structured **Walsh-Hadamard artifacts** — a characteristic checkerboard-like pattern caused by the abrupt truncation of the measurement basis. Rather than solving an expensive iterative optimization at inference time, a **residual convolutional neural network** learns a mapping from the noisy back-projection to the ground-truth image, effectively learning to suppress exactly the artifact pattern produced by this sensing system.

### 4.2 Network Architecture (ResNet-style)

The network is a lightweight **residual (skip-connection) CNN** that learns the *artifact residual* rather than the full image mapping. This is motivated by the observation that the back-projection $\hat{\mathbf{x}}$ already contains the correct low-frequency image content — only the high-frequency artifact component needs to be estimated and removed.

```
Input (N×N×1)
    │
    ├────────────────────────────────── Skip Connection ──────────────────────┐
    │                                                                          │
    ▼                                                                          │
Conv2D (5×5, 64 filters) → ReLU                  ← Artifact extraction       │
    ▼                                                                          │
Conv2D (3×3, 32 filters) → ReLU                  ← Artifact refinement       │
    ▼                                                                          │
Conv2D (5×5, 1 filter)                            ← Artifact map              │
    │                                                                          │
    └───────────────────────────────────► Addition ◄──────────────────────────┘
                                              │
                                              ▼
                                    Enhanced Output (N×N×1)
                                              │
                                              ▼
                                    Regression Loss (MSE)
```

The network learns artifact weights $\mathbf{r}$ such that:

$$\hat{\mathbf{x}}_{enhanced} = \hat{\mathbf{x}}_{simple} + f_{CNN}(\hat{\mathbf{x}}_{simple}; \mathbf{\theta})$$

where $f_{CNN}$ is the residual branch. At inference, this is equivalent to the network predicting the ground truth directly via the identity shortcut.

**Layer details:**

| Layer | Kernel | Filters | Activation | Role |
|---|---|---|---|---|
| Conv1 | 5×5 | 64 | ReLU | Patch feature extraction |
| Conv2 | 3×3 | 32 | ReLU | Non-linear mapping |
| Conv3 | 5×5 | 1 | — | Residual artifact map |
| Addition | — | — | — | Skip + residual |

All convolutions use `'same'` padding to preserve spatial dimensions throughout.

### 4.3 Training Pipeline

> **Script:** `+tools/train_CS_Enhancement_CNN.m`

**Data Preparation:**

1. Raw ADC measurements $\mathbf{y}$ are loaded from `cnn_training_data_50p.mat`
2. The sensing matrix $\mathbf{\Phi}$ is built from the mask list
3. For each training sample, a simple back-projection is computed and normalized to produce $\hat{\mathbf{x}}^{(i)}_{simple}$ — this is the **network input**
4. The ground-truth cropped/resized image is the **network target**

**Training Configuration:**

| Parameter | Value |
|---|---|
| Optimizer | Adam |
| Initial Learning Rate | $10^{-3}$ |
| Max Epochs | 50 |
| Mini-batch Size | 64 |
| Shuffle | Every epoch |
| Execution | GPU (CUDA) |
| Loss | MSE (Regression) |
| Training Data | BSDS300 + tiny-imagenet @ 50% sampling |

**Trained model output:** `+models/cs_enhancement_net_ResNet_50p.mat`

The model is loaded **once** at first call using a `persistent` variable in `cnnReconstruction.m` to avoid repeated disk reads during a session.

---

## 5. Camera Emulation

> **Function:** `+utils/emulateCameraCapture.m`

The emulation pipeline mirrors the physical hardware capture process:

1. **Load image** — accepts a filepath or raw matrix
2. **Greyscale conversion** — colour images are converted via `im2gray`
3. **Square crop** — a centred square crop is taken using `centerCropWindow2d` to match the aspect ratio of the hardware aperture
4. **Resize** — the crop is resized to the target resolution defined in `camera_settings.json`
5. **Simulate capture** — `utils.simulateCapture` projects the image through each Walsh mask, optionally adding noise to emulate ADC quantization and photon shot noise

**Output format:** an $N \times 2$ matrix where column 1 is the mask index and column 2 is the ADC value. A header row with index $-1$ encodes the image resolution for downstream parsers.

---

## 6. MATLAB Apps

Two MATLAB App Designer GUIs are provided:

| App | File | Purpose |
|---|---|---|
| **Emulation App** | `Emulation_app.mlapp` | Load an image, select sampling %, run emulated capture, export data |
| **Reconstruction App** | `Reconstruction_app.mlapp` | Import capture CSV, choose reconstruction algorithm, display result |

---

## 7. Configuration

All camera and sampling parameters are stored in `configs/camera_settings.json`:

```json
{
    "hardware": {
        "adc_bits": 12,
        "v_ref": 3.3,
        "quantization_levels": 4096,
        "saturation_limit": 3800
    },
    "sampling_parameters": {
        "resolution": [64, 64],
        "samples_per_mask": 256,
        "sampling_pct": 0.25,
        "core_mask_count": 1024
    },
    "bias_profile": {
        "low_freq_bias_pct": 0.15
    },
    "sensor_noise": {
        "std_dev_counts": 2.5,
        "dark_current_counts": 12.0
    },
    "mask_constraints": {
        "black_leakage_pct": 0.01,
        "white_attenuation_pct": 1.0
    }
}
```

**Hardware**

| Field | Value | Description |
|---|---|---|
| `adc_bits` | 12 | ADC resolution |
| `v_ref` | 3.3 V | ADC reference voltage |
| `quantization_levels` | 4096 | Total ADC levels ($2^{12}$) |
| `saturation_limit` | 3800 | Clipping threshold (counts) |

**Sampling Parameters**

| Field | Value | Description |
|---|---|---|
| `resolution` | `[64, 64]` | Square image dimensions |
| `samples_per_mask` | 256 | ADC readings averaged per mask exposure |
| `sampling_pct` | 0.25 | Fraction of $N^2$ masks captured (25%) |
| `core_mask_count` | 1024 | Lowest-sequency masks always included |

**Noise & Mask Constraints**

| Field | Value | Description |
|---|---|---|
| `std_dev_counts` | 2.5 | Gaussian read noise (ADC counts) |
| `dark_current_counts` | 12.0 | Dark current offset (ADC counts) |
| `low_freq_bias_pct` | 0.15 | Extra sampling weight on low-sequency masks |
| `black_leakage_pct` | 0.01 | Light leakage through nominally black mask pixels |
| `white_attenuation_pct` | 1.0 | Transmission loss through white mask pixels |

---

## 8. Getting Started

### Running a reconstruction from a CSV export

```matlab
cfg = utils.loadConfig('configs/camera_settings.json');
dataMatrix = readmatrix('data/camera_data_export.csv');

% Simple back-projection
img_simple = reco.simpleReconstruction(dataMatrix);
imshow(img_simple); title('Simple Reconstruction');

% Total Variation
img_tv = reco.tvReconstruction(dataMatrix);
imshow(img_tv); title('TV Reconstruction');

% CNN-Enhanced
img_cnn = reco.cnnReconstruction(dataMatrix);
imshow(img_cnn); title('CNN Enhanced');
```

### Running the emulator test

```matlab
run('+tools/test_emulateCameraCapture.m')
```

### Training the CNN

```matlab
% Requires cnn_training_data_50p.mat in /data
run('+tools/train_CS_Enhancement_CNN.m')
```

---

## 9. Dependencies

| Requirement | Notes |
|---|---|
| MATLAB R2021b+ | Core language |
| Deep Learning Toolbox | `trainNetwork`, `predict`, layer definitions |
| Image Processing Toolbox | `im2gray`, `imresize`, `centerCropWindow2d` |
| Parallel Computing Toolbox | GPU training (`ExecutionEnvironment: 'gpu'`) |
| CUDA-capable GPU | Recommended for training; inference runs on CPU |