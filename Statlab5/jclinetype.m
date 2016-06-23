function h = jclinetype(arg)
% JCLINETYPE - Adds contextmenu to line
%

%
% Copyright 1999 Joakim Lübeck
%

if nargin < 1
  error('Need more arguments')
end

if ~isstr(arg)
  cmenu = uicontextmenu;
  set(arg, 'UIContextMenu', cmenu);
  crmenu(cmenu, '.')
  crmenu(cmenu, 'o')
  crmenu(cmenu, 'x')
  crmenu(cmenu, '*')
  crmenu(cmenu, 'square', 's')
  crmenu(cmenu, 'diamond', 'd')
  crmenu(cmenu, 'triangle', 'v')
  crmenu(cmenu, 'pentagram', 'p')
  crmenu(cmenu, 'hexagram', 'h')

  if nargout > 0
    h = cmenu;
  end
else
  set(gco,'Marker', arg);
end


function crmenu(m, l, a)
if nargin < 3
  a = l;
end
uimenu(m, 'Label', l, 'Callback', ['jclinetype ' a]);
