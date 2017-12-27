%calculate the numbers of data we have.
%to calculate the "numOfSeconds" paramter, the first number (here is 300)
%need to match to the unit size 
%(parameter "line" in my_read_data_to_buffer)

%clear;
load('myBufferData.mat');
h=histogram(y);
numOfRecordsPerAct=h.Values;
% numOfRecordsPerAct(7)=numOfRecordsPerAct(7)+66;
% numOfRecordsPerAct(8)=numOfRecordsPerAct(8)+61;
numOfSeconds=numOfRecordsPerAct.*(300/50);
numOfMinutes=numOfSeconds./60;