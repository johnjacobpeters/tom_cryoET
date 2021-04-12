function [Dz,success] = tom_HT_ctffitter(filename,psdsize,lowcutoff,highcutoff,demomode)


if nargin < 5
    demomode = true;
end

if nargin < 4
    highcutoff = 0.4;
end

if nargin < 3
    lowcutoff = 0.1;
end

if nargin < 2
    psdsize = 256;
end

if ischar(filename)

    %open the file
    im = tom_emreadc(filename);
    %calc the psd
    ps = fftshift(tom_calc_periodogram(im.Value,psdsize));
    im = rmfield(im,'Value');
    ps = tom_cart2polar(ps);
    ps = log(double(sum(ps,2)./(size(ps,2))));
    
    ps = smooth(ps,size(ps,2)*.05);

else
    ps = filename;
end

%calculate cutoffs in pixel
lowcutoff = ceil(lowcutoff*psdsize);
highcutoff = ceil(highcutoff*psdsize);
    
if demomode == true
    figure;
    subplot(3,1,1);plot(ps);hold on;title('Original powerspectrum');set(gca,'XLim',[1 psdsize/2]);
    set(gcf,'Position',[281   128   969   936]);
end

ps = ps(lowcutoff:highcutoff);
pssize = highcutoff-lowcutoff+1;
%fit the noise function to the experimental power spectrum
lb = [];
ub = [];
Aeq = [1 sqrt(pssize) pssize pssize.^2];
beq = ps(end);
nonlcon = [];
x0 = [0 0 0 0]';
snoise = double(lowcutoff:highcutoff)';
A = [ones(size(snoise,1),1) sqrt(snoise) snoise snoise.^2];
options = optimset('LargeScale','off','Diagnostics','off','Display','off','TolCon',1e-4,'TolFun',1e-5,'MaxFunEvals',300,'MaxIter',100);
noiseparams = fmincon(@noiseobjfun, x0, A, ps, Aeq, beq, lb, ub, nonlcon, options,A,ps);
noisefunction = noiseplotfun(1:pssize,noiseparams);

if demomode == true
    plot(noisefunction,'--r');
end


%fit the envelope function to the experimental power spectrum
lb = [];
ub = [];
Aeq = [1 1 1 1;1 sqrt(pssize) pssize pssize.^2];
beq = [ps(1);ps(end)];
nonlcon = [];
x0 = [ps(1) 0 0 0]';
senv = (lowcutoff:highcutoff)';
A = [ones(size(senv,1),1) sqrt(senv) senv senv.^2];
%options = optimset('LargeScale','off','Diagnostics','off','Display','off','TolCon',1e-4,'TolFun',1e-5,'MaxFunEvals',300,'MaxIter',100);
envparams = fmincon(@noiseobjfun, x0, -A, -ps, Aeq, beq, lb, ub, nonlcon, options,A,ps);
envfunction = noiseplotfun(1:pssize,envparams);

avgfunction = (envfunction + noisefunction)./2;

if demomode == true
    plot(envfunction,'--r');
    plot(avgfunction,'--g');
end

ps = (ps - avgfunction);

lowcutoff = 0.04;
highcutoff = 0.4;
lowcutoff = ceil(lowcutoff*psdsize);
highcutoff = ceil(highcutoff*psdsize);

if demomode == true
    subplot(3,1,2);plot(lowcutoff:highcutoff,norm(ps(lowcutoff:highcutoff),1));hold on;
    plot(zeros(size(ps,2),1),'Color',[0 0 0]);title('Powerspectrum without envelope functions');set(gca,'XLim',[1 pssize./2]);
end



%--------------------------------------------------------------------------
% noise fit function
%--------------------------------------------------------------------------
function val = noiseobjfun(x,A,b)
bhat = ones(size(b,1),1);
l = size(bhat,1);
bhat(round(l/2):end)=0;
val = norm((A*x-b).*bhat,1);

%--------------------------------------------------------------------------
% noise plot function                                           
%--------------------------------------------------------------------------
function y = noiseplotfun(x,n)
i=1:size(x,2);
y = (n(1)+n(2).*(i.^(1/2))+n(3).*i+n(4).*i.^2)';
