function thylakoidSimGUI

%% Set things up
space = 10;
nItems = 9;
h = 30;
w = 210;% width of fields in left hand column


dtW = 432; %width of list on left hand side %defautl 332
dtH = 100;
listW = 360; % width of list on left hand side
listH = nItems * h + nItems * space + 20;
yspace = h+space;

% position of fields in right hand column
yPos = [listH-yspace:-yspace:0];
xPos = 130; % positions of controls on right hand side
xPosBB = 850;  %850

% Create Labels for the above inputs:
xPosLabel =2;% xPos - 130;
Lw = 125;
Lh = 20;
Lfontsize=14;

PSIIIndices=[];
otherIndices=[];

%GUI Initialization:
f = figure('Visible', 'off', 'Position', [0,0,1500,650]);

[chartW, chartx] = getChartWidth(f);


%% SET DEFAULT DIRECTORIES HERE
defaultOutDir     = '/Users/davidkramer/Dropbox/Data'
%'/Users/jzaks/Documents/GradSchool/FlemingLab/NPQ/ModelPaper1/simulations/';
defaultParamsFile = '/Users/davidkramer/Dropbox/Data/zaks sim/code/params.txt'
%'/Users/jzaks/Documents/GradSchool/FlemingLab/NPQ/ModelPaper1/code/params.txt';
defaultOutFigFolder = '/Users/davidkramer/Dropbox/Data'
%'/Users/jzaks/Documents/GradSchool/FlemingLab/NPQ/ModelPaper1/figures/';

[params paramUnits]=getparamsfromfilename(defaultParamsFile);


%User Input Variable Initialization:

ud.outSimFolder  = [defaultOutDir];
ud.defaultSimName  = 'sampleSim';
ud.paramsFile = [defaultParamsFile];
ud.outFigFolder = defaultOutFigFolder;
ud.saveFigName   = 'Fig';
ud.hold       = 'off';

   
%% Default Simulation conditions
paramfields=fields(params)
DefaultIntensity =[ 0.1 1000 0.1];
DefaultDuration  = [ 600 600 600];
npqsim=[];

colors='rgbcmyk'
symbols='.ospx';

%% Set Defaults
ud.intensity = DefaultIntensity;
ud.duration  = DefaultDuration;
ud.flashidx=zeros(size(ud.intensity));
ud.quenchModels  = [0];  %Default Quenching is no quenching
ud.act     = 1000; %Default Actinic Light Intensity
ud.simMode = 'PSIIAntenna';


%% Make panels
tfontsize=18; % t is for title

chartW=0.42;
chartx=.55;
figh = uipanel('Parent',f,...
    'Position',[chartx .2 chartW .7], 'ResizeFcn', @resizeFig, ...
    'BorderType', 'none');

cfontsize=12;
% % make axis
ah = axes('Parent', figh, 'Position', [0.15 0.15 .75 .75], 'fontsize', 22);

panelsHeight=0.8;



rpanelXPos  =    .01;
panelwidth  =    .25;
buffersize  =    0.005;
inputsHeight =   0.65;
panelsBottom =   0.25 ;



    function panelh= makePanelWithTitle(position, titleText)
    end

inputsh = uipanel('Parent', f, 'Position', [rpanelXPos     panelsBottom panelwidth inputsHeight], ...
    'ResizeFcn', @resizeLH, 'BorderType', ' none ', 'BackgroundColor', get(f,'Color'));




lightinputsh=uipanel('Parent', inputsh, 'Position',[0 0.5 1 0.55], 'BorderType', 'none' );

lightinputTitle = uicontrol('Parent', lightinputsh, 'Style', 'text', 'String', ...
    'Light Inputs', 'Value', 1, ...
    'Position', [80,225, w, Lh], 'fontsize', tfontsize);

quenchinputsh=uipanel('Parent', inputsh, 'Position',[0 00 1 0.4], 'BorderType', 'none' );
quenchinputTitle = uicontrol('Parent', quenchinputsh, 'Style', 'text', 'String', ...
    'Quenching Inputs', 'Value', 1, ...
    'Position', [80,180, w, Lh], 'fontsize', tfontsize);
   
panel2=uipanel('Parent', f, 'Position', [rpanelXPos+panelwidth+buffersize 0 panelwidth 1], 'BackgroundColor', get(f, 'Color'), ...
    'ResizeFcn', [], 'BorderType', ' none ');

paramsh = uipanel('Parent', panel2, 'Position', [0 panelsBottom+0.15 1 inputsHeight-0.15], ...
    'ResizeFcn', [], 'BorderType', ' line ');


%%%%%%%%%%%%
paramlisth = uipanel('Parent', paramsh, 'Position', [0 0.0  1 1], ...
     'BorderType', 'line');


