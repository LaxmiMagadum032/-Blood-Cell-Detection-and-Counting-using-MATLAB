
%% Read and show original Image

img = imread('my3.jpg');
figure;
subplot(4,3,1);
imshow(img);
title('Original Image')

%% Convert to grayscale and show Image

gray_image = rgb2gray(img);
subplot(4,3,2);
imshow(gray_image)
title('Grayscale Image')

%% Separate the channels (RGB) and display Red and Blue channel

red = img(:,:,1);
subplot(4,3,3);
imshow(red);
title('Red Channel')

subplot(4,3,4);
blue = img(:,:,3);
imshow(blue);
title('Blue channel')

%% Segment WBC Nucleas from RED channel

[w,h]=size(red);
wbc = zeros([w h]);
for i=1:w
   for j=1:h
      if red(i,j)<140
          red(i,j)=255;
          wbc(i,j)=255;
      end
   end
end

w_nuc = imbinarize(red);
subplot(4,3,5);
imshow(w_nuc);
title('WBC Nucleus Binarized')
wbc = imopen(wbc, strel('disk',2));
wbc = imclose(wbc, strel('disk',3));
subplot(4,3,6)
imshow(wbc);
title('Segmented WBC')
%% Segment RBC from BLUE channel

[w,h]=size(blue);
for i=1:w
   for j=1:h
      if blue(i,j)>175
          blue(i,j)=255;
      end
   end
end

rbc = imbinarize(blue);
subplot(4,3,7);
imshow(rbc);
title('Segmented RBC')

%% Add both Images and Invert the output
% Adding both images will remove the WBC nucleus from the image.
% This will improve the detection and will reduce the misidentification
rbc_clean = w_nuc + rbc;
subplot(4,3,8);
imshow(rbc_clean);
title('Combined RBC + WBC Binary')

inv_rbc_clean = ~rbc_clean;
subplot(4,3,9);
imshow(inv_rbc_clean);
title('Inverted RBC Clean mask')

%% Count the circles in the image and Highlight them
figure;
imshow(img);
hold on;
% Count number of RBC
[rcenters, rradii, rmetric] = imfindcircles(inv_rbc_clean,[50 600],'ObjectPolarity','bright','Sensitivity',0.94,'Method','twostage');
rh = viscircles(rcenters,rradii, 'Color', 'r');


[rm,rn]=size(rcenters);
fprintf('Number of RBC: %d\n', rm) %RBC COUNT

% Count number of WBC
[B,L] = bwboundaries(wbc);
visboundaries(B, 'Color','b');
fprintf('Number of WBC: %d\n', length(B));%WBC COUNT

text(20,30,['RBC count:',num2str(rm)],'Color', 'yellow','Fontsize',14,'FontWeight','bold');
text(20,60,['WBC count:',num2str(length(B))],'Color', 'cyan','Fontsize',14,'FontWeight','bold');

wbc_label = bwlabel(wbc);  % Label connected WBC regions
props = regionprops(wbc_label, 'Centroid');

for i = 1:length(props)
    c = props(i).Centroid;
    text(c(1), c(2), num2str(i), 'Color', 'cyan', 'FontSize', 10, ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

% Display RBC numbers at centers
if ~isempty(rcenters)
    for i = 1:size(rcenters, 1)
        x = rcenters(i, 1);
        y = rcenters(i, 2);
        if ~isnan(x) && ~isnan(y) && x > 0 && y > 0
            text(x, y, num2str(i), 'Color', 'black', ...
                'FontSize', 10, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
        end
    end
else
    disp(' No RBCs detected. rcenters is empty.');
end
uitable('Data',{rm,length(B)},'ColumnName',{'RBC Count','WBC Count'},...
    'Position',[100 100 300 60]);                                                                                                                                                                             

avg_rbc_radius=mean(rradii);
fprintf('Avg RBC Radius: %.2f pixels\n',avg_rbc_radius);


