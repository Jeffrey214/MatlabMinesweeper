classdef MinesweeperApp < matlab.apps.AppBase
    % MinesweeperApp: A simple Minesweeper game using MATLAB App Designer.

    % App by: Jeffrey Dotson
    % Date: 2025-05-02

    % Attributions:

            % Code:
            % Minesweeper game logic and UI design inspired by various online resources.
            % MATLAB App Designer documentation for UI components and layout.
            % MATLAB documentation for timer and file I/O functions.

            % Icons:
            % Mine Icon: <a href="https://www.flaticon.com/free-icons/mine" title="mine icons">Mine icons created by Creaticca Creative Agency - Flaticon</a>
            % Flag Icon: <a href="https://www.flaticon.com/free-icons/flags" title="flags icons">Flags icons created by nawicon - Flaticon</a>
            % Shovel Icon: <a href="https://www.flaticon.com/free-icons/shovel" title="shovel icons">Shovel icons created by popo2021 - Flaticon</a>
            % Timer Icon: <a href="https://www.flaticon.com/free-icons/time" title="time icons">Time icons created by Freepik - Flaticon</a>
            % Settings: <a href="https://www.flaticon.com/free-icons/settings" title="settings icons">Settings icons created by Freepik - Flaticon</a>
            % Play: <a href="https://www.flaticon.com/free-icons/play-button" title="play button icons">Play button icons created by Alfredo Hernandez - Flaticon</a>
            % High Score: <a href="https://www.flaticon.com/free-icons/trophy" title="trophy icons">Trophy icons created by Freepik - Flaticon</a>

    %% Public properties (UI components)
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        StartButton             matlab.ui.control.Button
        SettingsButton          matlab.ui.control.Button
        HighScoresButton        matlab.ui.control.Button
        SettingsPanel           matlab.ui.container.Panel
        DifficultyLabel         matlab.ui.control.Label
        DifficultyDropDown      matlab.ui.control.DropDown
        SaveSettingsButton      matlab.ui.control.Button
        ScoresPanel             matlab.ui.container.Panel
        ScoreFilterLabel        matlab.ui.control.Label
        ScoreFilterDropDown     matlab.ui.control.DropDown
        ScoresTable             matlab.ui.control.Table
        ResetScoresButton       matlab.ui.control.Button
        BackButton              matlab.ui.control.Button
        GamePanel               matlab.ui.container.Panel
        TimerLabel              matlab.ui.control.Label
        MinesLabel              matlab.ui.control.Label
        TitleLabel              matlab.ui.control.Label
        SubTitleLabel           matlab.ui.control.Label
        TimerIcon               matlab.ui.control.Image
        MineIcon                matlab.ui.control.Image
        BackgroundImage         matlab.ui.control.Image
    end

    %% Private properties
    properties (Access = private)
        iconFolder
        settings
        settingsFile = 'minesweeper_settings.mat'
        scoreFile    = 'minesweeper_scores.mat'
        field
        revealed
        flagged
        buttons
        gridLayout
        startTime
        timerObj
        firstClickDone logical = false
        hasWon logical = false
        remainingMines
    end

    %% Component creation and callbacks
    methods (Access = private)
        % Create all UI components and set up callbacks
        function createComponents(app)
            app.UIFigure = uifigure('Position', [300 200 520 585], 'Name', 'Minesweeper', 'Resize', 'off');
            app.UIFigure.WindowButtonDownFcn = @(src, event) app.onFigureClick();

            % Add background image
            app.BackgroundImage = uiimage(app.UIFigure, ...
                'ImageSource', fullfile(app.iconFolder, 'background.png'), ...
                'Position', [0, 0, app.UIFigure.Position(3), app.UIFigure.Position(4)]); % Stretch to fill the figure

            % Ensure the background image is behind other components
            uistack(app.BackgroundImage, 'bottom');

            figPos = app.UIFigure.Position;
            figW = figPos(3);
            figH = figPos(4);

            titleY = figH - 55;
            subtitleY = titleY - 30;

            app.TitleLabel = uilabel(app.UIFigure, 'Text', 'Minesweeper', 'FontSize', 36, ...
                'FontWeight', 'bold', 'FontName', 'Bookman Old Style', 'HorizontalAlignment', 'center', ...
                'Position', [0, titleY, figW, 55]);

            app.SubTitleLabel = uilabel(app.UIFigure, 'Text', 'MATLAB Edition', 'FontSize', 14, ...
                'FontAngle', 'italic', 'FontName', 'Courier New', 'HorizontalAlignment', 'center', ...
                'Position', [0, subtitleY, figW, 55]);

            yPlay = subtitleY - 40;
            ySet = yPlay - 60;
            yHigh = yPlay - 120;

            app.StartButton = uibutton(app.UIFigure, 'Icon', fullfile(app.iconFolder, 'play.png'), ...
                'Text', '  Play', 'Position', [180, yPlay, 160, 40], 'ButtonPushedFcn', @(~, ~) app.startGame());

            app.SettingsButton = uibutton(app.UIFigure, 'Icon', fullfile(app.iconFolder, 'settings.png'), ...
                'Text', '  Settings', 'Position', [180, ySet, 160, 40], 'ButtonPushedFcn', @(~, ~) app.showSettings());

            app.HighScoresButton = uibutton(app.UIFigure, 'Icon', fullfile(app.iconFolder, 'trophy.png'), ...
                'Text', '  High Scores', 'Position', [180, yHigh, 160, 40], 'ButtonPushedFcn', @(~, ~) app.showHighScores());

            app.SettingsPanel = uipanel(app.UIFigure, 'Title', 'Settings', 'Position', [20 20 480 330], 'Visible', 'off');
            app.DifficultyLabel = uilabel(app.SettingsPanel, 'Text', 'Difficulty:', 'Position', [20 260 100 22]);
            app.DifficultyDropDown = uidropdown(app.SettingsPanel, 'Items', {'Easy', 'Medium', 'Hard'}, ...
                'Position', [130 260 120 22], 'ValueChangedFcn', @(~, ~) app.updateDifficulty());
            app.SaveSettingsButton = uibutton(app.SettingsPanel, 'Text', 'Save & Back', ...
                'Position', [200 20 100 30], 'ButtonPushedFcn', @(~, ~) app.saveSettings());

            app.ScoresPanel = uipanel(app.UIFigure, 'Title', 'High Scores', 'Position', [20 20 480 330], 'Visible', 'off');
            app.ScoreFilterLabel = uilabel(app.ScoresPanel, 'Text', 'Show:', 'Position', [20 280 50 22]);
            app.ScoreFilterDropDown = uidropdown(app.ScoresPanel, 'Items', {'All', 'Easy', 'Medium', 'Hard'}, ...
                'Position', [80 280 100 22], 'ValueChangedFcn', @(~, ~) app.showHighScores());
            app.ScoresTable = uitable(app.ScoresPanel, 'Position', [20 60 440 200], ...
                'ColumnName', {'Name', 'Time', 'Difficulty'});
            app.ResetScoresButton = uibutton(app.ScoresPanel, 'Text', 'Reset Scores', ...
                'Position', [100 20 120 30], 'ButtonPushedFcn', @(~, ~) app.resetScores());
            app.BackButton = uibutton(app.ScoresPanel, 'Text', 'Back', ...
                'Position', [300 20 100 30], 'ButtonPushedFcn', @(~, ~) app.showStartScreen());

            app.GamePanel = uipanel(app.UIFigure, 'Position', [20 20 480 460], 'Visible', 'off');
            app.TimerIcon = uiimage(app.UIFigure, 'ImageSource', fullfile(app.iconFolder, 'timer.png'), ...
                'Position', [32, 516, 22, 22], 'Visible', 'off');
            app.MineIcon = uiimage(app.UIFigure, 'ImageSource', fullfile(app.iconFolder, 'mine.png'), ...
                'Position', [436, 516, 22, 22], 'Visible', 'off');
            app.TimerLabel = uilabel(app.UIFigure, 'Text', '00:00', 'Position', [50, 520, 120, 22], 'Visible', 'off');
            app.MinesLabel = uilabel(app.UIFigure, 'Text', '0', 'Position', [410, 520, 100, 22], 'Visible', 'off');
        end

        % Load settings from file or set defaults, sync UI
        function startupFcn(app)
            app.iconFolder = fullfile(fileparts(mfilename('fullpath')), 'Deps');
            try
                if isfile(app.settingsFile)
                    data = load(app.settingsFile);
                    if isfield(data, 'settings')
                        app.settings = data.settings;
                    else
                        app.settings = struct('gridSize', 9, 'numMines', 10);
                    end
                else
                    app.settings = struct('gridSize', 9, 'numMines', 10);
                end
            catch
                app.settings = struct('gridSize', 9, 'numMines', 10);
            end

            switch app.settings.numMines
                case 10, app.DifficultyDropDown.Value = 'Easy';
                case 30, app.DifficultyDropDown.Value = 'Medium';
                case 70, app.DifficultyDropDown.Value = 'Hard';
            end

            app.showStartScreen();
        end

        % Show main menu, hide all other panels
        function showStartScreen(app)
            app.hideAll();
            app.StartButton.Visible = true;
            app.SettingsButton.Visible = true;
            app.HighScoresButton.Visible = true;
            app.BackgroundImage.Visible = true;
        end

        % Show settings panel
        function showSettings(app)
            app.hideAll();
            app.SettingsPanel.Visible = true;
        end

        % Update settings struct based on dropdown value
        function updateDifficulty(app)
            switch app.DifficultyDropDown.Value
                case 'Easy'
                    app.settings = struct('gridSize', 9, 'numMines', 10);
                case 'Medium'
                    app.settings = struct('gridSize', 14, 'numMines', 30);
                case 'Hard'
                    app.settings = struct('gridSize', 18, 'numMines', 70);
            end
        end

        % Save settings to file and return to main menu
        function saveSettings(app)
            settings = app.settings;
            save(app.settingsFile, 'settings');
            app.showStartScreen();
        end

        % Show high scores panel, filter and display scores
        function showHighScores(app)
            app.hideAll();
            app.ScoresPanel.Visible = true;
            if isfile(app.scoreFile)
                D = load(app.scoreFile, 'scores');
                scores = D.scores;
            else
                scores = struct('name', {}, 'time', {}, 'difficulty', {});
            end

            filt = app.ScoreFilterDropDown.Value;
            if ~strcmp(filt, 'All')
                scores = scores(strcmp({scores.difficulty}, filt));
            end

            if isempty(scores)
                data = {};
            else
                times = arrayfun(@(s) sprintf('%02d:%02d', floor(s.time / 60), mod(s.time, 60)), scores, 'UniformOutput', false)';
                data = [ {scores.name}' times {scores.difficulty}' ];
            end
            app.ScoresTable.Data = data;
        end

        % Reset high scores for selected difficulty or all
        function resetScores(app)
            if isfile(app.scoreFile)
                D = load(app.scoreFile, 'scores');
                scores = D.scores;
            else
                scores = struct('name', {}, 'time', {}, 'difficulty', {});
            end

            filt = app.ScoreFilterDropDown.Value;
            if strcmp(filt, 'All')
                scores = struct('name', {}, 'time', {}, 'difficulty', {});
            else
                scores = scores(~strcmp({scores.difficulty}, filt));
            end

            save(app.scoreFile, 'scores');
            app.showHighScores();
        end

        % Hide all UI components and stop timer if running
        function hideAll(app)
            comps = {app.StartButton, app.SettingsButton, app.HighScoresButton, ...
                app.SettingsPanel, app.ScoresPanel, app.GamePanel, ...
                app.TimerLabel, app.MinesLabel};
            for c = comps
                c{1}.Visible = false;
            end

            app.TimerIcon.Visible = false;
            app.MineIcon.Visible = false;
            app.BackgroundImage.Visible = false;

            if ~isempty(app.timerObj) && isvalid(app.timerObj)
                stop(app.timerObj);
                delete(app.timerObj);
                app.timerObj = [];
            end

            app.firstClickDone = false;
            app.hasWon = false;
        end

        % Start a new game, initialize field and UI
        function startGame(app)
            app.hideAll();
            app.GamePanel.Visible = true;
            app.TimerLabel.Visible = true;
            app.MinesLabel.Visible = true;

            app.TimerIcon.Visible = true;
            app.MineIcon.Visible = true;
            app.TimerLabel.Visible = true;
            app.MinesLabel.Visible = true;

            n = app.settings.gridSize;
            app.field = zeros(n);
            app.revealed = false(n);
            app.flagged = false(n);
            app.remainingMines = app.settings.numMines;
            app.TimerLabel.Text = '00:00';
            app.MinesLabel.Text = sprintf('%d', app.remainingMines);

            delete(app.GamePanel.Children);
            app.gridLayout = uigridlayout(app.GamePanel, [n n]);
            app.gridLayout.RowHeight = repmat({'1x'}, 1, n);
            app.gridLayout.ColumnWidth = repmat({'1x'}, 1, n);
            app.gridLayout.RowSpacing = 1;
            app.gridLayout.ColumnSpacing = 1;
            app.buttons = gobjects(n^2, 1);

            for i = 1:n
                for j = 1:n
                    b = uibutton(app.gridLayout, 'Text', '', ...
                        'ButtonPushedFcn', @(~, ~) app.onLeftClick(i, j));
                    b.FontSize = 14;
                    b.UserData = [i j];
                    b.HorizontalAlignment = 'center';
                    app.buttons((i - 1) * n + j) = b;
                end
            end

            app.startTime = tic;
            app.timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 1, ...
                'TimerFcn', @(~, ~) app.updateTimer());
            start(app.timerObj);

            app.onFigureResize();
        end

        % Update timer label every second
        function updateTimer(app)
            t = round(toc(app.startTime));
            m = floor(t / 60);
            s = mod(t, 60);
            app.TimerLabel.Text = sprintf('%02d:%02d', m, s);
        end

        % Handle left click: reveal cell, place mines if first click
        function onLeftClick(app, i, j)
            if ~app.firstClickDone
                app.placeMines(i, j);
                app.firstClickDone = true;
            end

            if app.flagged(i, j)
                return;
            end

            if app.field(i, j) == -1
                idx = (i - 1) * app.settings.gridSize + j;
                btn = app.buttons(idx);
                btn.Icon = fullfile(app.iconFolder, 'mine.png');
                btn.Text = '';
                btn.BackgroundColor = [1 0 0];
                btn.Enable = 'off';

                app.revealAllMines();

                t = timer('StartDelay', 3, 'ExecutionMode', 'singleShot', ...
                    'TimerFcn', @(~, ~) app.gameOver());
                start(t);
                return;
            end

            app.revealCell(i, j);
            app.checkWin();
        end

        % Handle right click: flag/unflag cell
        function onFigureClick(app)
            if ~strcmp(app.UIFigure.SelectionType, 'alt')
                return;
            end

            obj = app.UIFigure.CurrentObject;
            if isempty(obj) || ~ismember(obj, app.buttons)
                return;
            end

            coords = obj.UserData;
            i = coords(1);
            j = coords(2);
            if ~app.firstClickDone
                return;
            end

            app.flagged(i, j) = ~app.flagged(i, j);
            if app.flagged(i, j)
                obj.Icon = fullfile(app.iconFolder, 'flag.png');
            else
                obj.Icon = '';
            end

            app.remainingMines = app.settings.numMines - sum(app.flagged, 'all');
            app.MinesLabel.Text = sprintf('%d', app.remainingMines);
        end

        % Responsive layout: keep game panel square and labels above
        function onFigureResize(app)
            figPos = app.UIFigure.Position;
            margin = 10;
            topSpace = 30;

            availW = figPos(3) - 2 * margin;
            availH = figPos(4) - topSpace - 2 * margin;
            sz = min(availW, availH);
            panelX = (figPos(3) - sz) / 2;
            panelY = margin;
            app.GamePanel.Position = [panelX, panelY, sz, sz];

            offset = 50;
            timePos = app.TimerLabel.Position;
            minesPos = app.MinesLabel.Position;
            app.TimerLabel.Position = [panelX + offset, panelY + sz + 5, timePos(3), timePos(4)];
            app.MinesLabel.Position = [panelX + sz - minesPos(3) + offset, panelY + sz + 5, minesPos(3), minesPos(4)];
        end

        % Place mines randomly, avoiding first click and neighbors
        function placeMines(app, si, sj)
            n = app.settings.gridSize;
            m = app.settings.numMines;
            allIdx = 1:n^2;

            [rs, cs] = ndgrid(max(si - 1, 1):min(si + 1, n), max(sj - 1, 1):min(sj + 1, n));
            forbid = sub2ind([n n], rs(:), cs(:));
            avail = setdiff(allIdx, forbid);

            mines = avail(randperm(numel(avail), m));
            app.field(:) = 0;
            app.field(mines) = -1;

            for x = 1:n
                for y = 1:n
                    if app.field(x, y) == -1
                        continue;
                    end
                    blk = app.field(max(x - 1, 1):min(x + 1, n), max(y - 1, 1):min(y + 1, n));
                    app.field(x, y) = sum(blk(:) == -1);
                end
            end

            safe = false(n);
            queue = [si sj];
            safe(si, sj) = true;
            while ~isempty(queue)
                x = queue(1, 1); y = queue(1, 2);
                queue(1, :) = [];
                if app.field(x, y) == 0
                    for dx = -1:1
                        for dy = -1:1
                            nx = x + dx; ny = y + dy;
                            if nx >= 1 && nx <= n && ny >= 1 && ny <= n && ~safe(nx, ny)
                                safe(nx, ny) = true;
                                queue(end + 1, :) = [nx ny];
                            end
                        end
                    end
                end
            end

            mineIdx = find(app.field == -1);
            bad = mineIdx(safe(mineIdx));
            if ~isempty(bad)
                avail = find(~safe & app.field ~= -1);
                newMines = avail(randperm(numel(avail), numel(bad)));

                app.field(bad) = 0;
                app.field(newMines) = -1;

                for x = 1:n
                    for y = 1:n
                        if app.field(x, y) ~= -1
                            blk = app.field(max(x - 1, 1):min(x + 1, n), max(y - 1, 1):min(y + 1, n));
                            app.field(x, y) = sum(blk(:) == -1);
                        end
                    end
                end
            end
        end

        % Reveal a cell, recursively reveal neighbors if zero
        function revealCell(app, i, j)
            n = app.settings.gridSize;
            if app.revealed(i, j)
                return;
            end

            app.revealed(i, j) = true;
            idx = (i - 1) * n + j;
            b = app.buttons(idx);
            b.Enable = 'off';
            b.BackgroundColor = [.9 .9 .9];
            b.FontColor = [0 0 0];

            if app.field(i, j) > 0
                b.Text = num2str(app.field(i, j));
            else
                b.Text = '';
                for di = -1:1
                    for dj = -1:1
                        ni = i + di;
                        nj = j + dj;
                        if ni >= 1 && ni <= n && nj >= 1 && nj <= n && ~app.revealed(ni, nj)
                            app.revealCell(ni, nj);
                        end
                    end
                end
            end
        end

        % Reveal all mines on the field (after loss)
        function revealAllMines(app)
            n = app.settings.gridSize;
            for x = 1:n
                for y = 1:n
                    if app.field(x, y) == -1
                        idx = (x - 1) * n + y;
                        btn = app.buttons(idx);
                        btn.Icon = fullfile(app.iconFolder, 'mine.png');
                        btn.Text = '';
                        btn.BackgroundColor = [1 0 0];
                        btn.Enable = 'off';
                    elseif ~app.revealed(x, y) && ~app.flagged(x, y)
                        idx = (x - 1) * n + y;
                        btn = app.buttons(idx);
                        btn.BackgroundColor = [0.9 0.9 0.9];
                        btn.Enable = 'off';
                    end
                end
            end
        end

        % Check for win: all non-mine cells revealed
        function checkWin(app)
            if app.hasWon
                return;
            end

            n = app.settings.gridSize;
            if sum(app.revealed(:)) == n * n - app.settings.numMines
                app.hasWon = true;
                stop(app.timerObj);
                elapsed = round(toc(app.startTime));
                name = inputdlg('You Won! Enter your name:', 'High Score', 1, {'Player'});
                if ~isempty(name)
                    app.saveScore(name{1}, elapsed);
                end
                app.showStartScreen();
            end
        end

        % Handle game over: stop timer, show alert, return to menu
        function gameOver(app)
            if ~isempty(app.timerObj) && isvalid(app.timerObj)
                stop(app.timerObj);
                delete(app.timerObj);
                app.timerObj = [];
            end
            uialert(app.UIFigure, 'Game Over!', 'Boom!');
            app.showStartScreen();
        end

        % Save a new high score to file, sorted by time
        function saveScore(app, name, time)
            if isfile(app.scoreFile)
                D = load(app.scoreFile, 'scores');
                sc = D.scores;
            else
                sc = struct('name', {}, 'time', {}, 'difficulty', {});
            end

            sc(end + 1) = struct('name', name, 'time', time, 'difficulty', app.DifficultyDropDown.Value);

            if ~isempty(sc)
                [~, o] = sort([sc.time]);
                sc = sc(o);
            end

            scores = sc;
            save(app.scoreFile, 'scores');
        end
    end

    methods (Access = public)
        % Constructor: create UI and initialize app
        function app = MinesweeperApp
            app.iconFolder = fullfile(fileparts(mfilename('fullpath')), 'Deps');
            app.createComponents();
            registerApp(app, app.UIFigure);
            app.startupFcn();
        end

        % Destructor: clean up UI and timer
        function delete(app)
            if isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
            if ~isempty(app.timerObj) && isvalid(app.timerObj)
                stop(app.timerObj);
                delete(app.timerObj);
            end
        end
    end
end
