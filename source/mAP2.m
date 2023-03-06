function [finalMAPs] = mAP(tops, testFiles, numOfClasses, DATASET, readAnnotation)
%MAP computes mean Avarage Precision class-specific

%     allMAPs = zeros(numOfClasses, numel(testFiles)/3);
    
    annotationsRoute = "D:\uni\Research\Moment-based Image Retrieval\DB\VOC2006-all\Annotations\";
    allMAPs = cell(numOfClasses,1);
    
    for i=1:3:numel(testFiles)-2

        query_leo = extractListOfExistingObjects(string(testFiles(i)), DATASET, readAnnotation, annotationsRoute);
        overallAP = 0;
        correctCounter = 0;
        for j=1:size(tops,2)
            
            % finding exisiting objects in the query image
            retreived_leo = extractListOfExistingObjects(string(tops(round((i/3)+1),j)),...
                DATASET, readAnnotation, annotationsRoute);
            
            % check if this is a true-positive case
            if max(query_leo + retreived_leo) > 1
                correctCounter = correctCounter +1;
                summingTerm = correctCounter/j;
            else
                summingTerm = 0;
            end 
            
            if isnan(summingTerm )
                summingTerm = 0;
            end
            
            overallAP = overallAP + summingTerm;
            
           
            
        end
        overallAP = overallAP/size(tops,2);
        if isnan(overallAP) 
            overallAP = 0; 
        end
        
        % assign the AP to the corresponding class
        [~,b] = find(query_leo==1);
        for l=length(b)
            allMAPs{b(l)} = [allMAPs{b(l)}, overallAP];
        end

    end
    
    if size(tops,2)==1
        finalMAPs = mean(cat(2, allMAPs{:}));
    else
        finalMAPs = cell2mat(cellfun(@mean,allMAPs,'uni',0));
        finalMAPs(isnan(finalMAPs)) = 1;
    end
end


function [leo] = extractListOfExistingObjects(imgFile, DATASET, readAnnotation, annotationsRoute)
    
    if DATASET == "VOC"
        % determine the address of the corresponding label file
        str = erase(imgFile,".png");
        str = erase(str,".jpg");
        str = extractBetween(str,strlength(str)-5,strlength(str));
        str = strcat(annotationsRoute, str,'.txt');
    elseif DATASET == "WANG"
        str = imgFile;
    elseif DATASET == "CAL256"
        str = imgFile;
    elseif DATASET == "WANG-Rand"
        str = imgFile;
    elseif DATASET == "OT"
        str = imgFile;  
    elseif (DATASET == "CALTECH101") || (DATASET == "CALTECH101-2")
        str = imgFile;  
    end
    leo = readAnnotation(str); %list of exisiting objects
    
end
