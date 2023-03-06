% Developed at Computer Vision lab, Institue for Advanced Studies in Basic Sciences

%% INITIALIZATION
final_allIter_APs = {};

run("config")
addpath('./local_pattern_lib/descFuncs')
addpath('./local_pattern_lib/sideFuncs')

if KRAW_EXTRACTOR == "OURS"
    addpath('../KrawMomDec/');   %path to our impelementation
elseif KRAW_EXTRACTOR == "2DKD"
        %path to 2DKD source
    addpath('D:\uni\Research\Moment-based Image Retrieval\2DKD\2DKD-master\scripts');
end    

xs = round(PATCH_SIZE/2);
ys = xs;
if ~exist('ALLCONSTS','var') && (KRAW_EXTRACTOR == "OURS")
    ALLCONSTS = [];
    if MULTI_P
        for i=1:length(PSET)
            for j=1:length(PSET)
                ALLCONSTS = [ALLCONSTS, krawPrep(PATCH_DIMs, PSET(i), PSET(j))];
            end
        end
    else
        ALLCONSTS = krawPrep(PATCH_DIMs, .5, .5);
    end
elseif ~exist('ALLCONSTS','var') && (KRAW_EXTRACTOR == "2DKD")
    ALLCONSTS = prepStep(PATCH_SIZE);
elseif ~exist('ALLCONSTS','var')
    error("Wrong value for Krawtchouk extractor. choose between 2DKD and OURS")
end


%% TRAINING STAGE

clear fg_moments

% extracting all features
if ~exist('allMoments.mat', 'file')

    allMoments = {};
    for i = 1:3:NUM_OF_IMGS-2
        allMoments{round((i/3)+1)} = [];
        if i>1  % avoid writing log in multipule lines
            fprintf(repmat('\b', 1, 22+numel(num2str(NUM_OF_IMGS/3))+ numel(num2str(round((i/3)))))); 
        end
        fprintf("describing im %d out of %d", round((i/3)+1), NUM_OF_IMGS/3);

        %reading images
        if size(imread(char(imageSetAll.Files(i))),3)==3
            im = rgb2gray(imread(char(imageSetAll.Files(i))));
        else
            im = imread(char(imageSetAll.Files(i)));
        end
        im = imresize(im, SCALE);
        %patch extraction
        keyPoints = vl_sift(single(im));    %extracting SIFT keypoints
        fg_keyPoints = keyPoints;
        bg_keyPoints = keyPoints;

        sm = imread(char(imageSetAll.Files(i+1)));    %saliency map
        sm = imresize(sm, SCALE);
        %removing bg points
        smt = imread(char(imageSetAll.Files(i+2)));    %saliency map thresholded
        smt = imresize(smt, SCALE);
        valuesInPoints = (diag(smt(round(keyPoints(2,:)), round(keyPoints(1,:)))))'; 
        fg_keyPoints(:, valuesInPoints == 0 ) = [];
        bg_keyPoints(:, valuesInPoints ~= 0 ) = [];

        fg_patches = patchExtractor(im2double(im), fg_keyPoints, PATCH_SIZE);
        bg_patches = patchExtractor(im2double(im), bg_keyPoints, PATCH_SIZE);


        % Kraw moment computation
        % background
        for j=1:length(bg_patches)   
            if KRAW_EXTRACTOR == "OURS"
                  q_tilda = [];
                  for c=1:length(ALLCONSTS)
                      if ~(sum(sum(ALLCONSTS(c).W  .* double(bg_patches{j})))==0)
                        q_tilda = [q_tilda, krawtchuckMoment(PATCH_DIMs,double(bg_patches{j}), ALLCONSTS(c))];
                      end
                  end
            elseif KRAW_EXTRACTOR == "2DKD"
                q_tilda = compDesc(double(bg_patches{j}), xs, ys, ALLCONSTS);
            end
            allMoments{round((i/3)+1)} = [allMoments{round((i/3)+1)}; q_tilda];
        end


        %forground
        fg_moments{round((i/3)+1)} = [];
        for j=1:length(fg_patches)   
            if KRAW_EXTRACTOR == "OURS"
                q_tilda = [];
                for c=1:length(ALLCONSTS)
                    if ~(sum(sum(ALLCONSTS(c).W  .* double(fg_patches{j})))==0)
                        q_tilda = [q_tilda, krawtchuckMoment(PATCH_DIMs,double(fg_patches{j}), ALLCONSTS(c))];
                    end
                end
            elseif KRAW_EXTRACTOR == "2DKD"
                q_tilda = compDesc(double(fg_patches{j}), xs, ys, ALLCONSTS);
            end
            allMoments{round((i/3)+1)} = [allMoments{round((i/3)+1)}; q_tilda];
            fg_moments{round((i/3)+1)} = [fg_moments{round((i/3)+1)}; q_tilda];
        end

    end

    fprintf("\n")
    save('allMoments', 'allMoments');
    save('fg_moments', 'fg_moments');

