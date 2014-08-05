function [BackgroundTextures, GL] = BackgroundCubes(Display, Cube, GL)

%========================= BackgroundCubes.m ==============================
% Creates a stereoscopic background texture the size of the screen (specified 
% by input structure 'Display') with 3D cubes randomly located within a 
% volume that projects onto the outer border. This 3D texture aids stable 
% vergence during binocular viewing. 'Cube.Window' specifies the rectangle 
% in which stimuli will be presented. A PTB window must already be open and
% its handle should be passed in Dsisplay.win., and the OpenGL commands 
% "AssertOpenGL" and "InitializeMatlabOpenGL" should have been called
% first.
% 
% EXAMPLE:
%   AssertOpenGL;                                      
%   InitializeMatlabOpenGL;                                       
%   Display = DisplaySettings(1);
%   [Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, ...
%       0,Display.Rect,[],2, Display.Stereomode, Display.MultiSample, Display.Imagingmode);
%   BackgroundTextures = BackgroundCubes(Display);
%   for Eye = 1:2
%         currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);
%         Screen('DrawTexture', Display.win, BackgroundTextures(Eye));
%   end    
%   [VBL FrameOnset] = Screen('Flip', Display.win);
%   KbWait;
%   Screen('CloseAll');
%
% INPUTS:
%   Cube:                   Structure containing any of the following fields:
%       Cube.Density        proportion of the texture area to fill with squares
%       Cube.BlankRect      central rectangle in which no cubes will be drawn
%       Cube.InnerBorder    size of border between surrounding cubes and stimulus (pixels)
%       Cube.Size           dimensions of each cube (pixels)
%       Cube.Texture        0 = wire frame; 1 = solid; 2 = window texture; 3 = Rubiks texture; 4 = custom texture
%       Cube.DepthRange     [near, far] depth limits (metres)
%	GL:                     Handle if OpenGL has already been called. If provided,
%                           cubes scene will be drawn without returning a PTB texture
%                           and will be viewable on next screen flip command.
%
% REVISIONS:
% 25/10/2012 - Created by Aidan Murphy (apm909@bham.ac.uk)
% 27/10/2012 - Updated to load 3D meshes from OBJ or STL files (APM)
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================
CubesStart = GetSecs;
if nargin < 3,
    ReturnTex = 1;
    AssertOpenGL;                                                           	% Check OpenGL compatability of installed PTB3
    InitializeMatlabOpenGL;                                                     % Setup Psychtoolbox for OpenGL 3D rendering support 
end

%======================== SET DEFAULT PARAMETERS ==========================
if ~isfield(Cube,'Density'), Cube.Density = 0.7; end                            % set the density of cubes in the border
if ~isfield(Cube,'InnerBorder'),Cube.InnerBorder = 2*Display.Pixels_per_deg;end % set the size of the inner border between the surrounding cubes and the stimulus (degrees)
if ~isfield(Cube,'Size'), Cube.Size = 1.5*Display.Pixels_per_deg; end          	% set the size of the surrounding cubes (degrees^2)
if ~isfield(Cube,'DepthRange'), Cube.DepthRange = [-0.2 0.1]; end               % Set far and near depth limits (metres) [-far, near]         
if ~isfield(Cube,'Background'), Cube.Background = [0 0 0 255];end               % Set background color RGBA
if ~isfield(Cube,'Perspective'), Cube.Perspective = 1; end                      % Use perspective projection?
if ~isfield(Cube,'LineWidth'), Cube.LineWidth = 2; end                          % Set line width for wire frame cubes             
if ~isfield(Cube,'Opacity'), Cube.FaceOpacity = 0; end                          % Set cube face opacity for solid cubes              
if ~isfield(Cube,'BlankRect'), Cube.BlankRect = [0 0 400 400];end               % Set stimulus window rectange size
if ~isfield(Cube,'Texture'), Cube.Texture = 2; end                              % Set cube type (wire frame/ solid/ textured)
if ~isfield(Cube,'IPD'), Cube.IPD = 0.064; end                                  % Default inter-pupillary distance is 0.064 metres
if ~isfield(Cube,'Number'), Cubes.Number = 50; end

if numel(Cube.BlankRect)==2, Cube.BlankRect = [0 0 Cube.BlankRect];end
if numel(Cube.Size)>1, Cube.Size = Cube.Size(1); end
if numel(Cube.Background)<4, Cube.Background(4) = 255; end
if Cube.Texture == 2
    Cube.TextureName = 'CubeTexture.bmp';
