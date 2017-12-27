function plotPSDForGivenSubject(subject) %(acc, actid, fs)

%% Collective plotting - PSD

cmap = colormap(lines(6));
% Design filter
% f1 = 0.4;
% f2 = 0.8;
fhp = hpfilter;

for s = subject:subject
    % Get subject s
    [acc, actid, ~, ~, fs] = getRawAcceleration(...
        'SubjectID',s,...
        'AccelerationType','total',...
        'Component','x');
    % "Decouple" acceleration due to body dynamics from gravitational
    ab = filter(fhp,acc);

    for k = 1:6
        idx = (actid == k);
        l = bwlabels1(idx);
        numregions = max(l);

        for r = 1:numregions
            idx = l == r;
            d = ab(idx,:)';

            [psd,fp] =  pwelch(d,[],[],[],fs);

            hp = plot3(fp,k*ones(size(fp)), db(psd),'-','Color',cmap(k,:));
            hp.LineWidth = 1.5;
            grid on
            set(gca,'Xlim',[0 10])
        %     set(gca,'Zlim',[0 0.15])
            hold on
        end

    end
end
hold off
ax = gca;
ax.YTickMode = 'manual';
ax.YTick = int32(Act(1:6));
% ax.YTickLabels = Act(1:6);
mA = ?Act; ti = {mA.EnumerationMemberList(:).Name};
ax.YTickLabel = ti;
xlabel('Frequency (Hz)')

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

