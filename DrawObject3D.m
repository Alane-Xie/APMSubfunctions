function Textures = DrawObject3D(Display, Object, GL)

%=========================== DrawObject3D.m ===============================
% Loads a 3D object file (.OBJ or .STL) and renders it stereoscopically in 
% OpenGL. Object appearance can be controlled in realtime by keyboard inputs:
%
% KEYBOARD INPUTS:
%       't'     Loops through surface textures, from mesh > solid > texture map
%       </>     Rotation speed/ direction
%       ^/down  Move object near/ far
%
% REQUIREMENTS:
%	APMSubfunctions > 3D rendering:
%   - LoadOBJFile.m (W.S. Harwin/ Mario Kleiner) - Psychtoolbox
%         Basic script for importing Wavefront .OBJ files, which must: 
%         1) be ASCII format (not binary)
%         2) only contain triangle and/or quad polygons (not NURBS)
%         3) only contain single objects
% 	- read_wobj.m (Dirk-Jan Kroon) - Wavefront Toolbox
%         Slower function for importing Wavefront .OBJ files and .MTL
%         library, but can import multiple objects from a single file.
%         Handles all polygon types and NURBS and converts them to
%         triangles.
%  	- import_stl_fast.m (Eric Trautmann)
%         Imports ASCII .STL files
%   - stlread.m (Francis Esmonde-White)
%         Imports binary .STL files
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
%       Object.Filename     filename including full path of .OBJ or .STL object
%       Object.Texturename  filename including full path of texture image
%       Object.Centre       world coordinates of object centre [x y z]
%       Object.Size         dimension of object major axis (pixels)
%       Object.Texture   	0 = wire frame; 1 = solid; 2 = map texture image;
%
% REVISIONS:
% 27/10/2012 - Created by Aidan Murphy (apm909@bham.ac.uk)
% 08/03/2013 - Object.Texture options added
% 10/03/2013 - Alternative .OBJ and .MTL import function integrated
%     ___  ______  __   __
%    /   ||  __  \|  \ |  \    APM SUBFUNCTIONS
%   / /| || |__/ /|   \|   \   Aidan P. Murphy - apm909@bham.ac.uk
%  / __  ||  ___/ | |\   |\ \  Binocular Vision Lab
% /_/  |_||_|     |_| \__| \_\ University of Birmingham
%==========================================================================
clear all;
AssertOpenGL;                                                                   % Check OpenGL compatability of installed PTB3
InitializeMatlabOpenGL;                                                         % Setup Psychtoolbox for OpenGL 3D rendering support 
PsychImaging('PrepareConfiguration');
Debug = 0;
Stereo = 1;

% try
if nargin == 0
    fprintf('No inputs were provided to %s.m! Running in test mode...\n', mfilename);
    Screen('Preference', 'SkipSyncTests', 1);
    Display = DisplaySettings(Stereo);
    Display.ScreenID = 0;
    Display.Background = [0 0 0];
    Display.Rect = Screen('Rect',Display.ScreenID);
    if Debug == 1
        Display.Rect = Display.Rect/2;
    end
    if Display.Environment ~= 6
%         Display.Rect = Screen('Rect', 1);
     	Display.Imagingmode = kPsychNeedFastBackingStore;
        Display.Imagingmode = kPsychNeedFastOffscreenWindows;
        Display.MultiSample = 4;
        [Display.win, Display.Rect] = PsychImaging('OpenWindow', Display.ScreenID, 0,Display.Rect,[],2, Display.Stereomode, Display.MultiSample, Display.Imagingmode);
    else
        [Display.win, Display.Rect] = Screen('OpenWindow', Display.ScreenID, Display.Background(1),Display.Rect,[],[], Display.Stereomode);
    end
%     SetAnaglyphStereoParameters('FullColorAnaglyphMode', Display.win);
%     BackgroundTextures = BackgroundSquares(Display);
%     Screen('DrawTexture', Display.win, BackgroundTextures(Eye));
    Object = struct('StartTime',GetSecs);
    KbName('UnifyKeyNames');
    if Debug == 0
        HideCursor;
        ListenChar(2);                                                              
        warning off all; 
    end
