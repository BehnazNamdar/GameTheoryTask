%% Game Theory Task in MRI 

%% clear and get path
clearvars; clc;
f    = filesep;
p    = uigetdir;
addpath(genpath([p f 'suppl']));

%% settings - session settings
% dialogue input box to get session info
prompt         = {'Experimenter:',...
                  'Block:',...
                  'Player 1:',...
                  'Player 2:'};
dlgtitle       = 'Session Info ';
dims           = [1 35];
definput       = {'Bayat','1','behnaz','panir'};
opts           = 'on';

answer         = inputdlg(prompt, dlgtitle, dims, definput);
expName        = answer{1};
block          = str2num(answer{2});
player1        = answer{3};
player2        = answer{4};

%% settings - trial numbers & return strategy
trialNums     = 25;
switch block
    case 1
        state = 'stateRT1';
        returnStrategy = 1; % Cooperative
        payStrategy = [];
    case 2 
        state = 'stateRT1';
        returnStrategy = 2; % Noncooperative
        payStrategy = [];
    case 3 
        state = 'stateT4';
        payStrategy = 1;   % Cooperative 
        returnStrategy = [];
    case 4 
        state = 'stateT4';
        payStrategy = 2;   % Noncooperative
        returnStrategy = [];
end
   
%% settings - time variables
tOpponFix = 3;
tOpponIntro = 3;
tCue = 0.75;
maxRT1 = 6;
maxRT2 = 6;
T1 = 2 * ones(1,trialNums);
T2 = 2 * ones(1,trialNums);
T3 = 2 * ones(1,trialNums);
T4 = 2 * ones(1,trialNums);
T5 = 2 * ones(1,trialNums);

%% settings - reserved variables
P1Deposit = 10;      % set initial value of deposit for player 1
P2Deposit = 10;      % set initial value of deposit for player 2
% x;              % deposit time(now) - deposit time(previous)
% tempoP1Reserve; % temporal value of deposit for player 1 during task
% tempoP2Reserve; % temporal value of deposit for player 2 during task

%% settings - return strategy / payStrategy

if returnStrategy == 1
        % Cooperative
        percentGenerous = .25;  
        percentRecip    = .5;
        percentSelfish  = .25;
        
        nGenerous = round(trialNums * percentGenerous);
        nRecip    = round(trialNums * percentRecip);
        nSelfish  = round(trialNums * percentSelfish);
        
        index         = Shuffle([1:trialNums]);
        returnArray(index(1 : nGenerous))                  = "g";
        returnArray(index(nGenerous+1 : nGenerous+nRecip)) = "r";
        returnArray(index(nGenerous + nRecip + 1 : end))   = "s";

elseif returnStrategy == 2    
            % Noncooperative
        percentGenerous = .25;  
        percentRecip    = .25;
        percentSelfish  = .5;
        
        nGenerous = round(trialNums * percentGenerous);
        nRecip = round(trialNums * percentRecip);
        nSelfish = round(trialNums * percentSelfish);
        
        index         = Shuffle([1:trialNums]);
        returnArray(index(1 : nGenerous))                  = "g";
        returnArray(index(nGenerous+1 : nGenerous+nRecip)) = "r";
        returnArray(index(nGenerous + nRecip + 1 : end))   = "s";
       
end

%% settings - screen parameters and variables 
% Removes the blue screen flash and minimize extraneous warnings.
% Screen('Preference', 'VisualDebugLevel', 3);
% Screen('Preference', 'SuppressAllWarnings', 1);
% Screen('Preference', 'SkipSyncTests', 1);

screenNumber       = max(Screen('Screens'));
[width, height]    = Screen('WindowSize',screenNumber);
winRect            = [0 0 width-500 height-400];
winColor           = BlackIndex(window);   % Set color of window to black
[wPtr,rect]        = Screen('OpenWindow',screenNumber, winColor, winRect);
Screen('Preference', 'TextRenderer', 1);
Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   % has no effect on text rendering, used below for semi-transparent bounding boxes
Screen('Preference', 'TextAntiAliasing', 2);
colorBox           = 255;

