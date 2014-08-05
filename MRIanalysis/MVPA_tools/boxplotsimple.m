function boxplotsimple(data0, lineWidth, width)
% boxPlot(data0) - plot box-whiskers diagram, accept multiple columns
% Arguments: data0 -  unsorted data, mxn, m samples, n columns
%            lineWidth -  line thickness in the plot default = 1;
%            width -  the width of the box, default = 1;
% Returns:	 
% Notes: each column is considered as a single set	


    if(nargin < 3)
        width = 1;
    end;
    if(nargin < 2)
        lineWidth = 1;
    end;
 	LineColour = '-k';

    [m n] = size(data0);

    data = sort(data0, 1); % ascend
    
    
%     q2 = median(data, 1);
    
%     if(rem(m,2) == 0)
%         
%         upperA = data(1:m/2,:);
%         lowA =  data(m/2+1:end,:);
%         
%     else
%         
%         upperA = data(1:round(m/2), :);
%         lowA =  data(round(m/2):end, :);  
%         
%     end;
    
%     q1 = median(upperA, 1);
%     q3 = median(lowA, 1);

    q1 = prctile(data(:,:),32);
    q2 = prctile(data(:,:),50);
    q3 = prctile(data(:,:),68);
    
%     min_v = data(1,:);
%     max_v = data(end,:);
    
    CI_up = prctile(data(:,:),5);
    CI_down = prctile(data(:,:),95);
    
    draw_data = [CI_up; q3; q2; q1; CI_down];
%     draw_data = [max_v; q3; q2; q1; min_v];
    
    % adjust the width
    drawBox(draw_data, lineWidth, LineColour, width);

return;


function drawBox(draw_data, lineWidth, LineColour, width)

    n = size(draw_data, 2);
    unit = (1-1/(1+n))/(1+9/(width+1));
    
%     figure;    
    hold on;       
    for i = 1:n
        v = draw_data(:,i);
        
        X = [i+unit; i+unit/2; i+unit; i-unit; i-unit/2; i-unit];
        Y = [v(2); v(3); v(4); v(4); v(3); v(2)];
        C = zeros(size(X));
        
        plot([i-unit/2, i+unit/2], [v(5), v(5)], LineColour, 'LineWidth', lineWidth);           % draw the min 95% line
        plot([i-unit/2, i+unit/2], [v(1), v(1)], LineColour, 'LineWidth', lineWidth');          % draw the max 95% line
        plot([i, i], [v(5), v(4)], LineColour, 'LineWidth', lineWidth);                         % draw vertical lines
        plot([i, i], [v(2), v(1)], LineColour, 'LineWidth', lineWidth);
        
        p = patch(X,Y,C);
        set(p,'FaceColor',[1 0 0]);
    end;
return;