end
% Cube.Size = 1.5*Display.Pixels_per_deg;
% BackgroundCubes(Display, Cube, GL);

%======================== SET DEFAULT PARAMETERS ==========================
if ~isfield(Object,'Size'), Object.Size = round(6*Display.Pixels_per_deg(1));end	% set the size of the object's largest dimension (degrees)
if ~isfield(Object,'DepthRange'), Object.DepthRange = [-0.2 0.2]; end         	% Set far and near depth limits (metres) [-near, far]          
if ~isfield(Object,'Background'), Object.Background = [0 0 0 255];end         	% Set background color RGBA
if ~isfield(Object,'Perspective'), Object.Perspective = 1; end                 	% Use perspective projection?
if ~isfield(Object,'LineWidth'), Object.LineWidth = 2; end                    	% Set line width for wire frame            
if ~isfield(Object,'Opacity'), Object.FaceOpacity = 0; end                   	% Set object face opacity for solid faces             
if ~isfield(Object,'Texture'), Object.Texture = 0; end                       	% Set surface type (wire frame/ solid/ textured)
if ~isfield(Object,'IPD'), Object.IPD = 0.064; end                            	% Default inter-pupillary distance is 0.064 metres
if numel(Object.Size)>1, Object.Size = Object.Size(1); end
if numel(Object.Background)<4, Object.Background(4) = 255; end
if ~isfield(Object,'UseVertexArray'), Object.UseVertexArray = 1;end            
if ~isfield(Object,'PosInDepth'),Object.PosInDepth = 0.1*Display.Pixels_per_m; end
if ~isfield(Object,'AngularVelocity'),Object.AngularVelocity = 90; end         % Angular velocity of rotation (degrees per second)
Object.DegPerFrame = Object.AngularVelocity/Display.RefreshRate;
Object.Rotation = 0;
Object.RotationDirection = 1;


% Object.OBJdir = fullfile(cd,'3D rendering');
% cd(Object.OBJdir);
% OBJfiles = dir('*.obj');
Object.Number = 2;

Key.LastPress = GetSecs; 
Key.WaitTime = 0.1;                                                             % Time to wait between consecutive keypresses (seconds)
CaptureTexture = 0;                                                             % Write OpenGL scene to PTB texture?
Movie = 0;
CaptureRect = CenterRect([0 0 500 500], Display.Rect);
if Movie == 1 && ismac
    try
        movie = Screen('CreateMovie', Display.win, '3DObject.mov', Object.Size, Object.Size, Display.RefreshRate);
    catch
        rethrow(lasterror);
    end
end

if ~isfield(Object,'Filename')                                                  % Default 3D object is a banana!
    RootDir = mfilename('fullpath');                                            % Find directory where this function is being called from
    FileDir = fullfile(fileparts(RootDir),'3D rendering');
    switch Object.Number
        case 1
            Object.Filename = 'anon_obj.obj';
            Object.TextureName = 'anon_diffus.jpg';
            Object.Orientation = 0;
            Object.OBJFaceStruct = 4;
        case 2
            Object.Filename = 'banana_obj.obj';
            Object.TextureName = 'Banana.jpg';
            Object.Orientation =75;
        case 3
            Object.Filename = fullfile('Food_OBJ_Triangles','apple.obj');
            Object.TextureName = fullfile('Food_alternate_maps','apple_diffuse_red__no_ao.jpg');
            Object.Orientation = 20;
        case 4
            Object.Filename = 'female head_obj.obj';
            Object.TextureName = '_';
            Object.Orientation = 0;
            Object.OBJFaceStruct = 3;
        case 5
            Object.Filename = 'formica_rufa.obj';
            Object.TextureName = 'formica rufa.jpg';
            Object.Orientation = 0;
            Object.OBJFaceStruct = 5;
        case 6
            Object.Filename = 'ShoeNike.stl';
            Object.TextureName = '_';
            Object.Orientation = 0;
            Object.OBJFaceStruct = [];
    end
    Object.Fullfile = fullfile(FileDir,Object.Filename);
    Object.TextureName = fullfile(FileDir,Object.TextureName);                  % Specify location of texture image file
