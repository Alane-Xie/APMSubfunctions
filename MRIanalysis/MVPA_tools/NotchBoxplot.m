function [handle] = NotchBoxplot(data0, LineWidth, LineColour, BoxWidth, BoxColour)

%========================== NotchBoxplot.m ================================
% Plots notched box-whiskers diagram, accept multiple columns. each column
% is considered as a single set
%
% INPUTS:
%       data0:      unsorted data in an mxn matrix (m samples, n boxes);
%       LineWidth:  line thickness in the plot (default = 1);
%       LineColour: Line colour (default = black);
%       BoxWidth:   the width of the box (default = 1);
%       BoxColour:  fill colour of the box area (deafult = green);  
%
% 01/09/2011 - 'boxplotsimple.m' created by Hiroshi Ban
% 02/04/2012 - Updated to produce notch boxplots ('bowties'), APM
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================
if(nargin < 5); BoxColour = [0.5 1 0.5];end;    % Default box colour is green
if(nargin < 4); BoxWidth = 1;end;
if(nargin < 3); LineColour = '-k';end;          % Default line colour is black
if(nargin < 2); LineWidth = 1;end;              % Default line width is 1 pixel
             
[m n] = size(data0);                            
data = sort(data0, 1);                          % Sort ascending

%     q2 = median(data, 1);
%     if(rem(m,2) == 0) 
%         upperA = data(1:m/2,:);
%         lowA =  data(m/2+1:end,:);  
%     else
%         upperA = data(1:round(m/2), :);
%         lowA =  data(round(m/2):end, :);  
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

drawBox(draw_data, LineWidth, LineColour, BoxWidth, BoxColour);
return;


function drawBox(draw_data, lineWidth, LineColour, BoxWidth, BoxColour)

    n = size(draw_data, 2);
    unit = (1-1/(1+n))/(1+9/(BoxWidth+1));
     
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
        
        p = patch(X,Y,C);                                                                       % draw the notched box
        set(p,'FaceColor',BoxColour);                                                           % Fill the box with specified colour
    end;
return;