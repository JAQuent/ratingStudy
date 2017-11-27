function [] = ratingStudy()
% % % % % % % % % % % % % % % % % % % % % % % % % 
% Rating study
% Author: Alexander Quent (alex.quent at mrc-cbu.cam.ac.uk)
% Version: 1.0
% % % % % % % % % % % % % % % % % % % % % % % % %
% To do:
% - pause function via escape
% - percentage display

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
    end
    nTrials   = length(fileNames);
    matrixDim = [21, nTrials/21];
    index1    = [];
    index2    = [];
    for i = 1:nTrials
        if ratingType == 'object'
            index1 = fileNames{i};
            index2 = 1;
        else
            splitStr = strsplit(fileNames{1}, '_');
            index1 = splitStr{1};
            index2 = splitStr{2};
        end
    end
    
    % Output variables
    if currentTrial > 1
    else
        objectRatings   = zeros(matrixDim(1), 1) -999;
        locationRatings = zeros(matrixDim(1), matrixDim(2)) - 999;
        RT              = zeros(matrixDim(1), matrixDim(2)) - 999;
    end
    

    % Get information about the screen and set general things
%     Screen('Preference', 'SuppressAllWarnings',0);
%     Screen('Preference', 'SkipSyncTests', 0);
    screens       = Screen('Screens');
    if length(screens) > 1 % Checks for the number of screens
        screenNum        = 1;
    else
        screenNum        = 0;
    end
    rect             = Screen('Rect', screenNum); % Gets the dimension of one screen
    screenSize       = [0 0 1000 900];
    screenPosition   = CenterRectOnPoint(screenSize,rect(3)/2, rect(4)/2); % Draws the window in the middle of one screen
%     refreshRate      = 1/Screen('FrameRate', screenNum); % refresh rate in secs
%     center           = round([rect(3) rect(4)]/2);
    
    
    questionPosition = 0.2;
    keyPosition      = 0.8;

    % RGB Colors 
    bgColor    = [255, 255, 255];

    % Relevant key codes
    KbName('UnifyKeyNames');
    space  = KbName('space');
    escape = KbName('ESCAPE');

    % Textures and text
%     fixLen              = 20; % Size of fixation cross in pixel
%     fixWidth            = 3; 
    
    % Trial information and temporal parameters
%     nTrial         = length(stimuliPictures);
%     fixDuration    = refreshRate*60;  % 1000 msec
%     waitTime       = 1000;


    % Response variables
%     RT             = zeros(nTrial, 6) - 99;
%     responses      = zeros(nTrial, 6) - 99;
%     correctness    = zeros(nTrial, 2) - 99;
%     results        = cell(nTrial, 33); 

    % Instruction
    lineLength    = 70;
    messageIntro1 = WrapString('Instructions \n\n For all decisions, you can take as much time as you need. At each trial you will be presented with a picture of an object. You need to answer whether you have seen this object in the virtual room you just have been in by pressing <<y>> for yes and <<n>> for no. \n\n If you pressed <<y>> for yes, you will need to indicate whether you recollected this by pressing <<r>> or whether this object was only familiar by pressing <<f>>. You recollected an object if you see it and recall specific details about it (e.g. the location and/or the orientation of the object, what it was next to in the room or what you thought about it when you saw it). This should not be confused with different degrees confidence in memory. The item was only familiar to you if you know that you have seen this, but you cannot tell where it was or anything else as such as a thought you had while you were seeing it. This feeling of familiarity may vary in strength, but crucially you pick it if you really do not recall anything else. Press the spacebar to continue.',lineLength);
    messageIntro2 = WrapString('If you pressed <<y>> for yes, you will have to choose the correct location of the objects out of 3 alternatives by pressing number at top of the keyboard that corresponds to the picture. The exact location in those pictures is marked by a red cube. If you pressed <<n>> for no earlier, you skip this decision. \n\n After this, you will be asked to indicate how confident you were with that decision on scale from 1 to 4 by pressing the corresponding key at the top of the keyboard. \n\n Then, you will have indicate how expected that location was for you by moving a slider on a scale and by clicking the left mouse button when you have reached that location. The last question is how expected is this object in this room regardless of whether you have seen it or not. Again, please move the slider on the scale (from unexpected to expected) to the point you feel is appropriate and press the left mouse button when you reached that point on the scale. \n\n ',lineLength);
    messageIntro3 = WrapString('Please press escape if you are ready to start block  #',lineLength);

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
%     HideCursor;

    % Creating trials
