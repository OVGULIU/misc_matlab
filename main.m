%Main
%% 1.1
lambda = 3;
ustart = 2;
uold = ustart;
told = 1;
h = 0.2;

f = @(told, uold) lambda*uold;

for i = 1:10
    unew = RK4step(f, uold, i - 1, h);
    uold = unew;
    error(i) = norm(ustart*expm(lambda*(told - 1)) - unew)
end

loglog(1:10, error);
%y' - lambda*y = 0;

%% 1.2



