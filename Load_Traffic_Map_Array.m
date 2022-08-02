function Merge=Load_Traffic_Map_Array(Date,Time);

% Display user help if function is called without parameters
if nargin==0
  disp('Usage:  Load_Traffic_Map_Array(''09_19_19'',''10:30'')')
  return
end

% Load all traffic tiles for a given date and time
St = ['TrafficMap*',Date,'__',Time,'.png'];
Files = dir(St);

% Initialize number of images in horizontal and vertical directions
N_lat  = 0;
N_long = 0;

% Loop through all tiles for given date and time
for idx=1:size(Files,1)
  disp(Files(idx).name);
  
  % Determine horizontal and vertical tile indices
  Lat =Files(idx).name(12);
  Long=Files(idx).name(14);
  
  % Update number of images in horizontal and vertical directions
  N_lat =max(N_lat,str2num(Lat));
  N_long=max(N_long,str2num(Long));
  
  % Determine and dispaly number of pixels in one tile
  % (Each tile has the same number of pixels)
  if idx==1
    D=imread(Files(idx).name);
    N_pix=size(D,1);
    disp(['N_pix = ',num2str(N_pix)])
  end
end

% Stitch all tiles together for given date and time
Merge = uint8(zeros(N_lat*N_pix,N_long*N_pix,3));
for idx=1:size(Files,1)
  D=imread(Files(idx).name);
  Lat =str2num(Files(idx).name(12));
  Long=str2num(Files(idx).name(14));
  Merge(1+(N_lat-Lat)*N_pix:(N_lat-Lat+1)*N_pix,1+(Long-1)*N_pix:(Long)*N_pix,:) = D;
end 
