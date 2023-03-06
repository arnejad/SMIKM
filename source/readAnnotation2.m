%==========================================================================
%READANNOTATION finds the corresponding annotation file and returns the
% existing objects. Each index in the returned list implies a existance of 
% a specific  object.
%
%input:     filename: the name of the read image
%output:    lbls: boolean list, each index implies a specific object
%==========================================================================

function [lbls] = readAnnotation(filename)

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