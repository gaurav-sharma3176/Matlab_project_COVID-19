%%Although we have data of pandemic start from day 1,but we using data from
%%day 14 for the sake of model, since in beginning deaths and recoveries
%%are zero, that makes matrix singular.
%Same has been done in Research paper also, where they have data from 11
%11 Jan, but they took data from 16 Jan. 
%Corona Pandemic Estimator for Delhi area.
filename= 'S.xlsx';
A=xlsread(filename);
c=size(A);

%taking vectors
I=A(:,2);
R=A(:,3);
D=A(:,4);


%calculating R0 in the begining of pandemic. Here taking first 10 days.
Ir=zeros(10,1);
Rr=zeros(10,1);
Dr=zeros(10,1);
j=1;
for i=14:23
    Ir(j,1)=I(i,1);
    Rr(j,1)=R(i,1);
    Dr(j,1)=D(i,1);
    j=j+1;
end

R0=inv(transpose(Rr+Dr)*(Rr+Dr))*(transpose(Rr+Dr)*(Ir+Rr+Dr));
disp('Initial Basic Reproduction Parameter in the beginning of pandemic');
disp(R0);

%calculating Estimated R0 for every 10 days, denoting ER0,
ER0=zeros(1,86);
i=2;
t=1;
while i<88
    Ir=zeros(i,1);
    Rr=zeros(i,1);
    Dr=zeros(i,1);
    k=1;
    for j=14:i+13
        Ir(k,1)=I(j,1);
        Rr(k,1)=R(j,1);
        Dr(k,1)=D(j,1);
        k=k+1;
    end
    ER0(t)=inv(transpose(Rr+Dr)*(Rr+Dr))*(transpose(Rr+Dr)*(Ir+Rr+Dr));
    t=t+1;
    i=i+1;
end
disp('Estimated Basic Reproduction Parameter for every day as pandemic starts to spread');
disp(ER0);
disp('Here is average value of Basic reproduction parameter');
disp(mean(ER0));

figure(1);
plot(ER0);
grid;

%calculating fatality rate and recovery rate denoted fr & rr using rolling
%window
fr=zeros(1,86);
rr=zeros(1,86);

i=2;
t=1;
while i<88
    Ir=zeros(i,1);
    Rr=zeros(i,1);
    Dr=zeros(i,1);
    k=1;
    for j=14:i+13
        Ir(k,1)=I(j,1);
        Rr(k,1)=R(j,1);
        Dr(k,1)=D(j,1);
        k=k+1;
    end
    fr(t)=inv(transpose(Ir)*(Ir))*(transpose(Ir)*(Dr));
    rr(t)=inv(transpose(Ir)*(Ir))*(transpose(Ir)*(Rr));
    t=t+1;
    i=i+1;
end
disp('Fatality rate for each day');
disp(fr);
disp('Recovery rate for each day');
disp(rr);
disp('Expected value of fatality rate is');
disp(mean(fr));
disp('Expected value of recovery rate is');
disp(mean(rr));

figure(2);
plot(fr);
grid;

figure(3)
plot(rr);
grid;

%calculating effective fr and rr denoting as efr && err
Ir=zeros(86,1);
Rr=zeros(86,1);
Dr=zeros(86,1);
j=1;
for i=14:101
   Ir(j,1)=I(i,1);
   Rr(j,1)=R(i,1);
   Dr(j,1)=D(i,1);
   j=j+1;
end
delD=A(102,4)-A(101,4);
delR=A(102,3)-A(101,3);
efr=inv(transpose(Ir-Rr-Dr)*(Ir-Rr-Dr))*transpose(Ir-Rr-Dr)*delD;
err=inv(transpose(Ir-Rr-Dr)*(Ir-Rr-Dr))*transpose(Ir-Rr-Dr)*delR;
disp('Effective fatality rate of SIRD Model');
disp(efr);
disp('Effective recoveryy rate of SIRD Model');
disp(err);


figure(4);
plot(efr);
grid;

figure(5);
plot(err);
grid;

%now calculating alpha i.e. infection rate using Levenberg Marquad
%Algorithm taking alpha=0.191
prompt='Enter the day to find infected person of that day.Keep value more than 102.';
n=input(prompt);
S=zeros(1,n-1);
S(1)=1900000;
I=zeros(1,n-1);
for i=1:102
    I(i)=A(i,2);
end
for i=2:n-1
    if i<103
        %disp(S(i));
        S(i)=S(i-1)-((0.191)*S(i-1)*I(i-1))/S(1);
    else
        S(i)=S(i-1)-((0.191)*S(i-1)*I(i-1))/S(1);
        I(i)=I(i-1)+((0.191)*S(i-1)*I(i-1))/S(1)-mean(err)*I(i-1)-mean(efr)*I(i-1);
    end
end

FRR=I(n-1)+((0.191)*S(n-1)*I(n-1))/S(1)-mean(err)*I(n-1)-mean(efr)*I(n-1);
disp('Infected person on the day you entered are');
disp(int64(FRR));

y=zeros(1,20);
%RMSE
n=81;
x=zeros(20,2);
for i=1:20
    x(i,1)=I(n-1)+((0.191)*S(n-1)*I(n-1))/S(1)-mean(err)*I(n-1)-mean(efr)*I(n-1);
    x(i,1)=int64(x(i,1));
    y(i)=x(i)-I(n);
    n=n+1;
end


%b=zeros(1,20);
n=81;
for i=1:20
    x(i,2)=I(n);
    n=n+1;
end
disp('Predicted value vs Actual value ');
disp(x);

figure(6);
plot(x(:,1),x(:,2));
grid;






