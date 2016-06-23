function y = twopBVP(fvec, alpha, beta, L, N)
dx = L/(N+1);
Bu = zeros(N,1);
Bu(1,1) = -2; Bu(2,1) = 1;
A = (1/(dx^2))*toeplitz(Bu);


fvec(1) = fvec(1) - alpha/(dx^2);
fvec(N) = fvec(N) - beta/(dx^2);
y = A\fvec;
y = [alpha; y; beta];

end