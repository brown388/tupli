clc
clear all
close all

tic
I1=imread('D:\����\��ש3\R\r55.png');
I=rgb2gray(I1);
mapping=getmapping(8,'u2'); 

H=lbp(I,3,8,mapping,'a');   %�������ͼ����ʽ��ʾlbp��������������������һ��ֵ�������ܲ��衣H1=lbp(I,1,8,mapping,1);
figure('menubar','figure');imshow(H);

% H1=lbp(I,10,8,mapping,'h'); %LBP histogram in (8,1) neighborhood
% 
% H2=lbp(I);
% figure(2);
% subplot(2,1,1),stem(H1);
% subplot(2,1,2),stem(H2);
% 
SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
I2=lbp(I,SP,0,'i');

toc
t=toc