%==========================================================================
%MIXEDFEATEXTRACTOR computes and merges histograms of channel H, channel S and LBP for
%   both foreground and background and the istorgram of visual words appearnce
%   into one object
%
%inputs:    img is the input image
%           sm is the seliency segmentation.
%           fgKrawMoms is the list of Krawtchouk moments extracted from fg
%               in case of having no moment already computed, input [] to
%               instruct the function to compute them
%           BOW is the Bag-Of-Words
%           patchSize is the constant size for patches (only needed when
%               kraw must be computed by this function)
%                   
% Output:   an object comprised of two sections fg (forground) and bg
%           (background) histograms in each is returned
%
% Authors:  Computer Vision Lab, IASBS
% =========================================================================
function [allFeats] = multiFeatExtractor(img, smt, sm, descs, BOW, PATCH_DIMs,...
    ALLCONSTS, KrawMethod, xs, ys)

    [numY, numX, ~] = size(img);
    if([numY, numX] ~= size(smt))
        error("image and the saliency map should have same sizes")
    end
    
    % local pattern descriptor prepration
%     descFunc = str2func(['desc_' char(localPatterMethod)]);
    options.gridHist = 1;
    options.mask = 'prewitt';
    options.msize = 7;
    
    % Background analysis
    smVec = im2double(smt(:));
    
    %removing the margin from Saliency Map
    orig_smt = smt;
    smt(1,:) = [];
    smt(size(smt,1),:) = [];
    smt(:,1) = [];
    smt(:,size(smt,2)) = [];
    
    if(size(img,3)==1); img=cat(3, img, img, img);end
    img_HSV = rgb2hsv(img);
%     img_YCbCr = rgb2ycbcr(img);
    
    img_H = img_HSV(:,:,1);
    img_S = img_HSV(:,:,2);
    img_V = img_HSV(:,:,3);
%     img_Y = img_YCbCr(:,:,1);
    
%     if (FBdivide)
    img_b_H = img_H(:); img_b_H = img_b_H(~smVec); % vectorizing & removing foreground
    img_b_S = img_S(:); img_b_S = img_b_S(~smVec);

    % calculating H and S histograms for background
    allFeats.bg.hist_H = histcounts(img_b_H, 0:1/80:1);
    allFeats.bg.hist_S = histcounts(img_b_S, 0:1/80:1);
%     [allFeats.bg.patt, ~] = descFunc(double(img_V), ~smt,options);
    allFeats.bg.pattV = lbp(double(img_V), ~smt);
%     allFeats.bg.pattY = lbp(double(img_Y), ~smt);

%     allFeats.bg.patt = lbp(img_V, ~sm);
%     allFeats.bg.lbp = ELDP(img_V, ~sm);
%     if localPatterMethod == "lbp"
%         allFeats.fg.lbp = lbp(img_V, ~sm);    % lbp hist on V channel
%     elseif localPatterMethod == "eldp"
%         allFeats.fg.lbp = ELDP(img_V, ~sm);
%     elseif localPatterMethod == "implbp"
% %         [LSP_convex_up,LSP_convex_down] = LSP_func(img_V,15,1.0045);
%         [~,LBP_convex_up,LBP_convex_down] = impLBP(img_V,15,1.0045, ~sm);
% %         allFeats.bg.lbp = [LBP_convex_up LBP_convex_down LSP_convex_up LSP_convex_down];
%         allFeats.bg.lbp = [LBP_convex_up LBP_convex_down];
%     end
    
    clear img_b_H img_b_S img_b_V img_b

    % FOREGROUND ANALYSIS
    img_f_H = img_H(:); img_f_H = img_f_H(logical(smVec)); % vectorizing & removing foreground
    img_f_S = img_S(:); img_f_S = img_f_S(logical(smVec));

    % calculating H and S histograms for foreground
    allFeats.fg.hist_H = histcounts(img_f_H, 0:1/80:1);   % H channel hist
    allFeats.fg.hist_S = histcounts(img_f_S, 0:1/80:1);   % S channel hist
%     [allFeats.fg.patt, ~] = descFunc(double(img_V), logical(smt),options);
    allFeats.fg.pattV = lbp(double(img_V), logical(smt));
