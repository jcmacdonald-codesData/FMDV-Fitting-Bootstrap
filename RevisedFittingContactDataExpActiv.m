function [] = RevisedFittingContactDataExpActiv
close all
% turn figure display on  or off
set(0,'DefaultFigureVisible','on')
% import and organize data
xs = readtable('SAADataContact.csv');

groups = xs(:,1);
groups = table2array(groups);
groups = string(groups);

IDs = xs(:,2);
IDs = table2array(IDs);
%IDs = string(groups);

xs = table2array(xs(:,3:end));
xs(xs>0) = log10(xs(xs>0));

ses = readtable('ViremiaContact.csv');
ses = table2array(ses(:,3:end));

pvs = readtable('VNTContactData.csv');
pvs = table2array(pvs(:,3:end));

% set up solution bin to store fit parameters for analysis 
pfitsContactFinal = zeros(12,8);

% initial guesss
% initial conditions 
%x0 = [2.4223;0.8164;2];
% params 
%lambda=5;k=1;d=0.5;r=8;K=8;theta=0.5;delta=0.7;atilde=0.1;b=0.0001;


% days corresponding to data points 
t = [0,2, 4, 6, 9,12,28];
% t = [0,2, 4, 6, 8, 11, 14, 30];
t2 = t;
tt = t(1):.01:30;

% parameter boundries 

