%% chloroplastSim
%
% This is the main function of the simulation. It returns a simulation
% for one sequence of light intensities/durations with one 
% model of quenching and one set of parameters.
%%

function [sim ]=chloroplastSim(LightIntensity, durat, params, quenchmodel, simMode)

%%  Input Format
%  Light Intensity is vector of light intensity sequences
%  durat is vector of the duration of light intensity sequences





if length(LightIntensity)~= length(durat)
    error('LightIntensity and duration do not have the same values. See line 16 of file chloroplastSim.m')
    % look into integrating error checking into gui
    
end


%% INITALIZE VARIALBES%
%start with ions in  stroma and lumen at the same concentration
if nargin<5
    simMode='test'; %default mode for simulation
    
end

%% Initialize simulation
simparams=initChloroplastSim(simMode, params, quenchmodel);



sim.params=params;
%% Setup function params


%%Setup parameter variation

initcond=simparams.initvarsforsim;
simulatedvalues=[0; initcond];
tstart=0;
%%END INITALIZING VARIALBES%
%%

%% Run Simulation
% Simulate each light intensity segment sequentially
sim.nsections=length(LightIntensity);
li=[0]; %starting vector for light intensity
startidx=1;
for j=1:sim.nsections
    
    
    intensnow=LightIntensity(j); %specify current intensity
    
    
    %a stiff solver is necessary.
    solverfun=@ode15s;
    
    % Run the simulation
    [time,y]=runChloroplastSim(solverfun,[0 durat(j)], initcond, ...
        intensnow, params, simparams,quenchmodel);
    
    % format simulated values
    time=time+tstart;
    w=vertcat(time(startidx:end), y(:,startidx:end));
    sim.sectionstart(j)=size(simulatedvalues,2)+1;
    sim.sectionlength(j)=size(w,2);
    
    % concatenate current simulation with previous simulations
    simulatedvalues=horzcat(simulatedvalues, w);
    tstart=time(end);
    
    % initialize next segment with  final values of the previous simulation segment
    initcond=y(:,end);
    li=horzcat(li, intensnow*ones(size(time(startidx:end))));
    
end
%% Create Output Structure
% fill in simulated values to the output struct sim

sim.timevalues                     =    simulatedvalues(1,:);
sim.simulatedvalues                =    simulatedvalues(2:end,:);
sim.simparams                      =    simparams;
sim.LightIntensity                 =    li;