else
    load('fg_moments.mat')
    load('allMoments.mat')
end
for iter = 1:NUM_OF_ITERS
    
    % split data

    if DATASET == "CALTECH101" || "ImageNet"
        testSetInit.Files = []; fg_moments_test=[]; trainMoments=[];
        imageSetInit.Files = []; fg_moments_train=[]; testMoments=[];
        fprintf("Conducting CALTECH101 sampeling strategy\n")
        for i=1:NUM_OF_CLASSES
            fprintf("Class %d\n", i)
            temp = and(contains(imageSetAll.Files,['/' num2str(i) '_']), contains(imageSetAll.Files, '.jpg'));
            classImgsIndcs = find(temp==1);
            classMembers = length(classImgsIndcs);
            all_indcs = randperm(classMembers);
%             indcs = (all_indcs*3)-2;
            trainMoments = [trainMoments allMoments(round(((classImgsIndcs(all_indcs(1:CLASS_SPECIFIC_NUM_TRAIN)))/3)+1))];
            fg_moments_train = [fg_moments_train fg_moments(round(((classImgsIndcs(all_indcs(1:CLASS_SPECIFIC_NUM_TRAIN)))/3)+1))];
            for s=1:CLASS_SPECIFIC_NUM_TRAIN
                imageSetInit.Files = [imageSetInit.Files; imageSetAll.Files(classImgsIndcs(all_indcs(s)));...
                    imageSetAll.Files(classImgsIndcs((all_indcs(s)))+1);imageSetAll.Files(classImgsIndcs((all_indcs(s)))+2)];
            end
            if classMembers<=(CLASS_SPECIFIC_NUM_TRAIN+CLASS_SPECIFIC_NUM_TEST)
                testMoments = [testMoments allMoments(round(((classImgsIndcs(all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):end)))/3)+1))];
%                 testMoments = [testMoments allMoments(round((all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):end))/3)+1)];
                fg_moments_test = [fg_moments_test fg_moments(round(((classImgsIndcs(all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):end)))/3)+1))];
%                     fg_moments(round((all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):end))/3)+1)];
                for s=(CLASS_SPECIFIC_NUM_TRAIN+1):classMembers
                    testSetInit.Files = [testSetInit.Files; imageSetAll.Files(classImgsIndcs(all_indcs(s)));...
                        imageSetAll.Files(classImgsIndcs((all_indcs(s)))+1);imageSetAll.Files(classImgsIndcs((all_indcs(s)))+2)];
                end
            else
                
                testMoments = [testMoments allMoments(round(((classImgsIndcs(all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):(CLASS_SPECIFIC_NUM_TRAIN+CLASS_SPECIFIC_NUM_TEST))))/3)+1))];
%                 testMoments = [testMoments allMoments(round(all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):(CLASS_SPECIFIC_NUM_TRAIN+CLASS_SPECIFIC_NUM_TEST))/3)+1)];
                fg_moments_test = [fg_moments_test fg_moments(round(((classImgsIndcs(all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):(CLASS_SPECIFIC_NUM_TRAIN+CLASS_SPECIFIC_NUM_TEST))))/3)+1))];
