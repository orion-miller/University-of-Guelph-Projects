%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Orion Miller            GRYPHON RACING TIRE MODEL            September 2018

% This program makes use of work from:

% Tire and Vehicle Dynamics 2nd edition, Hans Pacejka.
% Race Car Vehicle Dynamics, Milliken and Milliken.
% The Science of Vehicle Dynamics, Massimo Guiggiani.
% Michael Barnard (Pacejka 2012 Code)
% Bjorn Gustavsson (Scrolling Subplot Code)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc 
tic

cd(uigetdir);
load(uigetfile);

if strcmp(testid(1,1),'C')
    isCornering = 1;
else
    isCornering = 0;
end

% isCornering = 1;


%     Plot Control Variables, Temps, Radii
f = figure('Name',sprintf('Variables at a Glance: %s, %s', tireid, testid),'NumberTitle','off','Position',[0 0 1300 670]);
figure(f)

scrollsubplot(3,1,1)
    if isCornering ==1
    plot(ET,SA)
    title('Slip Angle vs. Time');
    xlabel('Time (s)');
    ylabel('SA (Degrees)');
    grid on
  %  set(gca,'color',[0 0 0])
    else 
        plot(ET,SR)
        hold on
        plot(ET,SL)
        title('Slip Ratios vs. Time');
        xlabel('Time (s)');
        ylabel('Slip Ratio');
        legend('SR','SL');
        grid on
       % set(gca,'color',[0 0 0])
    end

scrollsubplot(3,1,2)
    plot(ET,P*0.145)
    title('Pressure vs. Time');
    xlabel('Time (s)');
    ylabel('P (PSI)');
    grid on
 %   set(gca,'color',[0 0 0])

scrollsubplot(3,1,3)
    plot(ET,IA)
    title('Inclination Angle vs. Time');
    xlabel('Time (s)');
    ylabel('IA (Degrees)');
    grid on
   % set(gca,'color',[0 0 0])
    
scrollsubplot(3,1,4)
    plot(ET,FZ)
    title('Normal Force vs. Time');
    xlabel('Time (s)');
    ylabel('FZ (N)');
    grid on
   % set(gca,'color',[0 0 0])
    
scrollsubplot(3,1,5)
    plot(ET,FX)
    hold on
    plot(ET,FY)
    hold off
    title('Friction Forces vs. Time');
    xlabel('Time (s)');
    ylabel('Force (N)');
    legend('FX','FY')
    grid on

scrollsubplot(3,1,6)
    plot(ET,MX)
    hold on
    plot(ET,MZ)
    hold off
    title('Moments vs. Time');
    xlabel('Time (s)');
    ylabel('Torque (N.m)');
    legend('MX','MZ')
    grid on
    
scrollsubplot(3,1,7)
    plot(ET,V)
    title('Speed vs. Time');
    xlabel('Time (s)');
    ylabel('V (kph)');
    grid on
    
scrollsubplot(3,1,8)
    plot(ET,RE)
    hold on
    plot(ET,RL)
    hold off
    title('Radii vs. Time');
    xlabel('Time (s)');
    ylabel('Radius (cm)');
    legend('RE', 'RL')
    grid on
    
scrollsubplot(3,1,9)
    plot(ET,TSTI)
    hold on
    plot(ET,TSTC)
    plot(ET,TSTO)
    plot(ET,AMBTMP)
    plot(ET,RST)
    hold off
    title('Temperatures vs. Time');
    xlabel('Time (s)');
    ylabel('Temperature (Degrees C)');
    legend('TSTI', 'TSTC', 'TSTO','RST','AMBTMP')
    grid on
    
% Splits curves with Run Data
dif = diff(ET);
SWEEP_ENDS = find(dif>1); % creates finish splits
SWEEP_STARTS = [1; SWEEP_ENDS + 1]; % creates beginning splits
SWEEP_ENDS(numel(SWEEP_ENDS)+1) = numel(ET); % adds final finish split
SWEEPS_NUM = numel(SWEEP_STARTS);

Length = numel(ET);

FZ_LIST = [0 -220 -440 -660 -880 -1100 -1550 -2000 -3000];  %Middle 7 values are the vertical loads tested

% simpleFit = zeros(Length);
% MZ_FIT = zeros(Length);
% FX_FIT = zeros(Length);

if isCornering == 1
    Coeff_Friction(1:Length) = FY(1:Length)./FZ(1:Length);
else
    Coeff_Friction(1:Length) = FX(1:Length)./FZ(1:Length);
end 

h = 0.05; %This step size is used because it is the average difference in SA per data point
% stiffnessRange = -390:h:-270; 
% absfz = abs(FZ);
% stiffnessVals = find(absfz);
% stiffnessRange = FZ(stiffnessVals);

for i=1:SWEEPS_NUM-1   %Finds tire spring rate by calculating differences in avg FZ and RL from sweep to sweep
    
stiffnessFZ1 = mean(FZ(SWEEP_STARTS(i):SWEEP_ENDS(i)));
stiffnessFZ2 = mean(FZ(SWEEP_STARTS(i+1):SWEEP_ENDS(i+1)));

stiffnessRE1 = mean(RE(SWEEP_STARTS(i):SWEEP_ENDS(i)));
stiffnessRE2 = mean(RE(SWEEP_STARTS(i+1):SWEEP_ENDS(i+1)));

tireRate(i) = abs(stiffnessFZ1 - stiffnessFZ2)./abs(stiffnessRE1 - stiffnessRE2);
end

tireRate = mean(tireRate);
stiffnessStatement = sprintf('Tire Spring Rate: %s N/cm', tireRate);
disp(stiffnessStatement);


for i=1:SWEEPS_NUM
    SWEEP_FZ = FZ(SWEEP_STARTS(i):SWEEP_ENDS(i));
    SWEEP_P = P(SWEEP_STARTS(i):SWEEP_ENDS(i));
    SWEEP_IA = IA(SWEEP_STARTS(i):SWEEP_ENDS(i));
   
%     FY_PEAK_POS(i) = find(max(SWEEP_FY));                          %Finds max grips for each sweep
%     FX_PEAK_POS(i) = FX(FY_PEAK_POS(i));
%     FY_PEAK_NEG(i) = min(SWEEP_FY);
%     FX_PEAK_NEG(i) = FX(FY_PEAK_NEG(i));
    
%             maxFYindx = find(FY>(max(FY)*.95));
  
    FZ_AVG(i) = mean(SWEEP_FZ);
    P_AVG(i) = mean(SWEEP_P);
    IA_AVG(i) = mean(SWEEP_IA);
    
    FZ_STDDEV(i) = std(SWEEP_FZ);
    P_STDDEV(i) = std(SWEEP_P);
    IA_STDDEV(i) = std(SWEEP_IA);
    
    FZ_CLASS(i) = interp1(FZ_LIST,FZ_LIST,FZ_AVG(i),'nearest');
    P_CLASS(i) = round(P_AVG(i)*0.145);
    IA_CLASS(i) = round(IA_AVG(i));
    

end

if isCornering ==1

    [FY_FIT] = Pacejka2012_FY(FY,SA,FZ_AVG,P_AVG,IA_AVG,FZ_CLASS,P_CLASS,IA_CLASS,SWEEPS_NUM,SWEEP_STARTS,SWEEP_ENDS,Length);
    [MZ_FIT] = Pacejka2012_MZ(MZ,SA,FZ_AVG,P_AVG,IA_AVG,FZ_CLASS,P_CLASS,IA_CLASS,SWEEPS_NUM,SWEEP_STARTS,SWEEP_ENDS,Length);

else
    
    [FX_FIT] = Pacejka2012_FX(FX,SR,FZ_AVG,P_AVG,IA_AVG,FZ_CLASS,P_CLASS,IA_CLASS,SWEEPS_NUM,SWEEP_STARTS,SWEEP_ENDS,Length);

end 

while(1)
choice1 = input('What would you like to vary? Enter 1 for Vertical Force, 2 for Pressure, 3 for Inclination Angle: ');

if choice1 == 1
P_Choice = input('Choose Pressure: ');
IA_Choice = input('Choose Inclination Angle: ');
Fixed_1 = P_Choice;
Fixed_2 = IA_Choice;
Class_1 = P_CLASS;
Class_2 = IA_CLASS;

Class_3 = FZ_CLASS;
Class_3(Class_3 == -220) = 1;
Class_3(Class_3 == -440) = 2;
Class_3(Class_3 == -660) = 3;
Class_3(Class_3 == -880) = 4;
Class_3(Class_3 == -1100) = 5;
Class_3(Class_3 == -1550) = 6;
Class_3(Class_3 == -2000) = 7;

disp('FZ = 220: GREEN') 
disp('FZ = 440: RED') 
disp('FZ = 660: CYAN') 
disp('FZ = 880: MAGENTA') 
disp('FZ = 1100: YELLOW') 
disp('FZ = 1550: BLUE') 
disp('FZ = 2000: BLACK') 