elseif Cube.Texture == 3
    Cube.TextureName = 'RubiksTexture.bmp';
end

%========================== CALCULATE CUBE POSITIONS ======================
CubeDiameter = round(sqrt(2*Cube.Size^2));
NoCubeRect = ([0 0 Cube.InnerBorder]*2) + Cube.BlankRect;                       % Size of rectangle with no border texture in
ZeroRect = CenterRect(NoCubeRect, Display.Rect);                            	% Centred position of rectange with no border texture in
CubeCentresX = CubeDiameter: (CubeDiameter*2):(Display.Rect(3)-CubeDiameter);
CubeCentresY = CubeDiameter: (CubeDiameter*2):(Display.Rect(4)-CubeDiameter);
C = 1;
for x = 1:numel(CubeCentresX)
    for y = 1:numel(CubeCentresY)
        if ~IsInRect(CubeCentresX(x),CubeCentresY(y),ZeroRect)
          	CubeCentres(:,C) = [CubeCentresX(x); CubeCentresY(y)];
            C = C+1;
        end
    end
end
TotalSquares = (round(numel(CubeCentres(1,:))*Cube.Density));
AllSquares = randperm(numel(CubeCentres(1,:)));
SquareRects = CubeCentres(:,AllSquares(:,1:TotalSquares));
xPos = SquareRects(1,:);
yPos = SquareRects(2,:);
% Cubes.Number = numel(xPos);
xMax = Display.Rect(3)-CubeDiameter;
yMax = Display.Rect(4)-CubeDiameter;
zMin = round(Cube.DepthRange(1)*Display.Pixels_per_m(1))-(CubeDiameter/2); 
zMax = round(Cube.DepthRange(2)*Display.Pixels_per_m(1))-(CubeDiameter/2);      % Convert depth range to pixels
zPos = randi(zMax-zMin, [1, Cubes.Number]); 
xPos = xPos-xMax/2;
yPos = yPos-yMax/2;
zPos = sort(zPos+zMin);                                                         % Sort z position in depth order
xRot = randi(90, [1, Cubes.Number]); 
zRot = randi(90, [1, Cubes.Number]); 
Frame = 1;
                 
%========================= SET VIEW FRUSTUM GEOMETRY ======================
width = Display.Rect(3);                                                        % Get screen width (pixels)
height = Display.Rect(4);                                                       % Get screen height (pixels)
CameraTranslate = Cube.IPD/2*Display.Pixels_per_m(1);                           % Distance to move view point for orthographic projection (pixels)
CameraDistance = Display.D*Display.Pixels_per_m(1);    
zNear = 1000;
zFar = -300;
zNear = max(abs([round(Cube.DepthRange(1)*Display.Pixels_per_m(1)), zNear])); 	% Ensure viewing frustum depth accomodates requested cube positions
zFar = -max(abs([round(Cube.DepthRange(2)*Display.Pixels_per_m(1)), zFar]));

