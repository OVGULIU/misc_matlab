%Main
clear all; clc; clf;
f = @(x) sin(x) + 1; f2 = @(x) -sin(x);
N = 10; L = 10; alpha = f(0); beta = f(L);
dx = L/(N+1);
xx = 0:dx:L;
fvec = f2(xx(2:end-1));
y = twopBVP(fvec', alpha, beta, L, N);

% plot(xx, y); hold on;
% plot(xx, f(xx));
% f3 = f(xx);
% f3 = y - f3';
% plot(xx, f3);
size = 10;
for i = 1:size
    N(i) = 2^i;
end
dx = L./(N+1);
for k = 1:size
    xx = 0:dx(k):L;
    fvec = f2(xx(2:end-1));
    y = twopBVP(fvec', alpha, beta, L, N(k));
    err(k) = norm(y - f(xx)')/sqrt(N(k) + 1);
end

loglog(dx, err); hold on;
loglog(dx, dx.^2, '--');
coeff = polyfit(log(dx), log(err), 1)
grid on;


%% 2
size = 10;
for i = 1:size
    N(i) = 2^i;
end

L = 5; dx = L./(N+1);
E = 1; I = 1; q = 2; 
alpha = 0; beta = 0;

for j = 1:size
    fvec = q*ones(1, N(j)+2);
    x = 0:dx(j):L;
    M = twopBVP(fvec(2:end-1)', alpha, beta, L, N(j));
    M = M./(E*I);
    u = twopBVP(M(2:end-1), alpha, beta, L, N(j));
    ureal = beamSolver(L, q, I, E, x);
    err(j) = norm(u - ureal')/sqrt(N(j) + 1);
end


loglog(dx, err); hold on;
loglog(dx, dx.^2);

%% 2.2
L = 10; E = 1.9*10^11; q = -50*10^3;
alpha = 0; beta = 0;
N = 1000;
dx = L/(N+1);
x = 0:dx:L;

fvec = q*ones(1, N+2);
I = 10^(-3)*(3 - 2*(cos(pi*x/L)).^(12));
M = twopBVP(fvec(2:end-1)', alpha, beta, L, N);
M = M./(E*I');
u = twopBVP(M(2:end-1), alpha, beta, L, N);

plot(x, u);
