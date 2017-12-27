function plotCompareHistForActivities(acc, actid, act1, act2)

% Customised histogram for activity #1
subplot(211)
ha1 = plotHistogram(acc, actid, act1);

% Customised histogram for activity #1
subplot(212)
ha2 = plotHistogram(acc, actid, act2);

% Uniform X limits across two histogram plots
mintot = min(min(acc),min(acc));
maxtot = min(max(acc),max(acc));
set(ha1,'Xlim',[mintot, maxtot])
set(ha2,'Xlim',[mintot, maxtot])

function [ha, datasel] = plotHistogram(data, id, actstr)

% Select only data samples relevnat to selected activity 
sel = (id == Act.(actstr));
datasel = data(sel);

% Plot histogram with predefine binwidth
h = histogram(datasel,'BinWidth',0.5); 

% Customizations - colouring and labeling
nacts = length(enumeration('Act'));

cmap = colormap(lines(nacts));
col = cmap(Act.(actstr),:);

h.EdgeColor = col;
h.FaceColor = col;
h.FaceAlpha = 0.8;

xlabel('Acceleration Values (m \cdot s^{-2})')
ylabel('Occurencies')

addActivityLegend(Act.(actstr))

ha = h.Parent;

