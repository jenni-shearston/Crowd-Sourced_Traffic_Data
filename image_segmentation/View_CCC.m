function View_CCC(FileName)

D=imread(FileName);
figure(1), clf
Map_CCC=[153/255,0,0;1,0.2,0.2;1,0.5,0;0,1,0;.8,.8,.8;...
         255/255,191/255,0/255;1,25/255,25/255;0,0,0;1,1,1];
imshow(double(D),Map_CCC)
