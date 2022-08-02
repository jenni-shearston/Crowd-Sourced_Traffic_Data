%----------------------------------------------
function Determine_ActiveStreets(FileWildCard);
%----------------------------------------------

DEBUG=0;

if nargin==0
  disp('Not enough input arguments.')
  disp('Sample usage: Determine_ActiveStreets(''TrafficMap*_04_1*_22*.png'')')
  return
end  

NColors=256;

Maroon   = [36; 42; 77; 118];
Red      = [89; 49; 83; 124];
Orange   = [90; 125; 91; 159];
Green    = [113; 114; 79; 120];
Gray     = [254; 253];
Col_Work = [57];
Col_Fire = [48];

R_crit =[12,15];
RadFill=19;

Files = dir(FileWildCard);
Names = {Files.name};
Tail = extractAfter(Names,15);
Tail =unique(Tail);
Header = 'TrafficMap_*';
FileArray_Wildcards = append(Header,Tail);

for id_file=1:size(FileArray_Wildcards,2)
  disp(['Processing traffic map array ',char(FileArray_Wildcards(id_file))])
  D_RGB = Load_Map_Array(char(FileArray_Wildcards(id_file)));
  if ~exist('D_IND','var')
    GreenFound  = zeros(size(D_RGB,1),size(D_RGB,2),'uint8');
    OrangeFound = zeros(size(D_RGB,1),size(D_RGB,2),'uint8');
    RedFound    = zeros(size(D_RGB,1),size(D_RGB,2),'uint8');
    GrayFound   = zeros(size(D_RGB,1),size(D_RGB,2),'uint8');
  end  
  [D_IND,ColorMap] = rgb2ind( D_RGB, colorcube(NColors), 'nodither' );
  clf
  [CircleCent, CircleRad] = ...
    imfindcircles(D_IND,R_crit,'ObjectPolarity','dark','Sensitivity',.97);
  CIRCLES=Make_Mask(D_IND,CircleCent,CircleRad,R_crit,RadFill);
  for idx=1:size(Green,1)
    GreenFound(D_IND==Green(idx) & ~CIRCLES)=1;
  end
  for idx=1:size(Orange,1)
    OrangeFound(D_IND==Orange(idx) & ~CIRCLES)=1;
  end 
  for idx=1:size(Red,1)
    RedFound(D_IND==Red(idx) & ~CIRCLES)=1;
  end
  for idx=1:size(Gray,1)
    GrayFound(D_IND==Gray(idx) & ~CIRCLES)=1;
  end
  ActiveStreet = (GreenFound & (OrangeFound | RedFound | GrayFound));
  if DEBUG==1
    figure(2)
    subplot(1,2,1)
    imshow(D_IND,ColorMap)
    hold on
    viscircles(CircleCent, CircleRad,'Color','k','LineStyle','-');
    subplot(1,2,2)
    imshow(ActiveStreet,gray(2))
    pause(.1)
  end
end
figure(1), clf
imshow(~ActiveStreet,gray(2))
colorbar
disp('Active street network / background determined')
disp('')
disp('Press <Return> to save to file !')
pause
eval( ['save Active_Streets.mat ActiveStreet Maroon Red Orange Green Gray Col_Work Col_Fire R_crit NColors'])

  


function CIRCLES=Make_Mask(D_new,Cent,Rad,R_crit,RadFill)
%--------------------------------------------------------

NX = size(D_new,1);
NY = size(D_new,2);

CIRCLES = 0*D_new;
for idx=1:size(Cent,1)
 x1 = round(Cent(idx,2)-R_crit(2));
 x2 = round(Cent(idx,2)+R_crit(2)); 
 y1 = round(Cent(idx,1)-R_crit(2));
 y2 = round(Cent(idx,1)+R_crit(2));
 x1=max(1,x1);
 x2=min(x2,NX);
 y1=max(1,y1);
 y2=min(y2,NY);
 Sub_Image = D_new(x1:x2,y1:y2);

   SE=strel('disk',RadFill,8);
   SE=SE.Neighborhood;
   N_SE=size(SE,1);
   x_1 = round(Cent(idx,2)) -(N_SE-1)/2;
   x_2 = round(Cent(idx,2)) +(N_SE-1)/2;
   y_1 = round(Cent(idx,1)) -(N_SE-1)/2;
   y_2 = round(Cent(idx,1)) +(N_SE-1)/2;

   if x_1>0
     x_SE_1=1;
   else
     x_SE_1=-x_1+2;
     x_1=1;
   end
   if x_2<=NX
     x_SE_2=N_SE; 
   else
     x_SE_2=N_SE - x_2 + NX;
     x_2=NX;
   end
   if y_1>0
     y_SE_1=1; 
   else
     y_SE_1=-y_1+2; 
     y_1=1;
   end
   if y_2<=NY
     y_SE_2=N_SE; 
   else
     y_SE_2=N_SE - y_2 + NY; 
     y_2=NY;
   end

   CIRCLES(x_1:x_2,y_1:y_2)=SE(x_SE_1:x_SE_2,y_SE_1:y_SE_2);
end





function Merge=Load_Map_Array(Wildcard);

NXY=2000;
Files = dir(Wildcard);
N_lat  = 0;
N_long = 0;
for idx=1:size(Files,1)
  Lat =Files(idx).name(12);
  Long=Files(idx).name(14);
  N_lat =max(N_lat,str2num(Lat));
  N_long=max(N_long,str2num(Long));
end

Merge = uint8(zeros(N_lat*NXY,N_long*NXY,3));
for idx=1:size(Files,1)
  D=imread(Files(idx).name);
  Lat =str2num(Files(idx).name(12));
  Long=str2num(Files(idx).name(14));
  Merge(1+(N_lat-Lat)*NXY:(N_lat-Lat+1)*NXY,1+(Long-1)*NXY:(Long)*NXY,:) = D;
end