%     [objectNames, presented, room, relevancy, encodingCondition, retrievalCondition, firstLocation, secondLocation, thirdLocation] = textread(strcat('inputData/stimListRetrieval_', num2str(subNo),'.txt'),'%20s %n %20s %20s %20s %20s %n %n %n', 'delimiter','\t');

    % Loading stimuli
%     imageObjScale = 0.5;
%     imagesObj     = {};
%     stimuliObj    = {};
%     imageLocScale = 0.5;
%     imagesLoc     = {};
%     stimuliLoc    = {};
%     % Objects
%     for i = 1:length(objectNames)
%         imagesObj{i}  = imresize(imread(strcat('stimuli/', objectNames{i}, '.png')), imageObjScale);
%         stimuliObj{i} = Screen('MakeTexture', myScreen, imagesObj{i});
%     end
%     % Locations
%     for i = 1:length(stimuliLocations)
%         imagesLoc{i}  = imresize(imread(strcat('stimuli/', stimuliLocations{i}, '.png')), imageLocScale);
%         stimuliLoc{i} = Screen('MakeTexture', myScreen, imagesLoc{i});
%     end
%     imageLocSize   = size(imagesLoc{1});
%     shift          = 50;
%     leftPosition   = [center(1) - imageLocSize(2)*1.5 - shift, center(2) - imageLocSize(1)/2, center(1) - imageLocSize(2)*0.5 - shift, center(2) + imageLocSize(1)/2];
%     middlePosition = [center(1) - imageLocSize(2)*0.5, center(2) - imageLocSize(1)/2, center(1) + imageLocSize(2)*0.5, center(2) + imageLocSize(1)/2];
%     rightPosition  = [center(1) + imageLocSize(2)*0.5 + shift, center(2) - imageLocSize(1)/2, center(1) + imageLocSize(2)*1.5 + shift, center(2) + imageLocSize(1)/2];

