function createParamsPanelGUI(f,paramlisth)

% f is the parent fiugre
%paramlisth is the panel for the params stuff to be placed in
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
