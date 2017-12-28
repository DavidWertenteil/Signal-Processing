% this file read tada that we already saved from network - named: myRawData-date,
%or you can read the data from the web - firebase, with the commend "webread"

%the raw data we format with the action "my_format_data" and then
%mannipulate the data a little more, like remove the last 3 second that can
%be a noise, and divide by G=9.2
%also here the size of each unit is decided by the "line" parameter


%to read data from  web and save it locally
options = weboptions('ContentType','json');
dataFromWeb=webread('https://collectsensorsdata.firebaseio.com/data/fs-50-v2/samples/rightPocket/accelerometer.json', options);
save('../data/myRawData-5-6-1.0.mat','dataFromWeb');
%%
%read data from local
%load('myRawData-5-6-1.0.mat');
 
%format the data from json to our matrix
my_format_data

%the frequency
fs=50;

%the acts
actnames={'Walking','DragLimp','JumpLimp','AustoLimp'};
actlabels=actnames;
myindex=1;
%delete last 3 seconds(the fs is not fixed) - beacuse the fs isnt fixed,
%for percaution we remove double
for index=1:length(data)
    if(length(data(index).actid)>6*fs)
        subjects(myindex).actid=data(index).actid(1:length(data(index).actid)-6*fs,:);
        subjects(myindex).totalacc=data(index).totalacc(1:length(data(index).totalacc)-6*fs,:);
        myindex=myindex+1;
    end
end
atx=[];
aty=[];
atz=[];
actmat=[];

%this divide the data to sections in constant size, remove the leftover, and divide by gravity
%in order to change the size of each section, change the "line" parameter
line=128;
for index =1:length(subjects)
    ax=subjects(index).totalacc(:,1)./9.80665';
    atx=[atx; reshape(ax(1:numel(ax)-mod(numel(ax),line)),line,[])'];
    ay=subjects(index).totalacc(:,2)./9.80665';
    aty=[aty; reshape(ay(1:numel(ay)-mod(numel(ay),line)),line,[])'];
    az=subjects(index).totalacc(:,3)./9.80665';
    atz=[atz; reshape(az(1:numel(az)-mod(numel(az),line)),line,[])'];
    act=subjects(index).actid(:);
    actmat=[actmat;reshape(act(1:numel(act)-mod(numel(act),line)),line,[])'];
end
y=actmat(:,1);
% Design filter
fhp = hpfilter;

% "Decouple" acceleration due to body dynamics from gravity
abx = filter(fhp,atx);
aby = filter(fhp,aty);
abz = filter(fhp,atz);

t = (1/fs) * (0:line-1)';
save('..\data\myBufferData.mat','abx','aby','abz','atx','aty','atz','actlabels','actnames','fs','t','y');
    