%% set texts format
txtSizFix        = 80;
txtSiz           = 30;
Screen('TextFont',wPtr,'Calibri');
Screen('TextSize',wPtr,txtSizFix);
Screen('TextStyle',wPtr,1); % Bold font style

txtColor         = 255;
txtColorFlash    = 0;
ListenChar(2);

%% settings - load png files

% read and make png files
backgrnd_  = imread(fullfile(p,'suppl','backgroundBlack1.png'));
backgrnd   = imresize(backgrnd_,[winRect(4),winRect(3)]);
oppoPic   = imresize(imread(fullfile(p,'suppl','opponent2.png')),[350,250]);
backgrnd  = Screen('MakeTexture',wPtr,backgrnd);
oppoPic   = Screen('MakeTexture',wPtr,oppoPic);

%% settings - rate of scaling images
[ h , w ] = size(backgrnd_,[1 2]);
rateScreen_H = winRect(4) / h; % use for y 
rateScreen_W = winRect(3)  / w;  % use for x 
rectThickness = 4; % pixel

% size of two deposit cylandrs 
rect1_X1 = (294+rectThickness)* rateScreen_W;     rect1_Y1 = (110+rectThickness)* rateScreen_H;
rect1_X2 = (399-rectThickness)* rateScreen_W;     rect1_Y2 = (691-rectThickness)* rateScreen_H;

rect2_X1 = (883+rectThickness)* rateScreen_W;     rect2_Y1 = (110+rectThickness)* rateScreen_H;
rect2_X2 = (988-rectThickness)* rateScreen_W;     rect2_Y2 = (691-rectThickness)* rateScreen_H;
pxPerAmount = (rect1_Y2 - rect1_Y1 ) / 40;

% boxes sizes
box1_X1 = rect1_X1;  box1_X2 = rect1_X2; box1_Y2 = rect1_Y2; % box1_Y1 will be defined in the loop
box2_X1 = rect2_X1;  box2_X2 = rect2_X2; box2_Y2 = rect2_Y2; % box2_Y1 will be defined in the loop
        
% text box beside box 
txtbox1X = rect1_X2 + 10;  %txtbox1Y = box1_Y1;  % will be defined in the loop
txtbox2X = rect2_X1 - 50;  %txtbox2Y = box2_Y1;  % will be defined in the loop

txtFlshX  = 644 * rateScreen_W;
txtFlshY1 = 453 * rateScreen_H; 
txtFlshY2 = 548 * rateScreen_H; 

%% settings - texts content
txtOpponFix = '+';
txtWaiting = '*';
txtCue = 'X';
txtITI = '+';

%% settings - input device - keyboard
% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');
KbDeviceIndex = [];
upKey         = KbName('UpArrow');
downKey       = KbName('DownArrow');
enterKey      = KbName('Return');
exitKey       = KbName('ESCAPE');

%% experiment running

%% Display Opponent intro 

DrawFormattedText(wPtr, txtOpponFix ,'center', 'center', txtColor);
Screen('TextSize',wPtr,txtSizFix);
Screen('Flip', wPtr);
WaitSecs(tOpponFix);

Screen('DrawTexture',wPtr,oppoPic);
Screen('Flip', wPtr);
WaitSecs(tOpponIntro);

%% Run Experiment
response = table(); % response table stores all the data needed

