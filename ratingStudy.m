function [] = ratingStudy(subNo)
% % % % % % % % % % % % % % % % % % % % % % % % % 
% Rating study (Post encoding)
% Author: Alexander Quent (alex.quent at mrc-cbu.cam.ac.uk)
% Version: 1.0
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
    
    % Input variables
    [fileNames, questions] = textread('stimuli/questions.txt', '%20s %100s', 'delimiter', '\t');
    nTrial                 = length(fileNames);
    shuffle                = randomOrder(nTrial, nTrial);
    fileNames              = fileNames(shuffle);
    questions              = questions(shuffle);
    
    % This bit parses objects and locations
    objects   = [];
    locations = [];
    for i = 1:nTrial
        splitStr     = strsplit(fileNames{i}, '_');
        objects(i)   = str2double(splitStr{1}); % Object
        locations(i) = str2double(splitStr{2}); % Location
    end
    
    % Output variables & files
    filePointer = fopen(strcat('data/ratingStudy_' , num2str(subNo),'.dat'),'wt'); % opens ASCII file for writing
    mSave       = strcat('data/ratingStudy_', num2str(subNo),'.mat'); % name of another data file to write to (in .mat format)
    mSaveALL    = strcat('data/ratingStudy_', num2str(subNo),'all.mat'); % name of another data file to write to (in .mat format)
    

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
    % Relevant key codes
    KbName('UnifyKeyNames');
    space  = KbName('space');
    escape = KbName('ESCAPE');

    % Colors, sizes, instrurctions
    bgColor       = [255 255 255];
    textSize      = [20 20];
    lineLength    = 60;
    ITI           = 0.5;
    messageIntro1 = WrapString('Rating study \n\n Your task is to rate the expectancy of specific objects at specific locations in a kitchen. A generally unexpected object may be more or less expected depending on the location. The scale ranges from unexpected (-100) to expected (100). Move your mouse to move the slider across the scale. You have seen all objects in the previous part of the experiment. \n\n Press spacebar to start.',lineLength);
    endPoints     = {'unexpected', 'expected'};

    % Opening window and setting preferences
    try
        [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor);
    catch
        try
            [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor);
        catch
            try
                [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor);
            catch
                try
                    [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor);
                catch
                    [myScreen, rect]    = Screen('OpenWindow', screenNum, bgColor);
                end
            end
        end
    end

    % Loading stimuli
    for i = 1:length(fileNames)
        images{i}  = imresize(imread(strcat('stimuli/', fileNames{i}, '.png')), 0.5);
    end

%% Experimental loop
    for trial = 1:nTrial
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
        end 
        %% Trial
        [position, RT] = slideScale(myScreen, questions{trial}, rect, endPoints, 'device', 'mouse', 'image', images{trial},'scalaposition', 0.9, 'startposition', 'center', 'displayposition', true, 'aborttime', 200);

        %% Saving data
        fprintf(filePointer,'%i %i %i %i %i %i %f %f\n', ...
            subNo,...
            date,...
            time,...
            trial,...
            objects(trial),...
            locations(trial),...
            position,...
            RT);
        
        results{trial, 1} = subNo;
        results{trial, 2} = date;
        results{trial, 3} = time;
        results{trial, 4} = trial;
        results{trial, 5} = objects(trial);
        results{trial, 6} = locations(trial);
        results{trial, 7} = position;
        results{trial, 8} = RT;
        
        %% ITI
        Screen('Flip', myScreen);
        WaitSecs(ITI);
    end          
       
    %% End of experiment
    Screen('TextSize', myScreen, textSize(1)); % Sets size to instruction size
    DrawFormattedText(myScreen, horzcat('End of experiment. Thank you for your participation. \n Please press escape to leave.'), 'center', 'center');
    Screen('Flip', myScreen); 
    [~, ~, keyCode] = KbCheck; 
    while keyCode(escape) == 0 
        [~, ~, keyCode] = KbCheck;
    end

    clearvars images
    fclose('all');
    save(mSave, 'results');
    save(mSaveALL);
    Screen('CloseAll')
catch
    rethrow(lasterror)
    clearvars images
    fclose('all');
    Screen('CloseAll')
end
end