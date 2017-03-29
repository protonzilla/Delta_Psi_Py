%% Code and Equations for Kinetic Model of Psbs-Dependent Nonphotochemical Quenching

%% Reproducing Figures from Manuscript
% This site contains the code for the model of rapidly-reversible
% nonphotochemical quenching described in the manuscript "A Kinetic Mode of
% PbsS-Dependent Nonphotochemical Quenching" by Julia Zaks, Kapil Amarnath,
% David Kramer, Krishna Niyogi, and Graham Fleming. 
%
% The simulations portions of Figures 4-6 in the paper  can be generated using the scripts
% 
% <makeFigures.html |makeFigures|>
% 
% <makePamFigures.html |makePamFigures|>
% 
% <makeStaticFigures.html  |makeStaticFigures|>
% 
% 
% 
% In order to run the scripts, it is necesary to generate the variable samplepam using the script <PamSim.html |PamSim|>. 
% 
% The images in figure 4 are generated with the script <makeFigures.html |makeFigures|>. The script also loads and displays experimental data, and makes use of the class <data/html/pamtraceAv.html |pamtraceAv|> and <data/html/pamtrace1.html |pamtrace1|>  to organize the data. 
% 
% 
% 
% 
%% Model Differential Equations
% 
% The differential equations for each module (F_1-F_8, described in the Supplementary information) are contained in the following functions
% 
% <evolvePSII.html Photosystem II|>
% 
% <evolveqE.html qE quenching>
% 
% <evolvePQ.html Plastoquinone Pool>
% 
% <evolvecytb6f.html Cytochrome b6f>
% 
% <evolvePSI.html Photosystem I>
% 
% <evolveLumen.html Lumen Flux>
% 
% <evolveATPsynthase.html  ATP Synthase>
% 
% <evolveMV.html Reduction of Ferredoxin in Stroma>
% 
% 
% 
% In order to evaluate values such as the pH gradient, chemical potential gradient, and transmembrane electric field, which are quantities that are not differential equations themselves, these functions call 
% 
% <getStaticThylakoidValues.html |getStaticThylakoidValues|> 
% 
% <getStaticQuencherValues.html  |getStaticQuencherValues|>
% 
% 
% 
%% Running a Simulation
% 
% 1. Setting up Input
% 
% To run a simulation, it is necessary to specify the intensity of light that is input to the model and and the duration of light. These need to be specificed in the variables |LightIntensity| and |durat|. The light intensity sequence for a PAM trace can be set up with <setupPAMIntensities.html |setupPAMIntensities|>. 
% 
% 
% 
% 2. Running model
% 
% <chloroplastSim.html |chloroplastSim|> takes a series of light intensities and durations, and sequentially calls
% 
% <runChloroplastSim.html |runChloroplastSim|>, which simulates the
% variables for a single light intensity. The initial conditions for each section are the final values for the previous section. This function calls the differential equation solver (usually |ode15s|) and evaluates the differential equations for each module by calling them with the function <evolveVars.html |evolveVars|>
% 
% the function <chloroplastSim.html |chloroplastSim|> stitches together the simulations from the different light intensities and returns a struct containing the simulated values, the parameters for the simulation, and auxiliary information.
% 
% 3. Plotting Resuts
% 
% <plotvar.html |plotvar|> plots an individual variable for which there is an explicit differential equation
% 
% <plotStaticValues.html |plotStaticValues|> plots an individual variable that is evaluated by the functions <getStaticThylakoidValues.html |getStaticThylakoidValues|> and <getStaticQuencherValues.html |getStaticQuencherValues|>. 
% 
% <plotStaticVals.html |plotStaticVals|> plots several specific variables.
% 
% <plotallvars.html |plotallvars|> plots all the simulated variables. 
% 
% <plotFlux.html |plotFlux|> plots the flux of a given variable by plotting the rate of change from all the different modules that affect that variable.
% 
% To calculate NPQ-related parameters, the function <getChlorophyllkRates.html |getChlorophyllkRates|> calculates the rates of various quenching pathways for chlorophyll.
% 
% 
% 
% 4. Example functions
% 
% PamSim simulates PAM fluorescence experiment. It is used to generate the data in the paper.
% 
% <sampleSim.html |sampleSim|>
% 
% <testPSII.html |testPSII|>
% 
% The sequence of light intensities used to simulate PAM fluorescence measurements are set up in the script <initChloroplastSim.html |initChloroplastSim|>. 
% 
% 
% 
% The parameters used for the simulations are contained in the file <params.txt>, and are loaded into matlab using the script <getparamsfromfilename.html |getparamsfromfilename|>.
% 
% 

%% Proper Citation
% Any published result that uses this code should cite the paper.
