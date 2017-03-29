function totex(pamsim)

folder='/Users/jzaks/Documents/GradSchool/FlemingLab/Papers/qEmodel/Draft2/matlab2Tex/';


sp=pamsim.simparams;
printCellToTable(sp.varsforsim, [folder 'varnames.txt'])
printVarsOfField(sp,'varnames', folder)
printVarsOfField(sp,'inputs', folder)

end

function printVarsOfField(s, field, folder)
a=s.(field)
f=fields(a)
for k=1:length(f)
    printCellToTable(a.(f{k}), [folder field f{k} '.txt'])
end
end

    function printCellToTable(c, nametosave)
        fid=fopen(nametosave, 'w')
        for k=1:length((c))
            fprintf(fid, ['\n  \\verb+' c{k} ' + \\\\ [-0.15in] ']);
        end
        fclose(fid);
    end



    function printNumToTable(paramstosave, nametosave)
        fid=fopen(nametosave, 'w')
        %    paramstosave=simtoplot{1}.params
        
        paramval=    num2str(paramstosave.(f{j}), '%11.3g')
        for k=1:length(fields(c))
            fprintf(fid, ['\n $p_{' num2str(j) '}$ &'  paramval ' & \\verb+' f{j} '+ &  \\\\ '])
        end
        fclose(fid);
    end