%% Param Panels
paramTitle = uicontrol('Parent', paramlisth, 'Style', 'text', 'String', ...
    'Parameters', 'Value', 1, ...
    'Position', [80,330, w, Lh],  'fontsize', tfontsize);

%% select filename where params are contained

paramFolderLabel = uicontrol('Parent', paramlisth,'Style', 'text', 'String', 'Parameters file:', ...
    'Position', [xPosLabel, yPos(2)-10, Lw, Lh], 'fontsize', Lfontsize);


paramsFolder = uicontrol('Parent', paramlisth, 'Style', 'edit', 'String', ud.paramsFile, ...
    'Position', [xPos, yPos(2)-10, w, 30], 'Callback', @paramFolderSet);

    function paramFolderSet(folh, userData)
        ud.paramFile = get(folh, 'String');
    end

setParamsFolderButton = uicontrol('Parent', paramlisth, 'Style', 'pushbutton', ...
    'String', 'Browse', 'Position', [xPos+50, yPos(3), 80, 30], ...
    'Callback', {@setParamsFolder, paramsFolder}, 'fontsize', cfontsize);

    function setParamsFolder(bh, userData, oph)
        % oph stands for "old params handle"
        [newFile newPath] = uigetfile(ud.paramsFile);
        
        if newFile~=0 % newFile will equal zero if the user presses cancel
            ud.paramsFile = [newPath newFile];
            [params paramUnits]=getparamsfromfilename(ud.paramsFile);
            set(oph, 'String', ud.paramsFile);
            set(parameter, 'String', fields(params))
        end
    end


paramDefaultLabel = uicontrol('Parent', paramlisth,'Style', 'text', 'String', 'Default Value:', ...
    'Position', [xPosLabel, yPos(6), Lw, Lh], 'fontsize', Lfontsize);

paramLabel = uicontrol('Parent', paramlisth,'Style', 'text', 'String', ...
    'Parameter:', ...
    'Position', [xPosLabel,yPos(4), Lw, Lh], 'fontsize', Lfontsize);

%% Display Existing Parameters in Menu bar
paramValueDisp = uicontrol('Parent', paramlisth, 'Style', 'text', 'String', params.(paramfields{1}), ...
    'Position', [xPos, yPos(5), w*0.5, Lh], 'fontsize', cfontsize, 'BackgroundColor', [1 1 1]);

paramUnitsDisp = uicontrol('Parent', paramlisth, 'Style', 'text', 'String', paramUnits.(paramfields{1}), ...
    'Position', [xPos+w*0.55, yPos(5), w*0.5, Lh], 'fontsize', cfontsize, 'BackgroundColor', [1 1 1]);

varyParamButton = uicontrol('Parent', paramlisth, 'Style', 'check box', ...
    'String', 'Vary This Parameter', 'Position', [xPos, yPos(6), 200, 20], ...
    'Callback', {@setParamToVary}, 'Value', 0, 'fontsize', cfontsize);

    function setParamToVary(bh, userData)
        %%Change this
        %newPath = uigetfile(defaultParamsFile);
        % set param variation to 1
        paramSelect(parameter, userData)
        varythisparam = get(bh, 'Value'); % check if box is checked or not.
        
        
        if varythisparam
            set(paramVaryValues, 'Visible', 'on');
            set(paramValuesLabel, 'Visible', 'on');
        else
            set(paramVaryValues, 'Visible', 'off');
            set(paramValuesLabel, 'Visible', 'off');
        end
    end


%Field for entering param values
paramValuesYPos=yPos(7);
paramH=30;
paramValuesLabel = uicontrol('Parent', paramlisth,'Style', 'text', 'String', 'Param Values', ...
    'Position', [xPosLabel, paramValuesYPos, Lw, 25], 'fontsize', Lfontsize, 'Visible', 'off');


paramVaryValues = uicontrol('Parent', paramlisth,   'Style', 'edit',   ...
    'Position', [xPos, paramValuesYPos, 200, 30], 'fontsize', cfontsize,...
    'Callback', {@setParamVaryValues},'Visible', 'off');

    function setParamVaryValues(bh, userData)
        
        
        ud.paramVaryValues = str2num(get(paramVaryValues, 'String'));
        updateNSimulations(ud);
    end

%% Selecting Param value to vary

