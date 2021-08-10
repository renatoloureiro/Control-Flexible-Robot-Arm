% Flexible robot link
%--------------------------------------------------------------------
% Loads the true flexible link model
load('barrassmodel.mat')
% Defines experiment parameters
fs=100;
Ts=1/fs;    % Sampling interval
tfinal=100;

flag.input=0; % 1 - sinal quadrado
              % 0 - PRBS 
              
% PRBS input
    PRBS.dfreq=10000;  % Create the discrete time vector for this signal
    PRBS.time=0:tfinal/PRBS.dfreq:tfinal;
    
    PRBS.ref=idinput(length(PRBS.time),'PRBS',[0 0.02]);
    PRBS.T=AveragePeriod(PRBS.time,PRBS.ref); % Average signal Period
    PRBS.input=[transpose(PRBS.time), PRBS.ref];
% Square input
    Square.dfreq=10000;  % create the discrete time vector for this signal
    Square.time=0:tfinal/Square.dfreq:tfinal;
    Square.freq=0.08;  %Hertz
    Square.ref=square(2*pi*Square.freq*Square.time);
    Square.input=[transpose(Square.time), transpose(Square.ref)];
    

% Simulates the true model to generate data for identification
% Input: Ts, State-Space(Atrue,Btrue,Ctrue,Dtrue), 
% Output: t, ts, us, y, ys
sim('barra1');

% Filtering the output with differentiation
% The filter added has the property of being a low pass filter and
% atteniate the high frequency noise that may exist

    lambda.value=0.8;
    lambda.num=[1-lambda.value, -(1-lambda.value)];
    lambda.den=[1 ,-lambda.value];
    dy=filter(lambda.num,lambda.den,ys);
    
% Plot of the filter output signal with the labmda parameter specified
% earlier

    figure(1)
    gg=plot(ts,dy);
    set(gg,'LineWidth',1.5);
    gg=xlabel('t (s)');
    set(gg,'FontSize',14);
    gg=ylabel('y (volt)');
    set(gg,'Fontsize',14);
    %xlim([10 35]);
    hold on
    %plot(ts(1:length(ts)-1),diff(ys));
    plot(ts,filter([1,-1],[1,0],ys));
    hold off
    u = dtrend(us);
%% Plots the continuous and the discrete time outputs
    
    figure(2)
    gg=plot(t,y);               % Plot the continous time output position y
    set(gg,'LineWidth',1.5);
    gg=xlabel('t (s)');
    set(gg,'FontSize',14);
    gg=ylabel('y (volt)');
    set(gg,'Fontsize',14);
    %xlim([40 50]);
    hold on
    gg=plot(ts,ys,'r');         % Plot the discrete time output position y
    set(gg,'LineWidth',1.5);
    hold off

% Saves data for identification
% us and ys contain i/o data with a sampling interval of Ts
    save('iodata1.mat','us','ys','ts')

%% Identification algorithm

    
    z = [dy u];         % Z has the input and output data
    na = 5;             % AR part - order of the poles
    nb = 5;             % X part - order of zeros + 1
    nc = na;            % MA part - order of C
    nk = 1;             % Atraso puro – pure delay
    nn = [na nb nc nk];
    th = armax(z,nn);    % th is a structure in identification toolbox 
                        % format
                        
    [den1,num1] = polydata(th);
    dysim = filter(num1,den1,u); % gives the dy time domain using the 
                                 % estimated plant
    [num,den] = eqtflength(num1,conv(den1,[1 -1])); % plant from u to y
    ysim = filter(num,den,u);    % estimated response of y with the 
                                 % identified plant parameters
    [A,B,C,D] = tf2ss(num,den);  % State Space configuration
    
    
    
    %compare(z,th)               % Use this function to get a fit value 
                                 % for a test set

    
%% Write into .txt file

    fileID=fopen('data_identification.txt','a');
    fprintf(fileID,'--------------------------------------------- \n');
    fprintf(fileID,'Ts = %f \n',Ts);
    fprintf(fileID,'Square wave input with 1 Mhz\n');
    fprintf(fileID,' na = %d \n nb = %d \n nc = %d \n nk = %d \n',na,nb,nc,nk);
    fprintf(fileID,' den=');
    fprintf(fileID,' %f ',den);
    fprintf(fileID,'\n');
    fprintf(fileID,' num=');
    fprintf(fileID,' %f ',num);
    fprintf(fileID,'\n');
    %writematrix(round(A,2),'data_identification.txt','WriteMode','append');
    fclose(fileID);
             
    
    
    
%---------------------------------------------------------------------
% End of file