end

%========================= SET VIEW FRUSTUM GEOMETRY ======================
width = Display.Rect(3);                                                        % Get screen width (pixels)
height = Display.Rect(4);                                                       % Get screen height (pixels)
CameraTranslate = Object.IPD/2*Display.Pixels_per_m(1);                       	% Distance to move view point for orthographic projection (pixels)
CameraDistance = Display.D*Display.Pixels_per_m(1);    
zNear = 1000;
zFar = -500;
zNear = max(abs([round(Object.DepthRange(1)*Display.Pixels_per_m(1)), zNear]));	% Ensure viewing frustum depth accomodates requested object positions
zFar = -max(abs([round(Object.DepthRange(2)*Display.Pixels_per_m(1)), zFar])); 

%========================== LOAD OBJECT MODEL =============================
Display.Background = Object.Background;
LoadingText.Colour = [255 255 255 255];
LoadingText.String = sprintf('Loading 3D model: %s...', Object.Filename); 
DisplayText(LoadingText, Display);
LoadingText.StartTime = GetSecs;
if strcmp(Object.Filename(end-2:end),'obj');
%     try
%         OBJ=read_wobj(Object.Filename);
%         objobject{1}.vertices = OBJ.vertices';
%         objobject{1}.normals = OBJ.vertices_normal';
%         objobject{1}.texcoords = OBJ.vertices_texture';
%         objobject{1}.faces = [];
%         o = 1;
%         for n = 1:numel(OBJ.objects)
%             if isstruct(OBJ.objects(n).data)
%                 Object.OBJFaceStruct(o) = n;
%                 objobject{1}.faces = [objobject{1}.faces, OBJ.objects(n).data.vertices'-1];
% %                 objobject{1}.faces{o} = OBJ.objects(n).data.vertices'-1;
%                 o = o+1;
%             end
%         end
%        
%         if Debug == 1
%             FV.vertices=OBJ.vertices;
%             FV.faces=OBJ.objects(Object.OBJFaceStruct).data.vertices;
%             figure, patch(FV,'facecolor',[1 0 0]); camlight;
%         end
%         
%     catch
%         rethrow(lasterror);
%         sca
%         return
%     end
    try
        objobject = LoadOBJFile(Object.Fullfile);                             	% Load .OBJ file
    catch
       fprintf('ERROR: unable to load %s using LoadOBJFile.m!\n', Object.Filename);
       rethrow(lasterror);
       sca
       return
    end

    p = objobject{1}.vertices;                                               	% Get vertices
    if isfield(objobject{1}, 'faces')
        if size(objobject{1}.faces,1) == 3
            t = objobject{1}.faces';                                            % Get vertices indices for triangular faces
            t(t==0) = 1;
        elseif size(objobject{1}.faces,1) == 4
            q = objobject{1}.faces';                                         	% Get vertices indices for triangular faces
            q(q==0) = 1;
        end  
    end
    if isfield(objobject{1}, 'quadfaces')
        q = objobject{1}.quadfaces';
        q(q==0) = 1;
    end
    
    CentreDistFromOrigin = mean(objobject{1}.vertices');                       	% Get x, y and z distance from centre of object to world origin
    objobject{1}.vertices = p-repmat(CentreDistFromOrigin',[1,numel(p(1,:))]);  % Normalize object centre to world origin
%     if Debug == 1
%         trisurf(t,p(1,:),p(2,:),p(3,:),'facecolor','y');                          % TEST: 3D plot of object to check surface 
%         hold on;
%         Quads = p(q(1,:)
%         patch(q,'y');
%     end
elseif strcmp(Object.Filename(end-2:end),'stl')
    
    [p, t, n, c, stltitle] = stlread(Object.Fullfile);                          % Load .STL file
    
    
    [p,t,tnorm] = import_stl_fast(Object.Fullfile, 1);                          % Load .STL file
    norm = repmat(tnorm, 1, numel(p(:,1)));                                     % Get normal for each vertex
else
    fsprintf('ERROR: Unable to load %s because it is not an .obj or .stl file!\n',Object.Filename);
end

%======================= LOAD TEXTURE
if strcmp(Object.TextureName(end-3),'.')                                        % If texture image file was located...
    ObjectTexture = imread(Object.TextureName);                                 % Load texture image
    tx = permute(ObjectTexture,[3 2 1]);                                        % Permute RGB image to 3xMxN array
    tx = tx(:,:,end:-1:1);                                                      % Flip texture matrix
    tx = tx*(255/max(max(max(tx))));                                            % Maximize texture contrast
%  	TextureScale = 256/size(tx,2); 
%  	tx = imresize(tx, TextureScale);                                            % Resize texture
%   tx = uint8(tx);                                                             % Convert texture array to unit8
else
    fprintf('Texture file %s not found!\nProceeding without texture mapping.\n', Object.TextureName);                                                        % Revert to untextured object
end 
LoadingText.String = sprintf('Object loaded in %.0f ms!', GetSecs-LoadingText.StartTime);
DisplayText(LoadingText, Display);

%========================= BEGIN RENDERING LOOP ===========================
Screen('BlendFunction', Display.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);     % Enable blending for alpha transparency
EndLoop = 0;Frame = 1; Object.SetLightAndTex = 1;
while EndLoop == 0
    Object.BeginRender = GetSecs;
    for Eye = 1:2
    %     BackgroundTextures{Eye} = Screen('MakeTexture', Display.win, repmat(Cube.Background(1),Display.Rect([4,3])));
        currentbuffer = Screen('SelectStereoDrawBuffer', Display.win, Eye-1);           % Select buffer for current eye
        Screen('BeginOpenGL', Display.win);                                             % Prepare OpenGL to render
        glClear(mor(GL.DEPTH_BUFFER_BIT, GL.STENCIL_BUFFER_BIT));                       % Clear buffers
        if Object.SetLightAndTex == 1
            glEnable(GL.BLEND);
            glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);                          % Enable alpha blending for transparent occluding surfaces
            glViewport(0, 0, width, height);                                            % Specify all OpenGL object sizes in pixels
            glEnable(GL.DEPTH_TEST);                                                    % Enable proper occlusion handling via depth tests
           	if Object.Texture > 0                                                   %==== DRAW SHADED OBJECT
                glEnable(GL.LIGHTING);                                                  % Enable local lighting (Phong model with Gouraud shading)
                glEnable(GL.LIGHT0);                                                	% Enable the first light source
                glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);                        % Enable two-sided lighting
                glPolygonMode(GL.FRONT_AND_BACK, GL.FILL);                              % Enable filled polygons
            elseif Object.Texture == 0                                              %==== DRAW OBJECT MESH
                glDisable(GL.LIGHTING);                                                 % Disable lighting
                glPolygonMode(GL.FRONT_AND_BACK, GL.LINE);                              % Enable polygon outlines
            end
        end
        
    %     %======================== LOAD CUBE TEXTURE ===========================
    %     if Cube.Texture >= 2 && Eye == 1
    %         glEnable(GL.TEXTURE_2D);                                                % Enable texture mapping
    %         texname(1) = glGenTextures(1);                                          % Create a new texture
    %         Root = mfilename('fullpath');                                           % Find directory where this function is being called from
    %         TextureFile = fullfile(fileparts(Root),'3D rendering',Cube.TextureName);% Specify location of texture image file
    %         if ~isempty(dir(TextureFile))                                           % If texture image file was located...
    %             CubeTexture = imread(TextureFile);                                  % Load texture image
    %             if size(CubeTexture,1) ~= size(CubeTexture,2)                       % If texture image is not square...
    %             	Cube.Texture = 1;                                            	% Revert to untextured solid cubes
    %             end
    %             if size(CubeTexture,1) ~= 256                                       % resize texture image
    %                 TextureScale = 256/size(CubeTexture,1);
    %                 CubeTexture = imresize(CubeTexture, TextureScale);
    %             end
    %             tx{1} = permute(CubeTexture,[3 2 1]);                               % Permute RGB image to 3xMxN array
    %         else
    %             Cube.Texture = 1;                                                   % Revert to untextured cubes
    %         end
    %         if Cube.Texture >= 2
    %             glBindTexture(GL.TEXTURE_2D,texname(1));                                      	% Enable i'th texture by binding it:
    %             glTexImage2D(GL.TEXTURE_2D,0,GL.RGB,256,256,0,GL.RGB,GL.UNSIGNED_BYTE,tx{1});  	% Assign image in matrix 'tx' to i'th texture:
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);                    % Setup texture wrapping behaviour:
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.NEAREST);               % Setup filtering for the textures
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.NEAREST);
    %             glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);                     % Choose texture application function to modulate light reflection properties of the the cubes face
    %         end
    %     end

        %======================= SETUP PROJECTION MATRIX ======================
        glMatrixMode(GL.PROJECTION);            
        glLoadIdentity;     
        if Object.Perspective == 0                                                % Set orthographic projection
            glOrtho(0-(width/2), 0+(width/2), 0-(height/2), 0+(height/2), -500, 1000);  
        elseif Object.Perspective == 1                                            % Set perspective projection
            moglStereoProjection(0-(width/2), 0+(height/2), 0+(width/2), 0-(height/2), zNear, zFar, 0, CameraDistance, CameraTranslate*round(Eye-1.5));
        end

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
        glClearColor(Object.Background(1),Object.Background(2),Object.Background(3),Object.Background(4)); 	% Set background clear color