parameter = uicontrol('Parent', paramlisth, 'Style', 'popupmenu', 'String', ...
    paramfields, 'Value', 1, 'Position', [xPos,yPos(4), w, Lh], ...
    'Callback', {@paramSelect}, 'fontsize', cfontsize);

    function paramSelect(refHandle, userData)
        % When the user selects the parameter, the Default parameter field
        % should display the default value of the selected parameter
        val  = get(refHandle, 'Value');
        opts = get(refHandle, 'String');
        
        ud.param    = opts(val);
        ud.paramVal = params.(opts{val});
        
        
        %set the format
        if ud.paramVal<1e3
            paramValDisplay = num2str(ud.paramVal);
        else % scientific notation
            paramValDisplay = num2str(ud.paramVal, '%11.4g');
        end
        set(paramValueDisp, 'String', paramValDisplay);
        set(paramUnitsDisp, 'String', paramUnits.(opts{val}));
        
    end

panelwidth  = 1;
panelheight = 0.3;

%% Light Inputs Panels


lightPAM = uipanel('Parent', lightinputsh, 'Position',[0 0.4 panelwidth 0.5], 'BorderType', 'none' );
lightCustom = uipanel('Parent', lightinputsh, 'Position',[0 0 panelwidth panelheight], ...
    'BorderType', 'none' );

%% PAM light intensity inputs


pamInputs.act=1000; %default act setting
pamInputs.sat=7000;
pamInputs.flashlength=0.5;
[actLabelH actInputH    ]=labeledTextInput(lightPAM,'act' ,[ 20  45],  pamInputs.act, 120)
[satLabelH satInputH]    =labeledTextInput(lightPAM,'sat', [ 170 45], pamInputs.sat)
[flashLabelH flashInputH]=labeledTextInput(lightPAM,'flashlength', [ 250 45], pamInputs.flashlength)





