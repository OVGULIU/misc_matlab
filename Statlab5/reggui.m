function reggui(action, y, desc)
% REGGUI - GraphicalUserInterface for linear regression
%
% REGGUI(x,y)
%
%    x - xdata, no intercept column needed
%    y - ydata
%
% REGGUI(x,y,desc)
%
%    desc - (optional) cell array of same size as x and y
%        containing desciptions of the data points
%
% Title, x- and y-label: Click to change.
%
% The ''Clone'' button makes a copy of last clicked axes in a new
% figure window.
%
% The regression line will be red if not all parameters are
% significant and blue otherwise.
%
% Version 041
   
% Version 042, 121010: Residuals against x by default, darker 
% colors on prediction and confidence intervalls. Grid on by default.

%
% Copyright 1999 Joakim Lübeck
%


if ~nargin
   warning('No data supplied, using some test values');
   n=10;
   x=(1:n)';
   y=randn(n,1)*10+3+2*x;
   action = 'init';
end

if ~isstr(action)
   x = action;
   action = 'init';
end


switch action
 case 'init' %%%%%%%%%%%

  v = version; v(v < '0' | v > '9') = ' '; v = str2num(v); v=v(1)+v(2)/10;
  if v < 5.2
     error('Sorry, I need at least Matlab version 5.2')
  end

  if nargin < 3
     desc = [];
  end

  % Check input arguments 
  [r,c] = size(x);
  if c == 2
     c = 1;
     x = x(:,2);
     warning('First column in x-data deleted');
  end
  if ~any([r,c]==1) | all([r,c] == 1)
     error('Input argument x must be a vector')
  end
  if c > r
     x = x';
  end
  [r,c] = size(y);
  if ~any([r,c]==1) | all([r,c] == 1)
     error('Input argument y must be a vector')
  end
  if c > r
     y = y';
  end
  if ~all(size(x)-size(y) == 0)
     error('Input variables x and y must be same size')
  end

  % Setup gui
  f = initreggui;
  set(f,'KeyPressFcn', 'reggui keypress');

  % Stupid check.
  if v >= 5.2
     set(f,'doublebuffer','on')
     gmenu = uicontextmenu;
     uimenu(gmenu,'Label','Grid','Callback','grid');
  end

  RG.x = x;         % X-data
  RG.y = y;         % Y-data
  RG.degree = 1;    % Polynomial degree
  RG.cl = 0.95;     % Confidence-limit
  RG.ols = [];      % indices to outliers
  RG.desc = desc;   % ID-strings, if any
  RG.intercept = 0; % Set intercept to zero if 1
  RG.submean = 0;   % Subtract mean if 1
  RG.mark_ints = 0; % Show intervalls on mouse release if 1
  RG.on_data = 1;   % Mouse action when data point is clicked
  RG.ctype = 0;     % Test; Confinttype (l,u) or m+-d

  set(f,'UserData', RG);
  
  % Set default residual against x
  set(findobj(f, 'Tag', 'regx'),'Value', 2);

  % Setup main axes
  axes(findobj(f, 'Tag', 'MainAxes'))
  ma = gca;
  
  % Grid on by default
  grid on

  % Try to set labels
  if nargin >= 2
     if ~strcmp(inputname(1),inputname(2))
	if ~isempty(inputname(1))
	   set(get(ma,'XLabel'),'String',inputname(1))
	end
	if ~isempty(inputname(2))
	   set(get(ma,'YLabel'),'String',inputname(2))
	end
     end
  end

  % Default mouse action
  set(ma, 'ButtonDownFcn', 'reggui coord');

  % Data points
  h = line('Tag', 'Data', 'XData', [], 'YData', [],'LineStyle','none',...
	   'Marker','*','ButtonDownFcn', 'reggui delpoint',...
	   'Color', [0 0 1]);
  % Add right-click-menu to data points
  jc = jclinetype(h);
  % Outliers
  line('Tag', 'OLS', 'XData', [], 'YData', [],'LineStyle','none',...
       'Marker','*','ButtonDownFcn', 'reggui addpoint',...
       'Color', [1 0 0], 'UIContextMenu', jc);
  % Regression line
  line('Tag', 'RLine', 'XData', [], 'YData', [],'LineStyle','-',...
       'HitTest','off');
  % Confidence intervall for regline
  line('Tag', 'CIU', 'XData', [], 'YData', [],'LineStyle','-.',...
       'HitTest','off', 'Color', [0 0 0.7], 'Visible', 'off');
  line('Tag', 'CIL', 'XData', [], 'YData', [],'LineStyle','-.',...
       'HitTest','off', 'Color', [0 0 0.7], 'Visible', 'off');
  % Prediction intervall
  line('Tag', 'PIU', 'XData', [], 'YData', [],'LineStyle','--',...
       'HitTest','off', 'Color', [0.7 0 0], 'Visible', 'off');
  line('Tag', 'PIL', 'XData', [], 'YData', [],'LineStyle','--',...
       'HitTest','off', 'Color', [0.7 0 0], 'Visible', 'off');

  % Setup residuals
  a = findobj(f, 'Tag', 'ResAxes');
  if v >= 5.2, set(a,'UIContextMenu', gmenu); end
  axes(a)
  line('Tag', 'Res', 'XData', [], 'YData', [],'LineStyle','none',...
       'Marker','*', 'Color', [0 0 1]);
  grid on

  % Setup Normplot axes
  a = findobj(f, 'Tag', 'NormAxes');
  if v >= 5.2, set(a,'UIContextMenu', gmenu); end
  axes(a);
  line('Tag', 'Norm', 'XData', [], 'YData', [],'LineStyle','none',...
       'Marker','*', 'Color', [0 0 1]);
  t = [0.001 0.003 0.01 0.02 0.05 0.10 0.25 0.5 0.75 0.90 ...
       0.95 0.98 0.99 0.997 0.999];
  l = str2mat('0.001','0.003', '0.01','0.02','0.05','0.10','0.25','0.50', ...
	      '0.75','0.90','0.95','0.98','0.99','0.997', '0.999');
  set(a,'YTick', norminvers(t), 'YTickLabel', l);
  grid on

  axes(ma);
  update(f, RG)
  set(f, 'HandleVisibility', 'callback');

 % Recalculate the model
 case 'update' %%%%%%%%
  update;

 % Handle keyboard
 case 'keypress' %%%%%%%%
  ma = findobj(gcbf, 'Tag', 'MainAxes');
  switch get(gcbf, 'CurrentCharacter')
   case 'd'
    dumppoly;

   case 'v'
    use_visible;

   case 't'
    RG = get(gcbf, 'UserData');
    RG.ctype = ~RG.ctype;
    set(gcbf, 'UserData', RG);
    update;

   case 'e'
    RG = get(gcbf, 'UserData');
    assignin('base', 'RegData', RG);

   case 'i'
    RG = get(gcbf, 'UserData');
    delete(findobj(ma,'Type', 'text', 'Tag','ID'));
    if isempty(RG.desc)
       s = num2str((1:length(RG.x))');
    else
       s = RG.desc;
    end
    moveme(text(RG.x+range(RG.x)/50, RG.y, s, 'Tag', 'ID'));

   case 'I'
    delete(findobj(ma,'Type', 'text', 'Tag','ID'));
  end

 % Handle click on data
 case 'delpoint'
  if strcmp(get(gcbf,'SelectionType'),'normal')
     cp = get(gca,'CurrentPoint');
     RG = get(gcbf, 'UserData');
     x = cp(1,1); y = cp(1,2);
     [a,K]=min((RG.x-x).^2 + (RG.y-y).^2);

     h = findobj(gcf,'Tag','LastPoint');
     s = num2str(K);
     if ~isempty(RG.desc)
	s = RG.desc{K};
     end
     set(h, 'String', sprintf('%s x: %0.4g y:%0.4g', s, RG.x(K), RG.y(K)));
  
     switch RG.on_data
      case 2
       % Insert ID in plot
       moveme(text(RG.x(K)+range(RG.x)/50, RG.y(K), s, 'Tag', 'ID'));
      case 3
       % Mark point as outlier
       RG.ols = [RG.ols K];
       set(gcbf, 'UserData', RG);
       text(RG.x(K), RG.y(K),'(  )', 'Color', [1 0 0], 'HitTest','off',...
	    'VerticalAlignment','middle', 'HorizontalAlignment', 'center',...
	    'Clipping','on','Tag', ['(' num2str(K) ')']);
       update;
     end
  end


 % Handle click on data marked as outlier
 case 'addpoint'
  if strcmp(get(gcbf,'SelectionType'),'normal')
     cp = get(gca,'CurrentPoint');
     RG = get(gcbf, 'UserData');
     x = cp(1,1); y = cp(1,2);
     [a,K]=min((RG.x-x).^2 + (RG.y-y).^2);
  
     h = findobj(gcf,'Tag','LastPoint');
     s = num2str(K);
     if ~isempty(RG.desc)
	s = RG.desc{K};
     end
     set(h, 'String', sprintf('%s x: %0.4g y:%0.4g', s, RG.x(K), RG.y(K)));

     switch RG.on_data
      case 2
       moveme(text(RG.x(K)+range(RG.x)/50, RG.y(K), s, 'Tag', 'ID'));
      case 3
       % Remove outlier
       RG.ols = setdiff(RG.ols, K);
       set(gcbf, 'UserData', RG);
       delete(findobj(gca, 'Type', 'text', 'Tag', ['(' num2str(K) ')']));
       update;
     end
  end

 % Handle mouse click on main axes
 case 'coord'
  % Remove confidence intervall marks, if any
  delete(findobj(gca,'Tag','Temp'));
  cp = get(gca,'CurrentPoint');
  RG = get(gcbf, 'UserData');
  h = findobj(gcf,'Tag','LastPoint');
  x = cp(1,1); y = regline(x,RG);
  set(h, 'String', sprintf('x: %0.4g, y: %0.4g', x, y));
  set(gcbf, 'UserData',RG);
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  line(xlim,[y y], 'Tag','TempX', 'LineStyle','--', 'Color',[0 0 0]);
  line([x x], ylim, 'Tag','TempY', 'LineStyle','--', 'Color',[0 0 0]);
  set(gcbf, 'WindowButtonUpFcn', 'reggui up');
  set(gcbf, 'WindowButtonMotionFcn', 'reggui move');
  
 case 'move'
  RG = get(gcbf, 'UserData');
  cp = get(gca,'CurrentPoint');
  h = findobj(gcf,'Tag','LastPoint');
  x = cp(1,1); y = regline(x,RG);
  set(h, 'String', sprintf('x: %0.4g, y: %0.4g', x, y));
  xlim = get(gca,'XLim');
  ylim = get(gca,'YLim');
  h = findobj(gca,'Tag','TempX');
  set(h, 'XData',xlim,'YData', [y y]);
  h = findobj(gca,'Tag','TempY');
  set(h, 'XData',[x x],'YData', ylim);
  
 case 'up'
  RG = get(gcbf, 'UserData');
  cp = get(gca,'CurrentPoint');
  h = findobj(gcf,'Tag','LastPoint');
  x = cp(1,1); [y,CL,CU,PL,PU,KL,KU] = regline(x,RG);
  if KU < Inf
     set(h, 'String', ...
	    sprintf(['x: %0.4g, y: %0.4g  ConfI:%s  '...
		     'PredI:%s  CalibI:%s'],...
		    x, y, int_str(RG.ctype,CL, CU), ...
		    int_str(RG.ctype,PL, PU), int_str(RG.ctype,KL, KU)));
  else
     set(h, 'String', ...
     sprintf('x: %0.4g, y: %0.4g  ConfI:%s  PredI:%s',...
	     x, y, int_str(RG.ctype,CL,CU), int_str(RG.ctype,PL, PU)));
%     sprintf('x: %0.4g, y: %0.4g  ConfI:(%0.4g,%0.4g)  PredI:(%0.4g,%0.4g)',...
%	     x, y, CL, CU, PL, PU));
  end
  if RG.mark_ints
     xl = get(gca,'XLim');
     yl = get(gca,'YLim');
     if (KU < Inf) & (cp(1,2) > y)
	line([xl(1) KU KU], [y y yl(1)], 'Tag','Temp','HitTest','off');
	line([KL KL; x x]', [yl(1) y; yl(1) y]','Tag','Temp','HitTest','off');
     else
	line([xl(1) x x], [PU PU yl(1)], 'Tag','Temp','HitTest','off');
	line([xl(1) x], [y y],'Tag','Temp','HitTest','off');
	line([xl(1) x], [CU CU],'Tag','Temp','HitTest','off');
	line([xl(1) x], [CL CL],'Tag','Temp','HitTest','off');
	line([xl(1) x], [PL PL],'Tag','Temp','HitTest','off');
     end
  end
  delete(findobj(gca,'Tag','TempX'));
  delete(findobj(gca,'Tag','TempY'));
  set(gcbf, 'WindowButtonUpFcn', '');
  set(gcbf, 'WindowButtonMotionFcn', '');

 % Zoom
 case 'zoom_down'
  cp = get(gca,'CurrentPoint'); cp = cp(1,1:2);
  xlim = get(gca,'XLim');
  rx = diff(xlim);
  ylim = get(gca,'YLim');
  ry = diff(ylim);
  set(findobj(gcf,'Tag','lock_scale'), 'Value', 1);
  if strcmp(get(gcbf,'SelectionType'),'normal')
    % Zoom in
    r = rbbox;
    cp2 = get(gca,'CurrentPoint'); cp2 = cp2(1,1:2);
    nx=[cp(1);cp2(1)]; nx = [min(nx) max(nx)];
    ny=[cp(2);cp2(2)]; ny = [min(ny) max(ny)];
    if (diff(nx) < rx/50) | (diff(ny) < ry/50)
       set(gca, 'YLimMode', 'manual', 'XLimMode', 'manual',...
		'XLim', cp(1)+[-1 1]*rx/3, 'YLim', cp(2)+[-1 1]*ry/3);
    else
       set(gca, 'YLimMode', 'manual', 'XLimMode', 'manual',...
		'XLim', nx, 'YLim', ny);
    end
  else
     % Zoom out
     set(gca, 'YLimMode', 'manual', 'XLimMode', 'manual',...
	      'XLim', xlim+[-1 1]*rx/2, 'YLim', ylim+[-1 1]*ry/2);
  end

 % Toggle subtract intercept
 case 'intercept' %%%%%%%%
  h = findobj(gcbf,'Tag','submean');
  RG = get(gcbf, 'UserData');
  RG.submean = get(h,'Value');
  RG.intercept = get(gcbo,'Value');
  if RG.submean & RG.intercept
    set(h, 'Value', 0);
    RG.submean = 0;
  end
  set(gcbf, 'UserData', RG);
  update;

 % Toggle subtract mean
 case 'submean' %%%%%%%%
  h = findobj(gcbf,'Tag','intercept');
  RG = get(gcbf, 'UserData');
  RG.submean = get(gcbo,'Value');
  RG.intercept = get(h,'Value');
  if RG.submean & RG.intercept
    set(h, 'Value', 0);
    RG.intercept = 0;
  end
  set(gcbf, 'UserData', RG);
  update;

 % Set model order
 case 'degree' %%%%%%%%
  RG = get(gcbf, 'UserData');
  RG.degree = get(gcbo, 'Value');
  set(gcbf, 'UserData', RG);
  update;
  
 case 'test' %%%%%%%%
  RG = get(gcbf, 'UserData');
  n=10;
  RG.x=(1:n)';
  RG.y=randn(n,1)*10+3+2*RG.x;
  RG.ols = [];
  set(gcbf, 'UserData', RG);
  update;

 % Set confidence limit
 case 'climit' %%%%%%%%
  RG = get(gcbf, 'UserData');
  val = get(gcbo, 'Value');
  str = get(gcbo, 'String');
  RG.cl = str2num(str{val});
  set(gcbf, 'UserData', RG);
  update;
 
 % Make a copy of current axes in a new figure 
 case 'clone'
  s = gca;
  f = figure;
  % Check were a new axes is placed
  a = axes;
  p = get(a,'Position');
  delete(a);
  copyobj(s, f);
  set(gca,'Position',p, 'ButtonDownFcn','')
  set(findobj(f, 'Type', 'line'), 'ButtonDownFcn','' ,'HitTest','on')

 % Toggle grid
 case 'grid'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  axes(ma)
  grid
  if strcmp(get(ma, 'YGrid'), 'on')
     set(gcbo, 'Value', 1)
  else
     set(gcbo, 'Value', 0)
  end

 case 'lock_scale'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  if strcmp(get(ma, 'YLimMode'), 'auto')
     set(gca, 'YLimMode', 'manual', 'XLimMode', 'manual');
     set(gcbo, 'Value', 1)
  else
     set(gca, 'YLimMode', 'auto', 'XLimMode', 'auto');
     set(gcbo, 'Value', 0)
  end

 % Toggle visibility of PI
 case 'pred_int'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  if get(gcbo, 'Value')
     newval = 'on';
  else
     newval = 'off';
  end
  set(findobj(ma, 'Tag', 'PIU'), 'Visible', newval);
  set(findobj(ma, 'Tag', 'PIL'), 'Visible', newval);

 % Toggle visibility of CI
 case 'conf_int'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  if get(gcbo, 'Value')
     newval = 'on';
  else
     newval = 'off';
  end
  set(findobj(ma, 'Tag', 'CIU'), 'Visible', newval);
  set(findobj(ma, 'Tag', 'CIL'), 'Visible', newval);

 % Select mouse action - not on data
 case 'mouse'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  if get(gcbo, 'Value') == 1
     set(ma, 'ButtonDownFcn', 'reggui coord');
  else
     set(ma, 'ButtonDownFcn', 'reggui zoom_down');
  end

 % Select mouse action - on data points
 case 'on_data'
  RG = get(gcbf, 'UserData');
  RG.on_data = get(gcbo, 'Value');
  set(gcbf, 'UserData', RG);

 % Toggle show ints on mouse release
 case 'mark_ints'
  RG = get(gcbf, 'UserData');
  RG.mark_ints = get(gcbo, 'Value');
  set(gcbf, 'UserData', RG);

 % Delete confidence marks
 case 'clear_marks'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  delete(findobj(ma,'Tag','Temp'));

 % Insert id - text for _all_ points
 case 'ident'
  RG = get(gcbf, 'UserData');
  delete(findobj(ma,'Type', 'text', 'Tag','ID'));
  if isempty(RG.desc)
     s = num2str((1:length(RG.x))');
  else
     s = RG.desc;
  end
  moveme(text(RG.x+range(RG.x)/50, RG.y, s, 'Tag', 'ID'));

 % Delete all ID's
 case 'deident'
  ma = findobj(gcf, 'Tag', 'MainAxes');
  delete(findobj(ma,'Type', 'text', 'Tag','ID'));

 % Remove outliers
 case 'deout'
  RG = get(gcbf, 'UserData');
  for K=RG.ols
     delete(findobj(ma, 'Type', 'text', 'Tag', ['(' num2str(K) ')']));
  end
  RG.ols = [];
  set(gcbf, 'UserData', RG);
  update;
  
 case 'close'
  close(gcbf)
  
 otherwise
  error(['Unknown action: ' action])
end


%%%%%%%%%%%%%%%%%%%%%%
function update(f, RG)
   if nargin < 1
      f = gcf;
      RG = get(f, 'UserData');
   end
  
   ma = findobj(f, 'Tag', 'MainAxes');
   delete(findobj(gca,'Tag','Temp'));

   x = RG.x; x(RG.ols)=[];
   y = RG.y; y(RG.ols)=[];
   RG.mx = mean(x);
   RG.my = mean(y);
   r = range(RG.x);
%r = r*40;
   % x-values for regline and intervalls
   xl = linspace(min(RG.x)-r/20, max(RG.x)+r/20)';

   U = makeU(x, RG);
   XL = makeU(xl, RG);

   [n,k] = size(U);
   if (n-k) < 1
      error('To few degrees of freedom')
   else
      RG.kv = tinvers(1-(1-RG.cl)/2, n-k);
   end

   RG.b = U\y;

   RG.res = y - U*RG.b;
   RG.Q0 = sum(RG.res.^2);
   RG.s = sqrt(RG.Q0/(n-k));
   RG.Sxx = sum((x-RG.mx).^2);
   RG.Syy = sum((y-mean(y)).^2);
   RG.R2 = 1-RG.Q0/RG.Syy;
   RG.UPU = inv(U'*U);

   % Mean errors and quantiles for parameters
   db = RG.s * RG.kv * sqrt(diag(RG.UPU));
   % Confidence intervalls for parameters
   RG.CIb = [RG.b-db RG.b+db];
   % Significant if all confidence limits have same sign
   sig = all(RG.CIb(:,1).*RG.CIb(:,2) > 0);

   % Data
   h = findobj(ma, 'Tag', 'Data');
   set(h, 'XData', x, 'YData', y);
   if sig
      col = [0 0 1];
   else
      col = [1 0 0];
   end

   [yl,CL,CU,PL,PU] = regline(xl,RG);
   % Regression line
   h = findobj(ma, 'Tag', 'RLine');
   set(h, 'XData', xl, 'YData', yl, 'Color', col);

   % Outliers
   h = findobj(ma, 'Tag', 'OLS');
   set(h, 'XData', RG.x(RG.ols), 'YData', RG.y(RG.ols));

   % Prediction Intervall
   set(findobj(ma, 'Tag', 'PIU'), 'XData', xl, 'YData', PU);
   set(findobj(ma, 'Tag', 'PIL'), 'XData', xl, 'YData', PL);

   % Confidence intervall
   set(findobj(ma, 'Tag', 'CIU'), 'XData', xl, 'YData', CU);
   set(findobj(ma, 'Tag', 'CIL'), 'XData', xl, 'YData', CL);

   % Residuals
   a = findobj(f, 'Tag', 'ResAxes');
   rxv = get(findobj(f, 'Tag', 'regx'),'Value');
   switch rxv
    case 2
     rx = x;
    case 3
     rx = y;
    otherwise
     rx = (1:n)';
   end
   h = findobj(a, 'Tag', 'Res');
   set(h, 'XData', rx, 'YData', RG.res);

   % Normplot of residuals
   a = findobj(f, 'Tag', 'NormAxes');
   h = findobj(a, 'Tag', 'Norm');
   set(h, 'XData', sort(RG.res), 'YData', norminvers(((1:n)-0.5)/n))

   set(f, 'UserData', RG);

   h = findobj(f, 'Tag', 'Estimate');
   if RG.ctype == 0
      set(h , 'String', {...
	  'Estimated parameters',...
	  sprintf('Q0 = %0.4g', RG.Q0),...
	  sprintf('s = %0.4g', RG.s),...
	  sprintf('R2 = %0.4g', RG.R2),...
	  'b* = ',...
	  sprintf('  %0.4g  (%0.4g,%0.4g)\n', [RG.b RG.CIb]')});
   else
      set(h , 'String', {...
	  'Estimated parameters',...
	  sprintf('Q0 = %0.4g', RG.Q0),...
	  sprintf('s = %0.4g', RG.s),...
	  sprintf('R2 = %0.4g', RG.R2),...
	  'b* = ',...
	  sprintf('  %0.4g ± %0.4g\n', [RG.b diff(RG.CIb')'/2]')});
   end



function [y,CL,CU,PL,PU,KL,KU] = regline(x, RG)

   U = makeU(x,RG);
   y = U*RG.b;

   if nargout > 1
      k = RG.s*RG.kv;
      C = U*RG.UPU*U';
      d1 = k*sqrt(diag(C));
      d2 = k*diag(sqrt(1+C));
%assignin('base', 'CM', RG.s*U*RG.UPU*U'); % Testing
      CL = y - d1;
      CU = y + d1;
      PL = y - d2;
      PU = y + d2;
      if nargout > 5
	 % Calibration. Only valid for order 1 and significant slope.
	 if (RG.degree==1) & (length(x)==1) & (RG.CIb(end,1)*RG.CIb(end,2) > 0)
	    n = length(RG.x)-length(RG.ols);
	    b = RG.b(end);
	    mx = RG.mx;
	    sxx = RG.Sxx;
	    k2 = k^2;
	    if length(RG.b)==1 % y = bx
	       txx = sxx + n * mx^2;
	       c = txx*b^2-k2;
	       m = txx*y*b/c;
	       d = k*sqrt(txx*(txx*b^2+y^2-k2))/c;
	       KL = m - d;
	       KU = m + d;
	    else
	       c = b^2-k2/sxx;
	       my = RG.my;
	       m = mx+b*(y-my)/c;
	       d = k/c*sqrt(c*(1+1/n)+(y-my)^2/sxx);
	       KL = m - d;
	       KU = m + d;
	    end
	    if any(imag([KU KL])) | (KU < KL)
	       KL = -Inf;
	       KU = Inf;
	    end
	 else
	    KL = -Inf;
	    KU = Inf;
	 end
      end
   end


function U = makeU(x, RG)

   n = length(x);
   m = RG.degree + 1 - RG.intercept;
   U = zeros(n,m);
   mx = 0;

   if RG.submean
      mx = RG.x;
      mx(RG.ols) = [];
   end

   if ~RG.intercept
      U(:,1) = ones(n,1);
      for k = 2:m;
	 U(:,k) = x.^(k-1) - mean(mx.^(k-1));
      end
   else
      for k = 1:m
	 U(:,k) = x.^k - mean(mx.^k);
      end
   end

function s = int_str(type, lower, upper)
   if type == 0
      s = sprintf('(%0.4g,%0.4g)',[lower upper]);
   else
      s = sprintf('%0.4g±%0.4g',(upper+lower)/2, (upper-lower)/2);
   end


function r = range(x)
   r = max(x)-min(x);

function x = norminvers(y)
   x = -sqrt(2)*erfinv(1-2*y);


function x = tinvers(y, f);
% t-förd. förd.funkt. invers för x > 0 (y > 0.5)

   e = 1e-6; % 100*eps;
   fh = f*0.5;
   fhph = fh+0.5;
   k = exp(gammaln(fhph)-gammaln(fh))/sqrt(pi*f);

   x = 2;
   yk = 1-betainc(f/(f+x^2), fh, 0.5)*0.5;

   while abs(yk-y) > e
      % Newton-Raphson: x = x - (F-y)/f
      x = x - (yk-y)/(k/(1+x^2/f).^fhph);
      yk = 1-betainc(f/(f+x^2), fh, 0.5)*0.5;
   end


function dumppoly

   RG = get(gcf,'UserData');
   x = RG.x; x(RG.ols) = [];
   s = 'y = ';
   n = 1;
   if ~RG.intercept
      s = [s sprintf('%0.4g', RG.b(1))];
      n = 2;
   end
   si = '';
   if RG.b(n) >= 0 & n == 2
      si = '+';
   end
   s = [s sprintf('%s%0.4g',si,RG.b(n))];
   if RG.submean
      mx = mean(x);
      si = '+';
      if mx >= 0
         si = '-';
      end
      s = [s sprintf('*(x%s%0.4g)',si, abs(mx))];
   else
      s = [s '*x'];
   end
   d = 2;
   for k=n+1:length(RG.b)
      si = '';
      if RG.b(k) >= 0
         si = '+';
      end
      s = [s sprintf('%s%0.4g',si,RG.b(k))];
      if RG.submean
         mx = mean(x.^d);
         si = '+';
         if mx >= 0
            si = '-';
         end
         s = [s sprintf('*(x.^%d%s%0.4g)', d, si, abs(mx))];
      else
         s = [s sprintf('*x.^%d', d)];
      end
      d = d + 1;
   end
   disp(s);



function use_visible;

   RG = get(gcbf, 'UserData');
   ma = findobj(gcf, 'Tag', 'MainAxes');
   for K=RG.ols
      delete(findobj(ma, 'Type', 'text', 'Tag', ['(' num2str(K) ')']));
   end
   xl = get(ma, 'XLim');
   yl = get(ma, 'YLim');
   RG.ols = find(RG.x > xl(2) | RG.x < xl(1) | RG.y > yl(2) | RG.y < yl(1))';
   set(gcbf, 'UserData', RG);
   for K=RG.ols
      text(RG.x(K), RG.y(K),'(  )', 'Color', [1 0 0], 'HitTest','off',...
	   'VerticalAlignment','middle', 'HorizontalAlignment', 'center',...
	   'Clipping','on','Tag', ['(' num2str(K) ')']);
   end
   update;