%         	glColorMaterial(GL.FRONT_AND_BACK, GL.EMISSION);                    % hand control of lighting color to glColorMaterial
%           glEnable(GL.COLOR_MATERIAL);
%           glColorMaterial(GL.FRONT_AND_BACK, GL.AMBIENT_AND_DIFFUSE);

        if Object.Perspective == 0
            gluLookAt(CameraTranslate*round(Eye-0.5),0,CameraDistance,0,0,0,0,1,0);     % Camera fixates at the origin (0,0,0) from either eye view
        end
            
        if Object.SetLightAndTex == 1
            Object.SetLightAndTex = 0;
            %======================== LOAD MODEL TEXTURE ======================
            if Object.Texture > 1 && exist('tx','var')
                texname = glGenTextures(1);                                                     % Create a new texture
                glBindTexture(GL.TEXTURE_2D,texname);                                           % Enable texture by binding it
                glTexImage2D(GL.TEXTURE_2D,0,GL.RGB,size(tx,2),size(tx,3),0,GL.RGB,GL.UNSIGNED_BYTE,tx);      % Assign image in matrix 'tx' to i'th texture:
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);                    % Setup texture wrapping behaviour:
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.CLAMP_TO_EDGE);             % Setup texture wrapping behaviour:
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.CLAMP_TO_EDGE);        
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.LINEAR);                % Setup filtering for the textures
                glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.LINEAR);
    %             glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.LINEAR_MIPMAP_NEAREST );
                glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);                     % Choose texture application function to modulate light reflection properties of the the Objects face
    %             glGenerateMipmapEXT(GL.TEXTURE_2D);                                             
                glEnable(GL.TEXTURE_2D);
            else
                glDisable(GL.TEXTURE_2D);
            end

            %======================= SETUP VERTEX ARRAYS ======================
            if ~isempty(objobject{1}.vertices)
                vertices = reshape(objobject{1}.vertices, [1,numel(objobject{1}.vertices)]);
                glVertexPointer(3, GL.DOUBLE, 0, vertices);
                glEnableClientState(GL.VERTEX_ARRAY);
            else
                fprintf('\nERROR: vertex array loaded from %s contained no vertices!\n', Object.Filename);
                return
            end
            if ~isempty(objobject{1}.normals)
                normals = reshape(objobject{1}.normals, [1,numel(objobject{1}.normals)]);
                glNormalPointer(GL.DOUBLE, 0, normals);
                glEnableClientState(GL.NORMAL_ARRAY);
            end
            if ~isempty(objobject{1}.texcoords)
                texcoords = reshape(objobject{1}.texcoords, [1,numel(objobject{1}.texcoords)]);
                glTexCoordPointer(3, GL.DOUBLE, 0, texcoords);
                glEnableClientState(GL.TEXTURE_COORD_ARRAY);
            end
