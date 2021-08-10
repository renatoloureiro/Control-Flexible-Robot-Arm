% ------------------------------------------------------------------------
% File: demo.m
% Contents: This file has the basic parameters for the estimated model and
%           to run the simulink files correctly
%           This file has three sections, to run the simulations just need
%           to run the first section
%
% Authors:  Renato Loureiro
%           Pedro Sarnadas
%           Tiago Santos
% ------------------------------------------------------------------------

fs=100;
Ts=1/fs;    % Sampling interval

tfinal=100; % Time of simulation

load('Estimated_Model.mat')
load('barrassmodel.mat') % 'barrassmodel2.mat' - perturbado
whos A B C D
G=ss(A,B,C,0,Ts);

% Regulator design
Q = C'*C;
R = 100;    % Big R slow control
            % Small R nervous control
[K,~,p] = dlqr(A,B,Q,R);
% Current estimator design
B1=B;
QE = 1;
RE = 10;   % Big R slow observer
            % Small R nervous observer
G1 = eye(size(A));
[M,~,~,q]=dlqe(A,B1,C,QE,RE);

whos K M

N = inv([A-eye(size(A)), B; C,0])*[zeros(size(A,1),1);1];
Nx = N(1:end-1,:);
Nu = N(end,:);
Nbar = Nu+K*Nx;

PHIE = A-M*C*A;
GAMMAE = B-M*C*B;

%% LQR open loop and close loop
% Goal: obtain the transfer function and pole location for each case

C_lqr = ss(A-B*K,B*Nbar,C,0,Ts);
T_lqr = ss(A,B,K,0,Ts);
figure(1)
bode(T_lqr)
margin(T_lqr)
figure(2)
bode(C_lqr)
margin(C_lqr)


T2_lqg= ss([A zeros(size(A)); M*C*A PHIE-GAMMAE*K], [B; M*C*B],[zeros(size(K)) K],0,Ts);
figure(3)
bode(T2_lqg)
legend('C (LQG, m2)')
margin(T2_lqg)
C2_lqg = ss([A -B*K; M*C*A PHIE-GAMMAE*K-M*C*B*K],[B; M*C*B+GAMMAE]*Nbar,...
    [C zeros(size(C))],0,Ts);
figure(4)
bode(C2_lqg)
legend('C (LQG, m2)')
margin(C2_lqg)
%% LQR and LQE validation

color1=[0 0.4470 0.7410];
color2=[0.6350 0.0780 0.1840];

[yupper,ylower]=envelope(log(abs(out.y.Data(110:length(out.y.Data)))),...
    10,'peak');
figure(1)
plot(out.y.Time(110:length(out.y.Time)),yupper,'Color', color2,'LineWidth',4);
hold on
plot(out.y.Time(110:length(out.y.Time)),...
    log(abs(out.y.Data(110:length(out.y.Data)))),'Color', color1);
hold off
xlabel('Time [s]')
time=out.y.Time(110:length(out.y.Time));
mdl=fitlm(time(5000:length(time)),yupper(5000:length(yupper)));
declive=table2array(mdl.Coefficients(2,1));
a1=exp(declive*Ts);
a2=max(abs(p));
error_lqr=100*abs(a1-a2)/a2;

% LQE validation
[yupper2,ylower2]=envelope(log(abs(out.y2.Data(110:length(out.y2.Data),1))),...
    10,'peak');
figure(2)
plot(out.y2.Time(110:length(out.y2.Time)),yupper2,'Color', color2,'LineWidth',4);
hold on
plot(out.y2.Time(110:length(out.y2.Time)), ...
    log(abs(out.y2.Data(110:length(out.y2.Data),1))),'Color', color1);
hold off
xlabel('Time [s]')
time2=out.y2.Time(110:length(out.y2.Time));
mdl2=fitlm(time2(5000:length(time2)),yupper2(5000:length(yupper2)));
declive2=table2array(mdl2.Coefficients(2,1));
a1=exp(declive2*Ts);
a2=max(abs(q));
error_lqe=100*abs(a1-a2)/a2;

%% 
%color1=[0 0.4470 0.7410];
%color2=[0.6350 0.0780 0.1840];
%width = 8;                    
%height = 3; 
%pos=[100 100];
%aux=[0.001,0.1,1,10,100,1000];
%for i=1:length(aux)
%    R=aux(i);
%    disp(R)
%    [K,~,p] = dlqr(A,B,Q,R);
%    open_system('Control_Validation')
%    %set_param('Control_Validation', 'SimulationCommand', 'update')
%    set_param('Control_Validation','SimulationCommand','Update')
%    sim('Control_Validation')
%    set(figure(i), 'Position', [pos(1) pos(2) width*100, height*100]);
%    plot(out.y.Time, out.y.Data,'Color', color1)
%    hold on
%    plot(out.ref.Time, out.ref.Data,'Color',color2)
%    xlabel('Time [s]')
%    bdclose('all')
%end









