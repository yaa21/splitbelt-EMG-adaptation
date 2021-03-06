%% Open relevant intfigs
f(1)=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]medianALT.fig');
f(2)=openfig('/Datos/Documentos/code/splitbelt-EMG-adaptation/intfig/all/dyn/fig/Adapt[2.1_1]ALT.fig');
p=findobj(f(2),'Type','Axes');
set(p,{'Position'},cellfun(@(x) x+[.4 0 0 0],get(p,'Position'),'UniformOutput',false));
load ../data/dynamicsData.mat
%% Copy relevant panels:
figuresColorMap
fh=figure('Units','Normalized','Position',[0 0 1 1],'Colormap',flipud(map));
for j=1:2
  
p1=findobj(f(j),'Type','Axes');
np1=copyobj(p1(end-5:end),fh); %Copying states and associated checkerboards


off=[0;6;15;21];%Early post,lA,eA,B
for i=1:length(off)
    aux=copyobj(p1([11,12]+off(i)),fh); 
    if i~=4
        for k=1:2
            aux(k).Position(1)=np1(2*(mod(i,3)+1)).Position(1);
        end
    end
end
aux2=copyobj(p1(34),fh); 
aux2.Position(1)=aux(1).Position(1);
aux2.Position(2)=1.5*aux(1).Position(2)-.5*aux(2).Position(2);
aux2.Position(4)=.5*aux2.Position(4);
ll=findobj(aux2,'Type','Line');
lg=legend(ll,{'Proj. over C_2','Proj. over C_1','State 2','State 1'});
lg.Position(1)=lg.Position(1);
lg.Position(2)=lg.Position(2)+.02;
lg.FontWeight='bold';
grid on

% Add SLA evolution below
states=[ll(3).YData;ll(4).YData; [zeros(1,50), ones(1,900), zeros(1,600)]];
SLA=cat(1,nanmedian(dataContribs{1},3),nanmedian(dataContribs{2},3),nanmedian(dataContribs{3},3))-nanmean(nanmedian(dataContribs{1},3)); %Catting and removing base
SLA(isnan(SLA))=0;
ff=states'\SLA;
ax=axes();
ax.Position=aux2.Position+[0 -.1 0 0];
hold on
plot(SLA,'k','DisplayName','SLA data')
sim=states'*ff;
sim(50)=NaN;
sim(950)=NaN;
SLA(50)=NaN;
SLA(950)=NaN;
plot(sim,'Color',[.8,0,.1],'LineWidth',2,'DisplayName','SLA fitted')
ax.XTick=aux2.XTick;
ax.YTick=[-.15:.15:.15];
grid on
ax.YTickLabel={};
ax.XLim=aux2.XLim;
lg=legend('Location','SouthEast');
lg.FontWeight='bold';


%aux=copyobj(p1([11,12]+6),fh); %late adapt
%aux=copyobj(p1([11,12]+15),fh); %early adapt

%aux=copyobj(p1([11,12]+21),fh); %base
%aux.Position([2,4])=np1(1).Position([2,4]);
%aux.Title.String='Early Post Data (2:4)';

%np1(3).Title.String='End of Adaptation fit';
%np1(2).Title.String='Early Post prediction';

%set(np1,'Position',get(np1,'Position')+[]);

axes(np1(end-2))
pp=np1(end-2).Position;
cc=colorbar;
np1(end-2).Position=pp;

if j==2
    np1(2).YTickLabels=[strcat('s',np1(2).YTickLabels);strcat('f',np1(2).YTickLabels)];
    np1(2).YTick=1:30;
    np1(2).YAxis.FontSize=6;
end

end
%%
saveFig(fh,'./','twoStateCompare')