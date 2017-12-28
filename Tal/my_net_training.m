%this file make the net to run to identify every new data,
%here we devide the data to train,validation and test.
%here we alse play with the categories: remove some,or merge some, in order
%to see if its change the results
%here you can also  change the depth of the net
%

% Load pre-computed features for all signal buffers available at once
load('myBufferFeatures.mat')
% Load buffered signals (here only using known activity IDs for buffers)
load('myBufferData.mat')

%various manipulation on the classes divition:

%take only this classes:
%logical=y==Act.Walking|y==Act.DragLimp|y==Act.JumpLimp|y==Act.AustoLimp;

%take all data except this classes:
% logical=y~=Act.Sitting&y~=Act.Standing&y~=Act.Laying;

%apply the chosen to the data:
%  y=y(logical);
%  feat=feat(logical,:);

%unify classes
% y(y==Act.JumpLimp|y==Act.AustoLimp)=Act.DragLimp;
% y(y==Act.WalkingUpstairs|y==Act.WalkingDownstairs|y==Act.Running)=Act.Walking;


[trainInd,valInd,testInd] = dividerand(size(feat,1),0.5,0.05,0.45);
x=feat';
f=feat(trainInd,:);
%y=y';
ytemp=y(trainInd,:);
%clear('x');


% Correct data orientation
X = feat';
y = y';
tgt = dummyvar(y)';
% Reset random number generators
rng default

% Initialize a Neural Network with 18 nodes in hidden layer
net = patternnet(18);

% Train network
net = train(net, X, tgt);
%f=f';
Xtest = x(:,testInd);
ytest = y(:,testInd);
tgttest = dummyvar(ytest)';

% Run network on validation set
scoretest = net(Xtest);

% Display confusion matrix using results
figure
plotconfusion(tgttest,scoretest)
[a,b,c,d]=confusion(tgttest,scoretest);
RunTrainedNetworkOnBufferedData;
save('.\data\myTrainedNetwork.mat','net','actnames');


%this created a net that will idetify future data, 
%you can save the net in "myTrainedNetworkWithTrain.mat"
%in order to actuly run a new data on the trained net, you first need to divide
%it to equals section (line paramter) and to calc the features to each
%section. after that you can use that code and calc the new estimated catgory :
%   % Extract features
%     f = featuresFromBuffer(ax, ay, az, fs);
%     
%     % Classify with neural network
%     scores = net(f');
%     % Extract result
%     [~, maxidx] = max(scores);
%     % Display result as title in current plot 
%     estimatedActivity = actnames{maxidx};

