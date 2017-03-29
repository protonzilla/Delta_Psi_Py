
function sim=setupAndRunSimulation(varargin)
paramsfilename='params.txt';
paramstochange.paramname{1}=[];

quenchmodel=1;
simtype{1}='varint';
act=700;
actduration=3600;
switchperiod=60;

plotfigsyesno=0;

if nargin==0
    plotfigsyesno=1;
end
if nargin>=1
    act=varargin{1};
end
if nargin>=2
    if ischar(varargin{2})
        paramsfilename=varargin{2};
    else if isstruct(varargin{2})
            paramstochange=varargin{2}
        else
            error('input 2 cannot be read')
        end
    end
end
if nargin>=3
    quenchmodel=varargin{3};
end
if nargin>=4
    
    simtype{1}=varargin{4};
end
if nargin>=5
    actduration=varargin{5};
end
if (nargin>=6)&&~isempty(varargin{6})
    switchperiod=varargin{6};
end

if length(quenchmodel)>1
    error('quenchmodel is not well defined')
end
params=getparamsfromfilename(paramsfilename);

for k=1:length(paramstochange.paramname{1})
    if ~isfield(params, paramstochange.paramname{1}{k})
        error('this parameters name is incorect')
    end
    params.(paramstochange.paramname{1}{k})=paramstochange.paramvalue(k);
end
if strmatch( simtype{1},'varint', 'exact')
    intenparams.act=act;
    intenparams.verylow=.1;
    beforeaftertime=1e3;
    intenparams.durat        =[ beforeaftertime     actduration  beforeaftertime ];
    intenparams.lightintensity=[ intenparams.verylow act  intenparams.verylow   ] ;
end
if strmatch( simtype{1},'varintpul', 'exact')
    intenparams.act=act;
    intenparams.verylow=1;
    beforeaftertime=1e3;
    sat=10000;
    satduration=0.8;
    intenparams.durat        =[ beforeaftertime  satduration   actduration  beforeaftertime ];
    intenparams.lightintensity=[ intenparams.verylow sat act  intenparams.verylow   ] ;
end

if strmatch(simtype{1},'oneint')

    intenparams.verylow=1e-6;   %3;
    intenparams.durat        =[actduration   ];
    intenparams.lightintensity=[  act   ] ;
    intenparams.act=act;
end

if strmatch(simtype{1},'PAMsim')
    sat=10000;
    sim.satintensity=sat;
    intenparams.sat=sat;
    intenparams.act=act;
    intenparams.low=1;
    intenparams.verylow=1;%3;
    intenparams.dark=0.0;
    intenparams.flashspacing=120;
    intenparams.flashlength=8e-1;%seconds: the saturating flash shouldn't affect photochemistry
    %Pam fluorescence intensity is 2-3 microeinsteins and pulses are every 50
    %milliseconds
    intenparams.segmentduration =[ actduration  actduration]
    intenparams.segmentinten     ={ 'act' 'verylow'}
    [intenparams.durat intenparams.lightintensity]=genPAMsimlight(intenparams.segmentduration, intenparams.segmentinten, intenparams)
end

if strmatch(simtype{1}, 'varpul')
    if length(act)==1
        act(2)=1500;
    end
    intenparams.act=act;
    nsegments=ceil(actduration/switchperiod);
    intenparams.durat=zeros(1,nsegments+1);
    intenparams.durat(1)=10
    intenparams.lightintensity(1)=1;
  %  intenparams.durat(2)=1;
    intenparams.durat(2:end)=[switchperiod*ones(1,nsegments)];
    intenparams.lightintensity=zeros(1,nsegments+1);
    intenparams.lightinensity(1)=1;
    intenparams.lightintensity(1:2:end)=act(1);
    intenparams.lightintensity(2:2:end)=act(2);
    duratoffset=sum(intenparams.durat(2:end))-actduration;
    intenparams.durat(end)=intenparams.durat(end)-duratoffset;
    
end

if strmatch(simtype{1}, 'ramp')
    if length(act)~=2
        error('length of act is not right')
    end
    intenparams.act=act;
    nsegments=ceil(actduration/switchperiod);
    intenparams.durat=zeros(1,nsegments+1);
    intenparams.lightintensity=zeros(1,nsegments+1);
    
    intenparams.durat(1)=1e-3;
    intenparams.lightintensity(1)=act(1);
    
    [intenparams.lightintensity(2:end)    intenparams.durat(2:end)]=getramp(actstart, actend, nsegments, duration)
    
end

if strmatch(simtype{1}, 'triangle')
    if length(act)~=2
        error('length of act is not right')
    end
    rampsegments=4;
    intenparams.act=act;
    duration=actduration;
    nramps=actduration/switchperiod;
    nsegments=rampsegments*nramps;
    intenparams.durat=zeros(1,nsegments+1);
    intenparams.lightintensity=zeros(1,nsegments+1);
    intenparams.durat(1)=1e-3;
    intenparams.lightintensity(1)=act(1);
    for j=1:nramps
        actstart=act(mod(j-1,2)+1);
        actend=act(mod(j,2)+1);
        [intenparams.lightintensity((j-1)*rampsegments+2:j*rampsegments+1) intenparams.durat((j-1)*rampsegments+2:j*rampsegments+1)]=getramp(actstart, actend, rampsegments, switchperiod)
    end
end
 
%GET PARAMETERS

sim=chloroplastSim(intenparams.lightintensity, intenparams.durat, params, quenchmodel);

if strmatch( simtype{1},'PAMsim')
    sim.satintensity=sat;
end
sim.intenparams=intenparams;
sim.params=params;
sim.quenchmodel=quenchmodel;
sim=getsimauxvals(sim)

   function [inten durat]=getramp(actstart, actend, nsegments, duration)
        inten=linspace(actstart, actend, nsegments);
        durat=ones(size(inten))*duration/nsegments;
   

