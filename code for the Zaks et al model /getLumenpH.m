function lumenpH=getLumenpH(LumenProtons, params)

lumenpH=params.pHLumenStart-LumenProtons/params.bufferCapacityLumen;
end