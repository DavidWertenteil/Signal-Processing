function feat = featuresFromBuffer(atx, aty, atz, fs)

persistent fhp
if(isempty(fhp))
    fhp = hpfilter;
    fhp.PersistentMemory = false;
end

feat = zeros(1,66);

abx = filter(fhp,atx);
aby = filter(fhp,aty);
abz = filter(fhp,atz);

%%
feat(1) = mean(atx);
feat(2) = mean(aty);
feat(3) = mean(atz);

%%
feat(4) = rms(abx);
feat(5) = rms(aby);
feat(6) = rms(abz);

%%
feat(7:9) = covFeatures(abx, fs);
feat(10:12) = covFeatures(aby, fs);
feat(13:15) = covFeatures(abz, fs);

%%
feat(16:27) = spectralPeaksFeatures(abx, fs);
feat(28:39) = spectralPeaksFeatures(aby, fs);
feat(40:51) = spectralPeaksFeatures(abz, fs);

%%
feat(52:56) = spectralPowerFeatures(abx, fs);
feat(57:61) = spectralPowerFeatures(aby, fs);
feat(62:66) = spectralPowerFeatures(abz, fs);

%%
function feats = covFeatures(x, fs)

feats = zeros(1,3);

[c, lags] = xcorr(x);

minprom = 0.0005;
mindist_xunits = 0.3;
minpkdist = floor(mindist_xunits/(1/fs));
[pks,locs] = findpeaks(c,...
    'minpeakprominence',minprom,...
    'minpeakdistance',minpkdist);

tc = (1/fs)*lags;
tcl = tc(locs);
% Feature 1 - peak height at 0
if(~isempty(tcl))   % else f1 already 0
    feats(1) = pks((end+1)/2);
end
% Features 2 and 3 - position and height of first peak 
if(length(tcl) >= 3)   % else f2,f3 already 0
    feats(2) = tcl((end+1)/2+1);
    feats(3) = pks((end+1)/2+1);
end
%%
function feats = spectralPeaksFeatures(x, fs)

mindist_xunits = 0.3;

feats = zeros(1,12);

N = 4096;
minpkdist = floor(mindist_xunits/(fs/N));

[p, f] = pwelch(x,rectwin(length(x)),[],N,fs);

[pks,locs] = findpeaks(p,'npeaks',20,'minpeakdistance',minpkdist);
if(~isempty(pks))
    mx = min(6,length(pks));
    [spks, idx] = sort(pks,'descend');
    slocs = locs(idx);

    pks = spks(1:mx);
    locs = slocs(1:mx);

    [slocs, idx] = sort(locs,'ascend');
    spks = pks(idx);
    pks = spks;
    locs = slocs;
end
fpk = f(locs);

% Features 1-6 positions of highest 6 peaks
feats(1:length(pks)) = fpk;
% Features 7-12 power levels of highest 6 peaks
feats(7:7+length(pks)-1) = pks;

function feats = spectralPowerFeatures(x, fs)

feats = zeros(1,5);

edges = [0.5, 1.5, 5, 10, 15, 20];

[p, f] = periodogram(x,[],4096,fs);
    
for kband = 1:length(edges)-1
    feats(kband) = sum(p( (f>=edges(kband)) & (f<edges(kband+1)) ));
end