variedThing = ('Normal Force Variation');

else if choice1 == 2
        FZ_CHOICE = input('Choose Vertical Force: ');
        IA_Choice = input('Choose Inclination Angle: ');
        Fixed_1 = -FZ_CHOICE;
        Fixed_2 = IA_Choice;
        Class_1 = FZ_CLASS;
        Class_2 = IA_CLASS;
        
        Class_3 = P_CLASS;
        Class_3(Class_3 == 8) = 1;
        Class_3(Class_3 == 10) = 2;
        Class_3(Class_3 == 12) = 3;
        Class_3(Class_3 == 14) = 4;
        
        disp('P = 8: GREEN') 
        disp('P = 10: RED') 
        disp('P = 12: CYAN') 
        disp('P = 14: MAGENTA') 
        
        variedThing = ('Pressure Variation');
    
    else if choice1 == 3
            FZ_CHOICE = input('Choose Vertical Force: ');
            P_Choice = input('Choose Pressure: ');
            Fixed_1 = -FZ_CHOICE;
            Fixed_2 = P_Choice;
            Class_1 = FZ_CLASS;
            Class_2 = P_CLASS;
            
            Class_3 = IA_CLASS;
            Class_3(Class_3 == 0) = 1;
            Class_3(Class_3 == 1) = 2;
            Class_3(Class_3 == 2) = 3;
            Class_3(Class_3 == 3) = 4;
            Class_3(Class_3 == 4) = 5;
            Class_3(Class_3 == 5) = 6;
            Class_3(Class_3 == 6) = 7;
            
            disp('IA = 0: GREEN') 
            disp('IA = 1: RED') 
            disp('IA = 2: CYAN') 
            disp('IA = 3: MAGENTA') 
            disp('IA = 4: YELLOW') 
            disp('IA = 5: BLUE') 
            disp('IA = 6: BLACK') 
            
            variedThing = ('Camber Variation');
        end 
    end
end 



if isCornering ==1
    
dotsz = 25;

f = figure('Name',sprintf('FY vs. Slip Angle, Tire Temperature: %s', tireid),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
plotinner = subplot(1,3,1);
scatter(plotinner,SA,FY,dotsz,TSTI)
title('SA vs. FY, TSTI')

plotcenter = subplot(1,3,2);
scatter(plotcenter,SA,FY,dotsz,TSTC)
title('SA vs. FY, TSTC')

plotouter = subplot(1,3,3);
scatter(plotouter,SA,FY,dotsz,TSTO)
title('SA vs. FY, TSTO')

f = figure('Name',sprintf('MZ vs. Slip Angle, %s: %s', variedThing, tireid),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
for i = 1:SWEEPS_NUM
if Class_1(i)==Fixed_1&&Class_2(i)==Fixed_2
       if Class_3(i) == 1
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.g');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'g');
       else if Class_3(i) == 2
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.r');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'r');
        else if Class_3(i) == 3
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.c');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'c');
        else if Class_3(i) == 4
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.m');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'m');
        else if Class_3(i) == 5
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.y');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'y');
        else if Class_3(i) == 6
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.b');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'b');
        else if Class_3(i) == 7
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.k');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'k');
            end
            end
            end
            end
            end
           end
       end
end
end
% plot(
% plot(SA_220,MZ_220,'.g',SA_440,MZ_440,'.b',SA_660,MZ_660,'.m',SA_1100,MZ_1100,'.r',SA_1550,MZ_1550,'.c');
title('MZ vs. \alpha ','FontSize',20);
xlabel('\alpha (degrees)','FontSize',16);
ylabel('MZ (N.m)','FontSize',16);
set(gca,'FontSize',14);
set(gca,'XTick',-12.5:2.5:12.5);
set(gca,'YTick',-100:20:100);
%set(gca,'color',[0 0 0])
grid on
%axis([-12.5 12.5 -400 4000]);

f = figure('Name',sprintf('Lateral Force vs. Slip Angle, %s: %s', variedThing, tireid),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
for i = 1:SWEEPS_NUM
if Class_1(i)==Fixed_1&&Class_2(i)==Fixed_2
       if Class_3(i) == 1
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.g');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'g');
       else if Class_3(i) == 2
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.r');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'r');
        else if Class_3(i) == 3
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.c');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'c');
        else if Class_3(i) == 4
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.m');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'m');
        else if Class_3(i) == 5
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.y');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'y');
        else if Class_3(i) == 6
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.b');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'b');
        else if Class_3(i) == 7
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.k');
        hold on
        plot(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)),FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'k');
            end
            end
            end
            end
            end
           end
       end
end
end
% plot(SA_220,FY_220,'.g',SA_440,FY_440,'.b',SA_660,FY_660,'.m',SA_1100,FY_1100,'.r',SA_1550,FY_1550,'.c');
%hold on;
% plot(SA,F1,'k',SA,F2,'k',SA,F3,'k',SA,F4,'k','LineWidth',2);
% plot(SA,0,'k',0,-4000:5:4000,'k','LineWidth',1);
title('F_y vs. \alpha ','FontSize',20);
xlabel('\alpha (degrees)','FontSize',16);
ylabel('F_y (N)','FontSize',16);
% h = legend(num2str([50 100 150 250]'*4.448));
% set(h,'Location','NorthWest');
% htitle = get(h,'Title');
% set(htitle,'String','F_z  (N)','FontSize',14);
set(gca,'FontSize',14);
set(gca,'XTick',-12.5:2.5:12.5);
set(gca,'YTick',-4000:1000:4000);
%set(gca,'color',[0 0 0])
grid on
%axis([-12.5 12.5 -400 4000]);

else
    
dotsz = 25;

f = figure('Name',sprintf('FX vs. Slip Ratio, Tire Temperature: %s', tireid),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
plotinner = subplot(1,3,1);
scatter(plotinner,SR,FX,dotsz,TSTI)
title('SR vs. FX, TSTI')

plotcenter = subplot(1,3,2);
scatter(plotcenter,SR,FX,dotsz,TSTC)
title('SR vs. FX, TSTC')

plotouter = subplot(1,3,3);
scatter(plotouter,SR,FX,dotsz,TSTO)
title('SR vs. FX, TSTO')
    

f = figure('Name',sprintf('SR vs. Coefficient of Friction, %s: %s', variedThing, tireid),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
for i = 1:SWEEPS_NUM
if Class_1(i)==Fixed_1&&Class_2(i)==Fixed_2
       if Class_3(i) == 1
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.g');
        hold on
       else if Class_3(i) == 2
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.r');
        hold on
        else if Class_3(i) == 3
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.c');
        hold on
        else if Class_3(i) == 4
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.m');
        hold on
        else if Class_3(i) == 5
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.y');
        hold on
        else if Class_3(i) == 6
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.b');
        hold on
        else if Class_3(i) == 7
        plot(abs(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))),abs(Coeff_Friction(SWEEP_STARTS(i):SWEEP_ENDS(i))),'.k');
        hold on
            end
            end
            end
            end
            end
           end
       end
end
end 
% plot(SR_220,FX_220,'.g',SR_440,FX_440,'.b',SR_660,FX_660,'.m',SR_1100,FX_1100,'.r',SR_1550,FX_1550,'.c');
title('Coefficient of Friction vs. Slip Ratio ','FontSize',20);
xlabel('SR (dimensionless)','FontSize',16);
ylabel('Coefficient of Friction (dimensionless)','FontSize',16);
set(gca,'FontSize',14);
set(gca,'XTick',-0.2:0.02:1.6);
set(gca,'YTick',-5:1:5);
%set(gca,'color',[0 0 0])
grid on
%axis([-12.5 12.5 -400 4000]);

f = figure('Name',sprintf('FX vs. Slip Ratio, %s: %s', variedThing, tireid),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
for i = 1:SWEEPS_NUM
if Class_1(i)==Fixed_1&&Class_2(i)==Fixed_2
       if Class_3(i) == 1
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.g');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'g');
       else if Class_3(i) == 2
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.r');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'r');
        else if Class_3(i) == 3
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.c');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'c');
        else if Class_3(i) == 4
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.m');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'m');
        else if Class_3(i) == 5
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.y');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'y');
        else if Class_3(i) == 6
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.b');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'b');
        else if Class_3(i) == 7
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX(SWEEP_STARTS(i):SWEEP_ENDS(i)),'.k');
        hold on
        plot(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)),FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)),'k');
            end
            end
            end
            end
            end
           end
       end
end
end
% plot(SR_220,FX_220,'.g',SR_440,FX_440,'.b',SR_660,FX_660,'.m',SR_1100,FX_1100,'.r',SR_1550,FX_1550,'.c');
title('FX vs. Slip Ratio ','FontSize',20);
xlabel('SR (dimensionless)','FontSize',16);
ylabel('FX (N)','FontSize',16);
set(gca,'FontSize',14);
set(gca,'XTick',-1.0:0.2:1.0);
set(gca,'YTick',-5000:2500:5000);
%set(gca,'color',[0 0 0])
grid on
%axis([-12.5 12.5 -400 4000]);

