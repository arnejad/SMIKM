function [result]=ELDP(im, sm)
% LDN0,LDN1,LDN2,LDN3,LDN4,LDN5,LDN6,LDN7

%% Gaussian smoothing
bins = 256;
% sigma = .3;
% F = fspecial('gaussian',2*ceil(3*sigma)+1,sigma);
% im  = imfilter(im,F,'replicate','same');

[M,N]=size(im);

%Kirsch Mask
Kirsch=cell(8,1);
Kirsch{1}=[-3 -3 5;-3 0 5;-3 -3 5];
Kirsch{2}=[-3 5 5;-3 0 5;-3 -3 -3];
Kirsch{3}=[5 5 5;-3 0 -3;-3 -3 -3];
Kirsch{4}=[5 5 -3;5 0 -3;-3 -3 -3];
Kirsch{5}=[5 -3 -3;5 0 -3;5 -3 -3];
Kirsch{6}=[-3 -3 -3;5 0 -3;5 5 -3];
Kirsch{7}=[-3 -3 -3;-3 0 -3;5 5 5];
Kirsch{8}=[-3 -3 -3;-3 0 5;-3 5 5];

%Made more efficient on 3-31-3015
for eldp=1:8
    B=filter2(Kirsch{eldp},im);
    V_ELDP(:,eldp)=B(:);
end
t=0:7;
t=2.^t;
V_ELDP(V_ELDP>0)=1;
V_ELDP(V_ELDP<=0)=0;
t=repmat(t,M*N,1);
V1=V_ELDP.*t;
V1=sum(V1,2);
% V_ELDP=reshape(V1, M, N);
filtered_ELDP = V1(sm);
result=hist(filtered_ELDP,0:(bins-1));




