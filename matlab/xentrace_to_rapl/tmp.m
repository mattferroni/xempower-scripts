clear 
clc

a = [1:10;11:20]'
%prec = [0 b(1:end-1)]
%b-prec


b = [a(1,2) a(:,2)']'
b = b(1:end-1)
a(:,2)=a(:,2)-b