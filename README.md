# MATLAB Minesweeper

A simple, interactive Minesweeper game built in MATLAB.
Constructed as my final project for Computer Programming 1 (BPA-PP1) at the Brno University of Technology (Vysoké Učení Technické) VUT in Brno, Czech Republic.

---

## Features

- GUI-based gameplay with MATLAB App Designer or custom figures
- Multiple difficulty levels: Beginner, Intermediate, Expert, or custom
- Timer and mine counter to track progress
- Save and load settings and high scores (`minesweeper_settings.mat`, `minesweeper_scores.mat`)

---

## Requirements

- MATLAB R2018b or later
- No additional toolboxes required

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Jeffrey214/MatlabMinesweeper.git
   cd MatlabMinesweeper
   ```
2. Add to MATLAB path:
   ```matlab
   addpath(genpath(pwd));
   ```

---

## Usage

1. In MATLAB, navigate to the project folder.
2. Run the app:
   ```matlab
   MinesweeperApp
   ```
3. Select difficulty or load custom settings.

---

## File Structure

```
.
├── MinesweeperApp.m
├── minesweeper_settings.mat
├── minesweeper_scores.mat
├── LICENSE
└── README.md
```

---

## Customization

- Edit `minesweeper_settings.mat` to change default rows, columns, or mine count.
- Modify UI callbacks and styling in `MinesweeperApp.m`.

---

## Contributing

1. Fork the repository and create a branch.
2. Commit your changes and push to your fork.
3. Open a pull request with a description of your changes.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Contact

Open an issue on GitHub or email **jeffreyrdotson@vt.edu** for questions or suggestions.