end

Repeat_Plot = input('Make another plot? Enter 1 for yes, 0 for no: ');
if Repeat_Plot == 0
    break
end 

end    %Asks user what variable to look at, makes plots

toc

function theAxis = scrollsubplot(nrows, ncols, thisPlot)
%SCROLLSUBPLOT Create axes in tiled positions.
%   SCROLLSUBPLOT(m,n,p), breaks the Figure window into
%   an m-by-n matrix of small axes, selects the p-th axes for 
%   for the current plot, and returns the axis handle.  The axes 
%   are counted along the top row of the Figure window, then the
%   second row, etc. 
%   Example:
% 
%       scrollsubplot(3,1,-1), plot(income)
%       scrollsubplot(3,1,1), plot(declared_income)
%       scrollsubplot(3,1,2), plot(tax)
%       scrollsubplot(3,1,3), plot(net_income)
%       scrollsubplot(3,1,4), plot(the_little_extra)
% 
%   plots declared_income on the top third of the window, tax in
%   the middle, and the net_income in the bottom third. Above the
%   top of the figure income is ploted and below the lower edge
%   the_little_extra is to be found. To navigate there is a slider
%   along the right figure edge.
% 
%   SCROLLSUBPLOT now also work with less regular subplot-layouts:
%
%   axs3(1) = scrollsubplot(3,3,1);
%   axs3(2) = scrollsubplot(3,3,3);
%   axs3(3) = scrollsubplot(3,3,[4,7]);
%   axs3(4) = scrollsubplot(3,3,5);
%   axs3(5) = scrollsubplot(3,3,[3,6]);
%   axs3(6) = scrollsubplot(3,3,10);
%   axs3(7) = scrollsubplot(3,3,[8,9,11,12]);
%   axs3(8) = scrollsubplot(3,3,[13,14,15]);
%   for i1 = 1:8,
%     if ishandle(axs3(i1))
%       axes(axs3(i1))
%       imagesc(randn(2+3*i1))
%     end
%   end
%
%   The function works well for regular grids where m,n is constant
%   for all p. When m,n varies there is no guarantee that the steps
%   of the slider is nicely adjusted to the sizes of the
%   subplots, further the slider also responds to mouse-wheel scrolling.
%
%   Differences with SUBPLOT: SCROLLSUBPLOT requires 3 input
%   arguments, no compatibility with subplot(323), no handle as
%   input. Further  PERC_OFFSET_L is decreased from 2*0.09 to 0.07
%   and PERC_OFFSET_R is decreased from 2*0.045 to 0.085. This
%   leaves less space for titles and labels, but give a plaid grid
%   of subplots even outside the visible figure area.
%   
%   Bug/feature when the slider is shifted from its initial
%   position and then extra subplots is added, they get
%   mis-positioned.
%   
%   See also SUBPLOT,

%   Copyright © Bjorn Gustavsson 20050526-2014, Modification/extension of
%   Mathworks subplot.
%   Version 2, modified from version 1 in that scroll now is a subfunction,
%   together with 

persistent maxrownr minrownr

%%% This is a matlab bug(?) that blanks axes that have been rescaled to
%%% accomodate a colorbar. I've not tried to fix it. BG
% we will kill all overlapping siblings if we encounter the mnp
% specifier, else we won't bother to check:
narg = nargin;
% kill_siblings = 0;
create_axis = 1;
delay_destroy = 0;
tol = sqrt(eps);
if narg ~= 3 % not compatible with 3.5, i.e. subplot ==
             % subplot(111) errors out
  error('Wrong number of arguments')
end

%check for encoded format
handle = '';
position = '';

kill_siblings = 1;

% if we recovered an identifier earlier, use it:
if(~isempty(handle))
  
  set(get(0,'CurrentFigure'),'CurrentAxes',handle);
  
elseif(isempty(position))
  % if we haven't recovered position yet, generate it from mnp info:
  if (min(thisPlot) < 1)&&0 % negative Thisplot corresponds to
                            % panels above top row, that is OK
    error('Illegal plot number.')
  else
    % This is the percent offset from the subplot grid of the plotbox.
    PERC_OFFSET_L = 0.07;
    PERC_OFFSET_R = 0.085;
    PERC_OFFSET_B = PERC_OFFSET_L;
    PERC_OFFSET_T = PERC_OFFSET_R;
    if nrows > 2
      PERC_OFFSET_T = 1.1*PERC_OFFSET_T;
      PERC_OFFSET_B = 1.4*PERC_OFFSET_B;
    end
    if ncols > 2
      PERC_OFFSET_L = 0.9*PERC_OFFSET_L;
      PERC_OFFSET_R = 0.9*PERC_OFFSET_R;
    end

    % Subplots version:
    % row = (nrows-1) -fix((thisPlot-1)/ncols)
    % col = rem (thisPlot-1, ncols);
    % Slightly modified to allow for having negative thisPlot
    row = (nrows-1) -floor((thisPlot-1)/ncols);
    col = mod (thisPlot-1, ncols);
    
    % From here on to line 190 essentially identical to SUBPLOT (==untouched)
    
    % For this to work the default axes position must be in normalized coordinates
    if ~strcmp(get(gcf,'defaultaxesunits'),'normalized')
      warning('DefaultAxesUnits not normalized.')
      tmp = axes;
      set(axes,'units','normalized')
      def_pos = get(tmp,'position');
      delete(tmp)
    else
      def_pos = get(gcf,'DefaultAxesPosition')+[-.05 -.05 +.1 +.05];
    end
    col_offset = def_pos(3)*(PERC_OFFSET_L+PERC_OFFSET_R)/ ...
	(ncols-PERC_OFFSET_L-PERC_OFFSET_R);
    row_offset = def_pos(4)*(PERC_OFFSET_B+PERC_OFFSET_T)/ ...
	(nrows-PERC_OFFSET_B-PERC_OFFSET_T);
    totalwidth = def_pos(3) + col_offset;
    totalheight = def_pos(4) + row_offset;
    width = totalwidth/ncols*(max(col)-min(col)+1)-col_offset;
    height = totalheight/nrows*(max(row)-min(row)+1)-row_offset;
    position = [def_pos(1)+min(col)*totalwidth/ncols ...
		def_pos(2)+min(row)*totalheight/nrows ...
		width height];
    if width <= 0.5*totalwidth/ncols
      position(1) = def_pos(1)+min(col)*(def_pos(3)/ncols);
      position(3) = 0.7*(def_pos(3)/ncols)*(max(col)-min(col)+1);
    end
    if height <= 0.5*totalheight/nrows
      position(2) = def_pos(2)+min(row)*(def_pos(4)/nrows);
      position(4) = 0.7*(def_pos(4)/nrows)*(max(row)-min(row)+1);
    end
  end
end

% kill overlapping siblings if mnp specifier was used:
nextstate = get(gcf,'nextplot');
if strncmp(nextstate,'replace',7), nextstate = 'add'; end
if(kill_siblings)
  if delay_destroy
    if nargout %#ok<UNRCH>
      error('Function called with too many output arguments')
    else
      set(gcf,'NextPlot','replace'); return,
    end
  end
  sibs = get(gcf, 'Children');
  got_one = 0;
  for i1 = 1:length(sibs)
    if(strcmp(get(sibs(i1),'Type'),'axes'))
      units = get(sibs(i1),'Units');
      set(sibs(i1),'Units','normalized')
      sibpos = get(sibs(i1),'Position');
      set(sibs(i1),'Units',units);
      intersect = 1;
      if(     (position(1) >= sibpos(1) + sibpos(3)-tol) || ...
	      (sibpos(1) >= position(1) + position(3)-tol) || ...
	      (position(2) >= sibpos(2) + sibpos(4)-tol) || ...
	      (sibpos(2) >= position(2) + position(4)-tol))
	intersect = 0;
      end
      if intersect
	if got_one || any(abs(sibpos - position) > tol)
	  delete(sibs(i1));
	else
	  got_one = 1;
	  set(gcf,'CurrentAxes',sibs(i1));
	  if strcmp(nextstate,'new')
	    create_axis = 1;
	  else
	    create_axis = 0;
	  end
	end
      end
    end
  end
  set(gcf,'NextPlot',nextstate);
end

% create the axis:
if create_axis
  if strcmp(nextstate,'new'), figure, end
  ax = axes('units','normal','Position', position);
  set(ax,'units',get(gcf,'defaultaxesunits'))
else 
  ax = gca; 
end


% return identifier, if requested:
if(nargout > 0)
  theAxis = ax;
end

%% SCROLLSUBPLOT modification part
%
% From here on out set up scrollbar if needed
scroll_hndl = findall(gcf,'Type','uicontrol','Tag','scroll');

ax_indx = findall(gcf,'Type','axes');

if length(ax_indx)==1
  maxrownr = -inf;
  minrownr = inf;