%                 fg_moments_test = [fg_moments_test fg_moments(round(all_indcs((CLASS_SPECIFIC_NUM_TRAIN+1):(CLASS_SPECIFIC_NUM_TRAIN+CLASS_SPECIFIC_NUM_TEST))/3)+1)];
                for s=(CLASS_SPECIFIC_NUM_TRAIN+1):(CLASS_SPECIFIC_NUM_TRAIN+CLASS_SPECIFIC_NUM_TEST)
                    testSetInit.Files = [testSetInit.Files; imageSetAll.Files(classImgsIndcs(all_indcs(s)));...
                        imageSetAll.Files(classImgsIndcs((all_indcs(s)))+1);imageSetAll.Files(classImgsIndcs((all_indcs(s)))+2)];
                end
            end
        end
        
    else
        all_indcs = randperm(NUM_OF_IMGS/3);
        indcs = all_indcs(1:NUM_OF_TEST);

        testMoments = allMoments(indcs);
        trainMoments = allMoments;
        trainMoments(indcs) = [];
        fg_moments_test = fg_moments(indcs);
        fg_moments_train = fg_moments;
        fg_moments_train(indcs) = [];
        testSetInit.Files = [];
        indcs = (indcs*3)-2;

        for s=1:NUM_OF_TEST
                testSetInit.Files = [testSetInit.Files; imageSetAll.Files(indcs(s));...
                    imageSetAll.Files((indcs(s))+1);imageSetAll.Files((indcs(s))+2)];
        end

        tempSetInit = imageSetAll;
        indcsToRemove = indcs;
        indcsToRemove = sort(indcsToRemove, 'descend');
        for l=1:NUM_OF_TEST
            tempSetInit.Files(indcsToRemove(l)+2) = [];
            tempSetInit.Files(indcsToRemove(l)+1) = [];
            tempSetInit.Files(indcsToRemove(l)) = [];
        end
        imageSetInit = tempSetInit;

    end
    
    
    epAPs = [];
    for epoch=1:NUM_OF_EPOCHS
        if ~exist('BOW.mat', 'file')

            %build BOW
            fprintf("Running K-means clustration\n");
            [~, BOW] = kmeans(double(cat(1, trainMoments{:})), NUM_OF_WORDS,'maxIter', 10000, 'Display','final','Replicates', 1);

        else
            load('BOW.mat')
        end

    %     clear allMoments
        clear fg_patches bg_patches valuesInPoints fg_keyPoints bg_keyPoints 
        clear keyPoints q_tilda


        %% OFFLINE PROCESSING
        % Computing the final features according to fromula 3 on (Bai, 2018)
        fprintf("Offline Processing\n")
        
        if ~exist('trainFinalFeats.mat', 'file')
            clear finalFeats
            for i = 1:3:(length(imageSetInit.Files)-2)

%                 if i>1  % avoid writing log in multipule lines
%                     fprintf(repmat('\b', 1, 29+numel(num2str(((((length(imageSetInit.Files)-2))*3-2)))+ numel(num2str(round((i/3))))))); 
%                 end
                fprintf("preprocessing im %d out of %d\n", round((i/3)+1), ((((length(imageSetInit.Files)-2))*3-2)));

                img = imread(char(imageSetInit.Files(i)));
                img = imresize(img, SCALE);
                sm = imread(char(imageSetInit.Files(i+1)));     %saliency map
                sm = imresize(sm, SCALE);
                smt = imread(char(imageSetInit.Files(i+2)));    %saliency map thresholded
                smt = imresize(smt, SCALE);
                if MULTI_P
                    finalFeats{round((i/3)+1)} = multiFeatExtractor(img, smt,...
                        sm, fg_moments_train{round((i/3)+1)}, BOW, PATCH_DIMs, ...
                        ALLCONSTS, KRAW_EXTRACTOR, xs, ys);
                else
                    finalFeats{round((i/3)+1)} = multiFeatExtractor(img, smt,...
                        sm, fg_moments_train{round((i/3)+1)}, BOW, PATCH_DIMs, ...
                        ALLCONSTS, KRAW_EXTRACTOR, xs, ys);
                end

            end
            fprintf("\n")
    %             save('trainFinalFeats', 'finalFeats')

        else
           load('trainFinalFeats.mat') 
        end


        %% ONLINE RETRIEVAL
        fprintf("Online Retrieval\n")
        NUM_OF_TEST_IMGS = numel(testSetInit.Files); % number of images in dataset

        % figure(1);
        results = string(zeros(round(NUM_OF_TEST_IMGS/3), NUM_OF_RETRIEVE));
        % results = repmat(' ', [round(NUM_OF_TEST_IMGS/3) NUM_OF_RETRIEVE]);
        for i=1:3:length(testSetInit.Files)-2

