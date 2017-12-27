function RunTrainedNetworkOnBufferedData
%% Great demo
% Use buffered data
% Read one buffer at a time
% Explain that we have
% * Data itself - 30 different subjects moving for about 8 minutes each
% * Info on what subject and what activity it was
% % Plot buffer, along guess and original knowledge as text on the plot
% Show function with few lines of code used to extract all the
%   information (freatures) from the raw data
%% Run Neural Network on buffered data
load('myTrainedNetwork.mat')
%load('BufferedAccelerations.mat')
%load('myBufferData.mat')
load('myOldData.mat')
mA = ?Act;
actnames = {mA.EnumerationMemberList(:).Name};

ntests = 1000;
idx = 1000+1*(0:ntests-1)+1;
sam_num=size(atx);
for k = 1:sam_num(1)%ntests
    % Get data buffer
    ax = atx(k,:);
    ay = aty(k,:);
    az = atz(k,:);
    
    % Plot 3 acceleration components
    plotAccelerationBuffer(ax,ay,az,t)
    
    % Extract features
    f = featuresFromBuffer(ax, ay, az, fs);
    
    % Classify with neural network
    scores = net(f');
    % Extract result
    [~, maxidx] = max(scores);
    % Display result as title in current plot 
    estimatedActivity = actnames{maxidx};
    % Look up actual activity
    actualActivity = actnames{y(k)};
    
    % Overlay classification results as plot title
    title(sprintf('Estimated: %s\nActually: %s\n', ...
        estimatedActivity,actualActivity))
    drawnow
    pause(0.02)
end