end

%% This is setting up the scroll-slider (invisible)
if isempty(scroll_hndl)
  uicontrol('Units','normalized',...
            'Style','Slider',...
            'Position',[.98,0,.02,1],...
            'Min',0,...
            'Max',1,...
            'Value',1,...
            'visible','off',...
            'Tag','scroll',...
            'Callback',@(scr,event) scroll(1));
  set(gcf,'WindowScrollWheelFcn',@wheelScroll)      
end
% making it visible when needed
if ( nrows*ncols < thisPlot || thisPlot < 1 )
  set(scroll_hndl,'visible','on')
end
scroll(1)


maxrownr = max(maxrownr(:),max(-row(:)));
minrownr = min(minrownr(:),min(-row(:)));

% Adjust the slider step-sizes to account for the number of rows of
% subplots: 
set(scroll_hndl,...
    'sliderstep',[1/nrows 1]./0.8)
%     'sliderstep',[1/nrows
%     1]/(1/((nrows)/max(1,1+maxrownr(:)-minrownr(:)-nrows))))   ORIGINAL
set(scroll_hndl,...
    'value',1)

   function scroll(old_val)
   % SCROLL - Scroll subplots vertically
   %   Used by scrollsubplot.
   % Calling:
   %   scroll(old_val)
   % Set as callback function handle:
   %   
   %   See also SCROLLSUBPLOT
   
   % Copyright Bjorn Gustavsson 20050526
   % Version 2, modified to become a subfunction of scrollsubplot.
   
   %% Scroll the subplot axeses
   %  That is change their position some number of steps up or down
   
   % Get the handle of the scroll-slider handle and all the handle
   % to all the subplot axes
   clbk_ui_hndl = findall(gcf,'Type','uicontrol','Tag','scroll');
   ax_hndl = findall(gcf,'Type','axes');
   
   for i2 = length(ax_hndl):-1:1
     a_pos(i2,:) = get(ax_hndl(i2),'position');
   end
   
   pos_y_range = [min(.07,min(a_pos(:,2))) max(a_pos(:,2) + a_pos(:,4) )+.07-.9];
   
   val = get(clbk_ui_hndl,'value');
   step = ( old_val - val) * diff(pos_y_range);
   
   
   for i2 = 1:length(ax_hndl)
     set(ax_hndl(i2),'position',get(ax_hndl(i2),'position') + [0 step 0 0]);
   end
   
   set(clbk_ui_hndl,'callback',@(scr,event) scroll(val));
   
   end % end scroll

   function wheelScroll(src,evnt) %#ok<INUSL>
   % wheelScroll - mouse-wheel wrapper to scroll-function
   % Calling:
   %   wheelScroll(src,evnt)
   % Set as calback
   %   set(gcf,'WindowScrollWheelFcn',@wheelScroll)
   try
     C = findobj(gcf,'type','uicontrol');
     MaxVal = get(C,'Max');%  = [1]
	 minval = get(C,'Min');% = [0]
	 sliderstep = get(C,'SliderStep'); % = [0.0555556 0.222222]
     oldval = get(C,'value');
     if evnt.VerticalScrollCount > 0 
       set(C,'value',max(minval,oldval-sliderstep(1)/10))
     elseif evnt.VerticalScrollCount < 0 
       set(C,'value',min(MaxVal,oldval+sliderstep(1)/10))
     end
     scroll(oldval)
   catch
   end
   end %wheelScroll

end

function [FY_FIT] = Pacejka2012_FY(FY,SA,FZ_AVG,P_AVG,IA_AVG,FZ_CLASS,P_CLASS,IA_CLASS,SWEEPS_NUM,SWEEP_STARTS,SWEEP_ENDS,Length)
% fitting a Pacejka tire model
    
% global maincoeffs;

    for i = 1:SWEEPS_NUM
        
        %% Do some initial fitting with only the main variables that have
        %%% some real world significance
        
        SWEEP_SA = SA(SWEEP_STARTS(i):SWEEP_ENDS(i));
        SWEEP_FY = FY(SWEEP_STARTS(i):SWEEP_ENDS(i));
       
                % find some known initial values
        % Dy
        maxFYindx = find(SWEEP_FY>(max(SWEEP_FY)*.95),1);
        Dy = SWEEP_FY(maxFYindx); % max force
        
        % Cy
        % crude horiz asymptote
        ya = 0.95*mean([abs(SWEEP_FY(find(SWEEP_SA==max(SWEEP_SA),1))) abs(SWEEP_FY(find(SWEEP_SA==min(SWEEP_SA), 1)))]);
        Cy = 1 + (1 - (2/pi).*asin(ya/Dy));
        
        % By
        linearPoints = intersect(find(SWEEP_SA>-1),find(SWEEP_SA<1)); % find the indices of the linear part of SA v FY
        corneringStiffness = fit(SWEEP_SA(linearPoints),SWEEP_FY(linearPoints),'poly1'); % fit a first degree poly to find slope
        By = corneringStiffness(1)./(Cy*Dy); % BCD = slope
        
        % Ey
        xm = SWEEP_SA(maxFYindx); % SA of max force
        Ey = (By.*xm - tan(pi./(2*Cy)))./(By.*xm - atan(By.*xm));
        
        % SVy
        SVy = 0;
        
        % SHy
        SHy = 0;
        
        x0simple = [Dy Cy By Ey SVy SHy];
        
        
        % fit data to simple model
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',3000);
        simpleFit = lsqnonlin(@simplePacejkaDiff,x0simple,[],[],options,SWEEP_SA,SWEEP_FY);
        FY_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)) = simpleFit(1).*sin(simpleFit(2).*atan(simpleFit(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + simpleFit(6)) - simpleFit(4).*(simpleFit(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+simpleFit(6)) - atan(simpleFit(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+simpleFit(6)))))) + simpleFit(5);
        
        
%         %%  move to fitting the more complex model without the full Kya
% 
%         
%         Fzo = FZ_CLASS(i); % nominal FZ
%         dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
%         pio = (P_CLASS(i)*6.89476); % nominal P
%         dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
%         
%         % model we fit to, stored in another function
% % %       Dy = uy*FZ
% % %       Cy = pCy
% % %       By = Kya/(Cy+Dy + ey)
% % %       Ey = (pEy1 + pEy2*dfz)(1 + pEy5*IA^2 - sgn(SA)*(pEy3 + pEy4*IA))
% % %       SVy = FZ*(pVy1 + pVy2*dfz) + SVyy
% % %       SHy = (pHy1 + pHy2*dfz) + (Kyyo*IA-SVyy)/(Kya+eK) - 1
%         
%         % create array of ones for inital points 
%         x0 = ones(23,1);
%         
%         % use old fitting data to find initial values to try and put the
%         % function in the area of the global minima
%         x0(1) = (simpleFit(1)./FZ_AVG(i)).^(1./4)./2;
%         x0(2) = (simpleFit(1)./FZ_AVG(i)).^(1./4)./2./dfz;
%         x0(3) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)-1)./2./dpi;
%         x0(4) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)-1)./2./(dpi.^2);
%         x0(5) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)+1)./(IA_AVG(i).^2);
%         
%         x0(6) = simpleFit(2);
%         x0(7) = simpleFit(3).*simpleFit(2).*simpleFit(1);
%         
%         x0(9) = simpleFit(4)^(1/2)/2;
%         x0(10) = simpleFit(4)^(1/2)/2/dfz;
%         x0(11) = (simpleFit(4)^(1/2)-1)/2/(IA_AVG(i)^2);
%         
%         x0(14) = simpleFit(5)/2/FZ_AVG(i)/IA_AVG(i)/2;
%         x0(15) = simpleFit(5)/2/FZ_AVG(i)/IA_AVG(i)/2/dfz;
%         x0(16) = simpleFit(5)/2/FZ_AVG(i);
%         x0(17) = simpleFit(5)/2/FZ_AVG(i)/dfz;
%         
%         x0(18) = ((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)./2;
%         x0(19) = ((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)./2./dfz;
%         x0(20) = (((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)-1)./dpi;
%         x0(21) = (simpleFit(6)+1)./2./2;
%         x0(22) = (simpleFit(6)+1)./2./2./dfz;
%         
% %         x0 = real(x0);
%         
%         % fit data to the complex model without the full Kya eqn
%         lsqfcn = @(x0)fullPacejkaDiff(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
%         options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
%         Pfit.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
%             'pCy1', 'Kya',...
%             'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
%             'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
%         Pfit.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
%         Pcurve(SWEEP_STARTS(i):SWEEP_ENDS(i)) = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + maincoeffs(7)) - (maincoeffs(4)-sign(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))).*maincoeffs(5)).*(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)) - atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)))))) + maincoeffs(6);
%         
%         Pfit.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
%         Pfit.vals.main = maincoeffs;
        