%             glColorPointer(3, GL.FLOAT, 0, colors);
%             glEnableClientState(GL.COLOR_ARRAY);

            %===================== COMPILE DISPLAY LIST FOR OBJECT ========
            glNewList('Object', GL.COMPILE); 
            glPushMatrix();
%                 glTranslatef(CentreDistFromOrigin(1),CentreDistFromOrigin(2),CentreDistFromOrigin(3));
                glRotatef(Object.Orientation, 1,0,0);                         	% Rotate object to desired 'upright' orientation
                Scale = 1/max(max(abs(objobject{1}.vertices)))*Object.Size;                    
                glScalef(Scale,Scale,Scale);                                    % Scale object to desired size
                glEnable(GL.NORMALIZE);                                         % Normalize vertex normal lengths
                if exist('t','var')
%                     glDrawElements(GL.TRIANGLES, 3, GL.UNSIGNED_INT, t);
                    glBegin(GL.TRIANGLES);
                    for n = 1:numel(t(:,1))
                        if Object.UseVertexArray == 1
                            glArrayElement(t(n,1));
                            glArrayElement(t(n,2));
                            glArrayElement(t(n,3));
                        else
                            glTexCoord2fv(texcoords(t(n,1)));
                            glNormal3fv(norm(t(n,1),:));
                            glVertex3dv(p(:,t(n,1)));
                            glTexCoord2fv(texcoords(t(n,2)));
                            glNormal3fv(norm(t(n,2),:));
                            glVertex3dv(p(:,t(n,2)));
                            glTexCoord2fv(texcoords(t(n,3)));
                            glNormal3fv(norm(t(n,3),:));
                            glVertex3dv(p(:,t(n,3)));
                        end
                    end
                    glEnd;
                end    
                if exist('q','var')
                    glBegin(GL.QUADS);
                    for n = 1:1:numel(q(:,1))
                        if Object.UseVertexArray == 1
                            glArrayElement(q(n,1));
                            glArrayElement(q(n,2));
                            glArrayElement(q(n,3));
                            glArrayElement(q(n,4));
                        else
                            glNormal3fv(norm(q(n,1),:));
                            glVertex3dv(p(:,q(n,1)));
                            glNormal3fv(norm(q(n,2),:));
                            glVertex3dv(p(:,q(n,2)));
                            glNormal3fv(norm(q(n,3),:));
                            glVertex3dv(p(:,q(n,3)));
                            glNormal3fv(norm(q(n,4),:));
                            glVertex3dv(p(:,q(n,4)));
                        end
                    end
                    glEnd;
                end
            glPopMatrix();
            glEndList();  

