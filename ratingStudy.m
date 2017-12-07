function [] = ratingStudy(subNo)
% % % % % % % % % % % % % % % % % % % % % % % % % 
% Rating study
% Author: Alexander Quent (alex.quent at mrc-cbu.cam.ac.uk)
% Version: 1.0
% % % % % % % % % % % % % % % % % % % % % % % % %

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
    subNo = num2str(subNo);
    
    % Input variables
    [ratingType, fileNames, questions] = textread(strcat('stimuli/questions', subNo, '.txt'),'%10s %20s %100s', 'delimiter','\t');
    [currentTrial, finished] = textread(strcat('log', subNo, '.txt'),'%n %n', 'delimiter','\t');
    if finished == 1
        error('You are already finished with the task. Please send me results.')
    else
        logPointer   = fopen(strcat('log', subNo, '.txt'), 'w');
        mSave        = strcat('data/ratingStudy_', subNo,'.mat'); % name of another data file to write to (in .mat format)
        mSaveALL     = strcat('data/ratingStudy_', subNo,'all.mat'); % name of another data file to write to (in .mat format)
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
        load(strcat('data/ratingStudy_', num2str(subNo), '.mat'))
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

    % Colors, sizes, instrurctions
    bgColor       = [255 255 255];
    textSize      = [20 20];
    lineLength    = 60;
    messageIntro1 = WrapString('Rating study \n\n Your task is to rate the expectancy of twenty objects in a kitchen and to rate the expectancy of certain locations within a particular kitchen for each object. The scale ranges from unexpected (-100) to expected (100). Move your mouse to move the slider across the scale. You have to rate 420 objects/locations. You are able to pause the experiment after each trial, so you don’t have to do that in one go. After completion, just send me your results. Thank you so much for your help. Press spacebar to start the experiment.',lineLength);
    endPoints     = {'unexpected', 'expected'};

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
        if length(fileNames{i}) < 7
            images{i}  = imresize(imread(strcat('stimuli/', fileNames{i}, '.png')),0.6987);
        else
            images{i}  = imresize(imread(strcat('stimuli/', fileNames{i}, '.png')), 0.5);
        end
    end

%% Experimental loop
    for trial = currentTrial:nTrial
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

            % Specifiying font settings for experimental trials
            Screen('TextSize', myScreen, textSize(2)); % Sets size to normal
        end 
        %% Trial
        [position, RT] = slideScale(myScreen, questions{trial}, rect, endPoints, 'device', 'keyboard', 'image', images{trial},'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true, 'aborttime', 20);
        if strcmp(ratingType{trial}, 'object')
            objectRatings(index1(trial), index2(trial))   = position;
            objectRT(index1(trial), index2(trial))        = RT;
        else
            locationRatings(index1(trial), index2(trial)) = position;
            locationRT(index1(trial), index2(trial))      = RT;
        end
        
        % Update files
        logPointer   = fopen(strcat('log', subNo, '.txt'), 'w');
        fprintf(logPointer,'\r%4d %4d', trial, finished);
        dlmwrite(strcat('data/objectRatings_' , num2str(subNo),'.dat'), objectRatings, 'delimiter', '\t', 'precision', 6);
        dlmwrite(strcat('data/locationRatings_' , num2str(subNo),'.dat'), locationRatings, 'delimiter', '\t', 'precision', 6);
        dlmwrite(strcat('data/objectRT_' , num2str(subNo),'.dat'), objectRT, 'delimiter', '\t', 'precision', 6);
        dlmwrite(strcat('data/locationRT_' , num2str(subNo),'.dat'), locationRT, 'delimiter', '\t', 'precision', 6);
        
        % Escape or continue
        DrawFormattedText(myScreen, strcat('Press space to continue or esacpe to pause experiment. \n Progress: ', num2str(round(trial/nTrial, 2)*100), ' %'), 'center', 'center');
        Screen('Flip', myScreen);
        KbReleaseWait;
        [~, ~, keyCode] = KbCheck; 
        while keyCode(escape) == 0 && keyCode(space) == 0
            [~, ~, keyCode] = KbCheck;
        end
        if keyCode(escape) == 1
            break
        end
        
    end          
       
    %% End of experiment
    if trial == nTrial
        finished = 1;
        Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
        DrawFormattedText(myScreen, horzcat('End of experiment. Thank you for your participation. \n Please press escape to leave.'), 'center', 'center');
        Screen('Flip', myScreen); 
        [~, ~, keyCode] = KbCheck; 
        while keyCode(escape) == 0 
            [~, ~, keyCode] = KbCheck;
        end
    else
        Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
        DrawFormattedText(myScreen, horzcat('The experiment has been paused. You can continue later. \n Please press escape to leave.'), 'center', 'center');
        Screen('Flip', myScreen); 
        [~, ~, keyCode] = KbCheck; 
        while keyCode(escape) == 0 
            [~, ~, keyCode] = KbCheck;
        end
    end
    logPointer   = fopen(strcat('log', subNo, '.txt'), 'w');
    fprintf(logPointer,'\r%4d %4d', trial, finished);
    fclose('all');
    save(mSave, 'objectRatings', 'objectRT','locationRatings','locationRT');
    save(mSaveALL);
    

    Screen('CloseAll')
catch
    logPointer   = fopen(strcat('log', subNo, '.txt'), 'w');
    fprintf(logPointer,'\r%4d %4d', trial, finished);
    fclose('all');
    rethrow(lasterror)
    Screen('CloseAll')
end
end

