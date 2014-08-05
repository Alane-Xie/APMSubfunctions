function [pValues, phi] = PlotIndex(Accuracy, Subjects, ROIs, Conditions)

%=========================== PlotIndex.m ================================
% Plots box plot of cue integration index (phi) for depth cues A and B by 
% region of interest (as used by Ban et al., 2012):
%
%           phi =   d'A+B / (sqrt(d'A^2)+(d'B^2)) - 1
%
% where d' is SVM classifier prediction sensitivity. 
%
% INPUTS:
%   dprime:     SVM sensitivity in a (Subjects X ROIs X Conditions) matrix
%   Accuracy:   SVM accuracies in a (Subjects X ROIs X Conditions) matrix
%   SE:         SVM standard error in same size matrix as Accuracy
%   Subjects:   Cell array of subject IDs
%   ROIs:       Cell array of regions-of-interest 
%
% REFERENCES:
% Ban H, Preston TJ, Meeson A & Welchman AE (2012). The integration of motion 
%   and disparity cues to depth in dorsal visual cortex. Nature
%   Neuroscience, 
%
% 28/02/2012 - Written by apm909@bham.ac.uk
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%
%==========================================================================

x=size(Accuracy);
if x([1,2,3]) ~= [numel(Subjects),numel(ROIs),numel(Conditions)+1];
    Accuracy = permute(Accuracy, [find(x==numel(Subjects)), find(x==numel(ROIs)), find(x==numel(Conditions)+1)]);
end

for S = 1:numel(Subjects)                                                    	% For each subject...
    for R = 1:numel(ROIs)                                                       % For each region of interest...
        for C = 1:3                                                             % For each condition...
            dprime(S,R,C) = 2*erfinv(2*Accuracy(S,R,C)-1);                      % Convert prediction accuracy to sensitivity (d-prime)
        end
     	phi(S,R) = (dprime(S,R,3)/sqrt(dprime(S,R,1)^2 + dprime(S,R,2)^2))-1;   % Calculate cue integration index
    end
end

[h,pValues,ci,stats] = ttest(phi);

figure;
% boxplot(phi,'notch','on');                                                      % Plot indices
boxplotsimple(phi);

hold on;
xlims = get(gca, 'xLim');
plot(xlims,[0 0],'-k');
ylabel('Integration index', 'FontSize', 12);
% set (gca,'FontName','Symbol');
% ylabel('f');
% set (gca,'FontName','Helvetica');
% xlabel('ROI', 'FontSize', 12);
set(gca, 'XTick' ,1:numel(ROIlabels));
set(gca,'XTickLabel', ROIlabels);
set(gca,'TickDir','out');
box off;
zoom yon;
% set(gca, 'yLim', [-3,3]);