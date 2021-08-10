% -------------------------------------------------------------------------
% File: IdentificationAlgorithm_best.m 
% Description: Determine a set of best model estimates considering a
%              certain test set choosen
% -------------------------------------------------------------------------

load('barrassmodel.mat')

% Set sampling frequency
    fs=100;
    Ts=1/fs;    
    tfinal=100;

    lambda.value=0.95;
    lambda.num=[1-lambda.value, -(1-lambda.value)];
    lambda.den=[1 ,-lambda.value];
    
    
    
% Create test set for fitting
    flag.input=0;
    % PRBS test set configuration
    PRBS.dfreq=10000;  % Create the discrete time vector for this signal
    PRBS.time=0:tfinal/PRBS.dfreq:tfinal;
    PRBS.ref=idinput(length(PRBS.time),'PRBS',[0 0.01]);
    PRBS.T=AveragePeriod(PRBS.time,PRBS.ref); % Average signal Period
    PRBS.Avfreq=1/PRBS.T;
    PRBS.input=[transpose(PRBS.time), PRBS.ref];
    % Square Signal test set configuration 
    Square.dfreq=10000;  % create the discrete time vector for this signal
    Square.time=0:tfinal/Square.dfreq:tfinal;
    Square.freq=0.04;  %Hertz
    Square.ref=square(2*pi*Square.freq*Square.time);
    Square.input=[transpose(Square.time), transpose(Square.ref)];
    sim('barra1');  % output: aux, us, y, ys, ts, t
    % Create struct with test set configuartions
    testset.u=us;
    testset.t=ts;
    testset.ys=ys;
    testset.dy=filter(lambda.num,lambda.den,ys);
    fprintf('test set PRBS with average Frequency: %f [Hz]\n', PRBS.Avfreq);
    clear PRBS Square aux us y ys ts t
    

%-----------------------------------------------------------------------%
    
% Flag for choosing type of input signal
    flag.input=0;   % 0 - PRBS 
                    % 1 - sinal quadrado          
              
% PRBS input
     PRBS.dfreq=10000;  % Create the discrete time vector for this signal
     PRBS.time=0:tfinal/PRBS.dfreq:tfinal;
     PRBS.ref=idinput(length(PRBS.time),'PRBS',[0 0.005]);
     PRBS.T=AveragePeriod(PRBS.time,PRBS.ref); % Average signal Period
     PRBS.Avfreq=1/PRBS.T;
     PRBS.input=[transpose(PRBS.time), PRBS.ref];
% Square input
     Square.dfreq=10000;  % create the discrete time vector for this signal
     Square.time=0:tfinal/Square.dfreq:tfinal;
     Square.freq=0.04;  %Hertz
     Square.ref=square(2*pi*Square.freq*Square.time);
     Square.input=[transpose(Square.time), transpose(Square.ref)];

sim('barra1');  % output: aux, us, y, ys, ts, t
dy=filter(lambda.num,lambda.den,ys);
u=dtrend(us);
z = [dy u];         % Z has the real input and output data
Data(1,:)=["Type of Signal", "Freq [Hz]" ,"na", "nb", "nc", "nk", "FIT"];
for na=1:8
    for nb=1:na
    nc = na;            % MA part - order of C
    nk = 1;             % Atraso puro – pure delay
    nn = [na nb nc nk];
    th = armax(z,nn);    % th is a structure in identification toolbox 
                         % format

    [den1,num1] = polydata(th);
    %dysim = filter(num1,den1,u); % gives the dy time domain using the 
                                     % estimated plant
    [num,den] = eqtflength(num1,conv(den1,[1 -1])); % plant from u to y
    %ysim = filter(num,den,u);    % estimated response of y with the 
                                     % identified plant parameters
    %[A,B,C,D] = tf2ss(num,den);  % State Space configuration
    
    [~,FIT]=compare([testset.dy testset.u],th);      % get a test set for this, maybe a PRBS  
    
    if (exist('best'))==0
        best.FIT=FIT;   best.na=na;     best.nb=nb;     best.nc=nc;
        best.nk=nk;     best.num=num;   best.den=den;
    else
       if best.FIT<FIT
            best.FIT=FIT;   best.na=na;     best.nb=nb;     best.nc=nc;
            best.nk=nk;     best.num=num;   best.den=den; 
       end
    end
    
    % Save data from each simulation 
        fileID=fopen('data_identification.txt','a');
        fprintf(fileID,'--------------------------------------------- \n');
        fprintf(fileID,'Ts = %f \n',Ts);
        %fprintf(fileID,'Square wave input with %f Hz\n', square.f);
        fprintf(fileID,' na = %d \n nb = %d \n nc = %d \n nk = %d \n'...
            ,na,nb,nc,nk);
        fprintf(fileID,' den=');    fprintf(fileID,' %f ',den);
        fprintf(fileID,'\n');       fprintf(fileID,' num=');
        fprintf(fileID,' %f ',num); fprintf(fileID,'\n');
        fprintf(fileID,'FIT=%f \n',FIT);
        %writematrix(round(A,2),'data_identification.txt','WriteMode','append');
        fclose(fileID);
    end
    % Write the best estimation for each na choosen 
    % The criteria is the FIT value resulted from the test set 
        fileID=fopen('best_cases.txt','a');
        fprintf(fileID,'--------------------- \n');
        fprintf(fileID,' na = %d \n nb = %d \n',best.na,best.nb);
        fprintf(fileID,' den=');
        fprintf(fileID,' %f ',best.den); 
        fprintf(fileID,'\n');
        fprintf(fileID,' num=');
        fprintf(fileID,' %f ',best.num);
        fprintf(fileID,'\n');
        fprintf(fileID,' FIT=%f \n',best.FIT);
        fclose(fileID);
        
        Data(na+1,:)=["PRBS", PRBS.Avfreq ,best.na, best.nb, best.nc, best.nk, best.FIT];
       
        
    clear best
end