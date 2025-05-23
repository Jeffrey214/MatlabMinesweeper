# MATLAB Minesweeper
**Version:** 1.0.0  
**Author:** Jeffrey R. Dotson  
**Email:** jeffreyrdotson@gmail.com  
**GitHub Repository:** [https://github.com/Jeffrey214/MatlabMinesweeper](https://github.com/Jeffrey214/MatlabMinesweeper)

## Overview
MATLAB Minesweeper is a GUI-based implementation of the classic Minesweeper game, developed using MATLAB App Designer and custom figure callbacks. Players can choose preset difficulty levels or customize their own board.

## Features
- Real-time GUI gameplay with interactive buttons and callbacks
- Multiple difficulty levels: Beginner, Intermediate, Expert, or custom board size
- Timer and mine counter displayed during play
- Persistent settings and high scores saved in `.mat` files

## Requirements
- MATLAB R2018b or later
- No additional toolboxes required

## Installation
### Clone the repository
```bash
git clone https://github.com/Jeffrey214/MatlabMinesweeper.git
cd MatlabMinesweeper
```
### Add to MATLAB path
```matlab
addpath(genpath(pwd));
```

## Project Structure
```
.
├── MinesweeperApp.m           % Main application
├── minesweeper_settings.mat   % Default board settings
├── minesweeper_scores.mat     % Saved high scores
├── Deps/                      % images, icons, etc.
├── LICENSE                    % MIT License
└── README.md                  % Project overview
```

## Usage
1. In the MATLAB Command Window, run:
   ```matlab
   MinesweeperApp
   ```
2. Select a difficulty preset or load custom settings.
3. Play the game: left-click to reveal, right-click to flag mines.

## Technical Details
- **GUI Construction:** Programmatic figures and callbacks
- **Data Storage:** `.mat` files for settings and high scores
- **Timer Logic:** `tic`/`toc` for elapsed time tracking
- **Mine Placement:** Randomized grid ensuring first-click safety

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository and create a feature branch (`git checkout -b feature-name`).
2. Commit your changes and push (`git push origin feature-name`).
3. Open a pull request describing your improvements.

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments
- **App by:** Jeffrey Dotson (Date: 2025-05-02)

- **Attributions:**
  - **Code:**
    - Minesweeper game logic and UI design inspired by various online resources.
    - MATLAB App Designer documentation for UI components and layout.
    - MATLAB documentation for timer and file I/O functions.

  - **Icons:**
    - Mine Icon: [Mine icons created by Creaticca Creative Agency - Flaticon](https://www.flaticon.com/free-icons/mine)
    - Flag Icon: [Flags icons created by nawicon - Flaticon](https://www.flaticon.com/free-icons/flags)
    - Shovel Icon: [Shovel icons created by popo2021 - Flaticon](https://www.flaticon.com/free-icons/shovel)
    - Timer Icon: [Time icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/time)
    - Settings Icon: [Settings icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/settings)
    - Play Icon: [Play button icons created by Alfredo Hernandez - Flaticon](https://www.flaticon.com/free-icons/play-button)
    - High Score Icon: [Trophy icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/trophy)
