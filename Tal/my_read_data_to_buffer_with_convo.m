%this is a copy of "my read data to buffer" - but in this file we added convulotion to tha data,
%in order to stablize the frequency


 %dataFromWeb=webread('https://collectsensorsdata.firebaseio.com/data/fs-50-v2/samples/rightPocket/accelerometer.json');
 %save('myRawData-5-6-1.0.mat','dataFromWeb');
 
 load('myRawData-5-6-1.0.mat');
 my_format_data;

fs=50;
actnames={'Walking','WalkingUpstairs','WalkingDownstairs','Sitting','Standing','Laying','DragLimp','JumpLimp','PersonFall','PhoneFall','Running','AustoLimp'};
actlabels=actnames;
%delete last ~~6 seconds
myindex=1;
for index=1:length(data)
    
    %subjects(index).totalacc=sh_subjects(index).totalacc(1:length(sh_subjects(index).totalacc)-6*fs,:);
    %uniqe and interpolate
    if(length(data(index).timestamps)>6*fs)
        timestamp=data(index).timestamps(1:length(data(index).timestamps)-6*fs,:);
        [uniq,ia,ic]=unique(timestamp);
        %subjects(myindex).actid=sh_subjects(index).actid(ia,:);
        %subjects(index).timestamps=uniq;
        
        newtime=[uniq(1):milliseconds(20):uniq(length(uniq))];
        vqx = interp1(uniq,data(index).totalacc(ia,1),newtime);
        vqy = interp1(uniq,data(index).totalacc(ia,2),newtime);
        vqz = interp1(uniq,data(index).totalacc(ia,3),newtime);
        subjects(myindex).actid=ones(length(vqx),1)*data(index).actid(1);
        subjects(myindex).totalacc=[vqx' vqy' vqz'];
        myindex=myindex+1;
    end
end

atx=[];
aty=[];
atz=[];
actmat=[];
%%%%%%%%%%%%%%%%%%%
line=300;
for index =1:length(subjects)
    ax=subjects(index).totalacc(:,1)./9.80665';
    atx=[atx; reshape(ax(1:numel(ax)-mod(numel(ax),line)),line,[])'];
    %atx(index,:)=subjects(index).totalacc(1:2250,1)./9.80665';
    %aty(index,:)=subjects(index).totalacc(1:2250,2)./9.80665';
    %atz(index,:)=subjects(index).totalacc(1:2250,3)./9.80665';
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
save('..\data\myBufferDataWithConvo.mat','abx','aby','abz','atx','aty','atz','actlabels','actnames','fs','t','y');
    