function [ProjectionMatrix] = GeneralizedPerspectiveProjection(pe, pa, pb, pc, n, f)
%[ProjectionMatrix} = GeneralizedPerspectiveProjection(pe, pa, pb, pc, n, f)

%==========================================================================
% This function provides a more genrealized version of the parallel 
% projection matrix used by OpenGL's glFrustum.  Unlike glFrustum this
% function can deal with asymmetric frusta necessary for stereoscopic
% perspective projections, and can be applied to projection transformation
% calculations without invoking OpenGL.
% 
% INPUT VARIABLES:
%   pe =    Eye coordinates
%   pa =    Bottom Left screen 3D coordinate
%   pb =    Top Left screen 3D coordinate
%   pc =    Bottom Right screen 3D coordinate
%   n =     Near clipping plane
%   f =     Far clipping plane
%
% REFERNCES:
% Based on the C function from the following article by Robert Kooima:
% http://csc.lsu.edu/~kooima/pdfs/gen-perspective.pdf
%
% HISTORY:
% 02/08/2011 - Created by Aidan Murphy (apm909@bham.ac.uk)
%==========================================================================

% screen's coordinates vectors (normalized)
vr = (pb - pa)/norm(pb-pa);
vu = (pc - pa)/norm(pc-pa);
vn = cross(vr,vu)/norm(cross(vr,vu));

% vectors traced from an Eye to the corners of the screen
va = pa - pe;
vb = pb - pe;
vc = pc - pe;

% distance from the Eye to the Screen (n < d < f)
d = -dot(vn,va);    % check sign!

% Frustum parameters based on near clipping plane
l = dot(vr,va)*n/d;
r = dot(vr,vb)*n/d;
b = dot(vu,va)*n/d;
t = dot(vu,vc)*n/d;

% 
ProjectionMatrix = [    2*n/(r-l)     0             (r+l)/(r-l)        0            ; ...
                        0             2*n/(t-b)     (t+b)/(t-b)        0            ; ...
                        0             0            -(f+n)/(f-n)       -2*f*n/(f-n)  ; ...
                        0             0             -1                 0            ];