%% Experimental loop
    for trial = 1:nTrial
        % Exercise and instruction
        length(stimuliObj)
        if trial == 1 && block == 1

            Screen('TextSize', myScreen, textSize(2)); % Sets size to instruction size
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
            DrawFormattedText(myScreen, horzcat(messageIntro3, num2str(block)), 'center', 'center');
            Screen('Flip', myScreen);
            KbReleaseWait;
            [~, ~, keyCode] = KbCheck; 
            while keyCode(escape) == 0 
                [~, ~, keyCode] = KbCheck;
            end
            
            % Specifiying font settings for trials
            Screen('TextColor', myScreen, [0 0 0]); % Sets to normal font color
            Screen('TextFont', myScreen, 'DejaVu'); % Sets normal font
            Screen('TextSize', myScreen, textSize(1)); % Sets size to normal
        else % Start message without instructions for subsequent blocks
            if trial == 1
                DrawFormattedText(myScreen, horzcat(messageIntro3, num2str(block)), 'center', 'center');
                Screen('Flip', myScreen);
                KbReleaseWait;
                [~, ~, keyCode] = KbCheck; 
                while keyCode(escape) == 0 
                    [~, ~, keyCode] = KbCheck;
                end

                % Specifiying font settings for trials
                Screen('TextColor', myScreen, [0 0 0]); % Sets to normal font color
                Screen('TextFont', myScreen, 'DejaVu'); % Sets normal font
                Screen('TextSize', myScreen, textSize(1)); % Sets size to normal
            end
        end
        %% Fixation cross
        Screen('DrawLine', myScreen, fixColor, center(1)- fixLen, center(2), center(1)+ fixLen, center(2), fixWidth);
        Screen('DrawLine', myScreen, fixColor, center(1), center(2)- fixLen, center(1), center(2)+ fixLen, fixWidth);
        fixOnset = Screen('Flip', myScreen);

        %% Item presentation
        DrawFormattedText(myScreen, 'Was this object in the virtual room?', 'center', rect(4)*questionPosition);
        DrawFormattedText(myScreen, '(Y)es or (N)o', 'center', rect(4)*keyPosition);
        Screen('DrawTexture', myScreen,  stimuliObj{trial}); 
        stimObjOnset = Screen('Flip', myScreen, fixOnset + fixDuration - slack);

        %% Yes/No answer
        [~, secs, keyCode] = KbCheck; % saves whether a key has been pressed, seconds and the key which has been pressed.
        while keyCode(YN(1)) == 0 && keyCode(YN(2)) == 0
            [~, secs, keyCode] = KbCheck;
        end
        stimObjOffset = Screen('Flip', myScreen);
        RT(trial, 1) = (secs - stimObjOnset)*1000;
        
        % Coding response recognition
        if keyCode(YN(1)) == 1
            responses(trial, 1) = 1;
        elseif keyCode(YN(2)) == 1
            responses(trial, 1) = 0;
        end
        
         % Checking accuracy recognition
        if presented(trial) == 1
            if responses(trial, 1) == 1
                correctness(trial, 1) = 1;
            else
                correctness(trial, 1) = 0;
            end
        else
            if responses(trial, 1) == 0
                correctness(trial, 1) = 1;
            else
                correctness(trial, 1) = 0;
            end
        end
        
        %% Remeber/Know
        if(responses(trial, 1) == 1)
            DrawFormattedText(myScreen, '(R)ecollected or (F)amiliar?', 'center', 'center');
            rkOnset = Screen('Flip', myScreen);
            [~, secs, keyCode] = KbCheck; % saves whether a key has been pressed, seconds and the key which has been pressed.
            while keyCode(RF(1)) == 0 && keyCode(RF(2)) == 0
                [~, secs, keyCode] = KbCheck;
            end
            rkOffset     = Screen('Flip', myScreen);
            RT(trial, 2) = (secs - rkOnset)*1000;
            rkPreTime    = (rkOffset - rkOnset)*1000; 

            % Coding Remember/know response
            if keyCode(RF(1)) == 1
                responses(trial, 2) = 1;
            elseif keyCode(RF(2)) == 1
                responses(trial, 2) = 0;
            end
        else
            RT(trial, 2)        = -99;
            responses(trial, 2) = -99;
            rkPreTime           = -99;
        end

        if(responses(trial, 1) == 1)
        %% Location presentation for 3AFC
            posShuffle = randomOrder(3, 3);
            AFCloc = [firstLocation(trial), secondLocation(trial), thirdLocation(trial)];
            AFCloc = AFCloc(posShuffle);
            Screen('DrawTexture', myScreen,  stimuliLoc{AFCloc(1)}, [], leftPosition);
            DrawFormattedText(myScreen, '1', (leftPosition(3) + leftPosition(1))/2, rect(4)*keyPosition);
            left = AFCloc(1);
            Screen('DrawTexture', myScreen,  stimuliLoc{AFCloc(2)}, [], middlePosition);
            DrawFormattedText(myScreen, '2', (middlePosition(3) + middlePosition(1))/2, rect(4)*keyPosition);
            middle = AFCloc(2);
            Screen('DrawTexture', myScreen,  stimuliLoc{AFCloc(3)}, [], rightPosition);
            DrawFormattedText(myScreen, '3', (rightPosition(3) + rightPosition(1))/2, rect(4)*keyPosition);
            right = AFCloc(3);
            AFCOnset = Screen('Flip',myScreen);

            % 3AFC
            [~, secs, keyCode] = KbCheck; % saves whether a key has been pressed, seconds and the key which has been pressed.
            while keyCode(AFC(1)) == 0 && keyCode(AFC(2)) == 0 && keyCode(AFC(3)) == 0
                [~, secs, keyCode] = KbCheck;
                % No criteria for skipping response
            end
            KbReleaseWait;
            RT(trial, 4)  = (secs - AFCOnset)*1000;
            AFCOffest = Screen('Flip',myScreen);
            AFCPreTime = (AFCOffest - AFCOnset)*1000;
            
            % Response coding 3AFC
            if keyCode(AFC(1)) == 1
                responses(trial, 4) = 1;
            elseif keyCode(AFC(2)) == 1
                responses(trial, 4) = 2;
            elseif keyCode(AFC(3)) == 1
                responses(trial, 4) = 3; 
            end

            % Checking accuracy 3AFC
            if AFCloc(responses(trial, 4)) == firstLocation(trial)
                correctness(trial, 2) = 1;
            else
                correctness(trial, 2) = 0;
            end
            
            selLoc = AFCloc(responses(trial, 4));

            %% Confidence rating
            DrawFormattedText(myScreen, 'How confident are you \n from a scale from 1 to 4?', 'center', 'center');
            conOnset = Screen('Flip', myScreen);
            [~, secs, keyCode] = KbCheck; % saves whether a key has been pressed, seconds and the key which has been pressed.
            while keyCode(CON(1)) == 0 && keyCode(CON(2)) == 0 && keyCode(CON(3)) == 0 && keyCode(CON(4)) == 0
                [~, secs, keyCode] = KbCheck;
            end
            conOffset = Screen('Flip', myScreen);
            RT(trial, 5) = (secs - conOnset)*1000;
            conPreTime = (conOffset - conOnset)*1000;    
            
            % Coding confidence response
            if keyCode(CON(1)) == 1
                responses(trial, 5) = 1;
            elseif keyCode(CON(2)) == 1
                responses(trial, 5) = 2;
            elseif keyCode(CON(3)) == 1
                responses(trial, 5) = 3;
            elseif keyCode(CON(4)) == 1
                responses(trial, 5) = 4;
            end


            %% Rate expectedness of location
            [responses(trial, 6), RT(trial, 6)] = slideScale(myScreen, 'How expected was the location you chose?', rect, {'unexpected', 'expected'}, 'device', 'mouse', 'scalaposition', 0.9, 'aborttime', waitTime);
        else %If the participants does not recognize the time as old, all these variables become -99.
            AFCPreTime            = -99;
            left                  = -99;
            middle                = -99;
            right                 = -99;
            RT(trial, 4)          = -99;
            responses(trial, 4)   = -99;
            correctness(trial, 2) = -99;
            conPreTime            = -99;
            RT(trial, 5)          = -99;
            responses(trial, 5)   = -99;
            responses(trial, 6)   = -99;
            RT(trial, 6)          = -99;
            selLoc                = -99;
        end
        
        %% Rate object expectedness
        WaitSecs(0.3); % Wait 300 msec to allow for button relase. 
        [responses(trial, 3), RT(trial, 3)] = slideScale(myScreen, horzcat('How expected is this object for a ',room{1},'?'), rect, {'unexpected', 'expected'}, 'device', 'mouse', 'scalaposition', 0.9, 'aborttime', waitTime);
        
        %% Saving data to file
        % [objectNames, presented, room, relevancy, encodingLocation, retrievalCondition, firstLocation, secondLocation, thirdLocation
        % ('subNo', 'date', 'time', 'trial', 'room','objectName', 'presented', 'relevancy', 'encodingCon', 'retrievalCon', 'fixPreTime', 'objPreTime', 'rtYN', 'resYN', 'accYN','rkPreTime', 'rtRK', 
        % 'resRK', 'objRate', 'rtObjRate', 'AFCPreTime', 'rtAFC', 'resAFC', 'accAFC', 'left' ,'middle', 'right', 'conPreTime', 'rtCON', 'resCON', 'locRate', 'rtLocRate', 'corrLoc', 'selLoc')
        fprintf(datafilepointer,'%i %i %i %i %s %s %i %s %s %s %f %f %f %i %i %f %f %i %f %f %f %f %i %i %i %i %i %f %f %i %f %f %i %i\n', ...
            subNo,...
            date,...
            time,...
            trial,...
            room{1},...
            objectNames{trial},...
            presented(trial),...
            relevancy{trial},...
            encodingCondition{trial},...
            retrievalCondition{trial},...
            (stimObjOnset - fixOnset)*1000,...
            (stimObjOffset - stimObjOnset)*1000,...
            RT(trial, 1),... 
            responses(trial, 1),...
            correctness(trial, 1),...
            rkPreTime,...
            RT(trial, 2),...
            responses(trial, 2),...
            responses(trial, 3),...
            RT(trial, 3),...
            AFCPreTime,...
            RT(trial, 4),...
            responses(trial, 4),...
            correctness(trial, 2),...
            left,...
            middle,...
            right,...
            conPreTime,...
            RT(trial, 5),...
            responses(trial, 5),...
            responses(trial, 6),...
            RT(trial, 6),...
            firstLocation(trial),...
            selLoc);
%         
        % Save everything in a varibles that is saved at the end. 
        results{trial, 1}  = subNo;
        results{trial, 2}  = date;
        results{trial, 3}  = time;
        results{trial, 4}  = trial;
        results{trial, 5}  = room{1};
        results{trial, 6}  = objectNames{trial};
        results{trial, 7}  = presented(trial);
        results{trial, 8}  = relevancy{trial};
        results{trial, 9}  = encodingCondition{trial};
        results{trial, 10} = retrievalCondition{trial};
        results{trial, 11} = (stimObjOnset - fixOnset)*1000;
        results{trial, 12} = (stimObjOffset - stimObjOnset)*1000;
        results{trial, 13} = RT(trial, 1);
        results{trial, 14} = responses(trial, 1);
        results{trial, 15} = correctness(trial, 1);
        results{trial, 16} = rkPreTime;
        results{trial, 17} = RT(trial, 2);
        results{trial, 18} = responses(trial, 2);
        results{trial, 19} = responses(trial, 3);
        results{trial, 20} = RT(trial, 3);
        results{trial, 21} = AFCPreTime;
        results{trial, 22} = RT(trial, 4);
        results{trial, 23} = responses(trial, 4);
        results{trial, 24} = correctness(trial, 2);
        results{trial, 25} = left;
        results{trial, 26} = middle;
        results{trial, 27} = right;
        results{trial, 28} = conPreTime;
        results{trial, 29} = RT(trial, 5);
        results{trial, 30} = responses(trial, 5);
        results{trial, 31} = responses(trial, 6);
        results{trial, 32} = RT(trial, 6);
        results{trial, 33} = firstLocation(trial);
        results{trial, 34} = selLoc;
    end
    %% End of experiment
    % Saving .m files and closing files
    save(mSave, 'results');
    save(mSaveALL);
    fclose('all');

    % End Screen
    Screen('TextColor', myScreen, [0 0 0]); % Sets to normal font color
    Screen('TextFont', myScreen, 'DejaVu'); % Sets normal font
    Screen('TextSize', myScreen, textSize(2)); % Sets size to instruction size
    DrawFormattedText(myScreen, horzcat('End of experiment. Thank you for your participation. \n Please wait for the last instructions.'), 'center', 'center');
    Screen('Flip', myScreen);
    [~, ~, keyCode] = KbCheck; 
    while keyCode(escape) == 0 
        [~, ~, keyCode] = KbCheck;
    end

    Screen('CloseAll')
catch
    rethrow(lasterror)
    fclose('all');
    % Saving .m files and closing files
    save(mSave, 'results');
    save(mSaveALL);
    Screen('CloseAll')
end
end

