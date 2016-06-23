x = [1:8]';
y = [1.5 2.3 1.7 2.0 2.5 1.9 2.2 2.4]';
X = [ones(size(x)) x];
[b, bint] = regress(y, X)
mu = X*b;
plot(x, y, '*', x, mu, '-')
%%
y\X
%%
reggui(x, y)
%%
load co2.dat
subplot
plot(co2)
z = reshape(co2, 12, []);
y = mean(z)'
x = (1:32)';
plot(x, y, 'o')
%%
reggui(x, y)

%%
load cement.dat
cement
corrcoef(cement)
x = cement(:, 1:4);
Y = cement(:, 5);
help plotmatrix
plotmatrix(cement)

%%
X = [ones(size(Y)) x]
beta = X\Y
res = Y - X*beta
[n, c] = size(X)
f = n - c
s2 = sum(res.^2)/f
Vbeta = s2*inv(X'*X)
plot(res, 'o')
kvantil = tinv(1-0.05/2, f)
IbetaL = beta - kvantil*sqrt(diag(Vbeta))
IbetaH = beta + kvantil*sqrt(diag(Vbeta))

%%
[beta, Ibeta, res, resint, stats] = regress(Y, X, 0.05)
%%
stepwise(x, Y)
%%
Xfinal = [x(:,1) x(:,4)];
plot(Xfinal, Y, 'o')
%%
load flow.mat
reggui(fx1, fy1)

%%
reggui(fx2, fy2)
