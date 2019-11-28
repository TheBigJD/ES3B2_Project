function convImage(inputFile, Image_Height, Image_Width)
tic;

importedImage = imread(inputFile);

im_resized = imresize(importedImage, [Image_Height,Image_Width]);


figure;
imshow(importedImage);
imshow(im_resized);

im_red   = im_resized(:,:,1);
im_green = im_resized(:,:,2);
im_blue  = im_resized(:,:,3);

im_red_4    = im_red/16;
im_green_4  = im_green/16;
im_blue_4   = im_blue/16;

subplot(1,3,1);
image(im_red_4);
subplot(1,3,2);
image(im_green_4);
subplot(1,3,3);
image(im_blue_4);

Image = zeros(Image_Height, Image_Width, 3);
Image = uint8(Image);
Image(:,:,1) = im_red_4;
Image(:,:,2) = im_green_4;
Image(:,:,3) = im_blue_4;



Zero_Padded = cell(Image_Height * Image_Width, 1);

x_Values = dec2bin(0: 1: Image_Width -1,10);
y_Values = dec2bin(0: 1: Image_Height-1,10);

i = 1;

for y = 1:Image_Height
    for x = 1:Image_Width
        a = "20'b";
        b = convertCharsToStrings(x_Values(x,:));
        c = convertCharsToStrings(y_Values(y,:));
        d = " : ColourData = 12'h";
        e = convertCharsToStrings(dec2hex(im_red_4(y,x)-1));
        f = convertCharsToStrings(dec2hex(im_green_4(y,x)-1));
        g = convertCharsToStrings(dec2hex(im_blue_4(y,x)-1));
        k = ";";

        h = [a, b, c, d, e, f, g, k];

        h_Joined = strjoin(h, '');

        Zero_Padded{i} = h_Joined;
        
        i = i + 1;
    end
end

Converted_Image = Zero_Padded;

TableForm = cell2table(Converted_Image);

saveName = strcat(inputFile(1:end-4), "_VerilogForm");

writetable(TableForm, saveName);

toc;







