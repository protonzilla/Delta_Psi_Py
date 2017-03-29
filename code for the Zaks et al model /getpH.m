function out=getpH(protons, params, space)


if strcmpi(space, 'lumen')
        out=params.pHLumenStart-protons/params.bufferCapacityLumen;
end


if strcmpi(space, 'stroma')
        out=params.pHStromaStart-protons/params.bufferCapacityStroma;
end
    