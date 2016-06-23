function anscombe
% ANSCOMBE - plot the anscombe data sets
% 
% Linear regression is performed on the anscobe data.
% Figure 1 shows data, regression line and estimated parameters.
% Figure 2 contains residual plots.

% Joakim Lübeck - 990426

load anscombe

for k=1:4
   K = num2str(k);
   x = eval(['x' K]);
   y = eval(['y' K]);
   U = [ones(size(y)) x];
   th_hatt = U\y;
   y_hatt = U*th_hatt;
   res = y - y_hatt;
   
   figure(1)
   subplot(2,2,k);
   plot(x, y, '+', x, y_hatt, '-');
   title(sprintf('\\alpha^*=%0.4g \\beta^*=%0.4g', th_hatt(1), th_hatt(2)));
   xlabel(['x' K]), ylabel(['y' K])
   
   figure(2)
   subplot(2,2,k);
   plot(x, res, '+');
   xlabel(['x' K]), ylabel(['res' K])
end

figure(1)