%          	%===================== COMPILE DISPLAY LIST FOR WORLD ORIGIN MARKER
%             glNewList('Origin', GL.COMPILE);
%             radius = 10;
%             glPushMatrix();
%                 glTranslatef(0, radius, 0);                                 % Translate to sit on y = 0 plane
%                 glutSolidSphere(radius, 100, 100);                          % Draw sphere
%             glPopMatrix();
%             glEndList(); 
            
%          	Cube = struct('CallTime',GetSecs);                                                  % Generate background cubes
%             [BackgroundTextures, GL] = BackgroundCubes(Display, Cube, GL);
        end


%         glCallList('Cube');
%         glCallList('Origin');
        Object.Rotation = Object.Rotation+(Object.DegPerFrame*Object.RotationDirection);
        glTranslatef(0,0,Object.PosInDepth);                                                    % Set object position in depth
        glRotatef(Object.Rotation, 0,1,0);                                                      % Rotate object
        glCallList('Object');                                                                   % Call object display list
        Screen('EndOpenGL', Display.win);                                                       % Finish OpenGL rendering
        if CaptureTexture == 1
            ObjectTextures{Eye} = Screen('GetImage', Display.win, Display.Rect,'backBuffer');	% Capture texture as image
            Textures(Eye) = Screen('MakeTexture', Display.win, ObjectTextures{Eye});         	% Convert image to PTB texture
            Screen('FillRect', Display.win, Object.Background(1));                            	% Clear window buffer
        end
    end
    Screen('DrawingFinished', Display.win);
    RenderTimes(Frame) = (GetSecs-Object.BeginRender)*1000;
    [VBL FrameOnset] = Screen('Flip', Display.win);
    
    %======================= CAPTURE MOVIE FRAME ==========================
    if Movie > 0
       	MovieFrames{Frame} = Screen('GetImage', Display.win, CaptureRect);         % Add frame to movie
        fprintf('Captured frame %d of %d.\n', Frame, round(360/DegPerFrame));