%========================= BEGIN RENDERING LOOP ===========================
Screen('BlendFunction', Display.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);     % Enable blending for alpha transparency
for Eye = 1:2
%     BackgroundTextures{Eye} = Screen('MakeTexture', Display.win, repmat(Cube.Background(1),Display.Rect([4,3])));
    currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);       % Select buffer for current eye
    Screen('BeginOpenGL', Display.win);                                         % Prepare OpenGL to render
    glClear(mor(GL.DEPTH_BUFFER_BIT, GL.STENCIL_BUFFER_BIT));                   % Clear buffers
    if Frame == 1
        glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);                          % Enable alpha blending for transparent occluding surfaces
        glViewport(0, 0, width, height);                                            % Specify all OpenGL object sizes in pixels
        glEnable(GL.DEPTH_TEST);                                                    % Enable proper occlusion handling via depth tests
        if Cube.Texture > 0
            glEnable(GL.LIGHTING);                                                  % Enable local lighting (Phong model with Gouraud shading)
        end
        glEnable(GL.LIGHT0);                                                        % Enable the first light source
        glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);                            % Enable two-sided lighting

        %======================== LOAD CUBE TEXTURE ===========================
        if Cube.Texture >= 2 && Eye == 1
            glEnable(GL.TEXTURE_2D);                                                % Enable texture mapping
            texname(1) = glGenTextures(1);                                          % Create a new texture
            Root = mfilename('fullpath');                                           % Find directory where this function is being called from
            TextureFile = fullfile(fileparts(Root),'3D rendering',Cube.TextureName);% Specify location of texture image file
            if ~isempty(dir(TextureFile))                                           % If texture image file was located...
                CubeTexture = imread(TextureFile);                                  % Load texture image
                if size(CubeTexture,1) ~= size(CubeTexture,2)                       % If texture image is not square...
                    Cube.Texture = 1;                                            	% Revert to untextured solid cubes
                end
                if size(CubeTexture,1) ~= 256                                       % resize texture image
                    TextureScale = 256/size(CubeTexture,1);
                    CubeTexture = imresize(CubeTexture, TextureScale);
                end
                tx{1} = permute(CubeTexture,[3 2 1]);                               % Permute RGB image to 3xMxN array
            else
                Cube.Texture = 1;                                                   % Revert to untextured cubes
            end
            if Cube.Texture >= 2
                glBindTexture(GL.TEXTURE_2D,texname(1));                                      	% Enable i'th texture by binding it:
                glTexImage2D(GL.TEXTURE_2D,0,GL.RGB,256,256,0,GL.RGB,GL.UNSIGNED_BYTE,tx{1});  	% Assign image in matrix 'tx' to i'th texture:
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);                    % Setup texture wrapping behaviour:
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.NEAREST);               % Setup filtering for the textures
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.NEAREST);
                glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);                     % Choose texture application function to modulate light reflection properties of the the cubes face
            end
        end
    end

    %======================= SETUP PROJECTION MATRIX ======================
    glMatrixMode(GL.PROJECTION);            
    glLoadIdentity;     
    if Cube.Perspective == 0                                                % Set orthographic projection
        glOrtho(0-(width/2), 0+(width/2), 0-(height/2), 0+(height/2), -500, 1000);  
    elseif Cube.Perspective == 1                                            % Set perspective projection
        moglStereoProjection(0-(width/2), 0+(height/2), 0+(width/2), 0-(height/2), zNear, zFar, 0, CameraDistance, CameraTranslate*round(Eye-0.5));
    end
    
    if Frame == 1
        %======================= SETUP MODELVIEW MATRIX =======================
        glMatrixMode(GL.MODELVIEW);         
        glLoadIdentity;
        glLightfv(GL.LIGHT0,GL.POSITION,[-1 2 3 0]*100);                   	% Point lightsource is at position (x,y,z) == (-1,2,3)
        glLightfv(GL.LIGHT0,GL.AMBIENT, [0.2 0.2 0.2 1 ]);               	% Ambient light
        glLightfv(GL.LIGHT0,GL.DIFFUSE, [1 1 1 1 ]);                     	% Emits white (1,1,1,1) diffuse light
        glLightfv(GL.LIGHT0,GL.SPECULAR, [1 1 1 1 ]);                     	% Emits white (1,1,1,1) specular light
        glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [0.2 0.2 0.2 1]);      	% Change the color of the following objects
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [1.0 1.0 1.0 1]);        % Or try [ 1.0 0.0 0.0 1 ]);
        glMaterialfv(GL.FRONT_AND_BACK,GL.SHININESS, 30);                   % Add specular reflections
        glClearColor(Cube.Background(1),Cube.Background(2),Cube.Background(3),Cube.Background(4)); 	% Set background clear color

        glColorMaterial(GL.FRONT_AND_BACK, GL.EMISSION);                    % hand control of lighting color to glColorMaterial
        glEnable(GL.COLOR_MATERIAL);
        glColorMaterial(GL.FRONT_AND_BACK, GL.AMBIENT_AND_DIFFUSE);
    end
    if Cube.Perspective == 0
        gluLookAt(CameraTranslate*round(Eye-0.5),0,CameraDistance,0,0,0,0,1,0);     % Camera fixates at the origin (0,0,0) from either eye view
    end

    %============= COMPILE LIST TO DRAW CUBE AND SURFACE FEATURES =========
    for c = 1:numel(xPos)
        glNewList('Cube', GL.COMPILE);         
            %--------- Perform static translations to cube
            glPushMatrix();
                glTranslatef(xPos(c), yPos(c), zPos(c));                    % Set position of cube
                glRotatef(zRot(c), 0,0,1);                                  % Rotate around z-axis
                glRotatef(xRot(c), 1,0,0);                                  % rotate around x-axis
                
                if Cube.Texture == 0                                %======== Draw wire-frame cube
                    glLineWidth(Cube.LineWidth);                            % Set the cube line width
                    glColor3f(1,1,1);                                       % Set cube line colour     
                    glutWireCube(Cube.Size);                                % draw wire cube
                    
                elseif Cube.Texture == 1                         	%======== Draw solid cube
                    if Cube.FaceOpacity > 0
                        if Cube.FaceOpacity == 1
                            glColor3f(1,0,1);                               % Set cube face colour
                        elseif Cube.FaceOpacity < 1
                            glEnable(GL.BLEND);                             % Enable blending in RGBA
                            glColor4f(1,1,0, Cube.FaceOpacity);             % Set cube face colour
                        end
                        glBegin(GL.QUADS);                                  % Draw solid cube faces
                            glVertex3f(-Cube.Size/2, Cube.Size/2, -Cube.Size/2);     % Corner 1  
                            glVertex3f(Cube.Size/2, Cube.Size/2, -Cube.Size/2);      % Corner 2  
                            glVertex3f(Cube.Size/2, -Cube.Size/2, -Cube.Size/2);     % Corner 3
                            glVertex3f(-Cube.Size/2, -Cube.Size/2, -Cube.Size/2);    % Corner 4
                        glEnd();
                    end
                    
                elseif Cube.Texture >= 2                            %======== Draw textured cube faces
                    FaceColors = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 1 1; 0 1 1];
                    if Eye == 1
                        ColOrd(c,:) = randperm(numel(FaceColors(:,1)));
                    end
                    DrawCubeFace([ 4 3 2 1 ],texname(1),Cube, FaceColors(ColOrd(c,1),:));
                    DrawCubeFace([ 5 6 7 8 ],texname(1),Cube, FaceColors(ColOrd(c,2),:));
                    DrawCubeFace([ 1 2 6 5 ],texname(1),Cube, FaceColors(ColOrd(c,3),:));
                    DrawCubeFace([ 3 4 8 7 ],texname(1),Cube, FaceColors(ColOrd(c,4),:));
                    DrawCubeFace([ 2 3 7 6 ],texname(1),Cube, FaceColors(ColOrd(c,5),:));
                    DrawCubeFace([ 4 1 5 8 ],texname(1),Cube, FaceColors(ColOrd(c,6),:));
                end

            glPopMatrix();
        glEndList();
        glCallList('Cube');                                                                 % Draw current eye view of current cube
    end
   	Screen('EndOpenGL', Display.win);                                                       % Finish OpenGL rendering
    if ReturnTex == 1
        Screen('DrawingFinished', Display.win);
        CubesTextures{Eye} = Screen('GetImage', Display.win, Display.Rect,'backBuffer');        % Capture texture as image
        BackgroundTextures(Eye) = Screen('MakeTexture', Display.win, CubesTextures{Eye});       % Convert image to PTB texture
        Screen('FillRect', Display.win, Cube.Background(1));                                    % Clear window buffer
    end
