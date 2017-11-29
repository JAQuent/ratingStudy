function [] = ratingStudy()
% % % % % % % % % % % % % % % % % % % % % % % % % 
% Rating study
% Author: Alexander Quent (alex.quent at mrc-cbu.cam.ac.uk)
% Version: 1.0
% % % % % % % % % % % % % % % % % % % % % % % % %
% To do:
% - pause function via escape
% - percentage display
% - write to log file

%% Explanations

try
%% Setting everuthing up
    % Preliminary stuff
    % Clear Matlab/Octave window:
    clc;

    % check for Opengl compatibility, abort otherwise:
    AssertOpenGL;

    % Reseed randomization
    rand('state', sum(100*clock));

    % General information about subject and session
    date  = str2double(datestr(now,'yyyymmdd'));
    time  = str2double(datestr(now,'HHMMSS'));
    
    % Input variables
    [ratingType, fileNames, questions] = textread(strcat('stimuli/questions.txt'),'%10s %20s %100s', 'delimiter','\t');
    [subNo, currentTrial, finished] = textread('log.txt','%n %n %n', 'delimiter','\t');
    if finished == 1
        error('You are already finished with the task. Please send me results.')
    else
        logPointer   = fopen('log.txt', 'w');
        mSave        = strcat('data/ratingStudy',num2str(subNo),'.mat'); % name of another data file to write to (in .mat format)
        mSaveALL     = strcat('data/ratingStudy',num2str(subNo),'all.mat'); % name of another data file to write to (in .mat format)
    end
    nTrial     = length(fileNames);
    numObject   = nTrial/21;
    numLocation = 20;
    matrixDim   = [numObject, numLocation];
    index1      = [];
    index2      = [];
    % This bit parses whether the question (object vs. location) needs one
    % or two indices for the respective matrix.
    for i = 1:nTrial
        if strcmp(ratingType{i}, 'object')
            index1(i) = str2double(fileNames{i});
            index2(i) = 1;
        else
            splitStr = strsplit(fileNames{i}, '_');
            index1(i) = str2double(splitStr{1});
            index2(i) = str2double(splitStr{2});
        end
    end
    
    % Output variables
    if currentTrial > 1
        load(strcat('data/ratingStudy', num2str(subNo), '.mat'))
    else
        objectRatings   = zeros(numObject, 1) -999;
        locationRatings = zeros(matrixDim(1), matrixDim(2)) - 999;
        objectRT        = zeros(numObject, 1) - 999;
        locationRT      = zeros(matrixDim(1), matrixDim(2)) - 999;
    end
    

    % Get information about the screen and set general things
    Screen('Preference', 'SuppressAllWarnings',0);
    Screen('Preference', 'SkipSyncTests', 0);
    screens       = Screen('Screens');
    if length(screens) > 1 % Checks for the number of screens
        screenNum        = 1;
    else
        screenNum        = 0;
    end
    rect             = Screen('Rect', screenNum); % Gets the dimension of one screen
    screenSize       = [0 0 1000 900];
    screenPosition   = CenterRectOnPoint(screenSize,rect(3)/2, rect(4)/2); % Draws the window in the middle of one screen

    % Relevant key codes
    KbName('UnifyKeyNames');
    space  = KbName('space');
    escape = KbName('ESCAPE');

    % Colors, sizes, instrurctions and times
    bgColor       = [255 255 255];
    textSize      = [20 20];
    lineLength    = 70;
    messageIntro1 = WrapString('Instructions \n\n bla',lineLength);
    messageIntro2 = WrapString('bla',lineLength);
    messageIntro3 = WrapString('Please press escape if you are ready to start.', lineLength);
    endPoints     = {'unexpected', 'expected'};
    ISI           = 0.2;

    % Opening window and setting preferences
    try
        [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor, screenPosition);
    catch
        try
            [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor, screenPosition);
        catch
            try
                [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor, screenPosition);
            catch
                try
                    [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor, screenPosition);
                catch
                    [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor, screenPosition);
                end
            end
        end
    end
    slack       = Screen('GetFlipInterval', myScreen)/2; % Getting lack for accurate timing

    % Loading stimuli
    for i = 1:length(fileNames)
        images{i}  = imread(strcat('stimuli/', fileNames{i}, '.jpg'));
    end

%% Experimental loop
    for trial = 1:nTrial
        % Exercise and instruction
        if trial == 1
            Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
            % Page 1
            DrawFormattedText(myScreen, messageIntro1, 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
            while keyCode(space) == 0 
                [~, ~, keyCode] = KbCheck;
            end

            % Page 2
            DrawFormattedText(myScreen, messageIntro2, 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
            while keyCode(space) == 0 
                [~, ~, keyCode] = KbCheck;
            end

            % Page 3
            DrawFormattedText(myScreen, messageIntro3, 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
              while keyCode(escape) == 0 
                [~, ~, keyCode] = KbCheck;
            end
            
            % Specifiying font settings for experimental trials
            Screen('TextSize', myScreen, textSize(2)); % Sets size to normal
        end
        %% Trial
        [position, RT] = slideScale(myScreen, questions{trial}, rect, endPoints, 'device', 'mouse', 'image', images{trial},'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true);
        if strcmp(ratingType{trial}, 'object')
            objectRatings(index1(trial), index2(trial))   = position;
            objectRT(index1(trial), index2(trial))        = RT;
        else
            locationRatings(index1(trial), index2(trial)) = position;
            locationRT(index1(trial), index2(trial))      = RT;
        end
        
        % Blank ISI
        onsetISI = Screen('Flip', myScreen);
        Screen('Flip', myScreen, onsetISI + ISI - slack)
        
        % Update files
        logPointer   = fopen('log.txt', 'w');
        fprintf(logPointer,'%d %d %d', subNo, trial, finished);
        dlmwrite('objectRatings.dat', objectRatings, '\t');
        
        
    end
       
    %% End of experiment
    finished = 1;
    fclose('all');
    
    Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
    DrawFormattedText(myScreen, horzcat('End of experiment. Thank you for your participation. \n Please press escape to leave.'), 'center', 'center');
    Screen('Flip', myScreen);
    [~, ~, keyCode] = KbCheck; 
    while keyCode(escape) == 0 
        [~, ~, keyCode] = KbCheck;
    end

    Screen('CloseAll')
catch
    rethrow(lasterror)
    Screen('CloseAll')
end
end