%         if ismac
%             Screen('AddFrameToMovie', MovieFrames{Frame});
%         end
        if Frame == 90 || Frame == 180
            Object.Texture = Object.Texture+1;
        end
        if Frame == 380
            EndLoop = 1;
        end
    end
    
    %===================== CHECK FOR KEYPRESSES ===========================
    [keyIsDown,secs,keyCode] = KbCheck;                                             % Check keyboard for 'escape' press        
    if keyIsDown && secs > Key.LastPress+Key.WaitTime
        Key.LastPress = secs;
        if keyCode(KbName('Escape')) == 1                                  % Press Esc for abort
            EndLoop = 1;
        elseif keyCode(KbName('t'))
            Object.SetLightAndTex = 1;
            if Object.Texture < 2
                Object.Texture = Object.Texture+1;
            else
                Object.Texture = 0;
            end
        elseif keyCode(KbName('uparrow'))
            Object.PosInDepth = Object.PosInDepth-(Display.Pixels_per_m/100);
        elseif keyCode(KbName('downarrow'))
            Object.PosInDepth = Object.PosInDepth+(Display.Pixels_per_m/100);
        elseif keyCode(KbName('leftarrow'))
           Object.DegPerFrame = Object.DegPerFrame+(10/Display.RefreshRate);
        elseif keyCode(KbName('rightarrow'))
            Object.DegPerFrame = Object.DegPerFrame-(10/Display.RefreshRate);
        elseif keyCode(KbName('d'))
            Object.RotationDirection = -Object.RotationDirection;
        end
    end
    Frame = Frame+1; 
end
Screen('CloseAll');
ListenChar(0);                                              % Restore command line keyboard output
ShowCursor; 

%============================== ENCODE MOVIE ==========================
if Movie == 1
    if ismac
        Screen('FinalizeMovie', movie);
    else
        movieFile = 'StereoMask.avi';
        for Frame = 1:numel(MovieFrames)
            MatlabMovieFrames(Frame) = im2frame(MovieFrames{Frame});
        end
        if ismac
            movie2avi(MatlabMovieFrames, movieFile, 'compression', 'none', 'fps', 60);
        else
            movie2avi(MatlabMovieFrames, movieFile, 'compression', 'Cinepak', 'fps', 60);
        end
    end
    clear MatlabMovieFrames
elseif Movie == 2 
    for n = 1:numel(MovieFrames)
        StillFrame = MovieFrames{n};
     	movieFile = strcat('Object_Frame',num2str(n),'.png');
        imwrite(StillFrame, movieFile);
    end
end

%======================== PRINT TIMING STATS ==============================
fprintf('\n%d frames were rendered.\n', numel(RenderTimes));
fprintf('Mean render time per frame = %.0f ms +/- %.1f (SE).\n', mean(RenderTimes), std(RenderTimes)/sqrt(numel(RenderTimes)));
fprintf('Max render time = %.0f ms.\n', max(RenderTimes(2:end)));
% if Debug == 1
%     hist(RenderTimes,100)
% end

% catch
%     sca;
%     ListenChar(0);                                              % Restore command line keyboard output
%     ShowCursor; 
%     rethrow(lasterror);
% end