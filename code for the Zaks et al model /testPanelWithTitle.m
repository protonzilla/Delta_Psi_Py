function testPanelWithTitle

f = figure('Visible', 'off', 'Position', [0,0,500,650]);
g=makePanelWithTitle(f, [0.5 0.5 0.3 0.3], 'test')
set(f, 'Visible', 'on')
end
    function panelh= makePanelWithTitle(parent, position, titleText, bcolor)
    tfontsize=20
        %    position should be in fractions
         parentPos= get(parent, 'Position')
         if parentPos(3)<1
             error('parent position is less than 1')
         end
         panelWidthInPixels = parentPos(3)*position(3)
         panelHeightInPixels        = parentPos(4) * position(4)
       
        if (nargin >=4)
            if any(strfind(bcolor, 'background'))
             bcolor=get(parent,'Color')
            end
        else
            bcolor = [0.9 0.9 0.9];
        end
         panelh = uipanel('Parent', parent, 'Position', position,  'ResizeFcn', [], ...
             'BorderType', ' none ');
        textwidth  = 100
        textheight = 25
        gap   = 10
       title = uicontrol('Parent', panelh, 'Style', 'text', 'String', titleText,...
         'Value', 1,     'Position', [(panelWidthInPixels-textwidth)/2,panelHeightInPixels+ gap, textwidth, textheight],...
          'BackgroundColor', bcolor, 'fontsize', tfontsize);      
      
    end
