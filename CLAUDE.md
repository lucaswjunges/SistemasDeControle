# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Brazilian academic project on control systems for chemical reactors. The project consists of three parts studying the control of a continuously stirred tank reactor (CSTR) used in the chemical industry to produce cyclopentenol from cyclopentadiene.

## Repository Structure

The repository contains three separate assignments:
- **Trabalho 1 Sistemas de Controle/**: First assignment on system analysis and pole allocation design
- **Trabalho 2 Sistemas de Controle/**: Second assignment on root locus design and multi-loop control
- **Trabalho 3 Sistemas de Controle/**: Current assignment on Smith Predictor control with measurement delay

Each assignment folder contains:
- `main.tex`: LaTeX source file with complete report
- `Imagens/`: Directory with figures and plots
- Various PNG files and corresponding TXT files (OCR text extraction)

## Document Processing

The repository includes an OCR text extraction system:

### Python Script
```bash
python convert_images.py
```

This script automatically:
- Processes all PNG images in the directory tree
- Extracts Portuguese text using Tesseract OCR
- Creates corresponding .txt files with extracted text
- Skips files that already have text versions

### OCR Dependencies
- Tesseract OCR with Portuguese language support
- Custom tessdata directory with `por.traineddata`
- PIL (Python Imaging Library) for image processing

## LaTeX Document Structure

The main document follows this structure:
1. Introduction with problem statement
2. Development section with methodology
3. Three main sections corresponding to each assignment part
4. Extensive use of equations, figures, and MATLAB code blocks

### Key Features
- Portuguese language document using babel
- UFSC (Federal University of Santa Catarina) branding
- Extensive mathematical notation for control systems
- MATLAB/Simulink code listings with syntax highlighting
- Comprehensive figure integration with captions

### Document Generation Goal
The objective is to create a single consolidated PDF document that combines all three parts of the work (Trabalho 1, 2, and 3). This means merging the LaTeX content from all three assignment folders into one comprehensive report while maintaining proper figure references and section numbering.

## Control Systems Context

The project focuses on:
- **Plant**: Continuous stirred tank reactor for chemical production
- **Control Variable**: Product B concentration (CB)
- **Manipulated Variable**: Dilution flow rate (u = F/V)
- **Disturbance**: Input concentration (CAF)
- **Challenge**: 3-minute measurement delay in Part 3

### System Parameters
- k1 = 6.01 [1/min]
- k2 = 0.8433 [1/min]
- k3 = 0.1123 [mol/(l min)]
- Operating point: CAF = 5.1 mol/l, u = 1 [1/min]

## File Naming Convention

Images follow a systematic naming pattern:
- `q1.png`, `q11.png`, `q12.png`, etc. for question-specific figures
- `figure5.png`, `figure6.png`, etc. for general figures
- `image1.png`, `image2.png`, etc. for additional diagrams

Each image has a corresponding `.txt` file with OCR-extracted text for accessibility and searchability.