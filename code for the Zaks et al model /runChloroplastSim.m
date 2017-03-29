%% runChloroplastSim
%%

function [time,y]=runChloroplastSim(solverfun,trange, initcond, ...
    LightIntensity, params, simparams, quenchmodel)
%% Introduction
% runChloroplastSim function is the wrapper function that calles the ode
% solver and integrates the differential equations from different
% subsections. It runs this simulation for a single value of light
% intensity. It is called by the function
% <|chloroplastSim|chloroplastSim.html> which runs through a sequence of
% light intensities.

%% Setup
% Specify which variables will be able to have negative values. By
% default, all variables are nonnegative. Because it is nonphyscial for a
% biological quantity to be negative, usually these variables represent
% some sort of mathematical approximation to the physical system we are
% trying to model.
neg.names={'StromaProtons' , 'LumenProtons' ,'NADP'};

% pull out indices for negative values
idx=[];
for k=1:length(neg.names)
    thisidx=find(strcmp(neg.names{k}, simparams.varsforsim));
    idx=[idx thisidx];
end
nonnegidx=1:length(initcond);
nonnegidx(idx)=[];

%%
% The abstol values for each variable should be specified in the function
%<|initChloroplastSim| initChloroplastSim.html>. These values are important
%for the simulation to run properly and converge without crashing.
abstol=simparams.abstolforsim;

%% Setup options for differential equation solver
options=odeset(  'Nonnegative', nonnegidx, 'Stats', 'on',...
    'Vectorized', 'on', 'AbsTol', abstol);

% in some cases, particularly when debugging it is useful to display
% variables as they are propagated.
%varstodisp=[2:9] % which variables to display with the function @odeplot
%options=odeset(  'Nonnegative', nonnegidx, 'Stats', 'on',...
%'Vectorized', 'on', 'AbsTol', abstol, 'OutputFcn',@odeplot,...
%'OutputSel',varstodisp);% 'InitialStep', initstep,   'RelTol', reltol);
%maxstep=1e-1 for PAMSIM

% for low light intensities
if all(LightIntensity<10)
    initstep=1e-10;
    reltol=1e-1;
    maxstep=1e0;
    options=odeset(  'Nonnegative', nonnegidx, 'Stats', 'on',...
        'Vectorized', 'on', 'AbsTol', abstol, 'InitialStep', initstep, ...
        'MaxStep', maxstep, 'RelTol', reltol);
    %,  'OutputFcn',@odeplot,'OutputSel',[1:11]); %maxstep=1e-1 for PAMSIM
end

%% Run Simulation
% call the ode solver specified by solverfun (usually ode15s) to simulate
% the differential equation described by the function photosystemEvolve,
% which is specified below.
sim=solverfun(@photosystemEvolve, trange, initcond, options);

% Because the first column of the simulation are an array of zeros, start
% with the second
startindex=2;
time=sim.x(startindex:end);
y=sim.y(:,startindex:end);

%%  PhotosystemEvolve
% this is the function that propagates the differential equation at each
% step
%%
    function f=photosystemEvolve(t, currentValues)
        %%
        % Split variables into modules
        %%
        x=splitvars(currentValues,(simparams.simvars), simparams );
        %%
        % propagate each modules using the function <|evolveVars| evolveVars.html>
        %%
        dx=evolveVars(currentValues, x, params,simparams,...
            LightIntensity, quenchmodel );
        %%
        % Combine the modules into to one vector of differential values
        %%
        f=real(combinevars(dx, (simparams.simvars), simparams));
        
        %display Proton Flux for debugging purposes
        dispnow=1; % set this to zero to turn on display
        if dispnow==0
            disp('Protons In')
            disp( (dx.cytb6fLumen(4,:)+dx.PSIInodamage(6,:)))
            disp('Protons Out')
            disp( dx.ATPsynthaseLumen(1,:))
            disp('Net change in Protons per second ')
            disp( f(getIndices(simparams.varsforsim,{'LumenProtons'}),:))
        end
    end

    function W= splitvars(currentvars,varnames, simparams)
        for j=1:length(varnames)
            W.(varnames{j})=currentvars(simparams.varindices.(varnames{j}),:);
        end
    end
    function dallvars= combinevars(v,varnames, simparams)
        dallvars=zeros(size(simparams.initvarsforsim,1), size(v.(varnames{1}),2));
        for j=1:length(varnames)
            try
                dallvars(simparams.varindices.(varnames{j}),:)...
                    =dallvars(simparams.varindices.(varnames{j}),:)+v.(varnames{j});
            catch
                error('err')
            end
        end
        
    end



end