%         %% fit
%         x0 = ones(29,1);
%         x0(1:6) = Pfit.vals.all(1:6);
%         x0(7) = (Pfit.vals.all(7)/Fzo)^(1/3);
%         x0(8) = (((Pfit.vals.all(7)/Fzo)^(1/3)-1)/dpi);
%         x0(9) = (((Pfit.vals.all(7)/Fzo)^(1/3)+1)/abs(IA_AVG(i)));
%         x0(10) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(11) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(12) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(13) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(14:29) = Pfit.vals.all(8:23);
%         
% %         x0 = real(x0);
%         
%         lsqfcn = @(x)fullPacejkaDiff2(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
%         options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
%         Pfit2.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
%             'pCy1', 'pKy1', 'ppy1', 'pKy3', 'pKy4', 'pKy2', 'pKy5', 'ppy2',...
%             'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
%             'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
%         Pfit2.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
%         Pcurve(SWEEP_STARTS(i):SWEEP_ENDS(i)) = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + maincoeffs(7)) - (maincoeffs(4)-sign(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))).*maincoeffs(5)).*(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)) - atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)))))) + maincoeffs(6);
%         
%         Pfit2.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
%         Pfit2.vals.main = maincoeffs;

    end
end

function diff = simplePacejkaDiff(x0simple,ya,SWEEP_FY)
    % define your normal variables in terms of x(n)
    Dy = x0simple(1);
    Cy = x0simple(2);
    By = x0simple(3);
    Ey = x0simple(4);
    SVy = x0simple(5);
    SHy = x0simple(6);
    
    % Pacejka fitting model - real FY
    diff = Dy*sin(Cy*atan(By.*(ya+SHy) - Ey*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy - SWEEP_FY;
end

function diff = fullPacejkaDiff(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    PacejkaFY1 = Pacejka_eqn_noKya(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
    
    diff = PacejkaFY1 - SWEEP_FY;
end

function diff = fullPacejkaDiff2(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    PacejkaFY2 = Pacejka_fulleqn(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
    
    diff = PacejkaFY2 - SWEEP_FY;
end

function PacejkaFY1 = Pacejka_eqn_noKya(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    
        Fzo = FZ_CLASS(i); % nominal FZ
        dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
        pio = (P_CLASS(i)*6.89476); % nominal P
        dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = x0(1);
    pDy2 = x0(2);
    ppy3 = x0(3);
    ppy4 = x0(4);
    pDy3 = x0(5);
    
    % Cy
    pCy1 = x0(6);
    
    Kya  = x0(7); % begin with it set as By*Cy*Dy
    
    % By
    ey   = x0(8);
    
    % Ey1
    pEy1 = x0(9);
    pEy2 = x0(10);
    pEy5 = x0(11);
    % Ey2
    pEy3 = x0(12);
    pEy4 = x0(13);
    
    % SVyy
    pVy3 = x0(14);
    pVy4 = x0(15);
    % SVy
    pVy1 = x0(16);
    pVy2 = x0(17);
    
    % Kyyo
    pKy6 = x0(18);
    pKy7 = x0(19);
    ppy5 = x0(20);
    % SHy
    pHy1 = x0(21);
    pHy2 = x0(22);
    eK   = x0(23);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2.*dfz).*(1 + ppy3.*dpi + ppy4.*(dpi.^2)).*(1 - pDy3.*(IA_CLASS(i).^2));
    Dy = uy.*FZ_CLASS(i);
    
    Cy = pCy1;
    
    By = Kya./(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2.*dfz + (pEy1 + pEy2.*dfz).*pEy5.*IA_CLASS(i).^2;
    Ey2 = (pEy1 + pEy2.*dfz).*(pEy3 + pEy4.*IA_CLASS(i));
    
    SVyy = FZ_CLASS(i).*(pVy3 + pVy4.*dfz).*IA_CLASS(i);
    SVy = FZ_CLASS(i).*(pVy1 + pVy2.*dfz) + SVyy;
    
    Kyyo = FZ_CLASS(i).*(pKy6 + pKy7.*dfz).*(1 + ppy5.*dpi);
    SHy = (pHy1 + pHy2.*dfz) + (Kyyo.*IA_CLASS(i)-SVyy)./(Kya+eK) - 1;
    
    disp(Dy)
    disp(Cy)
    disp(By)
    disp(Ey1)
    disp(Ey2)
    disp(SVy)
    disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
  PacejkaFY1 = Dy.*sin(Cy.*atan(By.*(ya+SHy) - (Ey1-sign(ya).*Ey2).*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy;
end

function PacejkaFY2 = Pacejka_fulleqn(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
   
Fzo = FZ_CLASS(i); % nominal FZ
dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
pio = (P_CLASS(i)*6.89476); % nominal P
dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = x0(1);
    pDy2 = x0(2);
    ppy3 = x0(3);
    ppy4 = x0(4);
    pDy3 = x0(5);
    
    % Cy
    pCy1 = x0(6);
    
    % coeffs that belong to Kya
    pKy1 = x0(7);
    ppy1 = x0(8);
    pKy3 = x0(9);
    pKy4 = x0(10);
    pKy2 = x0(11);
    pKy5 = x0(12);
    ppy2 = x0(13);
    %
    % By
    ey   = x0(14);
    
    % Ey1
    pEy1 = x0(15);
    pEy2 = x0(16);
    pEy5 = x0(17);
    % Ey2
    pEy3 = x0(18);
    pEy4 = x0(19);
    
    % SVyy
    pVy3 = x0(20);
    pVy4 = x0(21);
    % SVy
    pVy1 = x0(22);
    pVy2 = x0(23);
    
    % Kyyo
    pKy6 = x0(24);
    pKy7 = x0(25);
    ppy5 = x0(26);
    % SHy
    pHy1 = x0(27);
    pHy2 = x0(28);
    eK   = x0(29);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2.*dfz).*(1 + ppy3.*dpi + ppy4.*(dpi^2)).*(1 - pDy3.*(IA_CLASS(i).^2));
    Dy = uy.*FZ_CLASS(i);
    
    Cy = pCy1;
    
    Kya = pKy1.*Fzo.*(1 + ppy1.*dpi)*(1 - pKy3.*abs(IA_CLASS(i))).*sin(pKy4.*atan((FZ_CLASS(i)./Fzo)./((pKy2 + pKy5.*IA_CLASS(i).^2)*(1 + ppy2.*dpi))));
    By = Kya./(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2.*dfz + (pEy1 + pEy2.*dfz)*pEy5.*IA_CLASS(i).^2;
    Ey2 = (pEy1 + pEy2.*dfz).*(pEy3 + pEy4.*IA_CLASS(i));
    
    SVyy = FZ_CLASS(i).*(pVy3 + pVy4.*dfz).*IA_CLASS(i);
    SVy = FZ_CLASS(i).*(pVy1 + pVy2.*dfz) + SVyy;
    
    Kyyo = FZ_CLASS(i).*(pKy6 + pKy7.*dfz)*(1 + ppy5.*dpi);
    SHy = (pHy1 + pHy2.*dfz) + (Kyyo.*IA_CLASS(i)-SVyy)./(Kya+eK) - 1;
    
%     disp(Dy)
%     disp(Cy)
%     disp(By)
%     disp(Ey1)
%     disp(Ey2)
%     disp(SVy)
%     disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
    PacejkaFY2 = Dy.*sin(Cy.*atan(By.*(ya+SHy) - (Ey1-sign(ya).*Ey2).*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy;
end

function [MZ_FIT] = Pacejka2012_MZ(MZ,SA,FZ_AVG,P_AVG,IA_AVG,FZ_CLASS,P_CLASS,IA_CLASS,SWEEPS_NUM,SWEEP_STARTS,SWEEP_ENDS,Length)
% fitting a Pacejka tire model
    
% global maincoeffs;

    for i = 1:SWEEPS_NUM
        
        %% Do some initial fitting with only the main variables that have
        %%% some real world significance
        
        SWEEP_SA = SA(SWEEP_STARTS(i):SWEEP_ENDS(i));
        SWEEP_MZ = MZ(SWEEP_STARTS(i):SWEEP_ENDS(i));
       
                % find some known initial values
        % Dy
        maxMZindx = find(SWEEP_MZ>(max(SWEEP_MZ)*.95),1);
        Dy = SWEEP_MZ(maxMZindx); % max force
        
        % Cy
        % crude horiz asymptote
        ya = 0.95*mean([abs(SWEEP_MZ(find(SWEEP_SA==max(SWEEP_SA),1))) abs(SWEEP_MZ(find(SWEEP_SA==min(SWEEP_SA), 1)))]);
        Cy = 1 + (1 - (2/pi).*asin(ya/Dy));
        
        % By
        linearPoints = intersect(find(SWEEP_SA>-1),find(SWEEP_SA<1)); % find the indices of the linear part of SA v FY
        corneringStiffness = fit(SWEEP_SA(linearPoints),SWEEP_MZ(linearPoints),'poly1'); % fit a first degree poly to find slope
        By = corneringStiffness(1)./(Cy*Dy); % BCD = slope
        
        % Ey
        xm = SWEEP_SA(maxMZindx); % SA of max force
        Ey = (By.*xm - tan(pi/(2*Cy)))./(By.*xm - atan(By.*xm));
        
        % SVy
        SVy = 0;
        
        % SHy
        SHy = 0;
        
        x0simple = [Dy Cy By Ey SVy SHy];
        
        
        % fit data to simple model
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',3000);
        simpleFit = lsqnonlin(@simplePacejkaDiffMZ,x0simple,[],[],options,SWEEP_SA,SWEEP_MZ);
        MZ_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)) = simpleFit(1).*sin(simpleFit(2).*atan(simpleFit(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + simpleFit(6)) - simpleFit(4).*(simpleFit(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+simpleFit(6)) - atan(simpleFit(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+simpleFit(6)))))) + simpleFit(5);
        
        
%         %%  move to fitting the more complex model without the full Kya
% 
%         
%         Fzo = FZ_CLASS(i); % nominal FZ
%         dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
%         pio = (P_CLASS(i)*6.89476); % nominal P
%         dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
%         
%         % model we fit to, stored in another function
% % %       Dy = uy*FZ
% % %       Cy = pCy
% % %       By = Kya/(Cy+Dy + ey)
% % %       Ey = (pEy1 + pEy2*dfz)(1 + pEy5*IA^2 - sgn(SA)*(pEy3 + pEy4*IA))
% % %       SVy = FZ*(pVy1 + pVy2*dfz) + SVyy
% % %       SHy = (pHy1 + pHy2*dfz) + (Kyyo*IA-SVyy)/(Kya+eK) - 1
%         
%         % create array of ones for inital points 
%         x0 = ones(23,1);
%         
%         % use old fitting data to find initial values to try and put the
%         % function in the area of the global minima
%         x0(1) = (simpleFit(1)./FZ_AVG(i)).^(1./4)./2;
%         x0(2) = (simpleFit(1)./FZ_AVG(i)).^(1./4)./2./dfz;
%         x0(3) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)-1)./2./dpi;
%         x0(4) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)-1)./2./(dpi.^2);
%         x0(5) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)+1)./(IA_AVG(i).^2);
%         
%         x0(6) = simpleFit(2);
%         x0(7) = simpleFit(3).*simpleFit(2).*simpleFit(1);
%         
%         x0(9) = simpleFit(4)^(1/2)/2;
%         x0(10) = simpleFit(4)^(1/2)/2/dfz;
%         x0(11) = (simpleFit(4)^(1/2)-1)/2/(IA_AVG(i)^2);
%         
%         x0(14) = simpleFit(5)/2/FZ_AVG(i)/IA_AVG(i)/2;
%         x0(15) = simpleFit(5)/2/FZ_AVG(i)/IA_AVG(i)/2/dfz;
%         x0(16) = simpleFit(5)/2/FZ_AVG(i);
%         x0(17) = simpleFit(5)/2/FZ_AVG(i)/dfz;
%         
%         x0(18) = ((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)./2;
%         x0(19) = ((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)./2./dfz;
%         x0(20) = (((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)-1)./dpi;
%         x0(21) = (simpleFit(6)+1)./2./2;
%         x0(22) = (simpleFit(6)+1)./2./2./dfz;
%         
% %         x0 = real(x0);
%         
%         % fit data to the complex model without the full Kya eqn
%         lsqfcn = @(x0)fullPacejkaDiff(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
%         options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
%         Pfit.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
%             'pCy1', 'Kya',...
%             'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
%             'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
%         Pfit.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
%         Pcurve(SWEEP_STARTS(i):SWEEP_ENDS(i)) = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + maincoeffs(7)) - (maincoeffs(4)-sign(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))).*maincoeffs(5)).*(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)) - atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)))))) + maincoeffs(6);
%         
%         Pfit.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
%         Pfit.vals.main = maincoeffs;
        

