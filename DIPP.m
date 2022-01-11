clc;
clear;
close all;
dInfo = dicominfo('000128.dcm');
dImage = uint8(dicomread(dInfo));
dImage = dicomread(dInfo);
img_in = uint16(dImage);
figure, imshow(img_in, []); 
title('Original Image');
img_in = medfilt2(img_in);
title('Medial Filtered Image');
[rows, columns] = size(dImage);
dImage = medfilt2(dImage,[9 12]);
[B, A] = imhist(dImage);
C=A.*B;
J=A.*A;
E=B.*J;
n=sum(B);
Average=sum(C)/sum(B);
var=sum(E)/sum(B)-Average*Average;
standDev= (var)^0.5;
thresholdValue = Average+0.5*standDev;
bwImage = dImage > thresholdValue;
figure
imshow(bwImage)
title('Binary image');
img_dil = imdilate(bwImage , strel('arbitrary', 20));
figure
imshow(img_dil);
title('Dilated image');
bwImage = imerode(img_dil , strel('arbitrary', 20 ));
figure
imshow(bwImage);
title('Eroded image');
NewImage=bwImage;
J = -bwdist(~NewImage);
figure
imshow(J,[])
Ld = watershed(J);
figure
imshow(label2rgb(Ld))
title('Watershed image');
bw2 = NewImage;
bw2(Ld == 0) = 0;
figure
imshow(bw2)
mask = imextendedmin(J,1500);
D2 = imimposemin(J,mask);
Ld2 = watershed(D2);
bw3 = NewImage;
bw3(Ld2 == 0) = 0;
title('Improved watershed image');
bwImage=bw3;
bigMask = bwareaopen(bwImage, 2000);
finalImage = bwImage;
finalImage(bigMask) = false;
bwImage=bwareaopen(finalImage,70);
labeledImage = bwlabel(bwImage, 8);
RegionMeasurements = regionprops(labeledImage, dImage, 'all');
Ecc = [RegionMeasurements.Eccentricity];
RegionNo = size(RegionMeasurements, 1);
allowableEccIndexes = (Ecc< 0.98);
keeperIndexes = find(allowableEccIndexes);
RegionImage = ismember(labeledImage, keeperIndexes);
bwImage=RegionImage;
figure
imshow(bwImage);
title('Nodule spotted');
%%%%%
clear labeledImage;
clear RegionMeasurements;
clear RegionNo;
labeledImage = bwlabel(bwImage, 8);
RegionMeasurements = regionprops(labeledImage, dImage, 'all');
figure
imshow(dImage);
title('Outlines');
axis image;
hold on;
boundaries = bwboundaries(bwImage);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
thisBoundary = boundaries{k};
plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 3);
end
hold off;
RegionMeas = regionprops(labeledImage, dImage, 'all');
RegionNo = size(RegionMeas, 1);
textFontSize = 14;
labelShiftX = -7;
RegionECD = zeros(1, RegionNo);
fprintf(1,'Region number Area Perimeter Centroid Diameter\n');
for k = 1 : RegionNo
RegionArea = RegionMeas(k).Area;
RegionPerimeter = RegionMeas(k).Perimeter;
RegionCentroid = RegionMeas(k).Centroid;
RegionECD(k) = sqrt(4 * RegionArea / pi);
fprintf(1,'#%2d %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, RegionArea,RegionPerimeter, RegionCentroid, RegionECD(k));
text(RegionCentroid(1) + labelShiftX, RegionCentroid(2), num2str(k), 'FontSize',textFontSize, 'FontWeight', 'Bold');
end
