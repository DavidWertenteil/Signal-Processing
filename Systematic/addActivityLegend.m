function addActivityLegend(mode)

if(isempty(mode))
    return
    % mode = 'all';
end

actlabels = {'Walking','WalkingUpstairs', 'WalkingDownstairs',...
    'Sitting','Standing','Laying'};

if(ischar(mode) && strcmp(mode,'all'))
    legend(actlabels);
elseif(isvalidactid(mode))
    legend(actlabels(mode));
end

end

function isit = isvalidactid(mode)

isit = all(round(mode)==mode) && all(mode > 0) && all(mode <= 6);
    
end


