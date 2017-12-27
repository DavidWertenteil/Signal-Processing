%% Human Activity Classification based on Smartphone Sensor Signals
% This example describes an analysis approach on accelerometer signals,
% captured with a smartphone worn by people during 6 different types
% of physical activity (walking, lying, sitting etc). The goal of this
% analysis is to build an algorithm to automatically identify the activity
% type given the sensor measurements. 
% 
% Copyright 2013-2014 MathWorks, Inc.
%
% The example uses data from a recorded dataset, courtesy of:
%  Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L.
%  Reyes-Ortiz. Human Activity Recognition on Smartphones using a
%  Multiclass Hardware-Friendly Support Vector Machine. International
%  Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz,
%  Spain. Dec 2012
%
% The original dataset is available at
% <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

%% What's the idea here?
% Let's take a look at what our final result may look like. This will give
% us a better feel for what we are trying to achieve

RunTrainedNetworkOnBufferedData

%% Open full "recording" for a single subject (e.g. #1)
[acc, actid, actlabels, t, fs] = getRawAcceleration(...
    'SubjectID',1,...
    'AccelerationType','total',...
    'Component','x');
plot(t,acc)

%% Just to make sure we understand what we are seeing...
% Let me show in a different way what we would like to be able to do 

plotAccelerationColouredByActivity(t, acc, actid, {'Vertical acceleration'})

% So
% * We would like to be able to tell the difference between the different
%   activities, just based on the content of the signal. 
% * Instead in this case I was able to plot the signal this way
%   because I already knew what was what
% * As we analyse as data...
%   -   Knowing what is what is helping us identify if the information we
%       extract is descriptive enough (e.g. different for different
%       activities but similar enough for similar activities across
%       different subjects)
%   -   Knowing what is what allows us to use this data to "train" a
%       classification mechanism so it can then work on data that we don't
%       know, and also to assess/validate the performance of a pre-trained
%       mechanism

%% First type of characterization - amplitude only
% For very different types of activities this can be already a successful
% tool

%% First example - Using a mean measure
% This can easily help separate e.g. Walking from Laying
figure
plotCompareHistForActivities(acc, actid,'Walking', 'Laying')

%% Second example - Using an RMS or standard devieation measure
% This can help separte things like e.g. Walking adn Standing
plotCompareHistForActivities(acc, actid,'Walking', 'Standing')

%% What next? Amplitude-only methods are most often not enough
% For example it would be very hard to make the distinction between
% simply Walking and WalkingUpstairs (same statistical moments)
plotCompareHistForActivities(acc, actid,'Walking', 'WalkingUpstairs')

%% So the next step is to take a look at more advanced methods
% More specifically those that look at how the data (or "signal")
% variations occur over time

%% 
% In that regard, I would like to draw your attention to a fairly important
% aspect of this data. After looking at it for a few minutes I think you
% can appreciate how here we are dealing with two types of contributions:
% * One to do with "fast" variations over time, due to body dynamics
%   (subject moving)
% * The other responsible for "slow" variations over time, to do with the
%   position of the body wrt the vertical gravitational field
%
% While the gravitational analysis is bound to be the easiest one, we'll
% now focus on understanding features that have more to do with the body
% dynamics (e.g. activities that are associated with more or less rapid or
% frequent movements).
% 
% Before moving forward, it is beneficial to introduce a very important
% class of techniques that are commonly used to separate such types of
% components in signals and time series. 
% While in this specific case a simple average over a period of time would
% most easily isolate the gravitational component (which could be then
% subtracted from the rest to get the body dynamics), it is worthwhile
% introducing the much more general approach based on digital filters

%% Digital filtering workflow
% If you wanted to use a digital filter in MATLAB to isolate the more rapid
% signal variations from the slow, this is how you would proceed
% 
% You would:
% * Probably use the Filter Design and Analysis Tool in MATLAB
%   to design a high-pass filter
% * Apply the designed filter to the original signal to only extract
%   the body dynamics contributions

%% Automate through a programmatic approach

% Design filter
fhp = hpfilter;

% "Decouple" acceleration due to body dynamics from gravity
ab = filter(fhp,acc);

plotAccelerationColouredByActivity(t, [acc, ab], actid,...
    {'Original','High-pass filtered'})

%%
% Now let's dive into the thick of it. Once we have a signal that
% represent only the body contributions, lets look at the most typical type
% of analysis people would do.
% 
% Let's remember we still have knowledge of what is what, so we first
% isolate portions of signals that refer to individual activities to
% understand what could be well-defining measurements that characterise
% those activities against others

%% Select the first portion of signal where the subject is walking
% Good opportunity to introduce a powerful semantic of the MATLAB language
% called logical indexing
%
% Just say in plain English what you are trying to do, then write it down:
% Only select samples for which the activity was walking and for which the
% time was less than 250 seconds

walking = 1;
sel = (t < 250) & (actid == walking);

% Walking-only signals
tw = t(sel);
abw = ab(sel);

plotAccelerationColouredByActivity(tw, abw, [],'Walking')

%% Plot Power Spetral Density
% Use Welch method with its default options, using right sample frequency

pwelch(abw,[],[],[],fs)

%% Validate potential of PSD to differentiate between different activities
% E.g. are there good clues in the position and height of different peaks?
figure
plotPSDActivityComparisonForSubject(1, 'Walking', 'WalkingUpstairs')

% %% Or you could look at all activities at once
% % In this case by selecting a single subject
% plotPSDForGivenSubject(1)

%% Validate PSD for given activity is roughly consistent across subjects
% E.g. try plotting the walking PSD (for first 30 subjects) using a linear
% amplitude scale so peaks visually stand out more

plotPSDForGivenActivity(2)

%% Automate peak identification with built-in function findpeaks
% findpeaks can help idenify amplitude and location of peaks

% Compute numerical values of PSD and frequency vector
[p,f] = pwelch(abw,[],[],[],fs);

% Use findpeaks to identify values (amplitude) and indices of peaks
[pks,locs] = findpeaks(p);

% Plot PSD manually and overlay peaks
plot(f,db(p),'.-')
grid on
hold on
plot(f(locs),db(pks),'rs')
hold off
addActivityLegend(1)
title('Power Spectral Density with Peaks Estimates')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

%% Refine peak finding by adding more specific requirements

% PSD with numerical output
[p,f] = pwelch(abw,[],[],[],fs);

% Find max 8 peaks, at least 5 bins apart from each other and with a given
% prominence value

fmindist = 0.25;                    % Minimum distance in Hz
N = 2*(length(f)-1);                % Number of FFT points
minpkdist = floor(fmindist/(fs/N)); % Minimum number of frequency bins

[pks,locs] = findpeaks(p,'npeaks',8,'minpeakdistance',minpkdist,...
    'minpeakprominence', 0.15);

% Plot PSD and overlay peaks
plot(f,db(p),'.-')
grid on
hold on
plot(f(locs),db(pks),'rs')
hold off
addActivityLegend(1)
title('Power Spectral Density with Peaks Estimates')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')


%% Autocorrelation as a feature
% Autocorrelation can be another powerful tool for frequency estimation,
% and especially effective for estimating low-pitch fundamental frequencies 

% xcorr with only one input will compute the cross-correlation 
[c, lags] = xcorr(abw);

% Highlight the main t=0 peak (overal energy) and the two second-highest
% peaks - position here is the main period
tmindist = 0.6;
minpkdist = floor(tmindist/(1/fs));
[pks,locs] = findpeaks(c,'minpeakprominence',1e4,...
    'minpeakdistance',minpkdist);

% Plot autocorrelation and three key peaks
tc = (1/fs)*lags;
tpks = tc(locs);
tpk1 = tpks((end+1)/2+1);
cpk1 = pks((end+1)/2+1);

plot(tc,c,'.-')
grid on
hold on
% plot(tc,c(locs),'rs')
plot(tpk1,cpk1,'rs')
hold off
xlim([-5,5])
addActivityLegend(1)
title('Autocorrrelation with Peaks Estimates')
xlabel('Time lag (s)')
ylabel('Correlation')

%% Check position of first peak varies between different activities
% Compare autocorrelation plots for same subject and different activity

plotCorrActivityComparisonForSubject(1, 'WalkingUpstairs', 'WalkingDownstairs')

%% Open function used to extract a list of features from a buffer
% of data samples

edit featuresFromBuffer

%% Count number of actual code lines of function featuresFromBuffer.m
% Using MATLAB Central submission "sloc" by Raymond Norris, available at
% <http://www.mathworks.co.uk/matlabcentral/fileexchange/3900-sloc>
sloc('featuresFromBuffer')

%% Classification through Neural networks
%% Train Neural Network using computed features on all buffers

% Load pre-computed features for all signal buffers available at once
load('BufferFeatures.mat')
% Load buffered signals (here only using known activity IDs for buffers)
load('BufferedAccelerations.mat')
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


%% Run Neural Network on buffered data
 load('TrainedNetwork.mat')
 load('BufferedAccelerations.mat')

ntests = 1000;
idx = 1000+1*(0:ntests-1)+1;

for k = 1:ntests
    % Get data buffer
    ax = atx(idx(k),:);
    ay = aty(idx(k),:);
    az = atz(idx(k),:);
    
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
    actualActivity = actnames{y(idx(k))};
    
    % Overlay classification results as plot title
    title(sprintf('Estimated: %s\nActually: %s\n', ...
        estimatedActivity,actualActivity))
    drawnow
end

%% Validate network more systematically, by selecting a test subset

% Randomly divide data between training, test and validation sets
[trainInd,valInd,testInd] = dividerand(size(X,2),0.7,0.15,0.15);

Xtest = X(:,testInd);
ytest = y(:,testInd);
tgttest = dummyvar(ytest)';

% Run network on validation set
scoretest = net(Xtest);

% Display confusion matrix using results
figure
plotconfusion(tgttest,scoretest)

%% Show APP to get data