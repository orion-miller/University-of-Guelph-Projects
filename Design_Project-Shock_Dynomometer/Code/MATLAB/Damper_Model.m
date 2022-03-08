%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Lindsay Burton, Orion Miller, Ben Tory-Pratt, Austin Van Rossum          
% OHLINS TTX25 DAMPER MODELER
% March 2019

% References:
%https://deepblue.lib.umich.edu/bitstream/handle/2027.42/49574/proj25_report.pdf?sequence=2

%Known Issues:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars
clc
tic

cd(uigetdir);

OhlinsData = load('x');
OhlinsDataVel = OhlinsData(:,1);
OhlinsDataCompForce = OhlinsData(:,2);
OhlinsDataExtForce = OhlinsData(:,3);

SweepStarts = [x x x x x x x x x x x x x x x x x x]; % creates beginning splits
SweepEnds = [x x x x x x x x x x x x x x x x x x]; % creates finish splits
SweepsNum = numel(SweepStarts);

OhlinsDataLSC = [0 2 4 6 10 15 25];
OhlinsDataLSR = [0 2 4 6 10 15 25];
OhlinsDataHSC = [0 1 2 3 4.3];
OhlinsDataHSR = [0 1 2  3 4.3]; 

for i=1:SweepsNum
    CD = x; %Initial Slope of Curve
    RCE = mean(OhlinsDataCompForce(SweepStarts(i):SweepEnds(i))/OhlinsDataExtForce(SweepStarts(i):SweepEnds(i))); %Ratio of compression forces over extension forces
    LAMBDA = x; %Non-linearity coefficient
end 

%Load Test Data
TestData = load(uigetfile);

%Index Test by Variables
TestDataTime = TestData(:,1);
TestDataLinDisp = TestData(:,x);
TestDataLinVel = x(TestDataLinDisp);
TestDataRPM = TestData(:,x);
TestDataForce = TestData(:,x);
TestDataTemp = TestData(:,x);

disp('Importing Test Data...')
TestDataLSC = input('Enter Low Speed Compression: ');
TestDataLSR = input('Enter Low Speed Rebound: ');
TestDataHSC = input('Enter High Speed Compression: ');
TestDataHSR = input('Enter High Speed Rebound: ');

%Create a scrollable display of all measured variables vs. time
f = figure('Name',sprintf('Test Data vs. Time: LSC = %s, LSR = %s, HSC = %s, HSR = %s', TestDataLSC, TestDataLSR, TestDataHSC, TestDataHSR),'NumberTitle','off','Position',[0 0 1300 670]);
figure(f)

scrollsubplot(3,1,1)
    plot(TestDataTime,TestDataLinDisp)
    title('Damper Displacement vs . Time');
    xlabel('Time (s)');
    ylabel('Displacement (mm?)');
    grid on
  %  set(gca,'color',[0 0 0])

scrollsubplot(3,1,2)
    plot(TestDataTime, TestDataLinVel)
    title('Damper Velocity vs. Time');
    xlabel('Time (s)');
    ylabel('Velocity (m/s)');
    grid on
 %   set(gca,'color',[0 0 0])

scrollsubplot(3,1,3)
    plot(TestDataTime, TestDataRPM)
    title('Skotch Yoke RPM vs. Time');
    xlabel('Time (s)');
    ylabel('RPM');
    grid on
   % set(gca,'color',[0 0 0])
   
scrollsubplot(3,1,4)
    plot(TestDataTime, TestDataForce)
    title('Force vs. Time');
    xlabel('Time (s)');
    ylabel('Force (Newtons)');
    grid on
   % set(gca,'color',[0 0 0])
    
scrollsubplot(3,1,5)
    plot(TestDataTime, TestDataTemp)
    title('Damper Temperature vs. Time');
    xlabel('Time (s)');
    ylabel('Temperature (C)');
    grid on
   % set(gca,'color',[0 0 0])

f = figure('Name',sprintf('Theoretical vs. Tested Damping Plot: LSC = %s, LSR = %s, HSC = %s, HSR = %s', TestDataLSC, TestDataLSR, TestDataHSC, TestDataHSR),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.g');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'g');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TheroeticalFit(SweepStarts(i):SweepEnds(i)),'b');
        grid on
        title('x')
        xlabel('x')
        ylabel('x')

         
   
f = figure('Name',sprintf('Test Data Heat Map: LSC = %s, LSR = %s, HSC = %s, HSR = %s', TestDataLSC, TestDataLSR, TestDataHSC, TestDataHSR),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
dotsz = 25;
scatter(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),dotsz,TestDataTemp(SweepStarts(i):SweepEnds(i)));
title('Force vs. Velocity, Temperature')

f = figure('Name',sprintf('Manufacturer vs. Tested Damping Plots, Low-Speed Adjustment Variation'),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
for i = 1:SweepsNum
if Class_1(i)==Fixed_1&&Class_2(i)==Fixed_2
       if Class_3(i) == 1
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.g');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'g');
       else if Class_3(i) == 2
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.r');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'r');
        else if Class_3(i) == 3
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.c');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'c');
        else if Class_3(i) == 4
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.m');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'m');
        else if Class_3(i) == 5
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.y');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'y');
        else if Class_3(i) == 6
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.b');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'b');
        else if Class_3(i) == 7
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.k');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'k');
            end
            end
            end
            end
            end
           end
       end
end
end    
    
f = figure('Name',sprintf('Manufacturer vs. Tested Damping Plots, High-Speed Adjustment Variation'),'NumberTitle','off');
set(f,'units','normalized','outerposition',[0,0,1,1]);
for i = 1:SweepsNum
if Class_1(i)==Fixed_1&&Class_2(i)==Fixed_2
       if Class_3(i) == 1
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.g');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'g');
       else if Class_3(i) == 2
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.r');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'r');
        else if Class_3(i) == 3
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.c');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'c');
        else if Class_3(i) == 4
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.m');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'m');
        else if Class_3(i) == 5
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.y');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'y');
        else if Class_3(i) == 6
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.b');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'b');
        else if Class_3(i) == 7
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce(SweepStarts(i):SweepEnds(i)),'.k');
        hold on
        plot(TestDataTime(SweepStarts(i):SweepEnds(i)),TestDataForce_Fit(SweepStarts(i):SweepEnds(i)),'k');
            end
            end
            end
            end
            end
           end
       end
end
end     



function [TheoreticalForce] = TheoreticalFit(TestDataLSC, TestDataLSR, TestDataHSC, TestDataHSR)

end 



