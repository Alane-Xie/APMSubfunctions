function powell_estimate=AutoColorEstimatePowell(rawxyY,myxyY,phosphers,lut,colorimeterhandler,displayhandler,options)

% function powell_estimate=AutoColorEstimatePowell(rawxyY,myxyY,phosphers,lut,colorimeterhandler,displayhandler,options);
%
% Estimate [R,G,B] values to produce xyY you want to display
% using Brent-Powell with Coggins/Golden-section line serach method
%
% [input]
% rawxyY             : raw xyY you want, [3 x n] matrix
% myxyY              : your xyY after preprocessing (e.g. flare-correction), [3 x n] matrix
%                      if no preprocessing is applied, myxyY=rawxyY;
% phosphers          : phospher xyY, [rx,gx,bx;ry,gy,by;rY,gY,bY] after preprocessing
% lut                : color lookup table, [n x 3(r,g,b)] matrix
%                      set lut=[]; if you do not need to use LUTs
% colorimeterhandler : handle to an object to manipulate colorimeter
% displayhandler     : function handle to manipulate/display color window
% options            : options, structure generated by optimset function
%                      e.g. options=optimset('Display','off','TolX',1e-2);
%
% [output]
% powell_estimate : cell structure {n x 1}, holding the estimation results with the variables below
%                      .method --- 'LUT' or 'RGB
%                      .wanted_xyY
%                      .measured_xyY
%                      .residuals --- measured_xyY minus rawxyY
%                      .rms --- error
%                      .RGB --- RGB values for all the estimations
%                      .LUT --- lut index if .method='LUT'
%                      .final_xyY --- the final estimation of xyY
%                      .final_RGB --- the final estimation of RGB
%                      .final_LUT --- the final estimation of LUT
%
% [dependency]
% iFit toolbox is required. Install it separately.
%
%
% Created    : "2012-04-15 12:20:15 ban"
% Last Update: "2012-05-16 15:32:49 ban"

%% check input variables
if nargin<6, help(mfilename()); powell_estimate=[]; return; end

if nargin<7 || isempty(options)
  options=optimset; % empty structure
  options.Display='iter';
  options.TolFun =1e-3;
  options.TolX   =1e-3;
  options.MaxIter=100;
  options.MaxFunEvals=200;
  options.Hybrid = 'Coggins';
  options.algorithm  = 'Powell Search (by Secchi) [ fminpowell ]';
  options.optimizer = 'fminpowell';
end

% set constrains
constrains.min=zeros(1,3);
constrains.max=ones(1,3);
constrains.fixed=zeros(1,3);
constrains.steps=0.1;

% initialize variable to store the results
powell_estimate=cell(size(myxyY,2),1);

% initialize color window
fig_id=displayhandler([255,255,255],1); pause(0.2);

% non-linear estimations of RGB values using a simplex-search method (direct search, having a local-minimum problem).
%
% here, estimation is done in XYZ space, not in xyY, to make the estimation stable.
% if we estimate in xyY space, the results will be distorted as Y is too large compared with the other values
%
% [reference]
% Lagarias, J.C., J. A. Reeds, M. H. Wright, and P. E. Wright,
% �gConvergence Properties of the Nelder-Mead Simplex Method in Low Dimensions,�h
% SIAM Journal of Optimization, Vol. 9 Number 1, pp. 112-147, 1998.
for mm=1:1:size(myxyY,2)

  % initial transformation
  pXYZ0=xyY2XYZ(phosphers); % set the global phospher XYZ matrix as initial values

  % set initial parameters
  RGB0=pXYZ0\xyY2XYZ(myxyY(:,mm));
  RGB0(RGB0<0)=0; RGB0(RGB0>1)=1;
  
  % Measuring & optimizing CIE1931 xyY
  RGB=fminpowell(@estimate_xyY,RGB0,options,constrains,rawxyY(:,mm),displayhandler,colorimeterhandler,lut,fig_id);
  if ~isempty(lut), RGB=getRGBfromLUT(lut,RGB); end
  
  % check the accuracy of xyY for the optimized RGB values
  [YY,xx,yy,displayhandler,colorimeterhandler]=...
    MeasureCIE1931xyY(displayhandler,colorimeterhandler,RGB,1,fig_id);

  mxyY=[xx;yy;YY];

  % calculate RMS error
  e=(mxyY-rawxyY(:,mm))./rawxyY(:,mm)*100; % [%] error
  rms=sqrt(e'*e);

  % store the data
  if ~isempty(lut)
    powell_estimate{mm}.method='LUT';
  else
    powell_estimate{mm}.method='RGB';
  end
  powell_estimate{mm}.wanted_xyY=rawxyY(:,mm);
  powell_estimate{mm}.measured_xyY=mxyY;
  powell_estimate{mm}.residuals=mxyY-rawxyY(:,mm);
  powell_estimate{mm}.rms=rms;
  powell_estimate{mm}.RGB=RGB;
  if ~isempty(lut)
    for nn=1:1:3
      [dummy,idx]=min(abs(lut(:,nn)-RGB(nn)));
      powell_estimate{mm}.LUT(nn)=idx;
    end
  end
  powell_estimate{mm}.final_xyY=powell_estimate{mm}.measured_xyY;
  powell_estimate{mm}.final_RGB=powell_estimate{mm}.RGB;
  if ~isempty(lut), powell_estimate{mm}.final_LUT=powell_estimate{mm}.LUT; end

end % for mm=1:1:size(myxyY,1)

displayhandler(-999,1,fig_id);

return


% subfunction to do non-linear optimization
function sse=estimate_xyY(params,wanted_xyY,displayhandler,colorimeterhandler,lut,fig_id)

% estimates CIE1931 xyY using a given transformation matrix
% params=[r;b;g]; or params=[lutRidx,lutGidx,lutBidx];

% set variable
RGB=params;
RGB(RGB>1)=1.0; RGB(RGB<0)=0.0;
if ~isempty(lut), RGB=getRGBfromLUT(lut,RGB); end

% measure CIE1931 xyY
[YY,xx,yy,displayhandler,colorimeterhandler]=...
  MeasureCIE1931xyY(displayhandler,colorimeterhandler,RGB,1,fig_id);

% calculate error
cxyY=[xx;yy;YY];

%% note: Though the error calculation here looks strange, I mean this fine.
%%       This is to match the criteria of error with linear transformation.
%%       If you want to calc the correct SSE, please use the first 2 lines.
%eXYZ=xyY2XYZ(cxyY)-xyY2XYZ(wanted_xyY);
%sse=eXYZ'*eXYZ;
exyY=(cxyY-wanted_xyY)./wanted_xyY.*100;
sse=sqrt(exyY'*exyY);

return


function [rgb,lutidx]=getRGBfromLUT(lut,rgb)

lutidx=ceil(rgb.*size(lut,1));
lutidx(lutidx<=0)=1;
lutidx(lutidx>size(lut,1))=size(lut,1);
for nn=1:1:3, rgb(nn)=lut(lutidx(nn),nn); end

return