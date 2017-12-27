function plotCorrActivityComparisonForSubject(subject, act1name, act2name) %(acc, actid, fs)

%% Collective plotting - autocorrelation corr

cmap = colormap(lines(6));
fhp = hpfilter;

id = double([Act.(act1name), Act.(act2name)]);

[acc, actid, ~, ~, fs] = getRawAcceleration(...
    'SubjectID',subject,...
    'AccelerationType','total',...
    'Component','x');
% "Decouple" acceleration due to body dynamics from gravitational
ab = filter(fhp,acc);

for k = 1:length(id)

    idx = (actid == id(k));
    l = bwlabels1(idx);
    % Select desired region (#1)
    r = 1;
    idx = (l == r);
    d = ab(idx,:)';

    [c,lags] =  xcorr(d);
    tc = (1/fs)*lags;

    hp = plot(tc,c,'.-','Color',cmap(id(k),:));
    hp.LineWidth = 1.5;
    grid on
    set(gca,'Xlim',[-5 5])
    hold on

end
hold off

addActivityLegend(id)
title('Autocorrrelation Comparison')
xlabel('Time lag (s)')
ylabel('Correlation')

function n = bwnumregions1(x)
% x is logical vector with connected regions of 1's
ends = diff(x) == -1;
ends = [ends; x(end)];
n = length(find(ends));


function l = bwlabels1(x)
% x is logical vector with connected regions of 1's
ends = diff(x) == -1;
ends = [ends; x(end)];
endspos = find(ends);

idx = zeros(size(x));
idx(:) = 1:length(x);

n = bwnumregions1(x);

l = zeros(size(x));
for k = 1:n
    if k == 1
        reg = x & (idx <= endspos(1));
    else
        reg = x & (idx > endspos(k-1)) & (idx <= endspos(k));
    end
    l(reg) = k;
end

