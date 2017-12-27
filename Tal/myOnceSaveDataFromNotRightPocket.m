  dataFromWeb=webread('https://collectsensorsdata.firebaseio.com/data/fs-50/samples/accelerometer.json');
  shani_script;

%load('mySubjectsData.mat');

%load('sh_rawAcc2.mat');
%load('RecordedAccelerationsBySubject.mat');


fs=50;
%delete last 3 seconds
for index=1:length(sh_subjects)
    subjects(index).actid=sh_subjects(index).actid(1:length(sh_subjects(index).actid)-3*fs,:);
    subjects(index).totalacc=sh_subjects(index).totalacc(1:length(sh_subjects(index).totalacc)-3*fs,:);
end
atx=[];
aty=[];
atz=[];
actmat=[];
line=128;
for index =1:length(sh_subjects)
    if (subjects(index).actid(1)>5&&subjects(index).actid(1)<9)
        ax=subjects(index).totalacc(:,1)./9.80665';
        atx=[atx; reshape(ax(1:numel(ax)-mod(numel(ax),line)),line,[])'];
        ay=subjects(index).totalacc(:,2)./9.80665';
        aty=[aty; reshape(ay(1:numel(ay)-mod(numel(ay),line)),line,[])'];
        az=subjects(index).totalacc(:,3)./9.80665';
        atz=[atz; reshape(az(1:numel(az)-mod(numel(az),line)),line,[])'];
        act=subjects(index).actid(:);
        actmat=[actmat;reshape(act(1:numel(act)-mod(numel(act),line)),line,[])'];
    end
end
y=actmat(:,1);
% Design filter
fhp = hpfilter;

% "Decouple" acceleration due to body dynamics from gravity
abx = filter(fhp,atx);
aby = filter(fhp,aty);
abz = filter(fhp,atz);

t = (1/fs) * (0:line-1)';
save('..\data\myBufferDataFromNotRightPocket.mat','abx','aby','abz','atx','aty','atz','y');
    