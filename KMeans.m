function [] = KMeans()
    % http://openclassroom.stanford.edu/MainFolder/DocumentPage.php?course=MachineLearning&doc=exercises/ex9/ex9.html
    % Run K-means
    % The variables are named according to the equations
    % Written by Dang Manh Truong (dangmanhtruong@gmail.com)
    
    Image = double(imread('bird_small.tiff'));
    [rows,cols, RGB] = size(Image);
    Points = reshape(Image,rows * cols, RGB);
    K = 16;
    Centroids = zeros(K,RGB);    
    s = RandStream('mt19937ar','Seed',0);
    % Initialization :
    % Pick out K random colours and make sure they are all different
    % from each other! This prevents the situation where two of the means
    % are assigned to the exact same colour, therefore we don't have to 
    % worry about division by zero in the E-step 
    % However, if K = 16 for example, and there are only 15 colours in the
    % image, then this while loop will never exit!!! This needs to be
    % addressed in the future :( 
    % TODO : Vectorize this part!
    done = false;
    while done == false
        RowIndex = randperm(s,rows);
        ColIndex = randperm(s,cols);
        RowIndex = RowIndex(1:K);
        ColIndex = ColIndex(1:K);
        for i = 1 : K
            for j = 1 : RGB
                Centroids(i,j) = Image(RowIndex(i),ColIndex(i),j);
            end
        end
        Centroids = sort(Centroids,2);
        Centroids = unique(Centroids,'rows'); 
        if size(Centroids,1) == K
            done = true;
        end
    end;

    eps = 0.01; % Epsilon
    IterNum = 0;
    while 1
        % E-step: Estimate membership given parameters 
        % Membership: The centroid that each colour is assigned to
        % Parameters: Location of centroids
        Dist = pdist2(Points,Centroids,'euclidean');

        [~, WhichCentroid] = min(Dist,[],2);

        % M-step: Estimate parameters given membership
        % Membership: The centroid that each colour is assigned to
        % Parameters: Location of centroids
        % TODO: Vectorize this part!
        OldCentroids = Centroids;
        for i = 1 : K
            PointsInCentroid = Points((find(WhichCentroid == i))',:);
            NumOfPoints = size(PointsInCentroid,1);
            % Note that NumOfPoints is never equal to 0, as a result of
            % the initialization. Or .... ???????
            if NumOfPoints ~= 0 
                Centroids(i,:) = sum(PointsInCentroid , 1) / NumOfPoints ;
            end
        end    

        % Check for convergence: Here we use the L2 distance
        IterNum = IterNum + 1;
        Margins = sqrt(sum((Centroids - OldCentroids).^2, 2));
        if sum(Margins > eps) == 0
            break;
        end

    end
    % Load the larger image
    [LargerImage,ColorMap] = imread('bird_large.tiff');
    OriginalLargerImage = LargerImage;
    OriginalColorMap = ColorMap;
    
    LargerImage = double(LargerImage);
    [largeRows,largeCols,~] = size(LargerImage);  % RGB is always 3     
    
    % TODO: Vectorize this part!    
    % Replace each of the pixel with the nearest centroid    
    for i = 1 : largeRows 
        for j = 1 : largeCols
            Dist = pdist2(Centroids,reshape(LargerImage(i,j,:),1,RGB),'euclidean');
            [~,WhichCentroid] = min(Dist);                  
            LargerImage(i,j,:) = Centroids(WhichCentroid,:);
        end
    end

    % Display new image
    figure('name', 'Before k-means');
    imshow(OriginalLargerImage, OriginalColorMap);    
    hold on
    figure('name', 'After k-means');
    imshow(uint8(round(LargerImage)),ColorMap);
    
    imwrite(uint8(round(LargerImage)), 'bird_kmeans.tiff');