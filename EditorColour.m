function EditorColour(Background, Text)

%========================== EditorColour.m ================================
% Changes the colours of the MATLAB editor window background and text, as
% specified by the RGB inputs (values in range 0-1). If no input arguments
% are provided, default colours (black text on white background) are
% returned.
% 
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================

if nargin < 1                                           % If no inputs were provided
    Background = [1 1 1];                               % Return editor background to white
    Text = [0 0 0];                                     % Return editor text to black
end
cmdWinDoc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance;
listeners = cmdWinDoc.getDocumentListeners;
for i = 1:numel(listeners)
    if strfind(char(listeners(i)),'JTextArea')
        Listener = i;
    end
end
jTextArea = listeners(Listener);

% eval(sprintf('jTextArea.setBackground(java.awt.Color(%s));', char(Background)));
set(jTextArea,'Background',Background);                 % Set area background colour
set(jTextArea,'Foreground',Text);                       % Set area text colour