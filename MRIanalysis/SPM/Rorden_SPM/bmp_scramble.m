function bmp_scramble (Filename);
%Creates phase spectrum scrambling bitmap with 's' prefix
%  Filename: name of bitmap [optional]
%Example
% bmp_scramble('dog.png');
%Adds a user interface wrapper for Nicolaas Prins' code
%   http://visionscience.com/pipermail/visionlist/2007/002181.html
%REQUIRES IMAGE PROCESSING TOOLBOX

if (nargin < 1)  
   [files,pth] = uigetfile({'*.bmp;*.jpg;*.png;*.tiff;';'*.*'},'Select the Image[s]', 'MultiSelect', 'on'); 
else
    [pth,nam, ext] = fileparts(Filename);
    files = cellstr([nam, ext]);
end;

if (license('checkout', 'signal_toolbox')) == 0 
    disp('You will need the image processing toolbox!')
end;



for i=1:size(files,2)
    nam = strvcat(deblank(files(:,i)));
    Inname = fullfile(pth, [nam]);
    Outname = fullfile(pth, ['s' nam ]);

    Im =  mat2gray(double(imread(Inname)));
    %read and rescale (0-1) image

    ImSize = size(Im);

    RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));
    %generate random phase structure

    if length(ImSize) == 2
        n = 1; %only one layer - e.g. grayscale image
    else
        n = ImSize(3); %multiple layers, e.g. color image
    end;
    
    for layer = 1:n
        ImFourier(:,:,layer) = fft2(Im(:,:,layer));       
        %Fast-Fourier transform
        Amp(:,:,layer) = abs(ImFourier(:,:,layer));       
        %amplitude spectrum
        Phase(:,:,layer) = angle(ImFourier(:,:,layer));   
        %phase spectrum
        Phase(:,:,layer) = Phase(:,:,layer) + RandomPhase;
        %add random phase to original phase
        ImScrambled(:,:,layer) = ifft2(Amp(:,:,layer).*exp(sqrt(-1)*(Phase(:,:,layer))));   
        %combine Amp and Phase then perform inverse Fourier
    end
    ImScrambled = real(ImScrambled); %get rid of imaginery part in image (due to rounding error)
    imwrite(ImScrambled,Outname);
end;
%imshow(ImScrambled) %display the result

