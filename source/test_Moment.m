imAddrss = 'D:/uni/Research/Moment-based Image Retrieval/DB/Caltech101-ss/2_image_0263.jpg';
smAddrss = 'D:/uni/Research/Moment-based Image Retrieval/DB/Caltech101-ss/2_image_0263_RC.png';
smtAddrss = 'D:/uni/Research/Moment-based Image Retrieval/DB/Caltech101-ss/2_image_0263_RCC.png';

tmmp_all = [];
tmmp_fg = [];

im = rgb2gray(imread(imAddrss));
keyPoints = vl_sift(single(im));
fg_keyPoints = keyPoints;
bg_keyPoints = keyPoints;

sm = imread(smAddrss);
smt = imread(smtAddrss);

valuesInPoints = (diag(smt(round(keyPoints(2,:)), round(keyPoints(1,:)))))'; 
fg_keyPoints(:, valuesInPoints == 0 ) = [];
bg_keyPoints(:, valuesInPoints ~= 0 ) = [];

[fg_patches, ~] = patchExtractor(im2double(im), sm, fg_keyPoints, PATCH_SIZE);
[bg_patches, ~] = patchExtractor(im2double(im), sm, bg_keyPoints, PATCH_SIZE);


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
    tmmp_all = [tmmp_all; q_tilda];
end


%forground
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
    tmmp_all = [tmmp_all; q_tilda];
    tmmp_fg = [tmmp_fg; q_tilda];
end

