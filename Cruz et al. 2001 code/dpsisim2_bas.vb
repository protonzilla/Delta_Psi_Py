Option Strict Off
Option Explicit On
Module Module1
	Public Camf As Double
	Public pCa As Double
	Public lumenCa As Double
	Public stromaCa As Double
	Public caflux As Double
	
	Public docounter As Short
	Public pHlumen As Double
	Public Hfree As Double ' the concentration of free protons
	Public Cbuffer(20) As Double ' the concentrations of each buffer
	Public Kbuffer(20) As Double ' the binding constant for each buffer for protons (i.e. 10^(-pKa)
	Public kbuff As Double 'the rate of proton unbinding from buffers
	' kon=kbuff/Kbuffer#()
	Public zion As Double ' holds the charge of the ion
	Public pHstroma As Double
	Public deltapH As Double
	Public pKreg As Double
	Public MaxPSFlux As Double
	Public psflux As Double
	Public FractionSaturated As Double
	Public ModpH As Double
	Public TimeSlice As Double
	Public Hin As Double
	Public MemCap As Double 'membrane capacitance
	Public DeltaPsi As Double 'membrane electric Field (V)
	Public LumenVol As Double 'volume of the lumen in liters/cm2 of thylakoid area.
	Public LumenBuf As Double 'buffering capacity of the lumen
	Public dpHlumen As Double 'change in pH of lumen per time slice
	Public Hlumen As Double 'change in total H+ concentation in the lumen per time slice
	Public ATPsynth As Double ' flux through the ATP synthase per time slice
	Public gATPSynth As Double 'conductance of the ATP synthase in moles cm-2V-1s-1
	Public pmf As Double 'proton motive force
	Public CyclesOn As Double 'cycles to simulate with light on
	Public CyclesOff As Double 'cycles to simulate with light off
	Public i As Double 'index of which cycle is presently being simulated
	Public LumenCl As Double 'lumen [Cl-]
	Public StromaCl As Double 'Stroma [Cl-]
	Public PCl As Double 'Permeability of Cl- to the membrane
	Public Clflux As Double 'flux of Cl- per time slice
	Public Clmf As Double 'the Cl- motive force
	Public Kmf As Double 'the K+ motive force
	Public LumenK As Double 'concentration of K+ in lumen
	Public StromaK As Double 'concentration of K+ in stroma
	Public Kflux As Double 'flux of K+ per time slice
	Public PK As Double 'Permeability of K to the membrane
	Public TotalCycles As Double
	Public PlotOffset As Double
	Public Update As Double 'when index is divisive by Update#, do plotting and saving routines
	Public OutFile As String
	Public autorunon As Short
	Public InitUpDate As Double
	Public UpDateD As Double
	Public SeriesNumber As Short
	Public stopsim As Short ' flag indicating that the simulation should stop
End Module