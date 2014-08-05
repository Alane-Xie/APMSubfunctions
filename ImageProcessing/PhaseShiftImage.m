
function ShiftFrames = PhaseShiftImage(Image, NoFrames, ShiftDir)

%============================ PhaseShiftImage.m ===========================
% This function animates the static image (m x n xp) input Image by
% applying phase-shift in the Fourier domain in the direction specified by 
% ShiftDir, across NoFrames number of frames. 
%
% INPUTS:
%   Image:          m x n x p image matrix. If m or n is an odd number, the
%                   image will be padded and teh returned images will be
%                   m+1 x n+1 x p.
%   NoFrames:       Number of frames to generate.
%   ShiftDir:       1 = left; -1 = right; 2 = up; -2 = down; 
%
% OUTPUT:           
%   ShiftFrames:    a 1 x NoFrames cell array, where each cell contains an
%                   m x n x p matrix of a phase shifted image.         
%
% REFERENCE:
%   Hayashi R & Tanifuji M (2012). Which image is in awareness during 
%       binocular rivalry? Reading perceptual status from eye movements.
%       Journal of Vision, vol. 12 no. 3 article 5.
%
% 12/03/2014 - Written by Aidan Murphy (murphyap@mail.nih.gov)
%==========================================================================

if nargin == 0
    load mandrill;                                        	% Load mandrill face for this example
    Image = ind2rgb(X,map);                                	% convert indexed image to RGB
    NoFrames = 20;                                        	% Set number of animation frames
    ShiftDir = 2;
    figure;
end
FrameInc = (2*pi)/(NoFrames-1);                             % Set phase shift increments
FrameShift = 0:FrameInc:2*pi;                               % Get phase shift for each frame
ImMax = max(Image(:));                                      % Get maximum pixel intensity of original image 
ImMin = min(Image(:));                                      % Get minimum pixel intensity of original image

%========== If image matrix has an odd x or y dimension, pad with zeros to make even
if mod(size(Image,1),2)~=0
    Image(end+1,:,:) = 0;
end
if mod(size(Image,2),2)~=0
    Image(:,end+1,:) = 0;
end

%========= Calculate shift frames
F = fft2(Image);                                         	% Perform fast fourier transform on original image
M = abs(F);                                                 % Get amplitude component
P = angle(F);                                               % Get phase component
if abs(ShiftDir)==2                                         % If shift is being applied in the vertical dimension...
    P = permute(P,[2,1,3]);                                 % Switch x and y dimensions
end
N = size(P)/2;                                              % Calculate half size of phase image
ShiftFrames = cell(NoFrames,1);                          	% Preallocate frames           
for f = 1:numel(FrameShift)                              	% For each animation frame...
    dp = FrameShift(f)*ShiftDir/abs(ShiftDir);           	% Set phase shift amount and direction 
    Aps = [P(:,1,:), P(:,2:N(2),:)+dp, P(:,N(2)+1,:), P(:,(N(2)+2):end,:)-dp];  % Apply phase shift
  	if abs(ShiftDir)==2                                     
        Aps = permute(Aps,[2,1,3]);                      	% Switch x and y dimensions back
    end
    ShiftedImage =  M.* exp(Aps * sqrt(-1));                % Recombine phase and amplitude
    ShiftFrames{f} = real(ifft2(ShiftedImage));           	% Perform inverse fourier trasnform

    %======= Normalize image to original range 0:255
    Range = max(ShiftFrames{f}(:)) - min(ShiftFrames{f}(:));
    ShiftFrames{f} = uint8( (ShiftFrames{f} - min(ShiftFrames{f}(:)))./Range*255 );

    if nargin == 0                                          % If running as demo...
        imagesc(ShiftFrames{f});                            % Plot results
        axis equal off;                                     
        drawnow;
    end
end

end