%         %% fit
%         x0 = ones(29,1);
%         x0(1:6) = Pfit.vals.all(1:6);
%         x0(7) = (Pfit.vals.all(7)/Fzo)^(1/3);
%         x0(8) = (((Pfit.vals.all(7)/Fzo)^(1/3)-1)/dpi);
%         x0(9) = (((Pfit.vals.all(7)/Fzo)^(1/3)+1)/abs(IA_AVG(i)));
%         x0(10) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(11) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(12) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(13) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(14:29) = Pfit.vals.all(8:23);
%         
% %         x0 = real(x0);
%         
%         lsqfcn = @(x)fullPacejkaDiff2(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
%         options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
%         Pfit2.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
%             'pCy1', 'pKy1', 'ppy1', 'pKy3', 'pKy4', 'pKy2', 'pKy5', 'ppy2',...
%             'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
%             'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
%         Pfit2.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
%         Pcurve(SWEEP_STARTS(i):SWEEP_ENDS(i)) = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + maincoeffs(7)) - (maincoeffs(4)-sign(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))).*maincoeffs(5)).*(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)) - atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)))))) + maincoeffs(6);
%         
%         Pfit2.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
%         Pfit2.vals.main = maincoeffs;

    end
end

function diff = simplePacejkaDiffMZ(x0simple,ya,SWEEP_MZ)
    % define your normal variables in terms of x(n)
    Dy = x0simple(1);
    Cy = x0simple(2);
    By = x0simple(3);
    Ey = x0simple(4);
    SVy = x0simple(5);
    SHy = x0simple(6);
    
    % Pacejka fitting model - real FY
    diff = Dy*sin(Cy*atan(By.*(ya+SHy) - Ey*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy - SWEEP_MZ;
end

function diff = fullPacejkaDiffMZ(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    PacejkaFY1 = Pacejka_eqn_noKya(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
    
    diff = PacejkaFY1 - SWEEP_FY;
end

function diff = fullPacejkaDiff2MZ(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    PacejkaFY2 = Pacejka_fulleqn(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
    
    diff = PacejkaFY2 - SWEEP_FY;
end

function PacejkaMZ1 = Pacejka_eqn_noKyaMZ(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    
        Fzo = FZ_CLASS(i); % nominal FZ
        dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
        pio = (P_CLASS(i)*6.89476); % nominal P
        dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = x0(1);
    pDy2 = x0(2);
    ppy3 = x0(3);
    ppy4 = x0(4);
    pDy3 = x0(5);
    
    % Cy
    pCy1 = x0(6);
    
    Kya  = x0(7); % begin with it set as By*Cy*Dy
    
    % By
    ey   = x0(8);
    
    % Ey1
    pEy1 = x0(9);
    pEy2 = x0(10);
    pEy5 = x0(11);
    % Ey2
    pEy3 = x0(12);
    pEy4 = x0(13);
    
    % SVyy
    pVy3 = x0(14);
    pVy4 = x0(15);
    % SVy
    pVy1 = x0(16);
    pVy2 = x0(17);
    
    % Kyyo
    pKy6 = x0(18);
    pKy7 = x0(19);
    ppy5 = x0(20);
    % SHy
    pHy1 = x0(21);
    pHy2 = x0(22);
    eK   = x0(23);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2.*dfz).*(1 + ppy3.*dpi + ppy4.*(dpi.^2)).*(1 - pDy3.*(IA_CLASS(i).^2));
    Dy = uy.*FZ_CLASS(i);
    
    Cy = pCy1;
    
    By = Kya./(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2.*dfz + (pEy1 + pEy2.*dfz).*pEy5.*IA_CLASS(i).^2;
    Ey2 = (pEy1 + pEy2.*dfz).*(pEy3 + pEy4.*IA_CLASS(i));
    
    SVyy = FZ_CLASS(i).*(pVy3 + pVy4.*dfz).*IA_CLASS(i);
    SVy = FZ_CLASS(i).*(pVy1 + pVy2.*dfz) + SVyy;
    
    Kyyo = FZ_CLASS(i).*(pKy6 + pKy7.*dfz).*(1 + ppy5.*dpi);
    SHy = (pHy1 + pHy2.*dfz) + (Kyyo.*IA_CLASS(i)-SVyy)./(Kya+eK) - 1;
    
    disp(Dy)
    disp(Cy)
    disp(By)
    disp(Ey1)
    disp(Ey2)
    disp(SVy)
    disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
  PacejkaFY1 = Dy.*sin(Cy.*atan(By.*(ya+SHy) - (Ey1-sign(ya).*Ey2).*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy;
end

function PacejkaMZ2 = Pacejka_fulleqnMZ(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
   
Fzo = FZ_CLASS(i); % nominal FZ
dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
pio = (P_CLASS(i)*6.89476); % nominal P
dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = x0(1);
    pDy2 = x0(2);
    ppy3 = x0(3);
    ppy4 = x0(4);
    pDy3 = x0(5);
    
    % Cy
    pCy1 = x0(6);
    
    % coeffs that belong to Kya
    pKy1 = x0(7);
    ppy1 = x0(8);
    pKy3 = x0(9);
    pKy4 = x0(10);
    pKy2 = x0(11);
    pKy5 = x0(12);
    ppy2 = x0(13);
    %
    % By
    ey   = x0(14);
    
    % Ey1
    pEy1 = x0(15);
    pEy2 = x0(16);
    pEy5 = x0(17);
    % Ey2
    pEy3 = x0(18);
    pEy4 = x0(19);
    
    % SVyy
    pVy3 = x0(20);
    pVy4 = x0(21);
    % SVy
    pVy1 = x0(22);
    pVy2 = x0(23);
    
    % Kyyo
    pKy6 = x0(24);
    pKy7 = x0(25);
    ppy5 = x0(26);
    % SHy
    pHy1 = x0(27);
    pHy2 = x0(28);
    eK   = x0(29);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2.*dfz).*(1 + ppy3.*dpi + ppy4.*(dpi^2)).*(1 - pDy3.*(IA_CLASS(i).^2));
    Dy = uy.*FZ_CLASS(i);
    
    Cy = pCy1;
    
    Kya = pKy1.*Fzo.*(1 + ppy1.*dpi)*(1 - pKy3.*abs(IA_CLASS(i))).*sin(pKy4.*atan((FZ_CLASS(i)./Fzo)./((pKy2 + pKy5.*IA_CLASS(i).^2)*(1 + ppy2.*dpi))));
    By = Kya./(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2.*dfz + (pEy1 + pEy2.*dfz)*pEy5.*IA_CLASS(i).^2;
    Ey2 = (pEy1 + pEy2.*dfz).*(pEy3 + pEy4.*IA_CLASS(i));
    
    SVyy = FZ_CLASS(i).*(pVy3 + pVy4.*dfz).*IA_CLASS(i);
    SVy = FZ_CLASS(i).*(pVy1 + pVy2.*dfz) + SVyy;
    
    Kyyo = FZ_CLASS(i).*(pKy6 + pKy7.*dfz)*(1 + ppy5.*dpi);
    SHy = (pHy1 + pHy2.*dfz) + (Kyyo.*IA_CLASS(i)-SVyy)./(Kya+eK) - 1;
    
%     disp(Dy)
%     disp(Cy)
%     disp(By)
%     disp(Ey1)
%     disp(Ey2)
%     disp(SVy)
%     disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
    PacejkaFY2 = Dy.*sin(Cy.*atan(By.*(ya+SHy) - (Ey1-sign(ya).*Ey2).*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy;
end

function [FX_FIT] = Pacejka2012_FX(FX,SR,FZ_AVG,P_AVG,IA_AVG,FZ_CLASS,P_CLASS,IA_CLASS,SWEEPS_NUM,SWEEP_STARTS,SWEEP_ENDS,Length)
% fitting a Pacejka tire model
    
% global maincoeffs;

    for i = 1:SWEEPS_NUM
        
        %% Do some initial fitting with only the main variables that have
        %%% some real world significance
        
        SWEEP_SR = SR(SWEEP_STARTS(i):SWEEP_ENDS(i));
        SWEEP_FX = FX(SWEEP_STARTS(i):SWEEP_ENDS(i));
       
                % find some known initial values
        % Dy
        maxFXindx = find(SWEEP_FX>(max(SWEEP_FX)*.95),1);
        Dy = SWEEP_FX(maxFXindx); % max force
        
        % Cy
        % crude horiz asymptote
        ya = 0.95*mean([abs(SWEEP_FX(find(SWEEP_SR==max(SWEEP_SR),1))) abs(SWEEP_FX(find(SWEEP_SR==min(SWEEP_SR), 1)))]);
        Cy = 1 + (1 - (2/pi).*asin(ya/Dy));
        
        % By
        linearPoints = intersect(find(SWEEP_SR>-1),find(SWEEP_SR<1)); % find the indices of the linear part of SA v FY
        corneringStiffness = fit(SWEEP_SR(linearPoints),SWEEP_FX(linearPoints),'poly1'); % fit a first degree poly to find slope
        By = corneringStiffness(1)./(Cy*Dy); % BCD = slope
        
        % Ey
        xm = SWEEP_SR(maxFXindx); % SA of max force
        Ey = (By.*xm - tan(pi/(2*Cy)))./(By.*xm - atan(By.*xm));
        
        % SVy
        SVy = 0;
        
        % SHy
        SHy = 0;
        
        x0simple = [Dy Cy By Ey SVy SHy];
        
        
        % fit data to simple model
        options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',3000);
        simpleFit = lsqnonlin(@simplePacejkaDiffFX,x0simple,[],[],options,SWEEP_SR,SWEEP_FX);
        FX_FIT(SWEEP_STARTS(i):SWEEP_ENDS(i)) = simpleFit(1).*sin(simpleFit(2).*atan(simpleFit(3).*(SR(SWEEP_STARTS(i):SWEEP_ENDS(i)) + simpleFit(6)) - simpleFit(4).*(simpleFit(3).*(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))+simpleFit(6)) - atan(simpleFit(3).*(SR(SWEEP_STARTS(i):SWEEP_ENDS(i))+simpleFit(6)))))) + simpleFit(5);
        
        
%         %%  move to fitting the more complex model without the full Kya
% 
%         
%         Fzo = FZ_CLASS(i); % nominal FZ
%         dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
%         pio = (P_CLASS(i)*6.89476); % nominal P
%         dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
%         
%         % model we fit to, stored in another function
% % %       Dy = uy*FZ
% % %       Cy = pCy
% % %       By = Kya/(Cy+Dy + ey)
% % %       Ey = (pEy1 + pEy2*dfz)(1 + pEy5*IA^2 - sgn(SA)*(pEy3 + pEy4*IA))
% % %       SVy = FZ*(pVy1 + pVy2*dfz) + SVyy
% % %       SHy = (pHy1 + pHy2*dfz) + (Kyyo*IA-SVyy)/(Kya+eK) - 1
%         
%         % create array of ones for inital points 
%         x0 = ones(23,1);
%         
%         % use old fitting data to find initial values to try and put the
%         % function in the area of the global minima
%         x0(1) = (simpleFit(1)./FZ_AVG(i)).^(1./4)./2;
%         x0(2) = (simpleFit(1)./FZ_AVG(i)).^(1./4)./2./dfz;
%         x0(3) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)-1)./2./dpi;
%         x0(4) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)-1)./2./(dpi.^2);
%         x0(5) = ((simpleFit(1)./FZ_AVG(i)).^(1./4)+1)./(IA_AVG(i).^2);
%         
%         x0(6) = simpleFit(2);
%         x0(7) = simpleFit(3).*simpleFit(2).*simpleFit(1);
%         
%         x0(9) = simpleFit(4)^(1/2)/2;
%         x0(10) = simpleFit(4)^(1/2)/2/dfz;
%         x0(11) = (simpleFit(4)^(1/2)-1)/2/(IA_AVG(i)^2);
%         
%         x0(14) = simpleFit(5)/2/FZ_AVG(i)/IA_AVG(i)/2;
%         x0(15) = simpleFit(5)/2/FZ_AVG(i)/IA_AVG(i)/2/dfz;
%         x0(16) = simpleFit(5)/2/FZ_AVG(i);
%         x0(17) = simpleFit(5)/2/FZ_AVG(i)/dfz;
%         
%         x0(18) = ((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)./2;
%         x0(19) = ((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)./2./dfz;
%         x0(20) = (((((simpleFit(6)+1)./2)*x0(7)+FZ_AVG(i)*IA_AVG(i)*(x0(14)+x0(15)*dfz))./IA_AVG(i)./FZ_AVG(i)).^(1./2)-1)./dpi;
%         x0(21) = (simpleFit(6)+1)./2./2;
%         x0(22) = (simpleFit(6)+1)./2./2./dfz;
%         
% %         x0 = real(x0);
%         
%         % fit data to the complex model without the full Kya eqn
%         lsqfcn = @(x0)fullPacejkaDiff(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
%         options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
%         Pfit.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
%             'pCy1', 'Kya',...
%             'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
%             'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
%         Pfit.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
%         Pcurve(SWEEP_STARTS(i):SWEEP_ENDS(i)) = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + maincoeffs(7)) - (maincoeffs(4)-sign(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))).*maincoeffs(5)).*(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)) - atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)))))) + maincoeffs(6);
%         
%         Pfit.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
%         Pfit.vals.main = maincoeffs;
        

