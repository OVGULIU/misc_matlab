function mregplot(x1, x2, y, int, kal, nl)
%function mregplot(x1, x2, y, int, kal, nl)
%
% Plottar regressionsplan för y = alpha + beta1*x1 + beta2*x2
% samt obervationer med en rät linje till närmaste lodräta
% punkt på regressionsplanet.
%
% Övriga (valfria) inparametrar är
%
%   int - rita konfidensplan om int=1, prediktionsplan om int=2.
%
%   kal - ritar ett kalibreringsplan vid detta y-värde.
%         För att se motsvarande kalibreringsområde i x1,x2-planet
%         kan man köra t.ex (kal.plan vid y = 100)
%
%            mregplot(x1, x2, y, 2, 100)
%            view(2)
%
%   nl  - antal delar (+1) som planen delas in i. Om den inte anges används
%
%         nl = 2 om man bara har ett regressionsplan
%         nl = 20 med konfidens eller prediktionsplan
%         nl = 100 med kalibreringsplan
%

% Joakim Lübeck ~ 1999
% Gränssnittet uppsnyggat 2003-09-26

if nargin < 6
   nl = 20;
   if nargin == 5
      nl = 100;
   end
   if nargin == 3
      nl = 2;
   end
end

if nargin < 4
   int = 0;
end


% Se till att det är kolonn-vektorer
x1 = x1(:);
x2 = x2(:);
y = y(:);

n = length(y);

X = [ones(n,1) x1 x2];
b = X\y;

rx1 = max(x1)-min(x1);
rx2 = max(x2)-min(x2);

r = 0.1;

[xl1, xl2] = meshgrid(linspace(min(x1)-r*rx1,max(x1)+r*rx1,nl)', ...
		      linspace(min(x2)-r*rx2,max(x2)+r*rx2,nl)');

yl = b(1)+b(2)*xl1+b(3)*xl2;

su=mesh(xl1,xl2,yl);
set(su, 'FaceColor', 'red');%, 'EdgeColor', [1 0 0])

holdstate = ishold;
hold on

if int == 1 | int == 2
   V = inv(X'*X);
   Q0 = sum((y-X*b).^2);
   s = sqrt(Q0/(n-3));
   d = zeros(nl,nl);

   for k=1:nl
      for l=1:nl
	 x0 = [1 xl1(k,l) xl2(k,l)]';
	 if int == 1
	    d(k,l) = s*sqrt(x0'*V*x0);
	 else % int ==2
	    d(k,l) = s*sqrt(1+x0'*V*x0);
	 end
      end
   end

   kv = tinv(1-0.05/2, n-3);
   s=mesh(xl1,xl2,yl-kv*d);
   set(s, 'FaceColor', 'green');%, 'EdgeColor', [0 1 0])
   s=mesh(xl1,xl2,yl+kv*d);
   set(s, 'FaceColor', 'green');%, 'EdgeColor', [0 1 0])
   alpha(s,0.2)
end

if nargin >= 5
   s = mesh(xl1,xl2,yl* 0 + kal);
   set(s, 'FaceColor', [1 1 1]*.7);
   alpha(s,0.7);
end
if ~holdstate, hold off, end

% Data points
line(x1,x2,y,'Marker','*','LineStyle','none')

% Line from plane to data points
line([x1'; x1'],[x2'; x2'],...
     [y';([ones(size(x1)) x1 x2]*b)'], 'Color',[0 0 1])



function s=mesh(varargin)
s=surf(varargin{:}, 'EdgeColor', 'none',...
       'FaceColor', 'interp',...
       'FaceLighting','phong');
v=version;
if v(1) > '5'
   alpha(s,0.5);
end
