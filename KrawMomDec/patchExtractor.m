function result = patchExtractor(Img,Points, patchSize)
%PATCHEXTRACTOR generates patches inside the input image based on the
%provided locations
%   Input: Img -> the input image.
%   Input: Points -> A matrix with X and Y as rows. X is row 1 & Y row 2

j = 1; %counts th last modified index in result list
for i = 1:size(Points,2)
    a = imcrop(Img, [Points(1, i) - (patchSize/2), Points(2, i) - (patchSize/2), patchSize - 1, patchSize - 1]);
    if(size(a,1) == patchSize && size(a, 2) == patchSize)
        result{j} = a;
        j = j + 1;
    end
end
end

