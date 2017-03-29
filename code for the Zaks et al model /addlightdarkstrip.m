function addlightdarkstrip(fnum, lighttime, act, fontsize)
if nargin==3
    fontsize=18
end
fontsize2=16
figure(fnum)
box on
yl=ylim;
xl=xlim;
dy=yl(2)-yl(1);


rectangle( 'Position',[xl(1) yl(1)+dy*0.9 lighttime(1)-xl(1) 0.090*(yl(2)-yl(1))], 'facecolor', 'k', 'linestyle', 'none')
rectangle( 'Position',[xl(1) yl(1)+dy*0.9 xl(2)-xl(1) 0.098*(yl(2)-yl(1))], 'facecolor', 'k', 'linestyle', 'none')


rectangle( 'Position',[lighttime(1) yl(1)+dy*0.904 lighttime(2)-lighttime(1) 0.090*(yl(2)-yl(1))], 'facecolor', 'w', 'linestyle', 'none')
%rectangle( 'Position',[lighttime(2) yl(1)+dy*0.9 xl(2)-lighttime(2) 0.09*(yl(2)-yl(1))], 'facecolor', 'k', 'linestyle', 'none')

h1 = text(lighttime(1)+0.01*(xl(2)-xl(1)), yl(1)+dy*0.946, ['' num2str(act) ], 'Color', [0 0 0], 'Fontsize', fontsize)
p=get(h1, 'Extent')
h2 = text(lighttime(1)+0.01*(xl(2)-xl(1))+p(3), yl(1)+dy*0.945, ['\muE m^{-2}s^{-1}'], 'Color', [0 0 0], 'Fontsize', fontsize2)


end