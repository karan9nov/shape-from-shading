clc
clear

%Read the images
i1 = imread('C:\Users\K-Chak\Google Drive\NYU\Spring 2017\Computer Vision\Assignment\3\p2\dog-png\dog1.png');
i2 = imread('C:\Users\K-Chak\Google Drive\NYU\Spring 2017\Computer Vision\Assignment\3\p2\dog-png\dog2.png');
i3 = imread('C:\Users\K-Chak\Google Drive\NYU\Spring 2017\Computer Vision\Assignment\3\p2\dog-png\dog3.png');
i4 = imread('C:\Users\K-Chak\Google Drive\NYU\Spring 2017\Computer Vision\Assignment\3\p2\dog-png\dog4.png');

%Scaling the images
i1 = double(i1)/255;
i2 = double(i2)/255;
i3 = double(i3)/255;
i4 = double(i4)/255;

%Initializing the light vectors and normalizing them
v1 = [16 19 30]';
v1=v1/norm(v1,2);
v2 = [13 16 30]';
v2=v2/norm(v2,2);
v3 = [-17 10.5 26.5]';
v3=v3/norm(v3,2);
v4 = [9 -25 4]';
v4=v4/norm(v4,2);

%Create a compiled light source vector
V = [v2'; v3'; v4'];

rows = size(i1,1);
cols = size(i1,2);

%Initialize g, albedo, p, q, normal, depth
g = zeros(rows,cols,3);
albedo = zeros(rows,cols);
p =  zeros(rows,cols);
q =  zeros(rows,cols);
normal = zeros(rows,cols, 3);
depth=zeros(rows,cols);

%Running the algorithm in the textbook
for x = 1:rows;
    for y = 1:cols;
        
        %creating the i matrix
        i = [i2(x,y); i3(x,y); i4(x,y)];
        
        %creating the diagonal matrix from i
        I = diag(i);
        
        %preparing the parameters to get g
        A = I * i;
        B = I * V;
        
        if (rank(B)< 3)
                continue;
        end
        
        %solving for g
        temp_g = B\A;
        
        %Storing the g for this x,y in the matrix
        g(x,y,:) = temp_g;   
        %calculating albedo
        albedo(x,y) = norm(temp_g);
        %calculating the normal
        normal(x,y,:) = temp_g/norm(temp_g);
        
        %calculating the gradient in x and y
        p(x,y) = normal(x,y,1)/normal(x,y,3);
        q(x,y) = normal(x,y,2)/normal(x,y,3);
    end
end

%normalizing the albedo
maxalbedo = max(max(albedo));
if( maxalbedo > 0)
    albedo = albedo/maxalbedo;
end

%calculating depth across first column
for i = 2:rows
    depth(i,1) = depth(i-1,1) + q(i,1);
end

%calculating depth across all rows using calculated depth of first column
for i = 2:rows
    for j = 2:cols
        depth(i,j) = depth(i,j-1)+p(i,j);
    end
end

%Albedo Map Colored
figure; 
imagesc(albedo);

%Albedo Map Grayscale
figure; 
imagesc(albedo);
colormap(gray);

%Normal Vectors
figure
spacing = 1;
[X ,Y] = meshgrid(1:spacing:rows, 1:spacing:cols);
quiver3(X,Y,-depth, normal(:,:,1),normal(:,:,2),normal(:,:,3))

%Graylevel depth image
figure
surfl(-depth);
colormap(gray);
grid on;
shading interp

%Wireframe of a depth map
figure
spacing = 1;
[X ,Y] = meshgrid(1:spacing:rows, 1:spacing:cols);
quiver3(X,Y,-depth, normal(:,:,1),normal(:,:,2),normal(:,:,3))
hold on
surf( X, Y, -depth, 'EdgeColor', 'none' );
hold off

%Calculating depth using frankotchellappa algorithm
fkDepth = frankotchellappa(p,q);

%Normal Vectors
figure
spacing = 1;
[X ,Y] = meshgrid(1:spacing:rows, 1:spacing:cols);
quiver3(X,Y,-fkDepth, normal(:,:,1),normal(:,:,2),normal(:,:,3))

%Graylevel depth image
figure
surfl(-fkDepth);
colormap(gray);
grid on;
shading interp

%Wireframe of a depth map
figure
spacing = 1;
[X ,Y] = meshgrid(1:spacing:rows, 1:spacing:cols);
quiver3(X,Y,-fkDepth, normal(:,:,1),normal(:,:,2),normal(:,:,3))
hold on
surf( X, Y, -fkDepth, 'EdgeColor', 'none' );
hold off