function dConc=fluxToConcentration(flux, space, params)

%flux is in units of moles per 
switch(space)
    case 'lumen'
        volumecorrection=params.lumenVolumePerArea;
        direction=1;
    case 'stroma'
        volumecorrection=(params.lumenVolumePerArea*params.StromaVolume/params.LumenVolume);
        direction=-1;
end
dConc=direction*flux./volumecorrection;
end