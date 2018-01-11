function [] = ratingStudy(subNo)
% % % % % % % % % % % % % % % % % % % % % % % % % 
% Rating study
% Author: Alexander Quent (alex.quent at mrc-cbu.cam.ac.uk)
% Version: 1.1
% % % % % % % % % % % % % % % % % % % % % % % % %

%% Explanations
% To run just call function with the respective subject number. 
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
        fprintf(logPointer,'\r%4d %4d', 1, 0);
        mSave        = strcat('data/ratingStudy_', subNo,'.mat'); % name of another data file to write to (in .mat format)
        mSaveALL     = strcat('data/ratingStudy_', subNo,'all.mat'); % name of another data file to write to (in .mat format)
    end
    nTrial      = length(fileNames);
    nPracTrial  = 8;
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
            index1(i) = str2double(splitStr{1}); % Object
            index2(i) = str2double(splitStr{2}); % Location
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
    messageIntro1 = WrapString('Rating study \n\n First, your task is to rate the expectancy of specific objects at specific locations in a kitchen. A generally unexpected object may be more or less expected depending on the location. The scale ranges from unexpected (-100) to expected (100). Move your mouse to move the slider across the scale. You have to rate 400 objects/locations. After completing those, you will be asked again to rate the general expectancy of the objects in a kitchen. \n\n You are able to pause the experiment after each trial, so you don’t have to do that in one go. After completion, just send me your results. Thank you so much for your help. To calibriate your object/location ratings, you will start with eight practice trials with representative objects and locations. Press spacebar to start the practice run.',lineLength);
    messageIntro2 = WrapString('End of practice \n\n Press spacebar to start the experiment.',lineLength);
    messageIntro3 = WrapString('Object ratings \n\n Press spacebar to continue.',lineLength);
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

    % Loading stimuli
    pracQuestions = {'How expected are these peppers in that location?', 'How expected is that wrench in that location?', 'How expected in this dumbbell in that location?', 'How expected are these peppers in that location?', 'How expected in this dumbbell in that location?', 'How expected is this pot in that location?', 'How expected is this pot in that location?', 'How expected is this wrench in that location?'};
    for i = 1:nPracTrial
        pracImages{i} = imresize(imread(strcat('stimuli/prac', num2str(i), '.png')),0.6987);
    end
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
            % Page 1
            Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
            DrawFormattedText(myScreen, messageIntro1, 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
            while keyCode(space) == 0 
                [~, ~, keyCode] = KbCheck;
            end

            Screen('TextSize', myScreen, textSize(2)); % Sets size to normal
            
            %Practice
            for pracTrial = 1:nPracTrial
                slideScale(myScreen, pracQuestions{pracTrial}, rect, endPoints, 'device', 'mouse', 'image', pracImages{pracTrial},'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true, 'aborttime', 200);
            
                % Escape or continue
                DrawFormattedText(myScreen, strcat('Press space to continue or esacpe to pause experiment. \n Progress: ', num2str(round(trial/nTrial, 2)*100), ' %'), 'center', 'center');
                Screen('Flip', myScreen);
                KbReleaseWait;
                [~, ~, keyCode] = KbCheck; 
                while keyCode(escape) == 0 && keyCode(space) == 0
                    [~, ~, keyCode] = KbCheck;
                end
            end
            
            clearvars pracImages % deletes extraneous variable
            
            % Page 2
            Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
            DrawFormattedText(myScreen, messageIntro2, 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
            while keyCode(space) == 0 
                [~, ~, keyCode] = KbCheck;
            end

            Screen('TextSize', myScreen, textSize(2)); % Sets size to normal
        elseif trial == 401
            % Page 2
            Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
            DrawFormattedText(myScreen, messageIntro3, 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
            while keyCode(space) == 0 
                [~, ~, keyCode] = KbCheck;
            end

            Screen('TextSize', myScreen, textSize(2)); % Sets size to normal
        end 
        %% Trial
        [position, RT] = slideScale(myScreen, questions{trial}, rect, endPoints, 'device', 'mouse', 'image', images{trial},'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true, 'aborttime', 200);
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
    clearvars images
    logPointer   = fopen(strcat('log', subNo, '.txt'), 'w');
    fprintf(logPointer,'\r%4d %4d', trial, finished);
    fclose('all');
    save(mSave, 'objectRatings', 'objectRT','locationRatings','locationRT');
    save(mSaveALL);
    Screen('CloseAll')
catch
    rethrow(lasterror)
    clearvars images
    fclose('all');
    Screen('CloseAll')
end
end