%         %% fit
%         x0 = ones(29,1);
%         x0(1:6) = Pfit.vals.all(1:6);
%         x0(7) = (Pfit.vals.all(7)/Fzo)^(1/3);
%         x0(8) = (((Pfit.vals.all(7)/Fzo)^(1/3)-1)/dpi);
%         x0(9) = (((Pfit.vals.all(7)/Fzo)^(1/3)+1)/abs(IA_AVG(i)));
%         x0(10) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(11) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(12) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(13) = asin(Pfit.vals.all(7)/(Fzo*x0(7)*(1+x0(8)*dpi)*(1-x0(9)*abs(IA_AVG(i)))))/atan(FZ_AVG(i)/Fzo);
%         x0(14:29) = Pfit.vals.all(8:23);
%         
% %         x0 = real(x0);
%         
%         lsqfcn = @(x)fullPacejkaDiff2(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
%         options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',6000);
%         Pfit2.labels.all = {'pDy1', 'pDy2', 'ppy3', 'ppy4', 'pDy3',...
%             'pCy1', 'pKy1', 'ppy1', 'pKy3', 'pKy4', 'pKy2', 'pKy5', 'ppy2',...
%             'ey', 'pEy1', 'pEy2', 'pEy5', 'pEy3', 'pEy4', 'pVy3', 'pVy4',...
%             'pVy1', 'pVy2', 'pKy6', 'pKy7', 'ppy5', 'pHy1', 'pHy2', 'eK'};
%         Pfit2.vals.all = lsqnonlin(lsqfcn,x0,[],[],options);
%         Pcurve(SWEEP_STARTS(i):SWEEP_ENDS(i)) = maincoeffs(1)*sin(maincoeffs(2)*atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i)) + maincoeffs(7)) - (maincoeffs(4)-sign(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))).*maincoeffs(5)).*(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)) - atan(maincoeffs(3).*(SA(SWEEP_STARTS(i):SWEEP_ENDS(i))+maincoeffs(7)))))) + maincoeffs(6);
%         
%         Pfit2.labels.main = {'Dy' 'Cy' 'By' 'Ey1' 'Ey2' 'SVy' 'SHy'};
%         Pfit2.vals.main = maincoeffs;

    end
