function plotAccelerationColouredByActivity(t, acc, actid, varargin)
% Optional argument - pass cell array containing list of strings to use as
% plot titles as last input argument

% Distill and count number of activities available
acts = unique(actid);
nacts = max(length(acts),1);

% Plan to draw as many subplots as columns available in acc 
nplots = size(acc,2);

% Define colours to use, using built-in colormap with as many entries as
% number of available activities
cmap = colormap(lines(nacts));

for kp = 1:nplots
    
    % Iterate through all the different signals passed as input
    subplot (nplots,1,kp)
    
    for ka = 1:nacts
        % Iterate over activities
        
        % First select data relevant to each activity
        [aid, tsel, asel] = getDataForActivityId(ka);
        try1=cmap(aid,:);
        % Then plot each activity with a different colour
        plot(tsel, asel, 'Color',cmap(aid,:),'LineWidth',1.5);
        % and keep axis on hold to overlay next plot 
        hold on

    end
    
    % Seal plots on current axis - plotting of current signal finished
    hold off
    
    % Customize plot appearance
    grid on
    xlabel('time (s)')
    ylabel('a_z (m s^{-2})')
    xlim([t(1), t(end)])
    if(length(varargin) >= 1)
        if(iscell(varargin{1}))
            title(varargin{1}{kp})
        elseif(ischar(varargin{1}))
            title(varargin{1})
        end
    end
    
end

% To minimize visual clutter, only add legend to last plot
addActivityLegend(acts)
    
% Helper nested function to select signal portions relevant to given
% activity
    function [aid, tsel, asel] = getDataForActivityId(ka)
    aid = 1;
    try %#ok<TRYNC>
        aid = acts(ka);
    end
    sel = (actid == aid);
    tsel = t;
    tsel(~sel) = NaN;
    asel = acc(:,kp);
    asel(~sel) = NaN;
    end

end