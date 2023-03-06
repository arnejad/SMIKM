DATASET = "ImageNet";
trainSpec = "large";

annotationsRoute = "D:\uni\Research\Moment-based Image Retrieval\DB\VOC2006-all\Annotations\";

addpath('local_pattern_lib');

if DATASET == "VOC"
    if trainSpec == "large"
        imageSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/VOC2006-restBest-ss-resized"); %finding name of all the iamges in dataset
        testSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/VOC2006-best200-ss-resized");
        %NUM_OF_CLASSMEMBERS = [79, 48, 71, 70, 79, 68, 78, 60, 38, 78];
    else
        testSetInit = imageDatastore("../DB/VOC2006-restBest-ss-resized"); %finding name of all the iamges in dataset
        imageSetInit = imageDatastore("../DB/VOC2006-best200-ss-resized");
        %NUM_OF_CLASSMEMBERS = ones(1,10)*.20;
    end
    readAnnotation = @readAnnotation_VOC;
    NUM_OF_CLASSES = 10;
elseif DATASET == "OT"
    
    imageSetAll.Files = [];
    list = dir(['D:/uni/Research/Moment-based Image Retrieval/DB/OT' filesep '*.jpg']);
    NUM_OF_TEST = 800;
    for s=1:2680
        add = ['D:/uni/Research/Moment-based Image Retrieval/DB/OT' '/' list(s).name(1:end-4)];
        imageSetAll.Files = [imageSetAll.Files; string([add '.jpg']);
            string([add '_RC.png']); string([add '_RCC.png'])];
    end

    readAnnotation = @readAnnotation_OT;
    NUM_OF_CLASSES = 8;

elseif DATASET == "CALTECH101" || DATASET == "CALTECH101-2"
    imageSetAll.Files = [];
    list = dir(['D:/uni/Research/Moment-based Image Retrieval/DB/Caltech101-ss' filesep '*.jpg']);
    NUM_OF_TEST = 4500;
    for s=1:9030
        add = ['D:/uni/Research/Moment-based Image Retrieval/DB/Caltech101-ss' '/' list(s).name(1:end-4)];
        if (size(imread([add, '.jpg']),3)==3 || contains(add,'/21_'))
             imageSetAll.Files = [imageSetAll.Files; string([add '.jpg']);
                string([add '_RC.png']); string([add '_RCC.png'])];
        else
            fprintf('skipped image %d\n', s);
        end
    end
    readAnnotation = @readAnnotation_Caltech101;
    NUM_OF_CLASSES = 102;
elseif DATASET == "WANG"
    if trainSpec == "large"
        imageSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/wang-10c-ss-renamed");
        testSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/wang-10c-ss-test-renamed");
        %NUM_OF_CLASSMEMBERS = ones(1,10)*92;
    else
        testSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/wang-10c-ss-renamed");
        imageSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/wang-10c-ss-test-renamed");
%         NUM_OF_CLASSMEMBERS = ones(1,10)*8;

    end
    readAnnotation = @readAnnotation_Wang;
    NUM_OF_CLASSES = 10;
    
elseif DATASET == "WANG-Rand"
    
    tempSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/wang-10c-ss-renamed-full");
    testSetInit.Files = [];
    indcsToRemove = [];
    for c=0:9
        if c == 0
            indcs = randi([1,((c*100)+98)], 1, 10);
        else
            indcs = randi([(c*100),((c*100)+98)], 1, 10);
        end
        
        indcs = (indcs*3)-2;
        for s=1:10
            testSetInit.Files = [testSetInit.Files; tempSetInit.Files(indcs(s));...
                tempSetInit.Files(indcs(s)+1);tempSetInit.Files(indcs(s)+2)];
        end
        indcsToRemove = [indcsToRemove, indcs];

    end
    
    indcsToRemove = sort(indcsToRemove, 'descend');
    for l=1:length(indcsToRemove)
        tempSetInit.Files(indcsToRemove(l)+2) = [];
        tempSetInit.Files(indcsToRemove(l)+1) = [];
        tempSetInit.Files(indcsToRemove(l)) = [];
        
    end
    imageSetInit = tempSetInit;
    readAnnotation = @readAnnotation_Wang;
    NUM_OF_CLASSES = 10;
    
