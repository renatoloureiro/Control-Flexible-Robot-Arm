% Control script - with LQR and LQE 

% Defines experiment parameters
fs=100;
Ts=1/fs;    % Sampling interval
tfinal=100;

load('Estimated_Model.mat') % load the model previously estimated
                            % loads: A, B, C, D, den, num, den1, num1
                            
% LQR Control calculations
Q=C'*C;
R= 100; % scalar
[K,~,p]=dlqr(A,B,Q,R);


% LQE observer
B1=B;
QE=1;
RE=10;

[M,~,~,q]=dlqe(A,B1,C,QE,RE);

sim('Control_Validation');
% LQR validation
[yupper,ylower]=envelope(log(abs(out.y.Data(110:length(out.y.Data)))),...
    10,'peak');
plot(out.y.Time(110:length(out.y.Time)),yupper);
time=out.y.Time(110:length(out.y.Time));
mdl=fitlm(time(5000:length(time)),yupper(5000:length(yupper)));
declive=table2array(mdl.Coefficients(2,1));

% LQE validation
[yupper2,ylower2]=envelope(log(abs(out.y2.Data(110:length(out.y2.Data),1))),...
    10,'peak');
plot(out.y2.Time(110:length(out.y2.Time)),yupper2);
time2=out.y2.Time(110:length(out.y2.Time));
mdl2=fitlm(time2(5000:length(time2)),yupper2(5000:length(yupper2)));
declive2=table2array(mdl2.Coefficients(2,1));

% Merge LQR and LQE
N = inv([A-eye(size(A)), B; C,0])*[zeros(size(A,1),1);1];
Nx = N(1:end-1,:);
Nu = N(end,:);
Nbar = Nu+K*Nx;
PHIE=A-M*C*A;
GAMMAE=B-M*C*B;
CE=eye(size(PHIE));


% ss_lqg=ss([A -B*K; M*C*A PHIE-GAMMAE*K-M*C*B*K],[B; M*C*B+GAMMAE]*Nbar,...
% [C zeros(size(C))],0,Ts);
% ss_lqg=ss([A-B*K, B*K;0*eye(6),A-M*C],)