%     allFeats.fg.pattY = lbp(double(img_Y), logical(smt));
    
    %     if localPatterMethod == "lbp"
    %         allFeats.fg.lbp = lbp(img_V, logical(sm));    % lbp hist on V channel
    %     elseif localPatterMethod == "eldp"
    %         allFeats.fg.lbp = ELDP(img_V, logical(sm));
    %     elseif localPatterMethod == "implbp"
    % %         [LSP_convex_up,LSP_convex_down] = LSP_func(img_V,15,1.0045);
    %         [~,LBP_convex_up,LBP_convex_down] = impLBP(img_V,15,1.0045, logical(sm));
    % %         allFeats.fg.lbp = [LBP_convex_up LBP_convex_down LSP_convex_up LSP_convex_down];
    %         allFeats.fg.lbp = [LBP_convex_up LBP_convex_down];
    %     end
    clear img_f_H img_f_S img_f_V img_f
%     else
%        allFeats.hist_H = histcounts(img_H, 0:1/80:1);
%        allFeats.hist_S = histcounts(img_S, 0:1/80:1);
%        allFeats.patt = descFunc(double(img_V), logical(ones(size(img_V,1)-2, size(img_V,2)-2)),options);
%     end
    
%     allFeats.SalMapLBP = descFunc(sm, logical(ones(size(sm,1)-2, size(sm,2)-2)), options);
    allFeats.SalMapLBP = lbp(sm, logical(ones(size(sm,1)-2, size(sm,2)-2)));
    % in case of not providing the descriptors
    if(isempty(descs))
        
        img = rgb2gray(img);
        keyPoints = vl_sift(single(img));    %extracting SIFT keypoints
        fg_keyPoints = keyPoints;

        
        valuesInPoints = (diag(orig_smt(round(keyPoints(2,:)), round(keyPoints(1,:)))))'; 
        fg_keyPoints(:, valuesInPoints == 0 ) = [];
        [fg_patches, ~] = patchExtractor(im2double(img), sm, fg_keyPoints, PATCH_DIMs(1)+1);

        descs = [];
        for j=1:length(fg_patches)   
            if KrawMethod == "OURS"
                q_tilda = [];
                for c=1:length(ALLCONSTS)
                    q_tilda = [q_tilda, krawtchuckMoment(PATCH_DIMs,double(fg_patches{j}), ALLCONSTS(c))];
                end
            elseif KrawMethod == "2DKD"
                q_tilda = compDesc(double(fg_patches{j}), xs, ys, ALLCONSTS);
            end
            descs = [descs; q_tilda];
        end
    end
    
    if size(img,3)==3; img = rgb2gray(img); end
    keyPoints = vl_sift(single(img));    %extracting SIFT keypoints
    fg_keyPoints = keyPoints;

    % computer saliency of patches
    normedSm = sm - min(sm(:));
    normedSm = double(normedSm) ./ 255;
    sm = normedSm;
    
    [~, fg_sal_pathcesh] = patchExtractor(im2double(img), sm, fg_keyPoints, PATCH_DIMs(1)+1);
    sal_num_patches = [];
    for j=1:size(fg_sal_pathcesh,2)
        sal_num_patches = [sal_num_patches median(fg_sal_pathcesh{j}(:))];
    end
    
%     sal_num_patches = (sal_num_patches + 1).^3;
    
    [~, sorted_sal_num_indc] = sort(sal_num_patches);
    top_patches = sorted_sal_num_indc(1:round(0.05*size(sorted_sal_num_indc,2)));

    % compute the visual word accurance histogram
    hist = zeros(1, size(BOW,1));
    for j = 1:size(descs,1)% each row in moments 
%          d1=pdist2(double(BOW),double(descs(j, :)));
        if isempty(find(top_patches==j)); cumPar = 1; else; cumPar = 2;end
%         cumPar = sal_num_patches(j);
        d1 = sum((double(BOW)-double(descs(j, :))).^2, 2).^0.5; % euclidean distance
        [~, ind_min_dis]=min(d1);
        hist(ind_min_dis) = hist(ind_min_dis) + 1;
    end
    allFeats.fg.wordsHist = hist;
    
end

