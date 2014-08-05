function [slope,threshold,sd,error,h] = do_pfit(data, nint, color)

% takes data in the following formatted table structure:
%
% 	[ stimulus value	  proportion		total
% 	  stimulus value	  proportion		total
%          ...               ...             ...    ]
%
% and fits a psychometric function, plots it and returns: slope, 
% threshold, error and a handle to the graph that is has drawn.
%    
%       nint: number of intervals (1 for 0-100%, 2 for 50-100%)
%       color: corresponds to the colors used in matlab ('k' for black)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adds the included psignifit to the path information, just to be sure.
p = genpath(cd); addpath(p);

% Make a batch string out of the preferences: 999 bootstrap replications
% assuming 2AFC design. All other options standard.
% Type "help psych_options" for a list of options that can be specified for
% psignifit.mex. Type "help batch_strings" for an explanation of the format.
shape = 'cumulative Gaussian';
prefs = batch('shape', shape, 'n_intervals', nint, 'runs', 999);
outputPrefs = batch('write_pa', 'pa', 'write_th', 'th');

% plot the individual data pionts, use color (marker size doesn't work)
hold on; d = plotpd(data, 'Color', char(color))
set(d,'MarkerSize', 6);

% Fit the data, according to the preferences we specified (999 bootstraps).
% The specified output preferences will mean that two structures, called
% 'pa' (for parameters) and 'th' (for thresholds) are created.
[EST_P OBS_S SIM_P LDOT] = psignifit(data, [prefs outputPrefs]);

% get the error (D)
error = OBS_S(1);

% Standard deviation of the underlying distribution (take absolute value)
pa
sd = abs(pa.est(2)) / sqrt(2)

% get slope and thresholds
slope = findslope(shape, pa.est);
threshold = findthreshold(shape, pa.est)

% Plot the fit to the original data, use color
h = plotpf(shape, pa.est, 'Color', char(color));

% Draw confidence intervals using the 'lims' field of th, which
% contains bias-corrected accelerated confidence limits.
% drawHeights = psi(shape, pa.est, th.est);
% line(th.lims, ones(size(th.lims,1), 1) * drawHeights, 'color', [0 0 1])
