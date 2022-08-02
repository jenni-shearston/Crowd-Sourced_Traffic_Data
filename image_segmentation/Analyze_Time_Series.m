%------------------------------------------------
function Analyze_Time_Series_Array(FileWildCard);
%------------------------------------------------

if nargin==0
  disp('Not enough input arguments.')
  disp('Sample usage: Analyze_Time_Series_Array(''TrafficMap_*.png'')')
  return
end  
 
Files = dir(FileWildCard);
Names = {Files.name};
Tail = extractAfter(Names,15);
Tail =unique(Tail);
Header = 'TrafficMap_*';
FileArray_Wildcards = append(Header,Tail);

for id_file=1:size(FileArray_Wildcards,2)
  disp(['Processing traffic map array: ',char(FileArray_Wildcards(id_file))])
  D_RGB = Load_Map_Array(char(FileArray_Wildcards(id_file)));
  Wildcard_as_char=char(FileArray_Wildcards(id_file));
  Date_Str=Wildcard_as_char(13:20);
  Time_Str=Wildcard_as_char(23:27);
  OutFileName = ['CCC_',Date_Str,'__',Time_Str,'.png'];
  D=Analyze_Frame_public(D_RGB);
  disp(['Writing ',OutFileName])
  imwrite(uint8(D),OutFileName)
end





function CCC=Analyze_Frame_public(D_RGB);
%----------------------------------------

DEBUG=0;

Map_CCC=[153/255,0,0;1,0.2,0.2;1,0.5,0;0,1,0;.8,.8,.8;...
	    255/255,191/255,0/255;1,25/255,25/255;0,0,0;1,1,1];

load 'Active_Streets.mat'
  
[D_IND,ColorMap] = rgb2ind( D_RGB, colorcube(NColors), 'nodither' );
[CircleCent, CircleRad] = ...
  imfindcircles(D_RGB,R_crit,'ObjectPolarity','dark','Sensitivity',.97);
[Work,Fire]=Make_Mask(D_IND,CircleCent,CircleRad,R_crit,Col_Work,Col_Fire,15);

GRAY  = (D_IND==243) | (D_IND==246);
BLACK = (D_IND==240) | (D_IND==241);
se = strel('line',10,0);
GRAY_HORI=imopen(GRAY,se);
BLACK_HORI=imopen(BLACK,se);
se = strel('line',10,90);
GRAY_VERT=imopen(GRAY,se);
BLACK_VERT=imopen(BLACK,se);
NS = GRAY_HORI | GRAY_VERT | BLACK_HORI | BLACK_VERT;

D_IND(~ActiveStreet)=255;
CCC=9*ones(size(D_IND));
CCC(~ActiveStreet)=9;
for idx=1:size(Green,1)
  CCC(D_IND==Green(idx))=4;
end
for idx=1:size(Orange,1)
  CCC(D_IND==Orange(idx))=3;
end
for idx=1:size(Red,1)
  CCC(D_IND==Red(idx))=2;
end
for idx=1:size(Maroon,1)
  CCC(D_IND==Maroon(idx))=1;
end
CCC(~(CCC==1) & ~(CCC==2) & ~(CCC==3) & ~(CCC==4) & ActiveStreet)=5;

CCC(Work==1)=6;
CCC(Fire==1)=7;
CCC(NS==1)  =8;

if DEBUG==1
   figure(1) 
   subplot(1,2,1)
   imshow(D_RGB);
   subplot(1,2,2)
   imshow(CCC,Map_CCC)
   drawnow;
   pause(.1)
end




function [Work,Fire]=Make_Mask(D_new,Cent,Rad,R_crit,Col_Work,Col_Fire,RadFill)
%------------------------------------------------------------------------------
NX = size(D_new,1);
NY = size(D_new,2);

Work = 0*D_new;
Fire = 0*D_new;
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
 Percent_Work = sum(sum(Sub_Image==Col_Work)) /  prod(size(Sub_Image));
 Percent_Fire = sum(sum(Sub_Image==Col_Fire)) /  prod(size(Sub_Image));

 if (Percent_Fire>0.14) | (Percent_Work>0.2)
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

   if Percent_Fire>0.14
     Fire(x_1:x_2,y_1:y_2)=SE(x_SE_1:x_SE_2,y_SE_1:y_SE_2);
   else
     Work(x_1:x_2,y_1:y_2)=SE(x_SE_1:x_SE_2,y_SE_1:y_SE_2);
   end  
 end
end





function Merge=Load_Map_Array(Wildcard);
%------------------------------------------------------------------------------

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
