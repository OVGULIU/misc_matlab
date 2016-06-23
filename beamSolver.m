function u = beamSolver(L, q, I, E, x)
% u = q./(E*I).*(x.^4/24 - L*x.^3/12) + q*L^3/(24*E.*I)*x;
u = q*x.^4./(E*I*24) - q*L*x.^3./(12*E*I) + q*L^3*x./(24*E*I);
end