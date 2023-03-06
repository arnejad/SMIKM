%==========================================================================
% DIST computes Chi-Square distance between corresponding histograms and
%   determins the final fused weighted distance between two multi-feature
%
% inputs:    feats1 and feats2 are feature object of formula 3 (bai - 2018)
%               also known as multi-feature.
%
% output:    res is the final distance
%
% Author: Computer Vision Lab, IASBS
%==========================================================================

function [dists] = multiDist(feats1, feats2)
   
    % REFINE
%     if FBdivided
    dists =[chiSq(feats1.bg.hist_H,     feats2.bg.hist_H)...
            chiSq(feats1.bg.hist_S,     feats2.bg.hist_S)...
            chiSq(feats1.bg.pattV,      feats2.bg.pattV)...
            chiSq(feats1.fg.hist_H,     feats2.fg.hist_H)...
            chiSq(feats1.fg.hist_S,     feats2.fg.hist_S)...
            chiSq(feats1.fg.pattV,      feats2.fg.pattV)...
            chiSq(feats1.fg.wordsHist,  feats2.fg.wordsHist)...
            chiSq(feats1.SalMapLBP,     feats2.SalMapLBP)];
%     else
%         dists =[chiSq(feats1.hist_H,    feats2.hist_H)...
%             chiSq(feats1.hist_S,        feats2.hist_S)...
%             chiSq(feats1.patt,       feats2.patt)...
%             chiSq(feats1.fg.wordsHist,  feats2.fg.wordsHist)...
%             chiSq(feats1.SalMapLBP,  feats2.SalMapLBP)];
%     end
end
%            
        
% chiSq(feats1.bg.pattV,      feats2.bg.pattV)
% chiSq(feats1.fg.pattV,      feats2.fg.pattV)
% chiSq(feats1.bg.pattY,      feats2.bg.pattY)
% chiSq(feats1.fg.pattY,      feats2.fg.pattY)
% distance measure
function [distance] = chiSq(hist1, hist2)
    tmp = ((hist1 - hist2)).^2 ./ (hist1 + hist2);
    tmp(isnan(tmp))=0;
    distance = sum(tmp, 2);
    
end

