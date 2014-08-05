function [slope,threshold,error,h,sd,se,upperlim,lowerlim,struct] = do_pfit2(data, nint, color, MarkerSize)
% takes data in the following formatted table structure:
%
% 	stimulus value	proportion		total
% 	stimulus value	proportion		total.. etc
%
% and fits a psychometric function; also plots it and returns slope, 
% threshold, error and a handle to the graph.

warning off;
if nargin < 4
    MarkerSize = [];
end

% Make a batch string out of the preferences: 999 bootstrap replications
% assuming 2AFC design. All other options standard.
% Type "help psych_options" for a list of options that can be specified for
% psignifit.mex. Type "help batch_strings" for an explanation of the format.
shape = 'cumulative Gaussian';
prefs = batch('shape', shape, 'n_intervals', nint, 'runs', 999, 'cuts', 0.5);
outputPrefs = batch('write_pa', 'pa', 'write_th', 'th');

% plot the individual data pionts, use color
hold on; 
res.handle.pd = plotpd(data, 'Color', char(color));
if ~isempty(MarkerSize)
    set(res.handle.pd,'MarkerSize', MarkerSize);
end

% Fit the data, according to the preferences we specified (999 bootstraps).
% The specified output preferences will mean that two structures, called
% 'pa' (for parameters) and 'th' (for thresholds) are created.
% [EST_P OBS_S SIM_P LDOT] = psignifit(data, [prefs outputPrefs]);

[s, sFull, str] = PFIT(data, [prefs]);

% get the error (D)
error = 0;

% Standard deviation: take the absolute value
sd = abs(sFull.params.est(2)) / sqrt(2);    

% Standard error: std(samplemeans)/sqrt(#samples)
se = std(sFull.params.sim(:,1)) / sqrt(numel(sFull.params.sim(:,1)));  

% sFull.params.lims
% sFull.thresholds.lims

% confidence limits for -2, -1 and 1, 2 standard deviations (BCa)
% limsBCa = confint('BCa', sFull.params.sim, [0.023 0.159 0.841 0.977], sFull.params.est, sFull.params.lff, sFull.ldot)
limsPerc = confint('percentile', sFull.params.sim, [0.023 0.159 0.841 0.977]);

% separate the lower and upper limits (95%)
lowerlim = limsPerc(1, 1);
upperlim = limsPerc(4, 1);

% get slope and thresholds
slope = findslope(shape, s.params.est);
threshold = findthreshold(shape, s.params.est);
h = plotpf(shape, s.params.est, 'Color', char(color));

% Plot the fit to the original data, use color and return the handle
% Draw confidence intervals using the 'lims' field of th, which
% contains bias-corrected accelerated confidence limits.
% drawHeights = psi(shape, pa.est, th.est);
% line(th.lims, ones(size(th.lims,1), 1) * drawHeights, 'color', [0 0 1])

struct = sFull;
