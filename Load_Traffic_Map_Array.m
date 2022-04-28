function Merge=Load_Traffic_Map_Array(Date,Time);

if nargin==0
  disp('Usage:  Load_Traffic_Map_Array(''09_19_19'',''10:30'')')
  return
end

St = ['TrafficMap*',Date,'__',Time,'.png'];
Files = dir(St);
N_lat  = 0;
N_long = 0;
for idx=1:size(Files,1)
  disp(Files(idx).name);
  Lat =Files(idx).name(12);
  Long=Files(idx).name(14);
  N_lat =max(N_lat,str2num(Lat));
  N_long=max(N_long,str2num(Long));
  if idx==1
    D=imread(Files(idx).name);
    N_pix=size(D,1);
    disp(['N_pix = ',num2str(N_pix)])
  end
end
Merge = uint8(zeros(N_lat*N_pix,N_long*N_pix,3));
for idx=1:size(Files,1)
  D=imread(Files(idx).name);
  Lat =str2num(Files(idx).name(12));
  Long=str2num(Files(idx).name(14));
  Merge(1+(N_lat-Lat)*N_pix:(N_lat-Lat+1)*N_pix,1+(Long-1)*N_pix:(Long)*N_pix,:) = D;
end 
