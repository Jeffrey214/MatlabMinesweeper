classdef MinesweeperApp < matlab.apps.AppBase
    % MinesweeperApp: A simple Minesweeper game using MATLAB App Designer.

    % App by: Jeffrey Dotson
    % Date: 2024-05-02

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
        UIFigure                matlab.ui.Figure                % Main application window
        StartButton             matlab.ui.control.Button        % Button to start a new game
        SettingsButton          matlab.ui.control.Button        % Button to open settings
        HighScoresButton        matlab.ui.control.Button        % Button to view high scores
        SettingsPanel           matlab.ui.container.Panel       % Panel for settings UI
        DifficultyLabel         matlab.ui.control.Label         % Label for difficulty dropdown
        DifficultyDropDown      matlab.ui.control.DropDown      % Dropdown for difficulty selection
        SaveSettingsButton      matlab.ui.control.Button        % Button to save settings
        ScoresPanel             matlab.ui.container.Panel       % Panel for high scores UI
        ScoreFilterLabel        matlab.ui.control.Label         % Label for score filter
        ScoreFilterDropDown     matlab.ui.control.DropDown      % Dropdown to filter scores
        ScoresTable             matlab.ui.control.Table         % Table to display high scores
        ResetScoresButton       matlab.ui.control.Button        % Button to reset scores
        BackButton              matlab.ui.control.Button        % Button to return to main menu
        GamePanel               matlab.ui.container.Panel       % Panel for the game grid
        TimerLabel              matlab.ui.control.Label         % Label to display elapsed time (numbers only)
        MinesLabel              matlab.ui.control.Label         % Label to display remaining mines (numbers only)
        TitleLabel              matlab.ui.control.Label         % Label to display the title
        SubTitleLabel           matlab.ui.control.Label         % Label to display the subtitle
        TimerIcon               matlab.ui.control.Image         % Timer icon
        MineIcon                matlab.ui.control.Image         % Mine icon
    end

    %% Private properties
    properties (Access = private)
        iconFolder                                  % Path to folder containing all your .png’s
        settings                                    % Struct: stores gridSize & numMines
        settingsFile = 'minesweeper_settings.mat'   % File path for settings
        scoreFile    = 'minesweeper_scores.mat'     % File path for high scores
        field                                       % Matrix: -1 for mines, >=0 for neighbor counts
        revealed                                    % Logical matrix: true if cell is revealed
        flagged                                     % Logical matrix: true if cell is flagged
        buttons                                     % Array of button handles for grid cells
        gridLayout                                  % UI grid layout for the game
        startTime                                   % Timer start time (tic)
        timerObj                                    % MATLAB timer object for UI timer
        firstClickDone logical = false              % True after first click (mines placed)
        hasWon logical = false                      % True if player has won
        remainingMines                              % Number of mines left to flag
    end

    %% Component creation and callbacks
    methods (Access = private)
        % Create all UI components and set up callbacks
        function createComponents(app)
            % 1) Make the window a little shorter
            app.UIFigure = uifigure( ...
                'Position', [300 200 520 575], ... % From 640 down to 600
                'Name',     'Minesweeper', ...
                'Resize',   'off' );
            % Set up figure right-click detection
            app.UIFigure.WindowButtonDownFcn = @(src, event) app.onFigureClick();

            % 2) Grab the (new) client‐area height/width
            figPos = app.UIFigure.Position;
            figW   = figPos(3);
            figH   = figPos(4);

            % 3) Position the title + subtitle just under the OS chrome
            titleY    = figH - 55;    % Shift "Minesweeper" title upward
            subtitleY = titleY   - 30;

            app.TitleLabel = uilabel(app.UIFigure, ...
                'Text',               'Minesweeper', ...
                'FontSize',           34, ...
                'FontWeight',         'bold', ...
                'FontName',           'Comic Sans MS', ...
                'HorizontalAlignment','center', ...
                'Position',           [0, titleY, figW, 55]);

            % Subtitle only on the home screen
            if strcmp(app.UIFigure.Name, 'Minesweeper')
                app.SubTitleLabel = uilabel(app.UIFigure, ...
                    'Text',               'MATLAB Edition', ...
                    'FontSize',           14, ...
                    'FontAngle',          'italic', ...
                    'FontName',           'Courier New', ...
                    'HorizontalAlignment','center', ...
                    'Position',           [0, subtitleY, figW, 55]);
            else
                if isvalid(app.SubTitleLabel)
                    delete(app.SubTitleLabel); % Remove subtitle on other screens
                end
            end

            % 4) Drop the buttons up under the subtitle
            yPlay = subtitleY - 40;   % ~60px gap below subtitle
            ySet  = yPlay       - 60;
            yHigh = yPlay       - 120;

            app.StartButton = uibutton(app.UIFigure, ...
                'Icon',     fullfile(app.iconFolder,'play.png'), ...
                'Text',     '  Play', ...
                'Position', [180, yPlay, 160, 40], ...
                'ButtonPushedFcn', @(~,~)app.startGame());

            app.SettingsButton = uibutton(app.UIFigure, ...
                'Icon',     fullfile(app.iconFolder,'settings.png'), ...
                'Text',     '  Settings', ...
                'Position', [180, ySet,  160, 40], ...
                'ButtonPushedFcn', @(~,~)app.showSettings());

            app.HighScoresButton = uibutton(app.UIFigure, ...
                'Icon',     fullfile(app.iconFolder,'trophy.png'), ...
                'Text',     '  High Scores', ...
                'Position', [180, yHigh, 160, 40], ...
                'ButtonPushedFcn', @(~,~)app.showHighScores());

            % Settings panel setup
            app.SettingsPanel = uipanel(app.UIFigure, 'Title', 'Settings', ...
                'Position', [20 20 480 330], 'Visible', 'off'); % Hidden by default
            app.DifficultyLabel = uilabel(app.SettingsPanel, 'Text', 'Difficulty:', ...
                'Position', [20 260 100 22]); % Difficulty label
            app.DifficultyDropDown = uidropdown(app.SettingsPanel, ...
                'Items', {'Easy', 'Medium', 'Hard'}, 'Position', [130 260 120 22], ...
                'ValueChangedFcn', @(~, ~) app.updateDifficulty()); % Difficulty dropdown
            app.SaveSettingsButton = uibutton(app.SettingsPanel, 'Text', 'Save & Back', ...
                'Position', [200 20 100 30], 'ButtonPushedFcn', @(~, ~) app.saveSettings()); % Save settings

            % High scores panel setup
            app.ScoresPanel = uipanel(app.UIFigure, 'Title', 'High Scores', ...
                'Position', [20 20 480 330], 'Visible', 'off'); % Hidden by default
            app.ScoreFilterLabel = uilabel(app.ScoresPanel, 'Text', 'Show:', ...
                'Position', [20 280 50 22]); % Filter label
            app.ScoreFilterDropDown = uidropdown(app.ScoresPanel, ...
                'Items', {'All', 'Easy', 'Medium', 'Hard'}, 'Position', [80 280 100 22], ...
                'ValueChangedFcn', @(~, ~) app.showHighScores()); % Filter dropdown
            app.ScoresTable = uitable(app.ScoresPanel, 'Position', [20 60 440 200], ...
                'ColumnName', {'Name', 'Time', 'Difficulty'}); % Table for scores
            app.ResetScoresButton = uibutton(app.ScoresPanel, 'Text', 'Reset Scores', ...
                'Position', [100 20 120 30], 'ButtonPushedFcn', @(~, ~) app.resetScores()); % Reset scores
            app.BackButton = uibutton(app.ScoresPanel, 'Text', 'Back', ...
                'Position', [300 20 100 30], 'ButtonPushedFcn', @(~, ~) app.showStartScreen()); % Back to menu

            % Game panel and info labels
            app.GamePanel = uipanel(app.UIFigure, 'Position', [20 20 480 460], 'Visible', 'off'); % Game grid panel
            if isprop(app.GamePanel, 'AutoResizeChildren')
                app.GamePanel.AutoResizeChildren = 'off';
            end

            % Add timer and mine icons to the board
            app.TimerIcon = uiimage(app.UIFigure, ...
                'ImageSource', fullfile(app.iconFolder, 'timer.png'), ...
                'Position', [32, 516, 22, 22], ...
                'Visible', 'off'); % Timer icon

            app.MineIcon = uiimage(app.UIFigure, ...
                'ImageSource', fullfile(app.iconFolder, 'mine.png'), ...
                'Position', [436, 516, 22, 22], ...
                'Visible', 'off'); % Mine icon

            % Set labels to display numbers only
            app.TimerLabel = uilabel(app.UIFigure, ...
                'Text', '00:00', ...
                'Position', [50, 520, 120, 22], ...
                'Visible', 'off'); % Timer label

            app.MinesLabel = uilabel(app.UIFigure, ...
                'Text', '0', ...
                'Position', [410, 520, 100, 22], ...
                'Visible', 'off'); % Mines left label
        end

        % Load settings from file or set defaults, sync UI
        function startupFcn(app)
            app.iconFolder = fullfile(fileparts(mfilename('fullpath')), 'Deps');
            try
                if isfile(app.settingsFile)
                    data = load(app.settingsFile);
                    if isfield(data, 'settings')
                        app.settings = data.settings; % Load saved settings
                    else
                        app.settings = struct('gridSize', 9, 'numMines', 10); % Default settings
                    end
                else
                    app.settings = struct('gridSize', 9, 'numMines', 10); % Default settings
                end
            catch
                app.settings = struct('gridSize', 9, 'numMines', 10); % Fallback to defaults
            end

            % Set dropdown to match loaded settings
            switch app.settings.numMines
                case 10
                    app.DifficultyDropDown.Value = 'Easy';
                case 30
                    app.DifficultyDropDown.Value = 'Medium';
                case 70
                    app.DifficultyDropDown.Value = 'Hard';
            end

            % Set the custom cursor to a small shovel icon (requires shovel.png in the Deps folder)
            try
                jFig = get(handle(app.UIFigure), 'JavaFrame');  % Undocumented feature
                jWindow = jFig.fHG2Client.getWindow;
                cursorImg = imread(fullfile(app.iconFolder, 'shovel.png'));  % Read shovel image
                jImg = im2java(cursorImg);  % Convert MATLAB image to Java image
                customCursor = java.awt.Toolkit.getDefaultToolkit().createCustomCursor(jImg, java.awt.Point(0,0), 'Shovel');
                jWindow.setCursor(customCursor);
            catch ME
                warning('Custom cursor could not be set: %s', ME.message);
                % Fallback to MATLAB's built-in hand pointer
                app.UIFigure.Pointer = 'hand';
            end

            app.showStartScreen(); % Show main menu
        end

        % Show main menu, hide all other panels
        function showStartScreen(app)
            app.hideAll(); % Hide all UI panels
            app.StartButton.Visible = true;    % Show start button
            app.SettingsButton.Visible = true; % Show settings button
            app.HighScoresButton.Visible = true; % Show high scores button
        end

        % Show settings panel
        function showSettings(app)
            app.hideAll(); % Hide all UI panels
            app.SettingsPanel.Visible = true; % Show settings panel
        end

        % Update settings struct based on dropdown value
        function updateDifficulty(app)
            % Set grid size and mine count based on selected difficulty
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
            settings = app.settings; % Copy settings struct
            save(app.settingsFile, 'settings'); % Save to file
            app.showStartScreen(); % Return to main menu
        end

        % Show high scores panel, filter and display scores
        function showHighScores(app)
            app.hideAll(); % Hide all UI panels
            app.ScoresPanel.Visible = true; % Show scores panel
            % Load scores from file or initialize empty
            if isfile(app.scoreFile)
                D = load(app.scoreFile, 'scores');
                scores = D.scores;
            else
                scores = struct('name', {}, 'time', {}, 'difficulty', {});
            end

            % Filter scores by difficulty if needed
            filt = app.ScoreFilterDropDown.Value;
            if ~strcmp(filt, 'All')
                scores = scores(strcmp({scores.difficulty}, filt));
            end

            % Prepare table data for display
            if isempty(scores)
                data = {};
            else
                times = arrayfun(@(s) sprintf('%02d:%02d', floor(s.time / 60), mod(s.time, 60)), scores, 'UniformOutput', false)';
                data = [ {scores.name}' times {scores.difficulty}' ];
            end
            app.ScoresTable.Data = data; % Update table
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
                scores = struct('name', {}, 'time', {}, 'difficulty', {}); % Clear all
            else
                scores = scores(~strcmp({scores.difficulty}, filt)); % Remove selected
            end

            save(app.scoreFile, 'scores'); % Save updated scores
            app.showHighScores(); % Refresh display
        end

        % Hide all UI components and stop timer if running
        function hideAll(app)
            comps = {app.StartButton, app.SettingsButton, app.HighScoresButton, ...
                app.SettingsPanel, app.ScoresPanel, app.GamePanel, ...
                app.TimerLabel, app.MinesLabel};
            for c = comps
                c{1}.Visible = false; % Hide each component
            end

            % Hide timer and mine icons
            app.TimerIcon.Visible = false;
            app.MineIcon.Visible = false;

            % Stop and delete timer if running
            if ~isempty(app.timerObj) && isvalid(app.timerObj)
                stop(app.timerObj);
                delete(app.timerObj);
                app.timerObj = [];
            end

            % Reset game state flags
            app.firstClickDone = false;
            app.hasWon = false;
        end

        % Start a new game, initialize field and UI
        function startGame(app)
            app.hideAll(); % Hide all UI panels
            app.GamePanel.Visible = true; % Show game panel
            app.TimerLabel.Visible = true; % Show timer
            app.MinesLabel.Visible = true; % Show mines left

            % Show timer and mine icons
            app.TimerIcon.Visible = true;
            app.MineIcon.Visible = true;
            app.TimerLabel.Visible = true;
            app.MinesLabel.Visible = true;

            n = app.settings.gridSize; % Grid size
            app.field = zeros(n);                % Field: -1 for mines, >=0 for neighbor counts
            app.revealed = false(n);             % All cells hidden
            app.flagged = false(n);              % No flags
            app.remainingMines = app.settings.numMines; % Set mine count
            app.TimerLabel.Text = '00:00'; % Reset timer label
            app.MinesLabel.Text = sprintf('%d', app.remainingMines); % Reset mines label

            % Remove old grid and create new grid layout
            delete(app.GamePanel.Children); % Remove old grid
            app.gridLayout = uigridlayout(app.GamePanel, [n n]); % Create new grid
            app.gridLayout.RowHeight = repmat({'1x'}, 1, n);
            app.gridLayout.ColumnWidth = repmat({'1x'}, 1, n);
            app.gridLayout.RowSpacing = 1;
            app.gridLayout.ColumnSpacing = 1;
            app.buttons = gobjects(n^2, 1); % Preallocate button handles

            % Create grid buttons, each with left-click callback
            for i = 1:n
                for j = 1:n
                    b = uibutton(app.gridLayout, 'Text', '', ...
                        'ButtonPushedFcn', @(~, ~) app.onLeftClick(i, j)); % Left click
                    b.FontSize = 14;
                    b.UserData = [i j]; % Store cell coordinates
                    b.HorizontalAlignment = 'center';
                    app.buttons((i - 1) * n + j) = b; % Store button handle
                end
            end

            % Start timer
            app.startTime = tic; % Start timer
            app.timerObj = timer('ExecutionMode', 'fixedRate', 'Period', 1, ...
                'TimerFcn', @(~, ~) app.updateTimer()); % Timer callback
            start(app.timerObj); % Start timer

            app.onFigureResize(); % Adjust layout
        end

        % Update timer label every second
        function updateTimer(app)
            t = round(toc(app.startTime)); % Elapsed seconds
            m = floor(t / 60);             % Minutes
            s = mod(t, 60);                % Seconds
            app.TimerLabel.Text = sprintf('%02d:%02d', m, s); % Update label
        end

        % Handle left click: reveal cell, place mines if first click
        function onLeftClick(app, i, j)
            if ~app.firstClickDone
                app.placeMines(i, j); % Place mines after first click
                app.firstClickDone = true;
            end

            if app.flagged(i, j)
                return; % Ignore if flagged
            end

            if app.field(i, j) == -1
                % 1) Highlight the exact clicked mine
                idx = (i - 1) * app.settings.gridSize + j;
                btn = app.buttons(idx);
                btn.Icon = fullfile(app.iconFolder, 'mine.png');
                btn.Text = '';
                btn.BackgroundColor = [1 0 0]; % A deeper red for the fatal click
                btn.Enable = 'off';

                % 2) Reveal all the others in light red
                app.revealAllMines();

                % 3) Wait 3 seconds, then show Game Over
                t = timer( ...
                    'StartDelay', 3, ...
                    'ExecutionMode', 'singleShot', ...
                    'TimerFcn', @(~, ~) app.gameOver() ...
                );
                start(t);
                return;
            end

            app.revealCell(i, j); % Reveal cell
            app.checkWin();       % Check for win
        end

        % Handle right click: flag/unflag cell
        function onFigureClick(app)
            % Process right-clicks; capture events via WindowButtonDownFcn
            if ~strcmp(app.UIFigure.SelectionType, 'alt')
                return;
            end

            obj = app.UIFigure.CurrentObject; % Get clicked object
            % Only process if the object is a grid button
            if isempty(obj) || ~ismember(obj, app.buttons)
                return;
            end

            coords = obj.UserData; % Get cell coordinates
            i = coords(1);
            j = coords(2);
            if ~app.firstClickDone
                return; % Ignore if game not started
            end

            % Toggle flag using flag.png icon
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
            figPos = app.UIFigure.Position; % Get figure position
            margin = 10;                    % Margin size
            topSpace = 30;                  % Space for labels

            availW = figPos(3) - 2 * margin;           % Available width
            availH = figPos(4) - topSpace - 2 * margin;% Available height
            sz = min(availW, availH);                  % Square size
            panelX = (figPos(3) - sz) / 2;             % Center X
            panelY = margin;                           % Y position
            app.GamePanel.Position = [panelX, panelY, sz, sz]; % Set panel position

            % Add an x-offset to shift the labels to the right by 20 pixels
            offset = 50;
            timePos = app.TimerLabel.Position;         % Timer label position
            minesPos = app.MinesLabel.Position;        % Mines label position
            app.TimerLabel.Position = [panelX + offset, panelY + sz + 5, timePos(3), timePos(4)];
            app.MinesLabel.Position = [panelX + sz - minesPos(3) + offset, panelY + sz + 5, minesPos(3), minesPos(4)];
        end

        % Place mines randomly, avoiding first click and neighbors
        function placeMines(app, si, sj)
            n = app.settings.gridSize;     % Grid size
            m = app.settings.numMines;     % Number of mines
            allIdx = 1:n^2;                % All cell indices

            % Exclude first click and its neighbors
            [rs, cs] = ndgrid(max(si - 1, 1):min(si + 1, n), max(sj - 1, 1):min(sj + 1, n));
            forbid = sub2ind([n n], rs(:), cs(:)); % Forbidden indices
            avail = setdiff(allIdx, forbid);       % Available indices

            % Randomly select mine locations
            mines = avail(randperm(numel(avail), m));
            app.field(:) = 0;              % Reset field
            app.field(mines) = -1;         % Place mines

            % Compute neighbor mine counts for each cell
            for x = 1:n
                for y = 1:n
                    if app.field(x, y) == -1
                        continue; % Skip mines
                    end
                    blk = app.field(max(x - 1, 1):min(x + 1, n), max(y - 1, 1):min(y + 1, n));
                    app.field(x, y) = sum(blk(:) == -1); % Count neighboring mines
                end
            end

            % Ensure no mines in the zero-cascade "safe" region
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
                                queue(end + 1, :) = [nx ny]; %#ok<AGROW>
                            end
                        end
                    end
                end
            end

            % Find any mines that accidentally fell in that safe region
            mineIdx = find(app.field == -1);
            bad = mineIdx(safe(mineIdx));
            if ~isempty(bad)
                % Pick new spots outside safe & outside existing mines
                avail = find(~safe & app.field ~= -1);
                newMines = avail(randperm(numel(avail), numel(bad)));

                % Move them
                app.field(bad) = 0;
                app.field(newMines) = -1;

                % Recompute neighbor counts globally
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
            n = app.settings.gridSize; % Grid size
            if app.revealed(i, j)
                return; % Already revealed
            end

            app.revealed(i, j) = true; % Mark as revealed
            idx = (i - 1) * n + j;     % Button index
            b = app.buttons(idx);      % Button handle
            b.Enable = 'off';          % Disable button
            b.BackgroundColor = [.9 .9 .9]; % Set background
            b.FontColor = [0 0 0];          % Set font color

            if app.field(i, j) > 0
                b.Text = num2str(app.field(i, j)); % Show mine count
            else
                b.Text = ''; % No text for zero
                % Recursively reveal neighbors
                for di = -1:1
                    for dj = -1:1
                        ni = i + di;
                        nj = j + dj;
                        if ni >= 1 && ni <= n && nj >= 1 && nj <= n && ~app.revealed(ni, nj)
                            app.revealCell(ni, nj); % Reveal neighbor
                        end
                    end
                end
            end
        end

        % Reveal all mines on the field (after loss)
        function revealAllMines(app)
            % Correctly reveal all mines on the field after a fail condition
            n = app.settings.gridSize; % Grid size
            for x = 1:n
                for y = 1:n
                    if app.field(x, y) == -1
                        idx = (x - 1) * n + y; % Button index
                        btn = app.buttons(idx); % Button handle
                        btn.Icon = fullfile(app.iconFolder, 'mine.png');
                        btn.Text = '';
                        btn.BackgroundColor = [1 0 0]; % Highlight mines in red
                        btn.Enable = 'off';
                    elseif ~app.revealed(x, y) && ~app.flagged(x, y)
                        % Mark non-mine cells that were not revealed
                        idx = (x - 1) * n + y;
                        btn = app.buttons(idx);
                        btn.BackgroundColor = [0.9 0.9 0.9]; % Light gray
                        btn.Enable = 'off';
                    end
                end
            end
        end

        % Check for win: all non-mine cells revealed
        function checkWin(app)
            if app.hasWon
                return; % Already won
            end

            n = app.settings.gridSize; % Grid size
            if sum(app.revealed(:)) == n * n - app.settings.numMines
                app.hasWon = true; % Mark as won
                stop(app.timerObj); % Stop timer
                elapsed = round(toc(app.startTime)); % Get elapsed time
                name = inputdlg('You Won! Enter your name:', 'High Score', 1, {'Player'}); % Prompt for name
                if ~isempty(name)
                    app.saveScore(name{1}, elapsed); % Save score
                end
                app.showStartScreen(); % Return to menu
            end
        end

        % Handle game over: stop timer, show alert, return to menu
        function gameOver(app)
            if ~isempty(app.timerObj) && isvalid(app.timerObj)
                stop(app.timerObj);
                delete(app.timerObj);
                app.timerObj = [];
            end
            uialert(app.UIFigure, 'Game Over!', 'Boom!'); % Show alert
            app.showStartScreen(); % Return to menu
        end

        % Save a new high score to file, sorted by time
        function saveScore(app, name, time)
            if isfile(app.scoreFile)
                D = load(app.scoreFile, 'scores');
                sc = D.scores;
            else
                sc = struct('name', {}, 'time', {}, 'difficulty', {});
            end

            % Add new score
            sc(end + 1) = struct('name', name, 'time', time, 'difficulty', app.DifficultyDropDown.Value);

            % Sort scores by time (ascending)
            if ~isempty(sc)
                [~, o] = sort([sc.time]);
                sc = sc(o);
            end

            scores = sc; % Assign sorted scores
            save(app.scoreFile, 'scores'); % Save to file
        end
    end

    methods (Access = public)
        % Constructor: create UI and initialize app
        function app = MinesweeperApp
            % 1) Set iconFolder before we ever build any buttons:
            app.iconFolder = fullfile(fileparts(mfilename('fullpath')), 'Deps');
            
            % 2) Now build everything
            app.createComponents();
            registerApp(app, app.UIFigure);
            app.startupFcn();
        end

        % Destructor: clean up UI and timer
        function delete(app)
            if isvalid(app.UIFigure)
                delete(app.UIFigure); % Delete UI
            end
            if ~isempty(app.timerObj) && isvalid(app.timerObj)
                stop(app.timerObj);
                delete(app.timerObj);
            end
        end
    end
end
