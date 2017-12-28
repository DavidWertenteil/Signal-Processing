%take the data that been saved in myBufferData.mat
%and calculate the featuers table to the machine learning using the file
%"featuresFromBuffer" that use signal processing
%and save it in "myBufferFeatures.mat"

load('myBufferData.mat');
sam_num=size(atx);
feat=[];
for k = 1:sam_num(1)
    % Get data buffer
    ax = atx(k,:);
    ay = aty(k,:);
    az = atz(k,:);
    % Extract features
    f = featuresFromBuffer(ax, ay, az, fs);
    feat=[feat; f];
end
% clear('atx','aty','atz');
% load('BufferedAccelerations.mat');
% sam_num=size(atx);
% for k = 1:sam_num(1)
%     % Get data buffer
%     ax = atx(k,:);
%     ay = aty(k,:);
%     az = atz(k,:);
%     
%     % Extract features
%     f = featuresFromBuffer(ax, ay, az, fs);
%     feat=[feat; f];
% end

featlabels={'TotalAccXMean';'TotalAccYMean';'TotalAccZMean';'BodyAccXRMS';'BodyAccYRMS';'BodyAccZRMS';'BodyAccXCovZeroValue';'BodyAccXCovFirstPos';'BodyAccXCovFirstValue';'BodyAccYCovZeroValue';'BodyAccYCovFirstPos';'BodyAccYCovFirstValue';'BodyAccZCovZeroValue';'BodyAccZCovFirstPos';'BodyAccZCovFirstValue';'BodyAccXSpectPos1';'BodyAccXSpectPos2';'BodyAccXSpectPos3';'BodyAccXSpectPos4';'BodyAccXSpectPos5';'BodyAccXSpectPos6';'BodyAccXSpectVal1';'BodyAccXSpectVal2';'BodyAccXSpectVal3';'BodyAccXSpectVal4';'BodyAccXSpectVal5';'BodyAccXSpectVal6';'BodyAccYSpectPos1';'BodyAccYSpectPos2';'BodyAccYSpectPos3';'BodyAccYSpectPos4';'BodyAccYSpectPos5';'BodyAccYSpectPos6';'BodyAccYSpectVal1';'BodyAccYSpectVal2';'BodyAccYSpectVal3';'BodyAccYSpectVal4';'BodyAccYSpectVal5';'BodyAccYSpectVal6';'BodyAccZSpectPos1';'BodyAccZSpectPos2';'BodyAccZSpectPos3';'BodyAccZSpectPos4';'BodyAccZSpectPos5';'BodyAccZSpectPos6';'BodyAccZSpectVal1';'BodyAccZSpectVal2';'BodyAccZSpectVal3';'BodyAccZSpectVal4';'BodyAccZSpectVal5';'BodyAccZSpectVal6';'BodyAccXPowerBand1';'BodyAccXPowerBand2';'BodyAccXPowerBand3';'BodyAccXPowerBand4';'BodyAccXPowerBand5';'BodyAccYPowerBand1';'BodyAccYPowerBand2';'BodyAccYPowerBand3';'BodyAccYPowerBand4';'BodyAccYPowerBand5';'BodyAccZPowerBand1';'BodyAccZPowerBand2';'BodyAccZPowerBand3';'BodyAccZPowerBand4';'BodyAccZPowerBand5'};
save('.\data\myBufferFeatures.mat','feat','featlabels');