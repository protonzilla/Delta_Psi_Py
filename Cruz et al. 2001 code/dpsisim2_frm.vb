Option Strict Off
Option Explicit On
Friend Class Simulation
	Inherits System.Windows.Forms.Form
	Private Sub Command1_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles Command1.Click
		autorunon = False
		OutFile = OutFileText.Text
		FileOpen(2, "c:\" & OutFile, OpenMode.Output)
		FileOpen(5, "c:\stuff.dat", OpenMode.Output)
		Call dosim()
		FileClose(2)
		FileClose(5)
		Text2.Text = "FINISHED"
		
	End Sub
	
	Sub dosim()
		stopsim = False
		
		pHlumen = Val(pHlumentext.Text)
		pHstroma = Val(pHStromaText.Text)
		
		
		'If pHlumen# > 6.7 Then
		'    Hlumen# = (7.9 - pHlumen#) / 105
		'ElseIf pHlumen# > 6.3 Then
		'    Hlumen# = (6.6 - pHlumen#) / 27
		'Else
		'    Hlumen# = (6.6 - pHlumen#) / 14
		'End If
		
		'Hlumen# = (6.6 - pHlumen#) / 14
		'Hlumen# = (7 - pHlumen#) / 4  'FOR 100 mM buffers
		
		Hlumen = 10 ^ (-1 * pHlumen)
		pKreg = Val(pKregtext.Text)
		MaxPSFlux = Val(MaxPSFluxtext.Text) * 0.000000000001
		FractionSaturated = Val(FractSattext.Text)
		TimeSlice = Val(TimeSliceText.Text)
		MemCap = Val(MemCapText.Text) * 0.000001
		LumenVol = Val(LumenVolText.Text) * 0.000000001
		LumenBuf = Val(LumenBufText.Text)
		CyclesOn = Val(CyclesOnText.Text)
		CyclesOff = Val(CyclesOffText.Text)
		gATPSynth = Val(gATPSynthText.Text) * 0.000000000001 'conductance of the ATP synthase in moles cm-2V-1s-1
		LumenCl = Val(lumenCltext.Text)
		StromaCl = Val(StromaCltext.Text)
		PCl = Val(PClText.Text)
		PK = Val(PKtext.Text)
		LumenK = Val(lumenKtext.Text)
		StromaK = Val(StromaKtext.Text)
		
		pCa = Val(pCaText.Text)
		lumenCa = Val(LumenCaText.Text)
		stromaCa = Val(StromaCaText.Text)
		
		Update = Val(UpdateText.Text)
		InitUpDate = Val(InitUpDateText.Text)
		If COUNTER.CheckState = 1 Then docounter = True Else docounter = False
		
		
		OutFile = OutFileText.Text
		
		
		'Picture1.Cls
		Call plotbaseline()
		System.Windows.Forms.Application.DoEvents()
		
		'Global LumenVol# 'volume of the lumen in liters/cm2 of thylakoid area.
		'Global LumenBuf# 'buffering capacity of the lumen
		
		
		
		TotalCycles = CyclesOn + CyclesOff
		PlotOffset = 0
		
		
		'Text1.Text = "c:\" + OutFile$
		PrintLine(2, "Series Number=" & Str(SeriesNumber))
		DeltaPsi = 0 'needs to be reset if re-running warm
		
		For i = 1 To CyclesOn
			
			Call simulate()
			If stopsim = True Then
				FileClose()
				Exit Sub
			End If
		Next i
		
		PlotOffset = CyclesOn
		Call savestuff()
		
		For i = 1 To CyclesOff
			MaxPSFlux = 0
			Call simulate()
			
			If stopsim = True Then
				FileClose()
				Exit Sub
			End If
			
		Next i
		
		
	End Sub
	
	Sub simulate()
		Call CalcPSFlux()
		ATPsynth = 0
		Clflux = 0
		Call Helectogenicity()
		Call CalcpHlumen()
		Call calcpmf()
		Call calcATPsyth()
		Hin = 0
		Call CalcpHlumen()
		Call Helectogenicity()
		Call calcpmf()
		
		If docounter = True Then
			Call counterions()
		Else
			Call ions()
		End If
		
		ATPsynth = 0
		Call Helectogenicity()
		Call calcpmf()
		
		If i < InitUpDate Then
			UpDateD = 1
		Else
			UpDateD = Update
		End If
		
		If Int(i / UpDateD) = i / UpDateD Then
			Call plotstuff()
			Call savedata()
			If UpdateStuff.CheckState = 1 Then
				Call Updatetexts()
			End If
			System.Windows.Forms.Application.DoEvents()
			
		End If
		
	End Sub
	Public Sub CalcPSFlux()
		
		'Light-dependent flux of protons into lumen:
		
		' We simplify the system by treating the photosynthetic apparatus as a simple flux
		' problem, but with a pHlumen-dependent maximum rate.  This reflects the pK on the
		' cyt b6f complex, below which rate drops off by a factor of 10/pH unit.  The
		' equation for this behavor is:
		'         PSFlux=MaxRate*ModpH*fractionsaturated
		' where PSFlux if the light-driven flux of protons into lumen
		' By calculating the number of protons deposited in the lumen by linear electron
		' transfer after a single turnover flash (equilavent to 50 mV with a capacitance of
		' 0.6 uF/cm2 (see page 81 of Project DPSI notebook, Vol. 1), or by calculating the #
		' of RCs/unit area, and a turnover time of 10 ms for the ntire chain (i.e. 3 H+) we
		' arrive at a maximum rate of: 30 pmoles H+ cm-2s-1
		' This is modified by the light intensity, regulatory light dissipative factors and
		' controlled by the pH of the lumen.  Using the Nishio and Whitmarsh estimated of b6f
		' turnover and assuming that this controls rate (i.e. for the time being ignoring
		' regulatory behavior, we arrive at:
		'               ModpH = 1 - (1 / (10 ^ (pHlumen# - pKreg#) + 1))
		'   where pH is the pH of the lumen and pKr is the pK of the control process (i.e. \
		' about 6.5).
		' We also ignore control by delta.psi (see Diner and Lavergne papers)
		
		'Global pHlumen#
		'Global pKreg#
		'Global MaxPSFlux#
		'Global PSFlux#
		'Global FractionSaturated#
		'Global ModpH#
		'Global TimeSlice# 'the time over which each iteration of the simulation is calculated
		'Global Hin# 'the number of protons transported to the lumen
		
		
		ModpH = 1 - (1 / (10 ^ (pHlumen - pKreg) + 1))
		
		psflux = MaxPSFlux * FractionSaturated * ModpH
		Hin = psflux * TimeSlice
		
		
		
	End Sub
	
	Sub Updatetexts()
		HinText.Text = CStr(Hin)
		ModpHCaption.Text = CStr(ModpH)
		PSFluxCaption.Text = CStr(psflux)
		DeltaPsiCaption.Text = CStr(DeltaPsi)
		HlumenCaption.Text = CStr(Hlumen)
		pHlumentext.Text = CStr(pHlumen)
		dpHLumenCaption.Text = CStr(dpHlumen)
		pmfcaption.Text = CStr(pmf)
		ATPSynthCaption.Text = CStr(ATPsynth)
		Clmftext.Text = CStr(Clmf)
		ClFluxCaption.Text = CStr(Clflux)
		lumenCltext.Text = CStr(LumenCl)
		Clmftext.Text = CStr(Clmf)
		KFluxCaption.Text = CStr(Kflux)
		lumenKtext.Text = CStr(LumenK)
		
	End Sub
	Sub Helectogenicity()
		' Here we caclulate the electrogenicity of the protons pumped INTO the lumen by
		' photosynthesis using the membrane capacitance and Hin# (the number of protons pumped in)
		'Global MemCap# 'membrane capacitance
		'Global DeltaPsi# 'membrane electric Field (V)
		' use the standard equation for q=CV and convert from moles to Coulonbs:
		' V = (moles charges*10^5)/Cap
		
		DeltaPsi = DeltaPsi + (Hin * 10 ^ 5) / MemCap - (ATPsynth * 10 ^ 5) / MemCap - (Clflux * 10 ^ 5) / MemCap - (zion * Kflux * 10 ^ 5) / MemCap - (caflux * 10 ^ 5) / MemCap
		
	End Sub
	
	Sub CalcpHlumen()
		
		' Here we calculate the concentration of total and free protons in the lumen.
		' We need the volume of the lumen per cm2 of thylakoid membrane area and the
		' buffering capacity of the lumen.
		
		' First, we calculate the molarity of the free+bound (i.e. total input protons)
		
		
		'Hlumen# = Hlumen# + Hin# / LumenVol# - ATPsynth# / LumenVol#
		
		If docounter = True Then
			Hlumen = Hin / LumenVol - ATPsynth / LumenVol - Kflux / 2
		Else
			
			Hlumen = Hin / LumenVol - ATPsynth / LumenVol - caflux / 2
			
		End If
		
		
		'If Hlumen# < 0.01 Then
		
		'    pHlumen# = 7.9 - 105 * Hlumen#
		
		'ElseIf Hlumen# < 0.03 Then
		'    pHlumen# = 7 - 27 * Hlumen#'
		
		'Else
		'   pHlumen# = 6.6 - 14.3 * Hlumen#
		
		'End If
		
		'pHlumen# = 6.6 - 14.3 * Hlumen#  '40 mM buffers
		
		'pHlumen# = 7 - 4 * Hlumen#  '100 mM buffers
		
		'(Hfree# * Cbuffer#(1) * kbuff# / Kbuffer#(1)) + Hbound# * kbuff#
		
		'(Hfree# * Cbuffer#(1) * kbuff# / Kbuffer#(1)) - Hbound# * kbuff#
		
		
		
		' We introduce a term, dpHlumen# to describe the change in pH per change in proton concentration,
		' as defined by the buffering capacity:
		
		' Beta (buff cap) = -d([H+]+.sigma.[HB+])/dpH
		' or
		' dpH = -d([H+]+.sigma.[HB+])/Beta
		
		dpHlumen = -1 * Hlumen / LumenBuf
		pHlumen = pHlumen + dpHlumen
		
		
		deltapH = pHstroma - pHlumen
		
	End Sub
	
	Sub calcpmf()
		' We now calculate pmf#
		
		pmf = DeltaPsi + (0.06 * (pHstroma - pHlumen))
		
		
	End Sub
	
	Sub calcATPsyth()
		' Here we caluclate the flux through the ATP synthase per time slice
		' We use Ohm's law rather than the 'Flux equation, because,
		' above the activation threshold for the enzyme
		' flux has been shown to be Ohmic with repect to pmf, regardless of the
		' origin of the pmf (i.e. it does not matter whether the pmf comes from .delta..psi.
		' or from .delta.pH
		
		' We've estimated a conductance for the ATP synthase from its activity of 1 ATP synthesized
		' per turnover of PSI/PSII (i.e. 3 protons) per 10 ms (i.e. the overall most rapid turnover time
		' of the chain, and a steady-state estimate of pmf=0.1V.  This probably needs to be adjusted to reflect
		' something over n*DGATP, but will suffice for now.
		
		' PATPSynth#=1.8e-9 moles cm-2 v-1 s-1
		
		' where v is the pmf in volts.
		
		
		ATPsynth = pmf * gATPSynth * TimeSlice
		
		
	End Sub
	
	Sub plotstuff()
		'For ip% = 1 To 100
		'UPGRADE_ISSUE: PictureBox method Picture1.PSet was not upgraded. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="CC4C7EC0-C903-48FC-ACCC-81861D12DA4A"'
		Picture1.PSet ((i + PlotOffset) / (TotalCycles), pmf), QBColor(5)
		'UPGRADE_ISSUE: PictureBox method Picture1.PSet was not upgraded. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="CC4C7EC0-C903-48FC-ACCC-81861D12DA4A"'
		Picture1.PSet ((i + PlotOffset) / (TotalCycles), 0.06 * deltapH), QBColor(13)
		'UPGRADE_ISSUE: PictureBox method Picture1.PSet was not upgraded. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="CC4C7EC0-C903-48FC-ACCC-81861D12DA4A"'
		Picture1.PSet ((i + PlotOffset) / (TotalCycles), DeltaPsi), QBColor(12)
		
		
		'Next ip%
	End Sub
	
	Sub savedata()
		PrintLine(2, (i + PlotOffset) * TimeSlice & Chr(9) & pmf & Chr(9) & DeltaPsi & Chr(9) & deltapH)
		
	End Sub
	Sub savestuff()
		
		PrintLine(5, pmf & Chr(9) & DeltaPsi & Chr(9) & deltapH)
		
	End Sub
	Sub plotbaseline()
		For i = 1 To 100
			'UPGRADE_ISSUE: PictureBox method Picture1.PSet was not upgraded. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="CC4C7EC0-C903-48FC-ACCC-81861D12DA4A"'
			Picture1.PSet (i / 100, 0), QBColor(12)
		Next i
		
		'Next ip%
	End Sub
	
	
	Sub ions()
		
		' Cl-
		'calculate the chloride motive force (Clmf)
		
		Clmf = (-0.06 * (System.Math.Log(LumenCl / StromaCl)) / 2.3) + DeltaPsi
		
		'Calculate the flux of Cl- using the Flux Equation:
		
		Clflux = PCl * ((LumenCl + StromaCl) / 50) * Clmf * TimeSlice
		LumenCl = LumenCl + (Clflux / LumenVol)
		
		'StromaCl# = StromaCl# - Clflux#
		
		' K+
		'calculate the potasium motive force (Kmf)
		
		Kmf = (0.06 * (System.Math.Log(LumenK / StromaK)) / 2.3) + DeltaPsi
		
		
		' Ca2+
		'calculate the Calcium motive force (Camf)
		
		Camf = (0.06 * (System.Math.Log(lumenCa / stromaCa)) / 2.3) + DeltaPsi - (0.06 * (pHstroma - pHlumen))
		
		'pmf# = DeltaPsi# + (0.06 * (pHstroma# - pHlumen#))
		
		'Calculate the flux of Cl- using the Flux Equation:
		Kflux = PK * ((LumenK + StromaK) / 50) * Kmf * TimeSlice
		
		LumenK = LumenK - (Kflux / LumenVol)
		If LumenK < 0 Then LumenK = 0
		
		
		caflux = pCa * ((lumenCa + stromaCa) / 50) * Camf * TimeSlice
		
		lumenCa = lumenCa - (caflux / LumenVol)
		'LumenCaText.Text = lumenCa# 'Int(lumanCa# * 1000) / 1000
		If lumenCa < 0 Then lumenCa = 0
		
		
		
	End Sub
	
	Sub counterions()
		' Cl-
		'calculate the chloride motive force (Clmf)
		
		Clmf = (-0.06 * (System.Math.Log(LumenCl / StromaCl)) / 2.3) + DeltaPsi
		
		'Calculate the flux of Cl- using the Flux Equation:
		
		Clflux = PCl * ((LumenCl + StromaCl) / 50) * Clmf * TimeSlice
		LumenCl = LumenCl + (Clflux / LumenVol)
		
		' Cl-
		'calculate the K+ motive force (Kmf)
		
		'calculate the potasium motive force (Kmf) with a 2K+/1H+ antiporter
		
		Kmf = (2 * 0.06 * (System.Math.Log(LumenK / StromaK)) / 2.3) + DeltaPsi - (0.06 * deltapH)
		
		'calculate the potasium motive force (Kmf) with a K+/2H+ antiporter
		
		'Kmf# = (0.06 * (Log(LumenK# / StromaK#)) / 2.3) - DeltaPsi# - (0.12 * deltapH#)
		
		'Calculate the flux of K+ using the Flux Equation:
		
		Kflux = PK * ((LumenK + StromaK) / 50) * Kmf * TimeSlice
		
		LumenK = LumenK - (Kflux / LumenVol)
		If LumenK < 0 Then LumenK = 0
		
		
	End Sub
	
	Private Sub Command2_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles Command2.Click
		'UPGRADE_ISSUE: PictureBox method Picture1.Cls was not upgraded. Click for more: 'ms-help://MS.VSCC.v90/dv_commoner/local/redirect.htm?keyword="CC4C7EC0-C903-48FC-ACCC-81861D12DA4A"'
		Picture1.Cls()
		
	End Sub
	
	Private Sub Command3_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles Command3.Click
		Dim j As String 'junk
		
		FileOpen(1, "c:\dpsisimi.txt", OpenMode.Input)
		
		Input(1, j)
		Input(1, pHlumen)
		pHlumentext.Text = CStr(pHlumen)
		
		Input(1, j)
		Input(1, pHstroma)
		pHStromaText.Text = CStr(pHstroma)
		
		Input(1, j)
		Input(1, j)
		pKregtext.Text = j
		
		Input(1, j)
		Input(1, j)
		MaxPSFluxtext.Text = j
		
		Input(1, j)
		Input(1, j)
		FractSattext.Text = j
		
		Input(1, j)
		Input(1, j)
		TimeSliceText.Text = j
		
		Input(1, j)
		Input(1, j)
		MemCapText.Text = j
		
		Input(1, j)
		Input(1, j)
		LumenVolText.Text = j
		
		Input(1, j)
		Input(1, j)
		LumenBufText.Text = j
		
		
		Input(1, j)
		Input(1, j)
		CyclesOnText.Text = j
		
		Input(1, j)
		Input(1, j)
		CyclesOffText.Text = j
		
		Input(1, j)
		Input(1, j)
		gATPSynthText.Text = j
		
		Input(1, j)
		Input(1, j)
		lumenCltext.Text = j
		
		Input(1, j)
		Input(1, j)
		StromaCltext.Text = j
		
		Input(1, j)
		Input(1, j)
		PClText.Text = j
		
		Input(1, j)
		Input(1, j)
		PKtext.Text = j
		
		
		Input(1, j)
		Input(1, j)
		lumenKtext.Text = j
		
		Input(1, j)
		Input(1, j)
		StromaKtext.Text = j
		
		Input(1, j)
		Input(1, j)
		UpdateText.Text = j
		
		
		Input(1, j)
		Input(1, j)
		InitUpDateText.Text = j
		
		FileClose(1)
	End Sub
	
	
	Private Sub savevars()
		Dim j As String 'junk
		
		FileOpen(1, "c:\dpsisimo.txt", OpenMode.Output)
		
		PrintLine(1, "pHlumen")
		PrintLine(1, pHlumentext.Text)
		
		PrintLine(1, "pHStroma")
		PrintLine(1, pHStromaText.Text)
		
		PrintLine(1, "pKreg")
		PrintLine(1, pKregtext.Text)
		
		PrintLine(1, "MaxPSFlux")
		PrintLine(1, MaxPSFluxtext.Text)
		
		PrintLine(1, "FractionSaturated")
		PrintLine(1, FractSattext.Text)
		
		PrintLine(1, "TimeSlice (s)")
		PrintLine(1, TimeSliceText.Text)
		
		PrintLine(1, "Membrane Capcitance (uF/cm2)")
		PrintLine(1, MemCapText.Text)
		
		PrintLine(1, "lumen volumen l/cm2)")
		PrintLine(1, LumenVolText.Text)
		
		PrintLine(1, "Lumen Buffering capacity")
		PrintLine(1, LumenBufText.Text)
		
		PrintLine(1, "number of cycles to simulate with light ON")
		PrintLine(1, CyclesOnText.Text)
		
		PrintLine(1, "number of cycles to simulate with light OFF")
		PrintLine(1, CyclesOffText.Text)
		
		PrintLine(1, "conductivity of the ATP synthase")
		PrintLine(1, gATPSynthText.Text)
		
		PrintLine(1, "[Cl-] lumen")
		PrintLine(1, lumenCltext.Text)
		
		PrintLine(1, "[cation]lumen")
		PrintLine(1, StromaCltext.Text)
		
		PrintLine(1, "permeability of the thylakoid to Cl-")
		PrintLine(1, PClText.Text)
		
		PrintLine(1, "permeability of thylakoid to cation")
		PrintLine(1, PKtext.Text)
		
		PrintLine(1, "[cation] (lumen)")
		PrintLine(1, lumenKtext.Text)
		
		
		PrintLine(1, "[cation] (lumen)")
		PrintLine(1, StromaKtext.Text)
		
		PrintLine(1, "Update when divisible by")
		PrintLine(1, UpdateText.Text)
		
		
		PrintLine(1, "Initial Update")
		PrintLine(1, InitUpDate)
		
		FileClose(1)
	End Sub
	
	Private Sub Command4_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles Command4.Click
		Call savevars()
	End Sub
	
	
	Sub autorun()
		
		stopsim = False
		
		Text2.Text = "STARTED"
		
		OutFile = OutFileText.Text
		FileOpen(2, "c:\" & OutFile, OpenMode.Output)
		FileOpen(5, "c:\stuff.dat", OpenMode.Output)
		
		FileOpen(1, "c:\series.txt", OpenMode.Input)
		
		If stopsim = True Then
			FileClose()
			Exit Sub
		End If
		
		Dim j As String 'junk
		While EOF(1) = False
			
			SeriesNumber = 0
			
			SeriesNumber = SeriesNumber + 1
			Input(1, j)
			Input(1, pHlumen)
			pHlumentext.Text = CStr(pHlumen)
			
			Input(1, j)
			Input(1, pHstroma)
			pHStromaText.Text = CStr(pHstroma)
			
			Input(1, j)
			Input(1, j)
			pKregtext.Text = j
			
			Input(1, j)
			Input(1, j)
			MaxPSFluxtext.Text = j
			
			Input(1, j)
			Input(1, j)
			FractSattext.Text = j
			
			Input(1, j)
			Input(1, j)
			TimeSliceText.Text = j
			
			Input(1, j)
			Input(1, j)
			MemCapText.Text = j
			
			Input(1, j)
			Input(1, j)
			LumenVolText.Text = j
			
			Input(1, j)
			Input(1, j)
			LumenBufText.Text = j
			
			
			Input(1, j)
			Input(1, j)
			CyclesOnText.Text = j
			
			Input(1, j)
			Input(1, j)
			CyclesOffText.Text = j
			
			Input(1, j)
			Input(1, j)
			gATPSynthText.Text = j
			
			Input(1, j)
			Input(1, j)
			lumenCltext.Text = j
			
			Input(1, j)
			Input(1, j)
			StromaCltext.Text = j
			
			Input(1, j)
			Input(1, j)
			PClText.Text = j
			
			Input(1, j)
			Input(1, j)
			PKtext.Text = j
			
			
			Input(1, j)
			Input(1, j)
			lumenKtext.Text = j
			
			Input(1, j)
			Input(1, j)
			StromaKtext.Text = j
			
			Input(1, j)
			Input(1, j)
			UpdateText.Text = j
			
			Input(1, j)
			Input(1, j)
			InitUpDateText.Text = j
			
			Call dosim()
			
			If stopsim = True Then
				FileClose()
				Exit Sub
			End If
			
		End While
		
		FileClose(1)
		FileClose(2)
		FileClose(5)
		Text2.Text = "FINISHED"
		
	End Sub
	
	Private Sub Command6_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles Command6.Click
		stopsim = True
		
	End Sub
	
	Private Sub Simulation_Load(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles MyBase.Load
		autorunon = True
		zion = 1
	End Sub
	
	Private Sub RunSeries_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles RunSeries.Click
		autorunon = True
		Call autorun()
	End Sub
End Class