loadPamButton = uicontrol('Parent', lightPAM, 'Style', 'pushbutton', ...
    'Position', [70,0,200,30], 'String', 'Load PAM Intensity and Duration',...
    'Callback', {@loadPamIntensities, actInputH, satInputH, flashInputH},...
    'Fontsize', cfontsize)

    function loadPamIntensities(button, userData, acth, sath, flashlengthh)
        act=str2num(get(acth, 'String'));
        sat=str2num(get(sath, 'String'));
        intensString ='';
        ud.intensity=[];
        fll=str2num(get(flashlengthh, 'String'));
        
        for k=1:length(act)
            [ud.intensity(k,:) ud.duration ud.flashidx]=setupPAMIntensities(act(k), sat, fll);
            
        end
        for kk=1:size(ud.intensity,2)
            if isequal(ud.intensity(:,kk)./ud.intensity(1,kk), ones(size(ud.intensity(:,kk)))) %Check if all elements of ud.intensity(kk,:) are equal
                actString=num2str(ud.intensity(1,kk));
            else
                actString=num2str(ud.intensity(:,kk)');
            end
            if kk==size(ud.intensity,2)
                intensString= [intensString  actString ];
            else
                intensString= [intensString  actString ';'];
            end
        end
        set(durationControl, 'String', num2str(ud.duration))
        set(intensityControl, 'String', intensString)
        feval(get(intensityControl, 'Callback'), intensityControl, [])
    end

%% Custom light intensity inputs

duratLabel = uicontrol('Parent', lightCustom,'Style', 'text', 'String', 'Duration (seconds)', ...
    'Position', [xPosLabel, yPos(8), Lw, Lh], 'fontsize', Lfontsize);

durationControl = uicontrol('Parent',lightCustom, 'String', num2str(DefaultDuration), ...
    'Style', 'Edit','BackgroundColor', [  1 1 1],'fontsize', 14, ...
    'Position', [xPos, yPos(8), w, h], 'Callback', @setDuration);


intensLabel = uicontrol('Parent', lightCustom,'Style', 'text', 'String', 'Intensity (uE/m^2/s)', ...
    'Position', [xPosLabel, yPos(9), Lw, h], 'fontsize', Lfontsize);

intensityControl = uicontrol('Parent', lightCustom, 'String', num2str(DefaultIntensity), ...
    'Style', 'Edit','BackgroundColor', [  1 1 1],'fontsize', 14, ...
    'Position', [xPos, yPos(9), w, h], 'Callback', @setIntensity);

%% Controls for getting intensity and duration of light inputs

    function  setDuration(durationControl, userData )
        ud.duration = str2num(get(durationControl, 'String'));
    end
    function   setIntensity( ih, userData)
        s=get(ih, 'String');
        
        % Semicolons delimit different values of actinic light
        containsSemicolon=regexp(s,';');
        if any(containsSemicolon)
            intens=[];
            nIntens=zeros(1,length(containsSemicolon)+1);
            idx=[1 containsSemicolon length(s)];
            for k=1:length(containsSemicolon)+1
                intens{k}=str2num(s(idx(k):idx(k+1)));
                nIntens(k)=length(intens{k});
            end
            [nact actidx]=max(nIntens)
            act=intens{actidx};
            ud.intensity=zeros(nact, length(intens));
            for k=1:nact 
                for kk=1:length(intens)
                    if length(intens{kk})==1
                        ud.intensity(k,kk)=intens{kk};
                    else
                        try   ud.intensity(k,kk)=intens{kk}(k);
                        catch
                            error('Input Light Intensity Lengths do not agree');
                        end
                    end
                end
                
            end
        end

         updateNSimulations(ud)
    end

%% Quenching inputs
[quenchLabelH quenchInputH]=labeledTextInput(quenchinputsh,'Quenching Models to Simulate:', [ 10 105], 0, 200, {@setQuenchModels})
    function setQuenchModels(bh, userData)
        try  ud.quenchModels=str2num(get(bh, 'String'));
        catch
            error('Quenching inputs may not be formatted correctly. Format should be numbers separated by commas or colons');
        end
        updateNSimulations(ud)
    end

quenchingText=uicontrol('Parent', quenchinputsh, 'Position', [10 10 300 50],...
    'Style', 'text', ...
    'String', 'code for the different quenching models is in the file getStaticQuencherValues.m', 'Fontsize', 14);

%% Select Type of Simulation
simmodepanel=uipanel('Parent', panel2, 'Position', [0 0.25 1 0.15], 'BackgroundColor', get(panel2, 'BackgroundColor'), 'BorderType', 'none')
selectSimTypeH = uicontrol('Parent', paramsh, 'Position', [30 -150 300 100], ...
    'Style', 'popupmenu','String', initChloroplastSim('getallmodes'), 'Value', 7,...
    'fontsize', 14, 'Callback', {@setSimType});
    function setSimType(bh, userData)
        simTypeString=get(bh, 'String');
        ud.simMode=simTypeString{get(bh, 'Value')};
    end
selectSimTypeLabel = uicontrol('Parent', paramsh, 'Position', [30 -40 300 20], ...
    'Style', 'text','String', 'Simulation Mode:', ...
    'fontsize', 14);
    
%% Run Simulation Button and Simulation Displays

buttonPositionSize   =  [ 50 90 200 50];

totalSimPositionSize    =  [ 200 60 100 25];
completedSimPositionSize = [ 200 5 100 20];
completedSimLabelPos   =   [ 0 5 150 20];
totalSimLabelPos     =  [ 0 60 150 25];
estTimePositionSize  =  [ 200 30 100 25];

estTimeLabelPos      =  [ 0 30 150 25];


runSimPanel    = uipanel('Parent', panel2, 'Position', [0 0.02 1 0.22], 'BackgroundColor', [.8 .8 .8])
runSimButton    = uicontrol( 'Parent', runSimPanel,'Style', 'pushbutton', ...
    'String', 'Run Simulation', 'Position', buttonPositionSize, ...
    'Callback', {@runSimulation,ah}, 'fontsize', 22);

totalSimsDisplayH = uicontrol('Parent', runSimPanel, 'Style', 'text', ...
    'String', num2str(1), 'Position', totalSimPositionSize, ...
    'Callback', {}, 'fontsize', 14);

estTimeDisplayH = uicontrol('Parent', runSimPanel, 'Style', 'text', ...
    'String', 'estimated duration of of sims (to fix)', 'Position', estTimePositionSize, ...
    'Callback', {}, 'fontsize', 10);

estTimeLabelH   = uicontrol( 'Parent', runSimPanel,'Style', 'text', ...
    'String', 'Estimated Time', 'Position', estTimeLabelPos, ...
    'Callback', {}, 'fontsize', 14);

totalSimLabel  = uicontrol('Parent', runSimPanel, 'Style', 'text', ...
    'String', 'Number of Simulations', 'Position', totalSimLabelPos, ...
    'Callback', {}, 'fontsize', 14);

totalSimLabel  = uicontrol( 'Parent', runSimPanel,'Style', 'text', ...
    'String', 'Number of Simulations', 'Position', totalSimLabelPos, ...
    'Callback', {}, 'fontsize', 14);

completedSimDisplayH  = uicontrol('Parent', runSimPanel, 'Style', 'text', ...
    'String', 'Completed Simulations', 'Position', completedSimLabelPos, ...
    'Callback', {}, 'fontsize', 14);

completedSimDisplayH  = uicontrol( 'Parent', runSimPanel, 'Style', 'text', ...
    'String', num2str(0), 'Position', completedSimPositionSize, ...
    'Callback', {}, 'fontsize', 14);



% % isRunningText = uicontrol('Parent', inputsh, 'Style', 'pushbutton', ...
% %     'String', 'Running', 'Position', [70, 10, 150, 50], ...
% %      'fontsize', cfontsize,'BackgroundColor', [  1 .1 .1], 'Visible', 'off');

%% Save Simulated Variable to Disk
p=get(inputsh, 'Position')
saveSimPanel=uipanel('Parent', f, 'Position', [p(1) 0.02 p(3) 0.22],'BorderType', 'none')

saveNameLabel = uicontrol( 'Style', 'text','Parent', saveSimPanel, ...
    'String', 'Save Sim As: ', 'Position', [ 30 90 100 25], ...
    'fontsize', cfontsize);

saveNameText = uicontrol( 'Style', 'edit', 'Parent', saveSimPanel,...
    'String', ud.defaultSimName, 'Position', [ 130 90 150 30], ...
    'fontsize', cfontsize);

saveDirLabel = uicontrol( 'Style', 'text','Parent', saveSimPanel, ...
    'String', 'in Folder ', 'Position', [ 30 60 100 25], ...
    'fontsize', cfontsize);
saveFolder = uicontrol('Parent', saveSimPanel, 'Style', 'edit', 'String', ud.outSimFolder, ...
    'Position', [ 130 60 150 30], 'Callback', @saveFolderSet);
    function saveFolderSet(folh, userData)
        
        ud.outSimFolder = get(folh, 'String');
    end


setSimSaveFolderButton = uicontrol('Parent', saveSimPanel, 'Style', 'pushbutton', ...
    'String', 'Browse', 'Position', [ 150 25 70 30], ...
    'Callback', {@setSimSaveFolder, saveFolder}, 'fontsize', cfontsize);

    function setSimSaveFolder(bh, userData, oph)
        % oph stands for "old params handle"
        [newPath] = uigetdir(ud.outSimFolder);
        if newPath~=0 % newFile will equal zero if the user presses cancel
            ud.outSimFolder = [newPath ];
            
            set(oph, 'String', ud.outSimFolder);
        end
    end

%% Load saved variable from disk to display
position=[0.550 0.90 0.3 0.1];
[dispFigFileH] =browseForFileControls(f,'Display simulation from File:', position)
   
    function [ folderTextH ]=browseForFileControls(parent, labelText, position)
        boxHeight=25;
        panelH=uipanel('Parent', parent, 'Position', position,'BorderType', 'none', 'BackgroundColor', [0.8 0.8 0.8]);
        
        labelH = uicontrol('Parent', panelH,'Style', 'text', 'String', labelText, ...
            'Position', [0 30  200 boxHeight], 'fontsize', Lfontsize, 'BackgroundColor', [0.8 0.8 0.8]);
        
        
        folderTextH = uicontrol('Parent', panelH, 'Style', 'edit', 'String', [ud.outFigFolder ud.defaultSimName], ...
            'Position', [200  30  400 boxHeight], 'Callback', @folderSet, 'HorizontalAlignment', 'left');
        
        function folderSet(folh, userData)
            ud.paramFile = get(folh, 'String');
        end
        buttonH = uicontrol('Parent', panelH, 'Style', 'pushbutton', ...
            'String', 'Browse', 'Position', [200,00, 80, 25], ...
            'Callback', {@setFolder, folderTextH});
        
        function setFolder(bh, userData, oph)
            % oph stands for "old params handle"
            fileString=get(oph, 'String');
            [newFile newPath] = uigetfile(fileString);
            
            if newFile~=0 % newFile will equal zero if the user presses cancel
                newString = [newPath  newFile];
                set(oph, 'String', newString);
                saveSimName=get(dispFigFileH, 'String');
        
        npqsim=load(saveSimName);%load([ud.outFolder '/' saveSimName]); % the forward slash is specific to mac, need to change if using Windows
        npqsim=npqsim.npqsim;
        
            end
        end
    end

%% Figure Plot Display
menuw=190;
selectPlotPositionSize  =  [800            100  menuw Lh];
selectPlotPositionSize2 =  [800+menuw+5    100  menuw Lh];
selectPlotPositionSize3 =  [800+2*menuw+10 100  menuw Lh];
holdCheckPosition       =  [800            50  menuw    Lh];


holdCheck = uicontrol('Parent', f, 'Style', 'checkbox', ...
    'String', 'Hold on', 'Position', holdCheckPosition, ...
    'Callback', @holdSelect, 'fontsize', cfontsize);
    function holdSelect(cbh, userData)
        switch(get(cbh, 'Value'))
            case 0
                ud.hold = 'off';
            case 1
                ud.hold = 'on';
        end
    end

plotTypes={'Chl Fluorescence' 'NPQ' 'Dynamic Variables' 'Static Variables' };
plotTypesSelect = uicontrol( 'Style', 'popupmenu', 'Parent', f,...
    'String', plotTypes, 'Value', 1, 'Position', selectPlotPositionSize, ...
    'Callback', {@displaySimResults,ah}, 'fontsize', cfontsize);



    function displaySimResults(bh, userData, ah)
        ud.plottype=get(plotTypesSelect, 'Value');
        
        
        if iscell(npqsim)
            if any(strfind(plotTypes{ud.plottype}, 'Dynamic Variables'))
                % Dynamic variables are ones that have
if isfield(npqsim{1}.simparams.varindices, 'PSII_Antenna')

                PSIIIndices=npqsim{1}.simparams.varindices.PSII_Antenna;
else
    PSIIIndices=npqsim{1}.simparams.varindices.PSII;
end
            otherIndices=setdiff(1:length(npqsim{1}.simparams.varsforsim), PSIIIndices);

            dynamicVarAllStrings=npqsim{1}.simparams.varsforsim(otherIndices);
                dynamicVarPSIIStrings=npqsim{1}.simparams.varsforsim(PSIIIndices);
                set(plotDynamicPSIIVarSelect, 'String',  dynamicVarPSIIStrings);
                set(plotDynamicAllVarSelect,  'String',  dynamicVarAllStrings);
                
                set(plotStaticQVarSelect,     'Visible', 'off');
                set(plotStaticTVarSelect,     'Visible', 'off');
                
                set(plotDynamicPSIIVarSelect, 'Visible', 'on');
                set(plotDynamicAllVarSelect,  'Visible', 'on');
                
            elseif any(strfind(plotTypes{ud.plottype}, 'Static Variables'))
                % Get the names of all the static variables
                % static variables are ones that are determine by dynamic
                % variables, and don't have explicit differential equations
                % for them. I think they are sometimes also called
                % algebraic variables.
                [s q]=getStaticVals(npqsim{1});
                 set(plotDynamicPSIIVarSelect, 'Visible', 'off');
                set(plotDynamicAllVarSelect,  'Visible', 'off');
                
                set(plotStaticQVarSelect,  'String',   fields(q));
                
                set(plotStaticTVarSelect,  'String',   fields(s));
                set(plotStaticQVarSelect,     'Visible', 'on');
                set(plotStaticTVarSelect,     'Visible', 'on');
                
                
            else
                
                set(plotDynamicPSIIVarSelect, 'Visible', 'off');
                set(plotDynamicAllVarSelect,  'Visible', 'off');
                set(plotStaticQVarSelect,     'Visible', 'off');
                set(plotStaticTVarSelect,     'Visible', 'off');
                
                hold(ah, ud.hold);
                if any(strfind(plotTypes{ud.plottype}, 'Chl Fluorescence'))
                    for k=1:size(npqsim,1)
                        for kk=1:size(npqsim,2)
                            for kkk=1:size(npqsim,3)
                                plotFluorescenceYield(npqsim{k,kk,kkk}, ah, [colors(kkk) symbols(k)]);
                                hold(ah, 'on');
                            end
                        end
                    end
                    
                elseif any(strfind(plotTypes{ud.plottype}, 'NPQ'))
                    for k=1:size(npqsim,1)
                        for kk=1:size(npqsim,2)
                            for kkk=1:size(npqsim,3)
                                plotNPQfromPAM(npqsim{k,kk,kkk}, ah, [colors(kkk) symbols(k)]);
                                hold(ah, 'on');
                            end
                        end
                    end
                    
                end
                
                hold(ah, ud.hold);
            end
            legendH=setParamLegend(ah, npqsim);
        end
    end


plotStaticTVarSelect = uicontrol( 'Style', 'popupmenu', 'Parent', f,...
    'String', '', 'Value', 1, 'Position', selectPlotPositionSize2, ...
    'Callback', {@plotSimulationVar,ah}, 'fontsize', cfontsize, 'Visible', 'off');

plotStaticQVarSelect = uicontrol( 'Style', 'popupmenu', 'Parent', f,...
    'String', '', 'Value', 1, 'Position', selectPlotPositionSize3, ...
    'Callback', {@plotSimulationVar,ah}, 'fontsize', cfontsize, 'Visible', 'off');

plotDynamicAllVarSelect = uicontrol( 'Style', 'popupmenu', 'Parent', f,...
    'String', '', 'Value', 1, 'Position', selectPlotPositionSize2, ...
    'Callback', {@plotSimulationVar,ah}, 'fontsize', cfontsize, 'Visible', 'off');

plotDynamicPSIIVarSelect = uicontrol( 'Style', 'popupmenu', 'Parent', f,...
    'String', '', 'Value', 1, 'Position', selectPlotPositionSize3, ...
    'Callback', {@plotSimulationVar,ah, }, 'fontsize', cfontsize, 'Visible', 'off');
varToPlot='';
legendText={};
paramVal=[];
paramName='';
    function plotSimulationVar(bh, ~, ah)
        varToPlot=get(bh, 'String')
        
        hold(ah, ud.hold);
        for k=1:size(npqsim,1)
            for kk=1:size(npqsim,2)
                for kkk=1:size(npqsim,3)
                    plotvar(ah, npqsim{k,kk,kkk}, varToPlot(get(bh, 'Value')),[colors(kkk) symbols(k)] );
                    hold(ah, 'on'); % keep figure plotted while different parameter values are plotted
                end
            end
        end
        legendH=setParamLegend(ah, npqsim);
        hold(ah, ud.hold);
        
    end



    function legendH= setParamLegend(ah, simCell)
        legendText=cell(size(simCell,3),1);
        hold(ah, ud.hold);
        if size(simCell,3)>1
            for k=1:size(simCell,1)
                for kk=1:size(simCell,2)
                    for kkk=1:size(simCell,3)
                        paramName=fields(simCell{k,kk,kkk}.varyParam);
                        legendText{kkk}= [paramName{1} ': ' num2str(simCell{k,kk,kkk}.varyParam.(paramName{1}))];
                    end
                end
            end
            legendH=legend(ah, legendText);
               set(legendH, 'fontsize', 14);
        
        else
            legendH=[];
            
        end
     
    end

%% Save Figure to file
savefigureh=uipanel('Parent', f, 'Position', [.65 .03 .2 .06], ...
    'BorderType', 'none',  'BackgroundColor', [0.8 0.8 0.8], 'visible', 'on');


saveFigLabel = uicontrol( 'Parent', savefigureh, 'Style', 'text', ...
    'String', 'Print Figure As: ', 'Position', [ 00 32.5 100 20], ...
    'fontsize', cfontsize);

saveFigFolder = uicontrol('Parent', savefigureh, 'Style', 'edit', ...
    'String', ud.outFigFolder, 'Position', [ 110 00 250 25], ...
    'fontsize', 9,'Callback', @saveFigFolderSet);

    function saveFigFolderSet(folh, userData)
        
        ud.outFigFolder = get(folh, 'String');
    end


saveDirLabel = uicontrol( 'Parent', savefigureh,'Style', 'text', ...
    'String', 'in Folder: ', 'Position', [ 00 00 100 20], ...
    'fontsize', cfontsize);

saveFigName = uicontrol('Parent', savefigureh, 'Style', 'edit', 'String', ud.saveFigName, ...
    'Position', [ 110 28 200 30], 'Callback', @saveFigNameSet,'fontsize', cfontsize);
    function saveFigNameSet(folh, userData)
        
        ud.outFigName = get(folh, 'String');
    end

setFigFolderButton = uicontrol('Parent', savefigureh, 'Style', 'pushbutton', ...
    'String', 'Browse', 'Position', [ 360 00 100 30], ...
    'Callback', {@setFigSaveFolder, saveFolder}, 'fontsize', cfontsize);


    function setFigSaveFolder(bh, userData, oph)
        % oph stands for "old params handle"
        [ newPath] = uigetdir(ud.outFigFolder);
        if newPath~=0 % newFile will equal zero if the user presses cancel
            ud.outFigFolder = [newPath];
            
            set(oph, 'String', [ud.outFigFolder]);
        end
    end

saveFigButton = uicontrol('Parent', savefigureh, 'Style', 'pushbutton', ...
    'String', 'Print Figure', 'Position', [ 360 30 100 30], ...
    'Callback', {@printFig,  ah}, 'fontsize', cfontsize);

% Declare some global variables
oh = [];
ph = [];
sh = [];
    function printFig(bh,   userData, ah)
        fnew=figure;
        copyobj(ah, fnew)
        [legendH oh  ph sh]=legend(ah);
        copyobj(legendH, fnew)
        ud.saveFigName=get(saveFigName, 'String');
        print(['-f' num2str(fnew)],[ud.outFigFolder '/' ud.saveFigName], '-depsc') ;
        
        
    end

%%
set(f,'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Run Simulation Functions


    function runSimulation(bh, userData, ah)
        origColor=get(runSimButton, 'BackgroundColor');
        act=[  1000  ]';
        npqsim={};% clear npqsim;
        % params=getparamsfromfilename('params.txt');
        % Change parameter if there are parameters to vary
        
        nVaryParams=getNParams(ud);
        if nVaryParams>1
            for k=1:nVaryParams;
                paramsStruct{k}=params;
                paramsStruct{k}.(ud.param{1})=ud.paramVaryValues(k);
            end
            
        else
            paramsStruct{1}=params;
            nVaryParams=1;
        end
        %colax = colormap(jet(10));
        % Run simulation and create a cell array called npqsim
        
        hold(ah, ud.hold)
        for k = 1:length(ud.quenchModels)
            for kk = 1:size(ud.intensity,1)
                for kkk = 1: nVaryParams
                    
                    
                    tic
                    npqsim{k,kk,kkk} = chloroplastSim(ud.intensity(kk,:), ud.duration, paramsStruct{kkk}, ud.quenchModels(k), ud.simMode);
                    npqsim{k,kk,kkk}.flashidx = ud.flashidx;
                    set( completedSimDisplayH, 'String', num2str(sub2ind(size(npqsim),k,kk,kkk)));
                    if nVaryParams>1
                        npqsim{k,kk,kkk}.varyParam.(ud.param{1})=paramsStruct{kkk}.(ud.param{1});
                        
                    else
                        npqsim{k,kk,kkk}.varyParam=struct([]);
                    end
                    plotFluorescenceYield(npqsim{k,kk,kkk}, ah, [colors(kkk) symbols(k)])
                    hold(ah, 'on')
                    toc
                end
            end
        end
        
        grid(ah,  'off')
        hold(ah, ud.hold)
        
        
        % output results to a workspace variable
        saveSimName=get(saveNameText, 'String')
        save([ud.outSimFolder saveSimName ], 'npqsim');
    end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Useful Auxiliary Functions
    function [labelh inputTexth]=labeledTextInput(parent,title, position, defaultVal, textWidth, inputCallbackFun)
        if nargin<5
            textWidth   = 70 ;
        end
        if nargin<6
            inputCallbackFun   = {} ;
        end
        textHeight  = 30 ;
        labelHeight = 20 ;
        
        labelh = uicontrol('Parent', parent,'Style', 'text', 'String', title, ...
            'Position', [position(1) position(2)+textHeight+5  textWidth labelHeight],...
            'fontsize', Lfontsize);
        
        inputTexth = uicontrol('Parent',parent, 'String', num2str(defaultVal), ...
            'Style', 'Edit','BackgroundColor', [  1 1 1],'fontsize', 14, ...
            'Position', [position(1) position(2) textWidth textHeight], 'Callback', inputCallbackFun);
        
    end

    function updateNSimulations(ud)
        nSims=length(ud.quenchModels)*size(ud.intensity,1)*getNParams(ud);
        set(totalSimsDisplayH, 'String', int2str(nSims));
    end

    function nVaryParams=getNParams(ud)
        if isfield(ud, 'paramVaryValues')
            nVaryParams=length(ud.paramVaryValues);
            
        else
            nVaryParams=1;
        end
    end


%% Resize Functions

    function resizeTH(th, userdata)
        
        %Resize
        currPos = get(th, 'Position');
        fh = get(th, 'Parent');
        fPos = get(fh, 'Position');
        currPos(3) = dtW/fPos(3);
        %   set(th, 'Position', currPos);
        
        dt = get(th, 'Children');
        tablePos = get(dt, 'Position');
        tablePos(4) = currPos(4)*fPos(4);
        
        %set children (subobjects) to current position
        % set(dt, 'Position', tablePos);
    end

    function resizeLH(lh, userdata)
        currPos = get(lh, 'Position');
        fh = get(lh, 'Parent');
        fPos = get(fh, 'Position');
        currPos(3) = listW/fPos(3);
        %  set(lh, 'Position', currPos);
    end

    function resizeILH(ilh, userdata, olh)
        currPos = get(ilh, 'Position');
        fh = get(olh, 'Parent');
        fPos = get(fh, 'Position');
        olPos = get(olh, 'Position');
        currPos(4) = listH/(fPos(4)*olPos(4));
        currPos(2) = ((fPos(4)*olPos(4)) - listH)/(fPos(4)*olPos(4));
        set(ilh, 'Position', currPos);
    end

    function height = getListH(ih)
        currPos = get(ih, 'Position');
        fh = get(ih, 'Parent');
        fPos = get(fh, 'Position');
        height = listH/(currPos(4)*fPos(4));
    end

    function height = getTableHeight(tPanel)
        currPos = get(tPanel, 'Position');
        fh = get(tPanel, 'Parent');
        fPos = get(fh, 'Position');
        height = (currPos(4)*fPos(4));
    end

    function [width, y] = getChartWidth(fh)
        currPos = get(fh, 'Position');
        width = (currPos(3) - listW - dtW - 30 - .02*currPos(3) - (.25*currPos(3) - dtW))/currPos(3);
        y = (.02*currPos(3) + dtW + 8)/currPos(3);
    end

    function resizeFig(figh, userdata)
        fh = get(figh, 'Parent');
        fPos = get(fh, 'Position');
        currPos = get(figh, 'Position');
        [currPos(3), currPos(1)] = getChartWidth(fh);
        %     set(figh, 'Position', currPos);
    end



end


