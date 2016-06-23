function moveme(arg)
% MOVEME - make text objects movable and deletable
%
% Left click and drag move selected textobject.
% Right click (or Ctrl Left) deletes the text object
%
% Ex.
%
%    moveme(text(1,2,'Hello'))
%
%    h = text(1,2,'Hello'); set(h, 'ButtonDownFcn', 'moveme init');
%
%    moveme - make all text objects in current figure movable

if nargin < 1
   %error('Need more arguments')
   arg = findobj(gcf,'Type', 'text');
end

if ~isstr(arg)
   arg = findobj(arg,'type', 'text');
   if isempty(arg)
      error('No text objects found');
   end
   set(arg,'ButtonDownFcn', 'moveme init', 'HitTest', 'on');
else
   global MM
   switch (arg)
    case 'init'
     if strcmp(get(gcf,'SelectionType'),'alt')
	delete(gcbo)
     else
	MM.mm = get(gcbf, 'WindowButtonMotionFcn');
	MM.mu = get(gcbf, 'WindowButtonUpFcn');
	set(gcbf, 'WindowButtonMotionFcn', 'moveme move');
	set(gcbf, 'WindowButtonUpFcn', 'moveme up');
	cp = get(gca, 'CurrentPoint');
	MM.ox = cp(1,1); MM.oy = cp(1,2);
	MM.op = get(gcbo, 'Position');
     end

    case 'move'
     cp = get(gca, 'CurrentPoint');
     x = cp(1,1); y = cp(1,2);
     set(gco, 'Position', [MM.op(1)+x-MM.ox MM.op(2)+y-MM.oy MM.op(3:end)]);

    case 'up'
     cp = get(gca, 'CurrentPoint');
     x = cp(1,1); y = cp(1,2);
     np = [MM.op(1)+x-MM.ox MM.op(2)+y-MM.oy MM.op(3:end)];
     set(gco, 'Position', np);
     set(gcbf, 'WindowButtonMotionFcn', MM.mm);
     set(gcbf, 'WindowButtonUpFcn', MM.mu);
     clear global MM
     if strcmp(get(gcf,'SelectionType'),'extend')
	fprintf('New Position: [ ');
	fprintf('%f ', np);
	fprintf(']\n');
     end

    otherwise
     error('Invalid argument');
     clear global MM
   end
end