elseif DATASET == "CAL256"
    preImageSet = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/Caltech256");
    %split into 60% for train and 40% for test
    trainProp = 0.6;
    nrow = size(preImageSet.Files,1);
    ntrain = floor(nrow * trainProp);
    train_ind = randperm(nrow, ntrain);
    test_ind = setdiff(linspace(1,nrow,nrow), train_ind);
    imageSetInit.Files = preImageSet.Files(train_ind, :);
    testSetInit.Files = preImageSet.Files(test_ind, :);
    
    if ~exist('imageSetInit', 'file')
        num = numel(imageSetInit.Files); % number of images in dataset
        i=1;
        while i ~= numel(imageSetInit.Files)+1
            filename = erase(char(imageSetInit.Files(i)),...
                "D:\uni\Research\Moment-based Image Retrieval\DB\Caltech256\");
            filename = erase(filename, '.jpg');
            sm = strcat("D:\uni\Research\Moment-based Image Retrieval\DB\Cal256_full\", filename, '_RC.png');
            smt = strcat("D:\uni\Research\Moment-based Image Retrieval\DB\Cal256_full\", filename, '_RCC.png');
            if (size(imread(char(imageSetInit.Files(i))),3) == 1)
                fprintf("grayscale image %s\n", filename)
                imageSetInit.Files(i) = [];
            elseif (exist(sm, 'file') && exist(smt,'file'))
                fprintf("sm and smt for %d added\n", i)
                imageSetInit.Files = [imageSetInit.Files([1:i],:);[sm;smt];imageSetInit.Files([i+1:end],:)];
                i=i+3;
            else
                fprintf("could not find sm or smt for %s\n", filename)
                imageSetInit.Files(i) = [];
            end
        end
        i=1;
        while i ~= numel(testSetInit.Files)+1
            filename = erase(char(testSetInit.Files(i)),...
                "D:\uni\Research\Moment-based Image Retrieval\DB\Caltech256\");
            filename = erase(filename, '.jpg');
            sm = strcat("D:\uni\Research\Moment-based Image Retrieval\DB\Cal256_full\", filename, '_RC.png');
            smt = strcat("D:\uni\Research\Moment-based Image Retrieval\DB\Cal256_full\", filename, '_RCC.png');
            if (size(imread(char(testSetInit.Files(i))),3) == 1)
                fprintf("grayscale image %s\n", filename)
                testSetInit.Files(i) = [];
            elseif (exist(sm, 'file') && exist(smt,'file'))
                fprintf("sm and smt for %d added\n", i)
                testSetInit.Files = [testSetInit.Files([1:i],:);[sm;smt];testSetInit.Files([i+1:end],:)];
                i=i+3;
            else
                fprintf("could not find sm or smt for %s\n", filename)
                testSetInit.Files(i) = [];
            end
        end
        save('testSetInit', 'testSetInit')
        save('imageSetInit', 'imageSetInit')
    else
        load('testSetInit')
        load('imageSetInit')
    end
    readAnnotation = @readAnnotation_Cal256;
%     testSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/Cal256_70_test");
%     imageSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/Cal256_70");
    NUM_OF_CLASSES = 256;

elseif DATASET == "ImageNet"
    preImageSet = imageDatastore("D:\ASH\SM-IKM\datasets\ImageNet-sub", 'IncludeSubfolders', true);
    
%     trainProp = 0.6;
%     nrow = size(preImageSet.Files,1);
%     ntrain = floor(nrow * trainProp);
%     train_ind = randperm(nrow, ntrain);
%     test_ind = setdiff(linspace(1,nrow,nrow), train_ind);
%     imageSetInit.Files = preImageSet.Files(train_ind, :);
    imageSetInit.Files = preImageSet.Files();
%     testSetInit.Files = preImageSet.Files(test_ind, :);

   if ~exist('imageSetInit', 'file')
        num = numel(imageSetInit.Files); % number of images in dataset
        i=1;
        while i ~= numel(imageSetInit.Files)+1
            filename = erase(char(imageSetInit.Files(i)),...
                "D:\ASH\SM-IKM\datasets\ImageNet-sub");
            filename = erase(filename, '.JPEG');
            sm = strcat("D:\ASH\SM-IKM\datasets\ImageNet-subSal", filename, '_RC.png');
            smt = strcat("D:\ASH\SM-IKM\datasets\ImageNet-subSal", filename, '_RCC.png');
            if (size(imread(char(imageSetInit.Files(i))),3) == 1)
                fprintf("grayscale image %s\n", filename)
                imageSetInit.Files(i) = [];
            elseif (exist(sm, 'file') && exist(smt,'file'))
                fprintf("sm and smt for %d added\n", i)
                imageSetInit.Files = [imageSetInit.Files([1:i],:);[sm;smt];imageSetInit.Files([i+1:end],:)];
                i=i+3;
            else
                fprintf("could not find sm or smt for %s\n", filename)
                imageSetInit.Files(i) = [];
            end
        end
%         save('testSetInit', 'testSetInit')
        save('imageSetInit', 'imageSetInit')
    else
%         load('testSetInit')
        load('imageSetInit')
   end
   imageSetAll = imageSetInit;
    readAnnotation = @readAnnotation_ImageNet;
%     testSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/Cal256_70_test");
%     imageSetInit = imageDatastore("D:/uni/Research/Moment-based Image Retrieval/DB/Cal256_70");
    NUM_OF_CLASSES = 6;

else
    error("Name of dataset must be VOC, WANG, WANG-Rand or CAL256");
end

PATCH_SIZE = 30;
PATCH_DIMs = [PATCH_SIZE-1, PATCH_SIZE-1];

FEATS_WEIGHTS = [1 1 2 1 1 3 3 2];
% FEATS_WEIGHTS = [1 1 2 1 1 3];

NUM_OF_ITERS = 10;
NUM_OF_EPOCHS = 1;
NUM_OF_RETRIEVE = 100;
NUM_OF_WORDS = 300;
CLASS_SPECIFIC_NUM_TRAIN = 25;
CLASS_SPECIFIC_NUM_TEST = 15;
VISUALIZE = 0;
MULTI_P = true;

PSET = [0.25, 0.75];

KRAW_EXTRACTOR = "OURS";    % choose between "2DKD" and "OURS"
% FBdivide = true;    % computer the colorHistogram for FG & BG seporatly
doubleCountForSalient = false;  % in case of setting to true, the top 10%
                            % salient patchers are counted on histograms
                            % two times instead of one.
NUM_OF_IMGS = numel(imageSetInit.Files); % number of images in dataset

SCALE = 1;

function res = readAnnotation_Wang(filename)
    res =zeros(1,10);
    filename = erase(filename,...
        "D:\uni\Research\Moment-based Image Retrieval\DB\wang-10c-ss-renamed\");
    
    filename = erase(filename,...
        "D:\uni\Research\Moment-based Image Retrieval\DB\wang-10c-ss-test-renamed\");
    filename = erase(filename,...
        "D:\uni\Research\Moment-based Image Retrieval\DB\wang-10c-ss-renamed-full\");
    filename = erase(filename, ".jpg");
    
    res(ceil((str2double(filename)+1)/100)) = 1;
end

function [lbls] = readAnnotation_VOC(filename)

    lbls = zeros(1,10);
    text = fileread(filename);
    
    lbls(1) =       contains(text,'bicycle');
    lbls(2) =       contains(text,'bus');
    lbls(3) =       contains(text,'car');
    lbls(4) =       contains(text,'cat');
    lbls(5) =       contains(text,'cow');
    lbls(6) =       contains(text,'dog');
    lbls(7) =       contains(text,'horse');
    lbls(8) =       contains(text,'motorbike');
    lbls(9) =       contains(text,'person');
    lbls(10) =      contains(text,'sheep');
    
    
end


function lbl = readAnnotation_Cal256(filename)

    lbl = zeros(1,70);
    text = erase(filename,...
        "D:\uni\Research\Moment-based Image Retrieval\DB\Caltech256\");
    text = erase(text,...
        "D:\uni\Research\Moment-based Image Retrieval\DB\Caltech256\");
    text = extractBetween(text,1,3);
    classNum = str2num(text);
    lbl(classNum) = 1;
    
end

function lbls = readAnnotation_OT(filename)

    lbls = zeros(1,8);
    text = filename;
    
    lbls(1) =       contains(text,'coast_');
    lbls(2) =       contains(text,'forest_');
    lbls(3) =       contains(text,'highway_');
    lbls(4) =       contains(text,'insidecity_');
    lbls(5) =       contains(text,'mountain_');
    lbls(6) =       contains(text,'opencountry_');
    lbls(7) =       contains(text,'street_');
    lbls(8) =       contains(text,'tallbuilding_');
    
end

function lbl = readAnnotation_Caltech101(filename)

    lbl = zeros(1,102);
    text = erase(filename,...
        "D:/uni/Research/Moment-based Image Retrieval/DB/Caltech101-ss/");
    text = char(text);
    text = text(1:end-15);
    classNum = str2num(text);
    lbl(classNum) = 1;
    
end

function lbls = readAnnotation_ImageNet(filename)

    lbls = zeros(1,6);
    text = filename;
    
    lbls(1) =       contains(text,'n01491361_');
    lbls(2) =       contains(text,'n02690373_');
    lbls(3) =       contains(text,'n02895154_');
    lbls(4) =       contains(text,'n02917067_');
    lbls(5) =       contains(text,'n02971356_');
    lbls(6) =       contains(text,'n04146614_');
    
end