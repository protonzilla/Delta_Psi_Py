function fractionFreeProtons=getFractionFreeProtons(totalProtons, space)


switch space
    case 'lumen'
        %from Photosynthesis Research 9, 211-227 (1986)
        
        bufferConcentration =[10  10   10 10  15  40  40  45  50   70]'*1e-3;  % numbers are in millimolar
        bufferpKa  =         [8   7.5   7 6.5 6.0 5.5 5.0 4.5 4.0 3.5]';
        
    case'stroma'
        
        bufferConcentration =[800 1700 2000 ]' ;  % 10 times more than lumen
        bufferpKa  =         [8   7.5  7 ]';
        
end

bufferKa   =         10.^-[bufferpKa];
totalProtonsM         =ones(size(bufferKa))*totalProtons;
bufferKaM             =bufferKa*ones(size(totalProtons));
bufferConcentrationM  =bufferConcentration*ones(size(totalProtons));


fractionFreeProtons=1./(1+sum(bufferConcentrationM./(totalProtonsM.*ones(size(bufferKaM))+bufferKaM),1));

