Delta Psi Py
=====================

Delta-Psi-Py is a **[Python]** package facilitating first-order, exploratory simulations of the effects of capacitance, proton buffering capacity and counter-ion movements on the thylakoid proton motive force (pmf), transthylakoid electric field (Δψ), stroma-lumen pH difference (ΔpH), linear electron flow (LEF), the ratio of ATP/NADPH produced by LEF, the activation and recovery of the lumen pH-dependent form of nontphotochemical quenching (NPQ), termed qE, photosystem II (PSII) activity and recombination rates and 1O2 production. 

New python users should consider installing **[Anaconda]** which includes both the python interpreter and the **[Jupyter]**  python editor.

***

### Installation
Install using pip in the terminal.

```bash
pip install git+https://github.com/tessmero/Delta-Psi-Py.git --upgrade --no-cache-dir
```


### Getting Started

See **[the example notebook](example_with_verbose_plot.ipynb)** which can be downloaded and run/modified using **[Jupyter]**.
See **[Supplemental Information from submitted paper](RS_Supplemental_Information_Delta_Psi_Py_RS_paper_5_submitted_figures (1).ipynb)** which can be downloaded and run/modified using **[Jupyter]**.


### Static and slowly-changing parameters
These variables describe the static, or slowly changing, parameters used in model; these constants are not updated by the odeint package, but can be updated between sub-sets . Baseline (standard) values and descriptions of the major parameters used in the simulations together with citations are given in Tables 1 and 2, but can be modified at run time, or during the simulations. 

