clear
close

%loading raw text files
low0_43 = load('low-0-4.3.txt');
low2_43 = load('low-2-4.3.txt');
low4_43 = load('low-4-4.3.txt');
low6_43 = load('low-6-4.3.txt');
low10_43 = load('low-10-4.3.txt');
low15_43 = load('low-15-4.3.txt');
low25_43 = load('low-25-4.3.txt');
high0_43 = load('high-0-4.3.txt');
high0_3 = load('high-0-3.txt');
high0_2 = load('high-0-2.txt');
high0_1 = load('high-0-1.txt');
high0_0 = load('high-0-0.txt');

%extracting force and velocity columns from low speed files
velocitylow0_43 = (low0_43(:,1));
forcelow0_43 = (low0_43(:,2));
velocitylow2_43 = (low2_43(:,1));
forcelow2_43 = (low2_43(:,2));
velocitylow4_43 = (low4_43(:,1));
forcelow4_43 = (low4_43(:,2));
velocitylow6_43 = (low6_43(:,1));
forcelow6_43 = (low6_43(:,2));
velocitylow10_43 = (low10_43(:,1));
forcelow10_43 = (low10_43(:,2));
velocitylow15_43 = (low15_43(:,1));
forcelow15_43 = (low15_43(:,2));
velocitylow25_43 = (low25_43(:,1));
forcelow25_43 = (low25_43(:,2));

%extracting force and velocity columns from high speed files
velocityhigh0_43 = (high0_43(:,1));
forcehigh0_43 = (high0_43(:,2));
velocityhigh0_3 = (high0_3(:,1));
forcehigh0_3 = (high0_3(:,2));
velocityhigh0_2 = (high0_2(:,1));
forcehigh0_2 = (high0_2(:,2));
velocityhigh0_1 = (high0_1(:,1));
forcehigh0_1 = (high0_1(:,2));
velocityhigh0_0 = (high0_0(:,1));
forcehigh0_0 = (high0_0(:,2));

%plotting force vs velocity for specific condition
figure(1);
plot(velocityhigh0_3,forcehigh0_3);
title('High Speed - (0 - 3)')
ylabel('Force(N)')
xlabel('Velocity(mm/s)')