end

function diff = simplePacejkaDiffFX(x0simple,ya,SWEEP_FX)
    % define your normal variables in terms of x(n)
    Dy = x0simple(1);
    Cy = x0simple(2);
    By = x0simple(3);
    Ey = x0simple(4);
    SVy = x0simple(5);
    SHy = x0simple(6);
    
    % Pacejka fitting model - real FY
    diff = Dy*sin(Cy*atan(By.*(ya+SHy) - Ey*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy - SWEEP_FX;
end

function diff = fullPacejkaDiffFX(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    PacejkaFY1 = Pacejka_eqn_noKya(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
    
    diff = PacejkaFY1 - SWEEP_FY;
end

function diff = fullPacejkaDiff2FX(x0,ya,SWEEP_FY,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    PacejkaFY2 = Pacejka_fulleqn(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i);
    
    diff = PacejkaFY2 - SWEEP_FY;
end

function PacejkaFX1 = Pacejka_eqn_noKyaFX(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
    
        Fzo = FZ_CLASS(i); % nominal FZ
        dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
        pio = (P_CLASS(i)*6.89476); % nominal P
        dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = x0(1);
    pDy2 = x0(2);
    ppy3 = x0(3);
    ppy4 = x0(4);
    pDy3 = x0(5);
    
    % Cy
    pCy1 = x0(6);
    
    Kya  = x0(7); % begin with it set as By*Cy*Dy
    
    % By
    ey   = x0(8);
    
    % Ey1
    pEy1 = x0(9);
    pEy2 = x0(10);
    pEy5 = x0(11);
    % Ey2
    pEy3 = x0(12);
    pEy4 = x0(13);
    
    % SVyy
    pVy3 = x0(14);
    pVy4 = x0(15);
    % SVy
    pVy1 = x0(16);
    pVy2 = x0(17);
    
    % Kyyo
    pKy6 = x0(18);
    pKy7 = x0(19);
    ppy5 = x0(20);
    % SHy
    pHy1 = x0(21);
    pHy2 = x0(22);
    eK   = x0(23);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2.*dfz).*(1 + ppy3.*dpi + ppy4.*(dpi.^2)).*(1 - pDy3.*(IA_CLASS(i).^2));
    Dy = uy.*FZ_CLASS(i);
    
    Cy = pCy1;
    
    By = Kya./(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2.*dfz + (pEy1 + pEy2.*dfz).*pEy5.*IA_CLASS(i).^2;
    Ey2 = (pEy1 + pEy2.*dfz).*(pEy3 + pEy4.*IA_CLASS(i));
    
    SVyy = FZ_CLASS(i).*(pVy3 + pVy4.*dfz).*IA_CLASS(i);
    SVy = FZ_CLASS(i).*(pVy1 + pVy2.*dfz) + SVyy;
    
    Kyyo = FZ_CLASS(i).*(pKy6 + pKy7.*dfz).*(1 + ppy5.*dpi);
    SHy = (pHy1 + pHy2.*dfz) + (Kyyo.*IA_CLASS(i)-SVyy)./(Kya+eK) - 1;
    
    disp(Dy)
    disp(Cy)
    disp(By)
    disp(Ey1)
    disp(Ey2)
    disp(SVy)
    disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
  PacejkaFX1 = Dy.*sin(Cy.*atan(By.*(ya+SHy) - (Ey1-sign(ya).*Ey2).*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy;
end

function PacejkaFX2 = Pacejka_fulleqnFX(x0,ya,FZ_AVG,P_AVG,FZ_CLASS,P_CLASS,IA_CLASS,i)
   
Fzo = FZ_CLASS(i); % nominal FZ
dfz = (FZ_AVG(i) - Fzo)/Fzo; % normalized FZ
pio = (P_CLASS(i)*6.89476); % nominal P
dpi = ((P_AVG(i)*6.89476) - pio)/pio; % normalized P
    
    % define your parameters in terms of coeffs(n)
    % uy
    pDy1 = x0(1);
    pDy2 = x0(2);
    ppy3 = x0(3);
    ppy4 = x0(4);
    pDy3 = x0(5);
    
    % Cy
    pCy1 = x0(6);
    
    % coeffs that belong to Kya
    pKy1 = x0(7);
    ppy1 = x0(8);
    pKy3 = x0(9);
    pKy4 = x0(10);
    pKy2 = x0(11);
    pKy5 = x0(12);
    ppy2 = x0(13);
    %
    % By
    ey   = x0(14);
    
    % Ey1
    pEy1 = x0(15);
    pEy2 = x0(16);
    pEy5 = x0(17);
    % Ey2
    pEy3 = x0(18);
    pEy4 = x0(19);
    
    % SVyy
    pVy3 = x0(20);
    pVy4 = x0(21);
    % SVy
    pVy1 = x0(22);
    pVy2 = x0(23);
    
    % Kyyo
    pKy6 = x0(24);
    pKy7 = x0(25);
    ppy5 = x0(26);
    % SHy
    pHy1 = x0(27);
    pHy2 = x0(28);
    eK   = x0(29);
    
    
    % calculate each major variable
    uy = (pDy1 + pDy2.*dfz).*(1 + ppy3.*dpi + ppy4.*(dpi^2)).*(1 - pDy3.*(IA_CLASS(i).^2));
    Dy = uy.*FZ_CLASS(i);
    
    Cy = pCy1;
    
    Kya = pKy1.*Fzo.*(1 + ppy1.*dpi)*(1 - pKy3.*abs(IA_CLASS(i))).*sin(pKy4.*atan((FZ_CLASS(i)./Fzo)./((pKy2 + pKy5.*IA_CLASS(i).^2)*(1 + ppy2.*dpi))));
    By = Kya./(Cy+Dy + ey);
    
%     Ey = (pEy1 + pEy2*dfz)*(1 + pEy5*IA^2 - sign(ay)*(pEy3 + pEy4*IA));
    % split into Ey1 - sign(ay)*Ey2
    Ey1 = pEy1 + pEy2.*dfz + (pEy1 + pEy2.*dfz)*pEy5.*IA_CLASS(i).^2;
    Ey2 = (pEy1 + pEy2.*dfz).*(pEy3 + pEy4.*IA_CLASS(i));
    
    SVyy = FZ_CLASS(i).*(pVy3 + pVy4.*dfz).*IA_CLASS(i);
    SVy = FZ_CLASS(i).*(pVy1 + pVy2.*dfz) + SVyy;
    
    Kyyo = FZ_CLASS(i).*(pKy6 + pKy7.*dfz)*(1 + ppy5.*dpi);
    SHy = (pHy1 + pHy2.*dfz) + (Kyyo.*IA_CLASS(i)-SVyy)./(Kya+eK) - 1;
    
%     disp(Dy)
%     disp(Cy)
%     disp(By)
%     disp(Ey1)
%     disp(Ey2)
%     disp(SVy)
%     disp(SHy)
    
    % to access main coeffs outside of fcn
    global maincoeffs;
    maincoeffs = [Dy Cy By Ey1 Ey2 SVy SHy];
    
    PacejkaFY2 = Dy.*sin(Cy.*atan(By.*(ya+SHy) - (Ey1-sign(ya).*Ey2).*(By.*(ya+SHy) - atan(By.*(ya+SHy))))) + SVy;
end