%             if i>1  % avoid writing log in multipule lines
%                     fprintf(repmat('\b', 1, 25+numel(num2str(NUM_OF_IMGS/3))+ numel(num2str(round((i/3)))))); 
%             end
            fprintf("retrieving query %d out of %d\n", round((i/3)+1), NUM_OF_TEST_IMGS/3);

            im = imread(char(testSetInit.Files(i)));
            im = imresize(im, SCALE);
            sm = imread(char(testSetInit.Files(i+1)));
            sm = imresize(sm, SCALE);
            smt = imread(char(testSetInit.Files(i+2)));
            smt = imresize(smt, SCALE);

            if MULTI_P
                TestFeat = multiFeatExtractor(im,smt,sm,fg_moments_test{round((i/3)+1)},BOW, PATCH_DIMs,...
                    ALLCONSTS, KRAW_EXTRACTOR, xs, ys);
            else
                TestFeat  = multiFeatExtractor(im,smt,sm,fg_moments_test{round((i/3)+1)},BOW, PATCH_DIMs,...
                    ALLCONSTS, KRAW_EXTRACTOR, xs, ys);
            end
            % distance calculation
            dists = [];
            for j=1:length(finalFeats)
                dists = [dists; multiDist(TestFeat, finalFeats{j})];
            end

            % fusion
            means = mean(dists, 1);
            stds = std(dists,1);
            zDists = (dists-means)./stds;
            zDists(isnan(zDists))=0;
            wzDists = zDists .* FEATS_WEIGHTS;
            final_dists = sum(wzDists,2);

            %sort
            [~, idxs] = sort(final_dists);

            %Visualization
            if (VISUALIZE == 1) && (i<=30)
                subplot(10,11,((round(i/3)*11)+1))
                imshow(im);
                for j=1:10
                    subplot(10,11,((round(i/3)*11)+j+1))
                    imshow(char(imageSetInit.Files((idxs(j)*3)-2)))
                end
            end

            results(round((i/3)+1),:) = string(imageSetInit.Files((idxs(1:NUM_OF_RETRIEVE)'*3)-2));


        end

         finalMAPs= mAP2(results, testSetInit.Files, NUM_OF_CLASSES, DATASET, readAnnotation);
         
%         finalAP = AP(results, testSetInit.Files, NUM_OF_CLASSES, DATASET, readAnnotation);
%         finalMAP = mean(finalMAPs);
        % MAP_new = mAP_new(results, testSetInit.Files(1:3:NUM_OF_TEST_IMGS-2), NUM_OF_CLASSMEMBERS,...
        %     DATASET, readAnnotation, annotationsRoute);
        fprintf("\nIteration %d - Epoch %d: %d", iter, epoch, mean(finalMAPs))
    %     AllfinalMAPs = [AllfinalMAPs; finalMAPs];
%         fprintf("\nEPOCH %d: %d", epoch, finalAP);
%         epAPs = [epAPs, finalAP];
        epAPs = [epAPs, finalMAPs];
    end
    final_allIter_APs{iter} = epAPs;
    
end

%% additional functionsn
%     load handel;
%     sound(y,Fs);

function [leo] = extractListOfExistingObjects(imgFile, DATASET, readAnnotation, annotationsRoute)
    
    if DATASET == "VOC"
        % determine the address of the corresponding label file
        str = erase(imgFile,".png");
        str = erase(str,".jpg");
        str = extractBetween(str,strlength(str)-5,strlength(str));
        str = strcat(annotationsRoute, str,'.txt');
    elseif DATASET == "WANG"
        str = imgFile;
    end
    leo = readAnnotation(str); %list of exisiting objects
    
end

function res = K_Precisions(retievedImgs, query, DATASET, readAnnotation, annotationsRoute)
    
    q_leo = extractListOfExistingObjects(string(query), DATASET, readAnnotation, annotationsRoute);
    
    res = zeros(1, size(retievedImgs,2));
    counter = 0;
    for k=1:size(retievedImgs,2)
        r_leo = extractListOfExistingObjects(string(retievedImgs(k)), DATASET, readAnnotation,annotationsRoute);
        if max(q_leo + r_leo) > 1
            counter = counter+1;
        end
        res(k) = counter/k;
    end
    
end