for i =1 : trialNums
    
    response.Block(i) = block;
    response.Trial(i) = i;
    response.P1DepositSt(i) = P1Deposit;
    response.P2DepositSt(i) = P2Deposit;
    
    
    %% cue
    % record timing - start trial
    tTrialStart = tic;
    
    % display 'X'
    Screen('TextSize',wPtr,txtSizFix);
    DrawFormattedText(wPtr, txtCue ,'center', 'center', txtColor);
    Screen('Flip', wPtr);
    response.tSCue(i) = toc(tTrialStart); 
    WaitSecs(tCue);
    response.tECue(i) = toc(tTrialStart);
    
    if   strcmp(state,'stateRT1')
        
        %% RT1
        
        tempoP1Reserve = response.P1DepositSt(i);
        tempoP2Reserve = response.P2DepositSt(i);
        
        box1_Y1 = box1_Y2 - tempoP1Reserve * pxPerAmount;
        box2_Y1 = box2_Y2 - tempoP2Reserve * pxPerAmount;
        box1Rect = [box1_X1,box1_Y1,box1_X2,box1_Y2];
        box2Rect = [box2_X1,box2_Y1,box2_X2,box2_Y2];
        
        txtbox1Y = box1Rect(2);
        txtbox2Y = box2Rect(2);
        
        Screen('DrawTexture',wPtr,backgrnd);
        Screen('Fillrect',wPtr,colorBox,box1Rect);
        Screen('Fillrect',wPtr,colorBox,box2Rect);
        Screen('TextSize',wPtr,txtSiz);
        
        textBounds1 = Screen('TextBounds', wPtr,txtWaiting);
        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
        
        textBounds2 = Screen('TextBounds', wPtr,txtWaiting);
        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
        
        Screen('DrawText', wPtr, txtWaiting, text1X,text1Y, txtColorFlash);
        Screen('DrawText', wPtr, txtWaiting, text2X,text2Y, txtColorFlash);
        
        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
        
        Screen('Flip',wPtr);
        response.tSRT1(i) = toc(tTrialStart);
        
        hav = 0;
        elapesed = toc(tTrialStart);
        while toc(tTrialStart) - elapesed <= maxRT1
            
            [ keyIsDown, seconds, keyCode ] = KbCheck;
            
            if keyIsDown
                secs = toc(tTrialStart);
                res_key = find(keyCode);
                if res_key  == upKey
                    if tempoP1Reserve <= 0
                        clear KbCheck;
                    else
                        tempoP1Reserve = tempoP1Reserve - 1;
                        tempoP2Reserve = tempoP2Reserve + 3;
                        x = response.P1DepositSt(i) - tempoP1Reserve;
                        
                        box1Rect(2) = box1Rect(2)+ pxPerAmount;
                        box2Rect(2) = box2Rect(2)- 3 * pxPerAmount;
                        
                        Screen('DrawTexture',wPtr,backgrnd);
                        if x ~= 10
                            Screen('Fillrect',wPtr,colorBox,box1Rect);
                        end
                        Screen('Fillrect',wPtr,colorBox,box2Rect);
                        
                        textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
                        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
                        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
                        
                        textBounds2 = Screen('TextBounds', wPtr,txtWaiting);
                        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
                        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
                        
                        Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
                        Screen('DrawText', wPtr, txtWaiting, text2X,text2Y, txtColorFlash);
                        
                        txtbox1Y = box1Rect(2);
                        txtbox2Y = box2Rect(2);
                        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
                        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
                        
                        Screen('Flip',wPtr); %FlushEvents;
                        response.tERT1(i) = toc(tTrialStart);
                        clear KbCheck;
                        hav = 1;
                    end
                    
                elseif res_key  == downKey
                    if tempoP1Reserve == response.P1DepositSt(i)
                        clear KbCheck;
                        
                    else
                        tempoP1Reserve = tempoP1Reserve + 1;
                        tempoP2Reserve = tempoP2Reserve - 3;
                        x = response.P1DepositSt(i) - tempoP1Reserve;
                        
                        box1Rect(2) = box1Rect(2)- pxPerAmount;
                        box2Rect(2) = box2Rect(2)+ 3 * pxPerAmount;
                        
                        Screen('DrawTexture',wPtr,backgrnd);
                        Screen('Fillrect',wPtr,colorBox,box1Rect);
                        Screen('Fillrect',wPtr,colorBox,box2Rect);
                        
                        textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
                        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
                        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
                        
                        textBounds2 = Screen('TextBounds', wPtr,txtWaiting);
                        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
                        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
                        
                        Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
                        Screen('DrawText', wPtr, txtWaiting, text2X,text2Y, txtColorFlash);
                        
                        txtbox1Y = box1Rect(2);
                        txtbox2Y = box2Rect(2);
                        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
                        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
                        
                        Screen('Flip',wPtr); %FlushEvents;
                        response.tERT1(i) = toc(tTrialStart);
                        clear KbCheck;
                        hav = 1;
                    end
                    
                elseif res_key == enterKey(1)
                    if hav == 0
                        x = 0;
                    end
                    response.x(i) = x;
                    response.RT1(i) = secs- elapesed;
                    clear KbCheck;
                    hav = 2;
                    break;
                    
                elseif res_key == exitKey
                    Screen('CloseAll');
                    ListenChar(0);
                    return;
                    
                end
            end
        end
       
        if hav == 0 || hav == 1  % time passed without any interaction or
            % there was(were) interaction(s) but not completed by subject
            x = 10;
            response.x(i)  = x;
            tempoP1Reserve = response.P1DepositSt(i) - response.x(i);
            tempoP2Reserve = response.P2DepositSt(i) + 3 * response.x(i);
            response.RT1(i) = maxRT1;
            
            box1Rect(2) = box1Rect(4);
            box2Rect(2) = box1Rect(4) - (tempoP2Reserve * pxPerAmount);
            
            Screen('DrawTexture',wPtr,backgrnd);
            %Screen('Fillrect',wPtr,colorBox,box1Rect);
            Screen('Fillrect',wPtr,colorBox,box2Rect);
            
            textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
            text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
            text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
            
            textBounds2 = Screen('TextBounds', wPtr,txtWaiting);
            text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
            text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
            
            Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
            Screen('DrawText', wPtr, txtWaiting, text2X,text2Y, txtColorFlash);
            
            txtbox1Y = box1Rect(2);
            txtbox2Y = box2Rect(2);
            Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
            Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
            
            Screen('Flip',wPtr); %FlushEvents;
            response.tERT1(i) = toc(tTrialStart);
            clear KbCheck;
        end
        
        %% T1
        Screen('TextSize',wPtr,txtSizFix);
        DrawFormattedText(wPtr, txtWaiting ,'center', 'center', txtColor);
        Screen('Flip', wPtr);
        response.tST1(i) = toc(tTrialStart);
        response.T1(i) = T1(i);
        
        response.waitForP2(i) = (maxRT1 - response.RT1(i)) + response.T1(i);
        WaitSecs(response.waitForP2(i));
        response.tET1(i) = toc(tTrialStart);
        
        %% T2
        response.returnStrategy(i) = returnStrategy; % 1 for cooperative
        response.returnArray(i) = returnArray(i);  % 2 for non cooperative
        y = dealStrategy(response.x(i),returnArray(i));
        response.y(i) = y;
        tempoP1Reserve = tempoP1Reserve + y;
        tempoP2Reserve = tempoP2Reserve - y;
        box1Rect(2) = box1Rect(2) - y * pxPerAmount;
        box2Rect(2) = box2Rect(2) + y * pxPerAmount;
        response.T2(i) = T2(i);
        
        Screen('DrawTexture',wPtr,backgrnd);
        Screen('Fillrect',wPtr,colorBox,box1Rect);
        Screen('Fillrect',wPtr,colorBox,box2Rect);
        Screen('TextSize',wPtr,txtSiz);
        
        textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
        
        textBounds2 = Screen('TextBounds', wPtr,num2str(y));
        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
        
        Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
        Screen('DrawText', wPtr, num2str(y), text2X,text2Y, txtColorFlash);
        
        txtbox1Y = box1Rect(2);
        txtbox2Y = box2Rect(2);
        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
        
        Screen('Flip',wPtr);
        response.tST2(i) = toc(tTrialStart);
        WaitSecs(response.T2(i));
        response.P1DepositEnd(i) = tempoP1Reserve;
        response.P2DepositEnd(i) = tempoP2Reserve;
        
        %% T3
        Screen('TextSize',wPtr,txtSizFix);
        DrawFormattedText(wPtr, txtITI ,'center', 'center', txtColor);
        response.tET2(i) = toc(tTrialStart);
        Screen('Flip', wPtr);
        response.tST3(i) = toc(tTrialStart);
        response.T3(i) = T3(i);
        WaitSecs(response.T3(i));
        response.tET3(i) = toc(tTrialStart);
    
    elseif  strcmp(state,'stateT4')
        
        %% T4
        tempoP1Reserve = response.P1DepositSt(i);
        tempoP2Reserve = response.P2DepositSt(i);
        
        box1_Y1 = box1_Y2 - tempoP1Reserve * pxPerAmount;
        box2_Y1 = box2_Y2 - tempoP2Reserve * pxPerAmount;
        box1Rect = [box1_X1,box1_Y1,box1_X2,box1_Y2];
        box2Rect = [box2_X1,box2_Y1,box2_X2,box2_Y2];
        
        txtbox1Y = box1Rect(2);
        txtbox2Y = box2Rect(2);
        
        Screen('DrawTexture',wPtr,backgrnd);
        Screen('Fillrect',wPtr,colorBox,box1Rect);
        Screen('Fillrect',wPtr,colorBox,box2Rect);
        Screen('TextSize',wPtr,txtSiz);
        
        textBounds1 = Screen('TextBounds', wPtr,txtWaiting);
        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
        
        textBounds2 = Screen('TextBounds', wPtr,txtWaiting);
        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
        
        Screen('DrawText', wPtr, txtWaiting, text1X,text1Y, txtColorFlash);
        Screen('DrawText', wPtr, txtWaiting, text2X,text2Y, txtColorFlash);
        
        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
        
        Screen('Flip',wPtr);
        response.tST4(i) = toc(tTrialStart);
        response.T4(i) = T4(i);
        WaitSecs(response.T4(i));
        response.tET4(i) = toc(tTrialStart);
        %% RT2
        
        % make P1 decision settings
        response.payStrategy(i) = payStrategy;
        
        if i == 1 
            if response.payStrategy(i) == 1 
                x = randsample([5:10], 1);
            elseif response.payStrategy(i) == 2
                x = randsample([0:5], 1);
            end
        else 
            x = dealPayStrategy(response.x(i-1),response.y(i-1),response.payStrategy(i));
        end
        response.x(i) = x;
        tempoP1Reserve = tempoP1Reserve - x;
        tempoP2Reserve = tempoP2Reserve + 3 * x;
        
        box1Rect(2) = box1Rect(2)+ (x * pxPerAmount);
        box2Rect(2) = box2Rect(2)- (3 * x * pxPerAmount);
        
        Screen('DrawTexture',wPtr,backgrnd);
        if x ~= 10
            Screen('Fillrect',wPtr,colorBox,box1Rect);
        end
        Screen('Fillrect',wPtr,colorBox,box2Rect);
        
        textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
        
        textBounds2 = Screen('TextBounds', wPtr,txtWaiting);
        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
        
        Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
        Screen('DrawText', wPtr, txtWaiting, text2X,text2Y, txtColorFlash);
        
        txtbox1Y = box1Rect(2);
        txtbox2Y = box2Rect(2);
        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
        mediateP1Res = tempoP1Reserve;
        mediateP2Res = tempoP2Reserve;
        
        Screen('Flip',wPtr);
        response.tSRT2(i) = toc(tTrialStart);
        
        hav = 0;
        elapesed = toc(tTrialStart);
        while toc(tTrialStart) - elapesed <= maxRT2
            
            [ keyIsDown, seconds, keyCode ] = KbCheck;
            
            if keyIsDown
                secs = toc(tTrialStart);
                res_key = find(keyCode);
                if res_key  == upKey
                    if tempoP2Reserve <= 0
                        clear KbCheck;
                    else
                        tempoP1Reserve = tempoP1Reserve + 1;
                        tempoP2Reserve = tempoP2Reserve - 1;
                        y = mediateP2Res - tempoP2Reserve;
                        
                        box1Rect(2) = box1Rect(2)- pxPerAmount;
                        box2Rect(2) = box2Rect(2)+ pxPerAmount;
                        
                        Screen('DrawTexture',wPtr,backgrnd);
                        Screen('Fillrect',wPtr,colorBox,box1Rect);
                        Screen('Fillrect',wPtr,colorBox,box2Rect);
                        
                        textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
                        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
                        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
                        
                        textBounds2 = Screen('TextBounds', wPtr,num2str(y));
                        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
                        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
                        
                        Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
                        Screen('DrawText', wPtr, num2str(y), text2X,text2Y, txtColorFlash);
                        
                        txtbox1Y = box1Rect(2);
                        txtbox2Y = box2Rect(2);
                        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
                        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
                        
                        Screen('Flip',wPtr); %FlushEvents;
                        response.tERT2(i) = toc(tTrialStart);
                        clear KbCheck;
                        hav = 1;
                    end
                    
                elseif res_key  == downKey
                    if tempoP2Reserve == mediateP2Res
                        clear KbCheck;
                    else
                        tempoP1Reserve = tempoP1Reserve - 1;
                        tempoP2Reserve = tempoP2Reserve + 1;
                        y = mediateP2Res - tempoP2Reserve;
                        
                        box1Rect(2) = box1Rect(2)+ pxPerAmount;
                        box2Rect(2) = box2Rect(2)- pxPerAmount;
                        
                        Screen('DrawTexture',wPtr,backgrnd);
                        Screen('Fillrect',wPtr,colorBox,box1Rect);
                        Screen('Fillrect',wPtr,colorBox,box2Rect);
                        
                        textBounds1 = Screen('TextBounds', wPtr,num2str(3*x));
                        text1X = txtFlshX - textBounds1(3) / 2; % Center text horizontally.
                        text1Y = txtFlshY1 - textBounds1(4)/ 2; % Center text vertically.
                        
                        textBounds2 = Screen('TextBounds', wPtr,num2str(y));
                        text2X = txtFlshX - textBounds2(3) / 2;  % Center text horizontally.
                        text2Y = txtFlshY2 - textBounds2(4) / 2; % Center text vertically.
                        
                        Screen('DrawText', wPtr, num2str(3 * x), text1X,text1Y, txtColorFlash);
                        Screen('DrawText', wPtr, num2str(y), text2X,text2Y, txtColorFlash);
                        
                        txtbox1Y = box1Rect(2);
                        txtbox2Y = box2Rect(2);
                        Screen('DrawText', wPtr, num2str(tempoP1Reserve), txtbox1X,txtbox1Y, txtColor);
                        Screen('DrawText', wPtr, num2str(tempoP2Reserve), txtbox2X,txtbox2Y, txtColor);
                        
                        Screen('Flip',wPtr); %FlushEvents;
                        response.tERT2(i) = toc(tTrialStart);
                        clear KbCheck;
                        hav = 1;
                    end
                    
                elseif res_key == enterKey(1)
                    if hav == 0
                        y = 0;
                    end
                    response.y(i) = y;
                    response.RT2(i) = secs - elapesed;
                    clear KbCheck;
                    hav = 2;
                    break;
                    
                elseif res_key == exitKey
                    Screen('CloseAll');
                    ListenChar(0);
                    return;
                    
                end
            end
        end
       
        
        if hav == 0 ||  hav == 1 % time passed without any interaction or
            % there was(were) interaction(s) but not completed by subject
            y = mediateP2Res;
            response.y(i)  = y;
            tempoP1Reserve = mediateP1Res + response.y(i);
            tempoP2Reserve = mediateP2Res - response.y(i);
            response.RT2(i) = maxRT2;
            response.tERT2(i) = toc(tTrialStart);
        end
        
        response.P1DepositEnd(i) = tempoP1Reserve;
        response.P2DepositEnd(i) = tempoP2Reserve;

        %% ITI2
        Screen('TextSize',wPtr,txtSizFix);
        DrawFormattedText(wPtr, txtITI ,'center', 'center', txtColor);
        Screen('Flip', wPtr);
        response.tST5(i) = toc(tTrialStart);
        response.T5(i) = T5(i);
        response.ITI2(i) = (maxRT2 - response.RT2(i)) + response.T5(i);
        WaitSecs(response.ITI2(i));
        response.tET5(i) = toc(tTrialStart);
 
    end
end

Screen('CloseAll');
ListenChar(0);

%% save
saveDateP = strcat(p,f,'data_set');
mkdir(strcat(saveDateP,f,player1));
date      = string(datetime('now','TimeZone','local','Format','_d_MMM_y_HH_mm'));
fileName  = strcat(player1,'_blk',num2str(block),'_',expName,date,'.csv');
saveDateP = strcat(p,f,'data_set',f,player1);
writetable(response,fullfile(saveDateP,fileName));





 