| **Parameter,**  **variable name** | **Initial Value** | **Units** | **Description** |
| --- | --- | --- | --- |
| standard PSII content, max\_PSII  | 1 | X 2 · 10-13 moles cm-2, X 6 · 1010 complexes cm-2 | To simplify the calculations, the contents of photosynthetic complexes are normalized to a certain area of the thylakoid membrane, the standard PSII content, or max\_PSII. The initial value is taken from the literature to be 6 · 10-10 complexes cm-2, see (1, 2) |
| cytochrome b6f content, b6f\_content | 1  | complex standard PSII content -1 | b6f\_content describes the content of cytochrome b6f complex relative to the standard PSII content. The content and properties of the cytochrome b6f complex are critical for maintaining photosynthetic control (3-9). Literature values range from substoichiometric to equal to that of PSII, and may change in response to environmental stresses or developmental regulation (10). Changes in this parameter can be compensated by changes in the rate constants. |
| PSI content, PSI\_content | 1  | complex standard PSII content -1 | Describes the content of PSI centers relative to the standard PSII content. Changes in this parameter can be compensated by changes in the rate constants. A recent review of the literature (10) concluded that the ratio of PSI to PSII is relatively close to 1:1, but can vary from species to species, and in response to environmental stresses or developmental regulation (10). |
| ATP synthase content, ATP\_synthase\_content | 1  | complex standard PSII content -1 | Describes the content of ATP synthase centers relative to the standard PSII content. Changes in this parameter can be compensated by changes in the rate constants. |
| lumen volume per standard PSII content lumen\_protons\_per\_turnover | 6.7 · 10-21 | L complex-1 | The lumen volume for each standard PSII content, derived from the estimated lumen volume per area of thylakoid (11). In this version, the volume is held constant, but in reality is expected to change with altered stromal and lumenal osmotic potentials, as reviewed in (12). |
| _n_, n   | 4.67 | scalar | The stoichiometry of moles of protons translocated through the ATP synthase per mole of ATP produced. The value of _n_ can be estimated based on the mechanistic model for ATP synthase and the observed stoichiometry of the c subunit ring in thylakoids (c\_subunits\_per\_ATP\_synthase = 14 (13), indicating 14 protons translocated for a complete rotation of the and the number of ATP molecules made for a full rotation of the F1 subcomplex = 3 (14), suggesting that n = 4.67 |
| ΔGATP, DeltaGatp\_KJ\_per\_mol | 40-45 kJ/mol | kJ/mol | ΔGATP is the free energy stored in stromal ATP/ADP + Pi couple. ΔGATPis thought to remain relatively constant under steady-state conditions, between 40-45 kJ/mol, but can change under fluctuating light (15). |
| ΔGATP(eV) DeltaGatp | 0.42-0.47 | eV | ΔGATP, expressed in electron volts. |
| pHstroma, pHstroma\_initial | 7.8 | pH units | The pH of the stromal compartment. Literature values for pHstroma range from 7.5 to 8, and is thought to be higher during photosynthesis (16, 17). The pH of the stroma (considered to be constant in this version of the simulation). |
| Vmax(VDE) , VDE\_max\_turnover\_number | 1 | s-1 PSII-1 | Because we do not have reliable information on the ratio of VDE to PSII, this value is modulated to roughly match the observed rates of zeaxanthin accumulation. |
| pKa(VDE), pKvde  | 5.8 | pH units | pKa(VDE) is the effective pKa for protonation of the violazanthin de-epoxidase (VDE), that results in the activation of the enzyme (18). |
| Hill coefficient for VDE activation, VDE\_Hill | 4 | scalar | Empirical fitting of Z accumulation to in vivo estimates of lumen pH are consistent with a range of values reported for isolated thylakoids  (18-20). Modulating this parameter from 1-5 affected results quantitatively, but did not alter the major trends. |
| rate constant for ZE, kZE | 0.01 | s-1 | The value of kZE was taken from Takizawa et al. (2007), to account for the apparent difference between the pKa for activation of VDE and the apparent pKa for accumulation of Z. Note that the zKE reaction is considered to be pseudo-first order with respect to the content of Z, and that any dependence on other substrates (NADPH and O2) are ignored. |
| pKa(PsbS), pKPsbS  | 6.0 | pH units | pKa(PsbS) describes the pKa for protonation of PsbS, which results in activation of the rapid qE response.  The value of kZE was taken from Takizawa et al. (7), based on empirical fits to in vivo estimates. |
| NPQmax, max\_NPQ | 5.8 | pH units | NPQmax is an empirically-derived term describing the relationship between maximum level of NPQ at saturation, when all xanthophyll components are in the Z form, and all PsbS is protonated, so that: NPQ=max\_NPQ [PsbS protonation][Z]. The maximum NPQ is known to be dependent on genotype and growth conditions.   |
| Vmax(ATP synthase), ATP\_synthase\_max\_turnover | 1000 | ATP s-1 complex-1 | The maximum turnover rate of ATP synthase. |
| Cthylakoid, Thylakoid\_membrane\_capacitance | 0.6 | F cm-2 | The thylakoid membrane electrical capacitance (1, 2, 11). |
| Inverse thylakoid membrane capacitance, Volts\_per\_charge | 0.033 | V charge-1standard PSII content -1 | Volts\_per\_charge is used to rapidly calculate the membrane voltage generated by chare movements. |
| PK+, perm\_K   | 60-6000 | ions s-1 V-1 standard PSII content -1 | PK+ describes the permeability of the thylakoid to K+ or similar counter-ions. This term is adjusted empirically to modulate the simulated rates of appearance and dissipation of the ΔpH component of _pmf_. The units are in V-1 because as in Cruz et al. 2001, the simulation considers the rate of K+ movement through the channels to be proportional to pK+ and the potassium motive force, Kmf, i.e. the sum of the electrical field and concentration differences, calculated as for the _pmf_, see also below. |
| Vmax(b6f), max\_b6f  | 300 | electrons from PQH2 to PC complex-1 s-1 | Maximum rate of the cytochrome b6f complex, when the plastoquinone pool is in the reduced form (PQH2) and lumen pH is well above the regulatory pKa. The rate is an average of the individual partial reactions, and a value of about 300 is consistent with the observed rates of photosynthesis and complex stoichiometries. |
| pKreg, pKreg | 6.0 | pH units | The pKreg determines pH-dependence of PQH2 oxidation at the cytochrome b6f complex. This is a kinetic constraint, likely related to the deprotonation of a His residue on the Rieske FeS protein (21-23). The empirically measured value is between 6.0 and 6.5 (6-9). |
| Em,7 (PC), Em7\_PC | 0.37 | V (versus SHE) | The midpoint potential of plastocyanin at pH=7, expressed as V against standard hydrogen electrode. The midpoint potential of PC is considered to be pH-independent over the physiological range (24). |
| Em,7 (PQ/PQH2), Em7\_PQH2 | 0.11 | V (versus SHE) | The midpoint potential of the PQ/PQH2 couple at pH=7. This value is pH dependent (22) and is adjusted in the program by -0.06 V per pH unit changes in lumen pH from 7.0. |
| lumen, buffering\_capacity   | 0.03 | M/pH unit | lumen describes the dependence of lumen pH on the number of protons introduced. the buffering capacity of the lumen |
| ΔPSI, PSI\_antenna\_size  | 1 | ratio | ΔPSI describes the relative PSI cross section (compared to that of PSII). Setting  ΔPSI and ΔPSII equal will ensure that photosystems receive the same light flux. |
| kPCP700+, k\_PC\_to\_P700  | 500 | PC-1 s-1 | The rate constant for oxidation of PC by P700+, with unity concentrations of reduced PC and P700+. The reaction is bimolecular, and the rate is determined by the product of kPCP700+, the concentration of reduced PC and P700+.  In version 1.0, the potential complexities of PC interactions with PSI and cytochrome _f_  (25, 26) are simplified in this version of the simulation. |
| ΔPSII, PSII\_antenna\_size | 1 | ratio | Describes the relative PSII cross section. See comments on ΔPSI. |
| kQA, kQA  | 1000 | s-1 | The rate constant for oxidation of QA- by PQ. The reaction is simplified as a second-order process between reduced QA- and oxidized PQ, and thus a rough average of the individual partial reactions (27) that involve a series of electron transfer to QB, exchange of PQ and PQH2 at the QB site etc.   |
| krecomb, k\_recomb   | 0.33 | s-1 | The rate of charge recombination in PSII. The value of krecomb is that for recombination from the S2QA- state in the absence of Δ_ψ_ and ΔpH. The actual value will depend on a number of factors, including the redox state of the oxygen evolving complex, i.e. the S-state as well as Δ_ψ_ and ΔpH. Some S-states are more or less stable than the S2 state, so the current code assumes the average is close to that from S2QA-, which measured in the presence of DCMU but in the absence of an electric field is about 0.3 s-1  The effects of Δ_ψ_ and ΔpH are discussed below. |
| triplet, triplet\_yield | 0.45 | fraction | The yield of 3P680 triplets arising from PSII recombination events. Recombination produces a high yield of 3P680 () |
| 1O2, triplet\_to\_singletO2\_yield | 1.0 | fraction | The yield of 1O2 from chlorophyll triplets, which is likely to be near unity (). |

### Variable states
These variables describe the rapidly changing states of the model, which are updated by the odeint routines. Each of these parameters can change rapidly, and are modified by the odeint solver. 

| **Parameter,**  **variable name** | **Initial Value** | **Units** | **Description** |
| --- | --- | --- | --- |
| Violaxanthin content, V | 1 | Relative | The content of violaxanthin in the thylakoid, expressed in relative units. |
| Zeaxanthin content, Z | 1 | Relative | The content of zeaxanthin in the thylakoid, expressed in relative units. |
| PQ, PQ  | 6  | Relative | The number of molecules of plastoquinone (PQ) in its oxidized form, relative tostandard PSI content. |
| PQH2, PQH2  | 1  | Relative | The number of molecules of plastoquinol (PQH2) in its oxidized form, relative tostandard PSI content. |
| PC(ox), PC\_ox | 0 | Relative | The number of molecules of plastocyanin (PC) in its oxidized form, relative tostandard PSI content. |
| PC(red), PC\_ox | 2 | Relative | The number of molecules of plastocyanin (PC) in its reduced form, relative tostandard PSI content. |
| _pmf_, pmf   | 0.06(ΔpH) + Δψ | V | The total proton motive force, _pmf_ The initial value is calculated from the sum of energetic contributuions from ΔpH and Δ. |
| ΔGATP, DeltaGatp\_KJ\_per\_mol | 40-45 kJ/mol | kJ/mol | ΔGATP is the free energy stored in stromal ATP/ADP + Pi couple. ΔGATPis thought to remain relatively constant under steady-state conditions, between 40-45 kJ/mol, but can change under fluctuating light (15). |
| ΔGATP (eV) DeltaGatp | 0.42-0.47 | eV | ΔGATP, expressed in electron volts. |
| pHstroma, pHstroma | 7.8 | pH units | The pH of the stromal compartment. Literature values for pHstroma range from 7.5 to 8, and is thought to be higher during photosynthesis (16, 17). The pH of the stroma (considered to be constant in this version of the simulation). |
| pHlumen, pHlumen | \*calculated at run time | pH units | The pH of the lumen. |
| K+lumen, Klumen  | 0.01-0.1 | M | The concentration of K+ in the lumen. The current model assumes that all K+ is free, i.e. not bound. |
| K+stroma, Kstroma  | 0.01-0.1 | M | The concentration of K+ in the stroma. The current model assumes that all K+ is free, i.e. not bound. In the current model, K+stroma is assumed to be constant. |
|  QA, QA\_content  | 1 | relative | The content of oxidized QA relative to standard PSII. |
| QA-, QAm\_content  | 0 | relative | The content of semiquinone QA- relative to standard PSII. |
| P700+, P700\_ox  | 0 | relative | The content of oxidized P700+ relative to PSI. |
| P700, P700\_red  | 1 | relative | The content of reduced P700 relative to PSI. |
| Fd(ox), Fd\_ox | 1 | relative | The content of oxidized ferredoxin (Fd) relative to standard PSII. |
| Fd(red), Fd\_red | 0 | relative | The content of reduced ferredoxin (Fd) relative to standard PSII. |
| NPQ | 0 | relative | The ratio of rate constant (kNPQ) for regulated nonphotochemical quenching (NPQ)  NPQ (kNPQ) relative to the sum of rate constants for non-radiative decay and fluorescence, see text for details. |
| 1O2, singletO2  | 0 | relative | The number of 1O2 molecules produced per standard PSII. |
| [ATP], ATP\_pool  | Set by DGATP, | relative | The content of ATP in the stroma relative to standard PSII. The value is set from the initial DGATP value, with ATP+ADP=60 |
| [ADP], ADP\_pool  | 30 |   | The content of ADP in the stroma relative to standard PSII. |

[Python]: https://www.python.org/ "Python"

[Jupyter]: http://jupyter.org/ "Jupyter"

[Anaconda]: https://www.continuum.io/downloads "Anaconda"