% sqwt = 3; %r (virus)
% sqwt2 = 3; % g (adapt)
% sqwt3 = 1; % b (innate)
% objective function 
function yy = paramfun1(p,t)
    
    lambda=(1/11.8)*p(end-2);
    
    
        %lambda2 = (1/11.8)*x(end);
        %lambda = min(lambda1,lambda2);
    %lambda = lambda2;
    k=p(1); d=1/11.18; r=p(6); K=p(2); theta=0; delta=p(3); b=p(4); %v0 = p(7); % use disperse here ...
    x0 = [p(5),vv(1),.0001*p(5)]; % initial conditions 
    atilde=0;
    f = @(t,a) [lambda+k*a(2)*a(1)- d*a(1); ... 
                (r*(1-(a(2)/K))-theta*a(1)-delta*a(3))*a(2); ...
                (atilde*(a(1)/(1+a(1)))+b*a(3))*a(2)];
   %  f = @(t,a) [lambda+k*(a(2)/(v0+a(2)))*a(1)- d*a(1); ... 
    %           (r*(1-(a(2)/K))-theta*a(1)-delta*a(3))*a(2); ...
     %           (atilde*(a(1)/(1+a(1)))+b*a(3))*a(2)];
   
   [~,yy] = ode45(f,t,x0);
   yy = [yy(1:end,1)'*sqwt3,yy(1:end,2)'*sqwt,yy(:,3)'*sqwt2];
end 

for j = 1:12
    x = xs(j,:);
    s = ses(j,:);
    vv = ViralGrowth(s);
    pv = pvs(j,:);
    %p0 = [5; 1; .5; 8; 8; .5; .7; 0.1; .0001;2.4223;0.8164;2];
    %p0 = p0';

    %lb=[0,0,5,8,0,0,0,0,08.01,0,0];
 sqwt = 5/max(s); %r (virus)
sqwt2 = 1/max(pv); % g (adapt)
sqwt3 = 1/max(x); % b (innate)
lb = [1/11.8,4,0,0,0,vv(2)];
lu = [2,12,2.0,.5,0,5];
lb(end-1) = .9*x(1);
lu(end-1) = 1.1*x(1);
if lu(end-1) < 2
    lb(end-1) = 1.5;
    lu(end-1) = 2.2;
end

%lu = ceil(lu);
%lu = 1.5*[2.40099681748832,0.180217620144872,0.876993739943215,3.85927467085888,7.45599739962807,0.240789681072565,1.34272390177740,0.198134316854021,1.12497644456651,0.000523669304140990,0.00942918373810948];
%lu = 1.75*[2.40099679870590,0.180217620144889,0.786055202145737,4.60385488746746,11.1283865156487,0.181310869153778,1.78832077905483,0.153899306617444,2.39652526351515,0.000674851227146082,0.0258226578980482]
%lu = 1.45*[2.65791789779996,0.170205504215460,0.872663789058628,3.89038597376605,8.40274034971183,0.235727503885955,1.38409634133711,0.180000794747487,2.19896305100556,0.000587279961082414,0.0181241441861195];
  %  lb=[0,0,0,5,5,0,0,0,0,0.01,0,0];
   % lu=[eps,2,1,15,10,10,5,5,1,2.5,2,2];
   % lb(8) = [];
   % lb(8) = [];z
%lu(1) = 2.4;
%lb(2) = .165;
%lb(5) = 8;
%lu(5) = 12;

    p0 = (lu+lb)/2;
    p0(2) = 12;
    array2table(lu)
    array2table(lb)
   [pfit resnorm] = lsqcurvefit(@paramfun1,p0,t,[x(1:end)*sqwt3,s(1:end)*sqwt,pv(1:end)*sqwt2],lb,lu);
   [pfit resnorm] = lsqcurvefit(@paramfun1,pfit,t,[x(1:end)*sqwt3,s(1:end)*sqwt,pv(1:end)*sqwt2],lb,lu);
array2table(pfit)
    bFits = paramfun1(pfit,t);
   xfitsC(j,:) = bFits(1:length(t))./sqwt3;
   sfitsC(j,:) = bFits(length(t)+1:2*(length(t)))./sqwt;
   pvfitsC(j,:) = bFits(2*(length(t))+1:end)./sqwt2;
   pfitsContactFinal(j,:) = [vv(1),pfit, resnorm];
    %lambda1=(1/11.8)*pfit(end-2);
    
    
        lambda=(1/11.8)*pfit(end-2);
    
    
       % lambda2 = (1/11.8)*x(end);
        %lambda = min(lambda1,lambda2);
    k=pfit(1); d=1/11.18; r=pfit(6); K=pfit(2); theta=0; delta=pfit(3); b=pfit(4); % use disperse here ...
    x0 = [pfit(5),vv(1),.0001*pfit(5)]; % initial conditions 
    atilde=0; %v0 = pfit(7);
 % f = @(t,a) [lambda+k*(a(2)/(v0+a(2)))*a(1)- d*a(1); ... 
  %             (r*(1-(a(2)/K))-theta*a(1)-delta*a(3))*a(2); ...
   %             (atilde*(a(1)/(1+a(1)))+b*a(3))*a(2)];
     f = @(t,a) [lambda+k*a(2)*a(1)- d*a(1); ... 
                (r*(1-(a(2)/K))-theta*a(1)-delta*a(3))*a(2); ...
                (atilde*(a(1)/(1+a(1)))+b*a(3))*a(2)];
   [tplot,yy] = ode45(f,tt,x0);
%    fits = paramfun1(pfit,tt);
%    xfit = fits(1:length(tt));
%    sfit = fits(length(tt)+1:2*(length(tt)));
%    [mVi I] = max(sfit/sqwt);
%    cumviralContact(j) = sum(sfit/sqwt);
%    maxViralContact(j,:) = [mVi tt(I)];
%    pvfit = fits(2*length(tt)+1:end);
    str = strcat('ID',' ',num2str(IDs(j)),', ',extractBetween(groups(j),1,4));
%    str2= strcat('ID',num2str(IDs(j)),groups(j),'A_0');
%    length(tt(1:end-1))
%    length(xfit)
   figure
   hold on
   plot(tt(1:end),yy(:,1),'b',tt(1:end),yy(:,2),'r',tt,yy(:,3),'g','linewidth',2)
   plot(t2,x,'b*',t2,s,'r+',t2,pv,'go','MarkerSize',20,'linewidth',2)
   hold off
   ylim([0 14])
   xlim([0 30])
   if j == 1
   legend('I(\tau)','P(\tau)','A(\tau)','log_{10}(I_{SAA})','FMDV','A_{VNT}')
   end
   title(str)
   set(gca,'FontSize',16)
%    baseFileName = sprintf(str2);
%        fname = '~/Dropbox/Within_host_dyn_FMD/Within_host_dyn_FMD/matlab_codes/Revised_Plots';
%     saveas(gca, fullfile(fname, baseFileName), 'png');
%    dvdtau = (gradient(sfit(:)/sqwt)./gradient(tt(1:end-1)));
 %   [mindV, index] = min(dvdtau);
  %  for w = 1:length(sfit)
   %     if abs(dvdtau(w)) <= .05
    %        if w > index
     %       VTC(j) = tt(w);
      %      break
 %           end
  %      end
  %  end
            
end
save('pfitsContactFinal.mat','pfitsContactFinal')
save('maxViralContactFinal.mat','maxViralContact')
save('cumviralContactFinal.mat','cumviralContact')
save('VTCFinal.mat','VTC')
save('xfitsCFinal.mat','xfitsC')
save('sfitsCFinal.mat','sfitsC')
save('pvfitsCFinal.mat','pvfitsC')

end