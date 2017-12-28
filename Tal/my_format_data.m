%this file take the default from-json table that saved in "dataFromWeb" and convert it to
%more fitted matrix and save it in "myFormatData.mat"

names =  fieldnames(dataFromWeb(1));
for i = 1:numel(names)
    temp=getfield(dataFromWeb(1),names{i});
    tempsize=size(temp);
    for j=1:tempsize(1)
        if(temp(j).activityNumber == 7)
            idvec(j)=2;
        elseif (temp(j).activityNumber == 8)
            idvec(j)=3;
        elseif (temp(j).activityNumber == 12)
            idvec(j)=4;
        else
            idvec(j)=1;
        end
        
        temaccarr=temp(j).values;
        
        accvec(j,:)=temaccarr;
    end
    data(i).actid = idvec';
    data(i).totalacc=accvec;
    clear('idvec','accvec');
end
save ('.\data\myFormatedData.mat','data');