end
fprintf('%s.m executed in %.3d seconds.\n', mfilename, GetSecs-CubesStart);

function DrawCubeFace(i, tx, Cube, FaceColor)

%==================== Subroutine for drawing cube faces ===================
global GL;                                                                              % Access OpenGL constants
v = Cube.Size*[ 0 0 0 ; 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 1 1 1 ; 0 1 1 ]'-0.5; 	% Vector v maps indices to 3D positions of the corners of a face
n = cross(v(:,i(2))-v(:,i(1)),v(:,i(3))-v(:,i(2)));                                     % Compute surface normal vector. Needed for proper lighting calculation
if Cube.Texture == 3                                                                    % For Rubik's cubes...
    glColor3d(FaceColor(1),FaceColor(2),FaceColor(3));                                  % Randomize face color
end
glBindTexture(GL.TEXTURE_2D,tx);            % Bind (Select) texture 'tx' for drawing
glBegin(GL.POLYGON);                        % Begin drawing of a new polygon
    glNormal3dv(n);                       	% Assign n as normal vector for this polygons surface normal
    glTexCoord2dv([ 0 0 ]);              	% Define vertex 1 by assigning a texture coordinate and a 3D position:
    glVertex3dv(v(:,i(1)));
    glTexCoord2dv([ 1 0 ]);               	% Define vertex 2
    glVertex3dv(v(:,i(2)));
    glTexCoord2dv([ 1 1 ]);               	% Define vertex 3
    glVertex3dv(v(:,i(3)));
    glTexCoord2dv([ 0 1 ]);               	% Define vertex 4
    glVertex3dv(v(:,i(4)));
glEnd;
return