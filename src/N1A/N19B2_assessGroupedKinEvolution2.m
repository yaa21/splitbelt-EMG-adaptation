% %% Assuming that the variables groups() exists (From N19_loadGroupedData)

%% Directory to save figs
figDir='../../fig';
dirStr=[figDir '/all/kin/'];
if ~exist(dirStr,'dir')
    mkdir(dirStr);
end
%% Colormap:
colorScheme
cc=cell2mat(colorConds');
cc(2:3,:)=cc([3,2],:);
color_palette(2:3,:)=color_palette([3,2],:);

%%
removeMissing=false;
matDataDir='../../paramData/';
loadName=[matDataDir 'groupedParams'];
loadName=[loadName '_wMissingParameters']; %Never remove missing for this script
if (~exist('patients','var') || ~isa('patients','groupAdaptationData')) || (~exist('controls','var') || ~isa('controls','groupAdaptationData'))
    load(loadName)
    load([loadName 'Unbiased'])
end
patientFastList=strcat('P00',{'01','02','05','08','10','13','15'}); %Patients above .8m/s
%patients=patients.getSubGroup(patientFastList);
patientFastList=strcat('P00',{'01','02','05','08','09','10','13','14','15','16'}); %Patients above .72m/s, which is the group mean. N=10. Mean speed=.88m/s. Mean FM=29.5 (vs 28.8 overall)
controlsSlowList=strcat('C00',{'01','02','04','05','06','07','09','10','12','16'}); %Controls below 1.1m/s (chosen to match pop size), N=10. Mean speed=.9495m/s


load ../../paramData/bioData.mat %speeds, ages and Fugl-Meyer

%Removing P07:
noP07=true;
%noP07=false;



switch matchSpeedFlag
    case 1
        patients2=patients.getSubGroup(patientFastList).removeBadStrides;
        controls2=controls.getSubGroup(controlsSlowList).removeBadStrides;
        controlsUnbiased2=controlsUnbiased.getSubGroup(controlsSlowList).removeBadStrides;
        patientsUnbiased2=patientsUnbiased.getSubGroup(patientFastList).removeBadStrides;
    case 0
        if noP07
            patientsUnbiased2=patientsUnbiased.removeSubs({'P0007'}).removeBadStrides;
            patients2=patients.removeSubs({'P0007'}).removeBadStrides;

            controlsUnbiased2=controlsUnbiased.removeSubs({'C0007'}).removeBadStrides;
            controls2=controls.removeSubs({'C0007'}).removeBadStrides;
        else
            patientsUnbiased2=patientsUnbiased.removeBadStrides;
            patients2=patients.removeBadStrides;
            controls2=controls.removeBadStrides;
            controlsUnbiased2=controlsUnbiased.removeBadStrides;
        end
end

%% Parameters and conditions to plot
paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
% suffix='Norm2';
% suffix='PNorm';
paramList=strcat(paramList,suffix);
condList={'TM base', 'Adap', 'Wash'};
condListExp={'TM base','Adaptation','Washout','TM slow'};
removeBiasFlag=0;
numberOfStrides=[20 -40];
exemptFirst=5;
exemptLast=5;

%% Kin changes 2: individual shifts
paramList={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
paramList=strcat(paramList,suffix);
removeBiasFlag=0;
exemptFirst=5;
exemptLast=5;
numberOfStrides=[20 -40]; %20 for early, 40 for late
conds={'TM base','Adaptation','Washout'};
labels=paramList;
bw=1; %Median filter bandwidth

patients2=patientsUnbiased2.removeSubs({'P0007'}).removeBadStrides;
controls2=controlsUnbiased2.removeBadStrides;
switch matchSpeedFlag
    case 1
        patients2=patients2.getSubGroup(patientFastList);
        controls2=controls2.getSubGroup(controlsSlowList);
    case 0
        %nop
end

pData2=patients2.medianFilter(bw).getGroupedData(labels,conds,0,numberOfStrides,exemptFirst,exemptLast);
cData2=controls2.medianFilter(bw).getGroupedData(labels,conds,0,numberOfStrides,exemptFirst,exemptLast);

%%
fh=figure('Units','Normalized','OuterPosition',[0 0 1 1]);
fSize=6;
for j=1:length(labels)


    subplot(4,6,6*(j-1)+[1,2])
    hold on
    dd=[squeeze((nanmean(pData2{2}(1,:,j,:),2))) squeeze((nanmean(pData2{1}(2,:,j,:),2))) squeeze((nanmean(pData2{2}(2,:,j,:),2))) ];
    dd2=[squeeze((nanmean(cData2{2}(1,:,j,:),2))) squeeze((nanmean(cData2{1}(2,:,j,:),2))) squeeze((nanmean(cData2{2}(2,:,j,:),2))) ];

%plot([1,2],mean(dd,1),'-o','MarkerSize',5,'LineWidth',4,'Color',colorOrder(1,:))
plot([1:3],dd2,'-o','MarkerSize',5,'LineWidth',1,'Color',colorOrder(2,:).^.7)
plot([1:3],dd,'-o','MarkerSize',5,'LineWidth',1,'Color',colorOrder(1,:))
%plot([1,2],mean(dd2,1),'-o','MarkerSize',5,'LineWidth',4,'Color',colorOrder(3,:))
text(3*ones(size(dd,1),1),dd(:,3),patients2.ID,'FontSize',fSize)
set(gca,'XTick',[1:3],'XTickLabel',{'lateBase','earlyAdap','lateAdap'})
%title(labels{j})
set(gca,'FontSize',20)
axis tight
aa=axis;
if j==1
title(labels{j}(8:end))
end
ylabel(labels{j}(1:8))
grid on

subplot(4,6,6*(j-1)+3)
    hold on
    m1=nanmean(diff(dd(:,2:3),1,2));
    m2=nanmean(diff(dd2(:,2:3),1,2));
    bar(1,m1,'FaceColor',colorOrder(1,:),'EdgeColor','none','FaceAlpha',.5)
    bar(2,m2,'FaceColor',colorOrder(2,:),'EdgeColor','none','FaceAlpha',.5)
    errorbar(1,m1,nanstd(diff(dd(:,[2,3]),1,2))/sqrt(size(dd,1)),'Color','k','LineWidth',2)
    errorbar(2,m2,nanstd(diff(dd2(:,[2,3]),1,2))/sqrt(size(dd2,1)),'Color','k','LineWidth',2)
    m1=(diff(dd(:,2:3),1,2));
    m2=(diff(dd2(:,2:3),1,2));
    [~,p]=ttest2(m1,m2);
    [p2]=ranksum(m1,m2);
    m1=(diff(dd(:,2:3),1,2));
    m2=(diff(dd2(:,2:3),1,2));
    %if p<.05
        plot([1,2],max([m1;m2])*[1,1],'LineWidth',4)
        text(1.2,.9*max([m1;m2]),['tt, p=' num2str(p,3)])
    %end
    %if p2<.05
        plot([1,2],1.2*max([m1;m2])*[1,1],'LineWidth',4,'Color','m')
        text(1.2,1.1*max([m1;m2]),['rs, p=' num2str(p2,3)])
    %end
    %ylabel('Adap change')
    
    [~,p]=ttest(m1);
    [p2]=signrank(m1);
    if p<.05
        text(.95,.65*max([m1;m2]),['*'],'FontSize',24,'Color',colorOrder(1,:))
    end
    if p2<.05
        %text(.95,.5*max([m1;m2]),['*rs'],'FontSize',24,'Color',colorOrder(1,:))
    end
    [~,p]=ttest(m2);
    [p2]=signrank(m2);
    if p<.05
        text(1.95,.65*max([m1;m2]),['*'],'FontSize',24,'Color',colorOrder(2,:))
    end
    if p2<.05
        %text(1.95,.5*max([m1;m2]),['*rs'],'FontSize',24,'Color',colorOrder(3,:))
    end
    title('Late - Early Adap')
    set(gca,'XTick',[1,2],'XTickLabel',{'Patients','Controls'})
    

    subplot(4,6,6*(j-1)+[4,5])
    hold on
    dd=[squeeze((nanmean(pData2{2}(2,:,j,:),2))) squeeze((nanmean(pData2{2}(1,:,j,:),2))) squeeze((nanmean(pData2{1}(3,:,j,:),2)))];
    dd2=[squeeze((nanmean(cData2{2}(2,:,j,:),2))) squeeze((nanmean(cData2{2}(1,:,j,:),2))) squeeze((nanmean(cData2{1}(3,:,j,:),2)))];
plot([1:3],dd,'-o','MarkerSize',5,'LineWidth',1,'Color',colorOrder(1,:))
%plot([1,2],mean(dd,1),'-o','MarkerSize',5,'LineWidth',4,'Color',colorOrder(1,:))
plot([1:3],dd2,'-o','MarkerSize',5,'LineWidth',1,'Color',colorOrder(2,:))
%plot([1,2],mean(dd2,1),'-o','MarkerSize',5,'LineWidth',4,'Color',colorOrder(3,:))
text(3*ones(size(dd,1),1),dd(:,3),patients2.ID,'FontSize',4)
set(gca,'XTick',[1:3],'XTickLabel',{'lateAdap','lateBase','earlyPost'})
%title(labels{j})
set(gca,'FontSize',20)
axis(aa)
axis tight
grid on

subplot(4,6,6*(j-1)+6)
    hold on
     m1=nanmean(diff(dd(:,[1,3]),1,2));
    m2=nanmean(diff(dd2(:,[1,3]),1,2));
    bar(1,m1,'FaceColor',colorOrder(1,:),'EdgeColor','none','FaceAlpha',.5)
    bar(2,m2,'FaceColor',colorOrder(2,:),'EdgeColor','none','FaceAlpha',.5)
    errorbar(1,m1,nanstd(diff(dd(:,[1,3]),1,2))/sqrt(size(dd,1)),'Color','k','LineWidth',2)
    errorbar(2,m2,nanstd(diff(dd2(:,[1,3]),1,2))/sqrt(size(dd2,1)),'Color','k','LineWidth',2)
    %ylabel('Adap change')
    title('EarlyPost - Late Adap')
    m1=(diff(dd(:,[1,3]),1,2));
    m2=(diff(dd2(:,[1,3]),1,2));
    [~,p]=ttest2(m1,m2);
    [p2]=ranksum(m1,m2);
    
    plot([1,2],max([m1;m2])*[1,1],'LineWidth',4)
    text(1.2,.9*max([m1;m2]),['tt, p=' num2str(p,3)])

    plot([1,2],1.2*max([m1;m2])*[1,1],'LineWidth',4,'Color','m')
    text(1.2,1.1*max([m1;m2]),['rs, p=' num2str(p2,3)])
    [~,p]=ttest(m1);
    [p2]=signrank(m1);
    if p<.05
        text(.95,.65*max([m1;m2]),['*'],'FontSize',24,'Color',colorOrder(1,:))
    end
    if p2<.05
        %text(.95,.5*max([m1;m2]),['*rs'],'FontSize',24,'Color',colorOrder(1,:))
    end
    [~,p]=ttest(m2);
    [p2]=signrank(m2);
    if p<.05
        text(1.95,.65*max([m1;m2]),['*'],'FontSize',24,'Color',colorOrder(2,:))
    end
    if p2<.05
        %text(1.95,.5*max([m1;m2]),['*rs'],'FontSize',24,'Color',colorOrder(3,:))
    end
    set(gca,'XTick',[1,2],'XTickLabel',{'Patients','Controls'}) 
end

if matchSpeedFlag
   saveName=[saveName '_speedMatched']; 
end
saveName=['indivKinChanges' suffix '_noP07_unbiased'];
saveFig(fh,dirStr,saveName)
%% Plot 1: 3D Scatter with bias removed
% figHandle=figure;
% removeBiasFlag=0;
% binSize=1;
% figHandle=adaptationData.groupedScatterPlot(subList(3:4),paramList([1,2,3]),condList,binSize,figHandle,[1,0,0],removeBiasFlag);
% hold on
% [~,~,latePoints]=adaptationData.getGroupedData(subList,{'velocityContributionNorm2'},condList,0,1,50,10);  
% patch([.5 0 -.25 .25],[0 .5 .25 -.25],[-.5 -.5 0 0],'c','FaceAlpha',.2);
% patch([.5 .5 -.5 -.5],[.5 -.5 -.5 .5],[0 0 0 0],'k','FaceAlpha',.2)
% vOffset=1/3 * 6.2/3.8 *1/2;
% patch([.5 .5 -.5 -.5],[.5 -.5 -.5 .5],-vOffset+[0 0 0 0],'k','FaceAlpha',.2)
% plot3([-.5 .5],[ .5 -.5],[0 0],'k--')
% plot3([-.5 .5],vOffset +[ .5 -.5],-vOffset*[1 1],'k--') %Target contribution level, assuming 2:1 belt ratio, symmetrical steps, and a 62:38 stance/swing ratio
% hold off
% legStr=legend;
% %axis equal
% 
% %% Plot 3: Grouped bar plots
% exemptLast=5;
% last=50;
% first=3;
% subList1={strokes,controls};
% subList1=cellfun(@(x) strcat(matDataDir,x),subList1,'UniformOutput',false);
% subList1=cellfun(@(x) strcat(x,'Params.mat'),subList1,'UniformOutput',false);
% aux={'Step-time contribution','Spatial contribution','velContribution','(Total) Step-length asymmetry'};
% removeBiasFlag=1;
% individualsFlag=1;
% 
% paramList1=groups{1}{1}.data.getLabelsThatMatch('ContributionNorm2$')';
% paramListP=groups{1}{1}.data.getLabelsThatMatch('ContributionP$')';
% paramListS=groups{1}{1}.data.getLabelsThatMatch('^singleStanceSpeed.*Abs$')';
% 
% [figHandle,allData]=adaptationData.plotGroupedSubjectsBars(subList1,paramList,removeBiasFlag,individualsFlag,condList,first,last,exemptLast,[],.05);
% aa=get(figHandle,'Children');
% for i=1:length(aa)-1
%     title(aa(i+1),aux{length(aux)-i+1})
%     set(aa(i+1),'XtickLabel',{'Baseline','Adaptation','Washout'})
% end
% saveFig(figHandle,dirStr,'contribsBars')
% 
% 
% %% Plot 4: time courses of kin & more
% binwidth=3;
% trialMarkerFlag=0;
% indivFlag=1;
% indivSubs=[];
% removeBiasFlag=1;
% medianFlag=1;
% labels={'stroke','control'};
% %adaptationData.plotAvgTimeCourse(subList,paramList,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels)
% %%This legacy version of the plotAvgTimeCourse doesn't work with
% %%indivFlag==1
% paramList1=groups{1}{1}.data.getLabelsThatMatch('Contribution$')';
% paramListP=groups{1}{1}.data.getLabelsThatMatch('ContributionP$')';
% paramListS=groups{1}{1}.data.getLabelsThatMatch('^singleStanceSpeed.*Abs$')';
% for i=1:length(labels)
% h=adaptationData.plotAvgTimeCourse(groups([i]),paramList1,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% saveFig(h,[figDir '/' labels{i} 's/'],'contributionsTimeCourse')
% h=adaptationData.plotAvgTimeCourse(groups([i]),paramList,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% saveFig(h,[figDir '/' labels{i} 's/'],'contributionsNormTimeCourse')
% h=adaptationData.plotAvgTimeCourse(groups([i]),paramListP,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% saveFig(h,[figDir '/' labels{i} 's/'],'contributionsPTimeCourse')
% h=adaptationData.plotAvgTimeCourse(groups([i]),paramListS,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% saveFig(h,[figDir '/' labels{i} 's/'],'speedsTimeCourse')
% h=adaptationData.plotAvgTimeCourse(groups(i),{'stepTimeSlow','stepTimeFast','stepTimeDiff','strideTimeSlow'},condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% saveFig(h,[figDir '/' labels{i} 's/'],'temporalTimeCourse')
% end
% indivFlag=0;
% medianFlag=1;
% h=adaptationData.plotAvgTimeCourse(groups(1:2),paramList1,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% saveFig(h,dirStr,'contributionsTimeCourseAvgPerGroup')
% h=adaptationData.plotAvgTimeCourse(groups(1:2),paramList,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% saveFig(h,dirStr,'contributionsNormTimeCourseAvgPerGroup')
% h=adaptationData.plotAvgTimeCourse(groups(1:2),paramListP,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% saveFig(h,dirStr,'contributionsPTimeCourseAvgPerGroup')
% h=adaptationData.plotAvgTimeCourse(groups(1:2),{'stepTimeSlow','stepTimeFast','stepTimeDiff','strideTimeSlow'},condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% saveFig(h,dirStr,'temporalTimeCourseAvgPerGroup')
% h=adaptationData.plotAvgTimeCourse(groups(1:2),paramListS,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% saveFig(h,dirStr,'speedsTimeCourseAvgPerGroup')
% 
% %% Plot 5: time course of EMG
% binwidth=3;
% trialMarkerFlag=0;
% indivFlag=1;
% indivSubs=[];
% removeBiasFlag=2;
% medianFlag=1;
% labels={'stroke','control'};
% %adaptationData.plotAvgTimeCourse(subList,paramList,condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels)
% %%This legacy version of the plotAvgTimeCourse doesn't work with
% %%indivFlag==1
% paramList1=groups{1}{1}.data.getLabelsThatMatch('Contribution$')';
% paramList1={'MGp1','MGp2','MGp3','MGp4','MGp5','MGp6'};
% muscList=strcat('s',paramList1);
% %muscList=strcat('f',paramList1);
% %All muscles we are claiming change:
% muscList1={'sMGp2','sMGp3','sSOLp2','sSOLp3','sPERp3','sLGp2','sVLp2','sRFp2','sSEMBp6','sSEMTp6','sBFp6','sADMp6'};
% muscList2={'fMGp5','fMGp6','fSOLp5','fSOLp6','fPERp6','fLGp5','fVLp5','fRFp5','fSEMBp3','fSEMTp3','fBFp3','fADMp3'};
% for i=1:length(labels)
% [h,~,~,ph]=adaptationData.plotAvgTimeCourse(groups([i]),[muscList1,muscList2],condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% ph=get(gcf,'Children');
%     for j=1:length(ph)
%         try
%         axes(ph(j))
%         axis tight
%         grid on
%         catch
%             %nop
%         end
%     end
% saveFig(h,[figDir '/' labels{i} 's/'],'emgTimeCourse')
% end
% indivFlag=0;
% medianFlag=1;
% [h,~,~,ph]=adaptationData.plotAvgTimeCourse(groups(1:2),[muscList1,muscList2],condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% ph=get(gcf,'Children');
% for i=1:length(ph)
%     try
%     axes(ph(i))
%     axis tight
%     grid on
%     catch
%         %nop
%     end
% end
% saveFig(h,dirStr,'emgTimeCourse_median')
% medianFlag=0;
% [h,~,~,ph]=adaptationData.plotAvgTimeCourse(groups(1:2),[muscList1,muscList2],condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% ph=get(gcf,'Children');
% for i=1:length(ph)
%     try
%     axes(ph(i))
%     axis tight
%     grid on
%     catch
%         %nop
%     end
% end
% saveFig(h,dirStr,'emgTimeCourse_mean')
% 
% %A selection of the most interesting ones:
% muscList1={'sMGp2','sMGp3','sSOLp2','sSOLp3','sLGp2','sVLp2','sRFp2'};
% muscList2={'fMGp5','fSOLp5','fPERp6','fLGp5','fVLp5','fRFp5','fSEMTp3'};
% indivFlag=1;
% for i=1:length(labels)
% [h,~,~,ph]=adaptationData.plotAvgTimeCourse(groups([i]),[muscList1,muscList2],condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels{i},medianFlag);
% ph=get(h,'Children');
% for j=1:length(ph)
%     try
%     axes(ph(j))
%     axis tight
%     grid on
%     catch
%         %nop
%     end
% end
% saveFig(h,[figDir '/' labels{i} 's/'],'emgTimeCourse_sel')
% end
% indivFlag=0;
% medianFlag=1;
% [h,~,~,ph]=adaptationData.plotAvgTimeCourse(groups(1:2),[muscList1,muscList2],condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% ph=get(gcf,'Children');
% for i=1:length(ph)
%     try
%     axes(ph(i))
%     axis tight
%     grid on
%     catch
%         %nop
%     end
% end
% saveFig(h,dirStr,'emgTimeCourse_median_sel')
% medianFlag=0;
% [h,~,~,ph]=adaptationData.plotAvgTimeCourse(groups(1:2),[muscList1,muscList2],condList,binwidth,trialMarkerFlag,indivFlag,indivSubs,[],[],removeBiasFlag,labels,medianFlag);
% ph=get(h,'Children');
% for i=1:length(ph)
%     try
%     axes(ph(i))
%     axis tight
%     grid on
%     catch
%         %nop
%     end
% end
% saveFig(h,dirStr,'emgTimeCourse_mean_sel')