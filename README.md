# Compressed Sensing Camera

## Project Overview
The objective of this capstone project is to design and build a functional prototype camera using compressed sensing principles with a single-pixel sensor to capture visible light. The system will acquire compressed measurements and reconstruct images using computational algorithms, demonstrating the viability of sub-Nyquist sampling for image acquisition.

## Team Members
- **[Mazen]** - [Role/Responsibility]
- **[Omar]** - [Role/Responsibility]
- **[Cole]** - [Role/Responsibility]
- **[Ghassan]** - [Role/Responsibility]

**Supervisor:** Steven Knudsen 
**Course:** ECE 492 - Capstone Design Project  
**Institution:** University of Alberta  
**Term:** Winter 2026

## Project Goals
- Design and implement hardware for single-pixel compressed sensing camera
- Develop firmware for measurement acquisition and control
- Implement image reconstruction algorithms (e.g., basis pursuit, greedy algorithms)
- Validate system performance through experimental testing
- Deliver a working prototype with documentation

## System Architecture
The system consists of three main components:
1. **Optical Frontend** - Single-pixel detector, spatial light modulator/DMD, optics
2. **Embedded System** - Microcontroller-based data acquisition and control
3. **Reconstruction Backend** - PC-based image processing and reconstruction

## Repository Structure
```
CS_Camera/
├── Firmware/              # Embedded firmware for sensor control and data acquisition
├── Image_reconstruction/  # Image reconstruction algorithms and processing code
├── docs/                  # Design documents, reports, and presentations
├── hardware/             # Schematics, PCB files, and hardware documentation
├── tests/                # Test scripts and validation data
├── data/                 # Sample measurements and calibration files
└── README.md             # This file
```

## Getting Started

### Prerequisites
**Hardware:**
- 
- Development board: Pi 
- Single-pixel detector: 
- LCD:

**Software:**
- TODO

### Installation
```bash
# Clone the repository
git clone git@github.com:UAlberta-ECE-492-W2026/CS_Camera.git
cd CS_Camera

# Setup firmware development environment
cd Firmware

```

### Quick Start
TODO

## Development Workflow
- **Branch Strategy:** Feature branches off `main`, merge via pull requests
- **Code Review:** All PRs require at least two review before merging
- **Testing:** Run tests before committing changes
- **Documentation:** Update relevant docs with any architectural changes

## Documentation

- Design specifications
- Hardware schematics
- Algorithm descriptions
- Testing procedures
- Final report and presentations

## Current Status/Milestones
- [ ] Project planning and requirements definition
- [ ] Hardware design and component selection
- [ ] Firmware development
- [ ] Image reconstruction algorithm implementation
- [ ] System integration and testing
- [ ] Final documentation and presentation

**Last Updated:** January 26, 2026


## Acknowledgments
Special thanks to the University of Alberta ECE Department and our project supervisor for their support and guidance.