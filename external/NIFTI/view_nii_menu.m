%  Imbed Zoom, Interp, and Info menu to view_nii window.
%
%  Usage: view_nii_menu(fig);
%

%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
%--------------------------------------------------------------------
function menu_hdl = view_nii_menu(fig, varargin)

   if isnumeric(fig)
      menu_hdl = init(fig);
      return;
   end

   menu_hdl = [];

   switch fig
   case 'interp'
      if nargin > 1
         fig = varargin{1};
      else
         fig = gcbf;
      end

      nii_menu = getappdata(fig, 'nii_menu');
      interp_on_state = get(nii_menu.Minterp,'Userdata');

      if (interp_on_state == 1)
         opt.useinterp = 1;
         view_nii(fig,opt);
         set(nii_menu.Minterp,'Userdata',0,'Label','Interp off');
         reset_zoom(fig);
      else
         opt.useinterp = 0;
         view_nii(fig,opt);
         set(nii_menu.Minterp,'Userdata',1,'Label','Interp on');
         reset_zoom(fig);
      end
   case 'reset_zoom'
      if nargin > 1
         fig = varargin{1};
      else
         fig = gcbf;
      end

      reset_zoom(fig);
   case 'orient'
      orient;
   case 'img_info'
      img_info;
   case 'save_disp'
      save_disp;
   end

   return					% view_nii_menu


%--------------------------------------------------------------------
function menu_hdl = init(fig)

   %  search for edit, view menu
   %
   nii_menu.Mfile = [];
   nii_menu.Medit = [];
   nii_menu.Mview = [];
   menuitems = findobj(fig, 'type', 'uimenu');

   for i=1:length(menuitems)
      filelabel = get(menuitems(i),'label');

      if strcmpi(strrep(filelabel, '&', ''), 'file')
         nii_menu.Mfile = menuitems(i);
      end

      editlabel = get(menuitems(i),'label');

      if strcmpi(strrep(editlabel, '&', ''), 'edit')
         nii_menu.Medit = menuitems(i);
      end

      viewlabel = get(menuitems(i),'label');

      if strcmpi(strrep(viewlabel, '&', ''), 'view')
         nii_menu.Mview = menuitems(i);
      end
   end

   set(fig, 'menubar', 'none');

   if isempty(nii_menu.Mfile)
      nii_menu.Mfile = uimenu('Parent',fig, ...
   	   'Label','File');

      nii_menu.Mfile_save = uimenu('Parent',nii_menu.Mfile, ...
   	   'Label','Save displayed image as ...', ...
           'Callback','view_nii_menu(''save_disp'');');
   else
      nii_menu.Mfile_save = uimenu('Parent',nii_menu.Mfile, ...
   	   'Label','Save displayed image as ...', ...
           'separator','on', ...
           'Callback','view_nii_menu(''save_disp'');');
   end

   if isempty(nii_menu.Medit)
      nii_menu.Medit = uimenu('Parent',fig, ...
   	   'Label','Edit');

      nii_menu.Medit_orient = uimenu('Parent',nii_menu.Medit, ...
   	   'Label','Convert to RAS orientation', ...
           'Callback','view_nii_menu(''orient'');');
   else
      nii_menu.Medit_orient = uimenu('Parent',nii_menu.Medit, ...
   	   'Label','Convert to RAS orientation', ...
           'separator','on', ...
           'Callback','view_nii_menu(''orient'');');
   end

   if isempty(nii_menu.Mview)
      nii_menu.Mview = uimenu('Parent',fig, ...
   	   'Label','View');

      nii_menu.Mview_info = uimenu('Parent',nii_menu.Mview, ...
   	   'Label','Image Information', ...
           'Callback','view_nii_menu(''img_info'');');
   else
      nii_menu.Mview_info = uimenu('Parent',nii_menu.Mview, ...
   	   'Label','Image Information', ...
           'separator','on', ...
           'Callback','view_nii_menu(''img_info'');');
   end

   nii_menu.Mzoom = rri_zoom_menu(fig);

   nii_menu.Minterp = uimenu('Parent',fig, ...
   	   'Label','Interp on', ...
	   'Userdata', 1, ...
           'Callback','view_nii_menu(''interp'');');

   setappdata(fig,'nii_menu',nii_menu);
   menu_hdl = nii_menu.Minterp;

   return					% init


%----------------------------------------------------------------
function reset_zoom(fig)

   old_handle_vis = get(fig, 'HandleVisibility');
   set(fig, 'HandleVisibility', 'on');

   nii_view = getappdata(fig, 'nii_view');
   nii_menu = getappdata(fig, 'nii_menu');

   set(nii_menu.Mzoom,'Userdata',1,'Label','Zoom on');
   set(fig,'pointer','arrow');
   zoom off;

   axes(nii_view.handles.axial_axes);
   setappdata(get(gca,'zlabel'), 'ZOOMAxesData', ...
			[get(gca, 'xlim') get(gca, 'ylim')])
%   zoom reset;
 %  zoom getlimits;
   zoom out;

   axes(nii_view.handles.coronal_axes);
   setappdata(get(gca,'zlabel'), 'ZOOMAxesData', ...
			[get(gca, 'xlim') get(gca, 'ylim')])
%   zoom reset;
 %  zoom getlimits;
   zoom out;

   axes(nii_view.handles.sagittal_axes);
   setappdata(get(gca,'zlabel'), 'ZOOMAxesData', ...
			[get(gca, 'xlim') get(gca, 'ylim')])
%   zoom reset;
 %  zoom getlimits;
   zoom out;

   set(fig, 'HandleVisibility', old_handle_vis);

   return;					% reset_zoom


%----------------------------------------------------------------
function img_info

   nii_view = getappdata(gcbf, 'nii_view');
   hdr = nii_view.nii.hdr;

   max_value = num2str(double(max(nii_view.nii.img(:))));
   min_value = num2str(double(min(nii_view.nii.img(:))));

   dim = sprintf('%d  %d  %d', double(hdr.dime.dim(2:4)));
   vox = sprintf('%.3f  %.3f  %.3f', double(hdr.dime.pixdim(2:4)));

   if double(hdr.dime.datatype) == 1
      type = '1-bit binary';
   elseif double(hdr.dime.datatype) == 2
      type = '8-bit unsigned integer';
   elseif double(hdr.dime.datatype) == 4
      type = '16-bit signed integer';
   elseif double(hdr.dime.datatype) == 8
      type = '32-bit signed integer';
   elseif double(hdr.dime.datatype) == 16
      type = '32-bit single float';
   elseif double(hdr.dime.datatype) == 64
      type = '64-bit double precision';
   elseif double(hdr.dime.datatype) == 128
      type = '24-bit RGB true color';
   elseif double(hdr.dime.datatype) == 256
      type = '8-bit signed integer';
   elseif double(hdr.dime.datatype) == 511
      type = '96-bit RGB true color';
   elseif double(hdr.dime.datatype) == 512
      type = '16-bit unsigned integer';
   elseif double(hdr.dime.datatype) == 768
      type = '32-bit unsigned integer';
   elseif double(hdr.dime.datatype) == 1024
      type = '64-bit signed integer';
   elseif double(hdr.dime.datatype) == 1280
      type = '64-bit unsigned integer';
   end

   msg = {};
   msg = [msg {''}];
   msg = [msg {['Dimension:  [', dim, ']']}];
   msg = [msg {''}];
   msg = [msg {['Voxel Size:  [', vox, ']']}];
   msg = [msg {''}];
   msg = [msg {['Data Type:  [', type, ']']}];
   msg = [msg {''}];
   msg = [msg {['Max Value:  [', max_value, ']']}];
   msg = [msg {''}];
   msg = [msg {['Min Value:  [', min_value, ']']}];
   msg = [msg {''}];

   if isfield(nii_view.nii, 'fileprefix')
      if isfield(nii_view.nii, 'filetype') & nii_view.nii.filetype == 2
         msg = [msg {['File Name:  [', nii_view.nii.fileprefix, '.nii]']}];
         msg = [msg {''}];
      elseif isfield(nii_view.nii, 'filetype')
         msg = [msg {['File Name:  [', nii_view.nii.fileprefix, '.img]']}];
         msg = [msg {''}];
      else
         msg = [msg {['File Prefix:  [', nii_view.nii.fileprefix, ']']}];
         msg = [msg {''}];
      end
   end

   h = msgbox(msg, 'Image Information', 'modal');
   set(h,'color',[1 1 1]);

   return;					% img_info


%----------------------------------------------------------------
function orient

   fig = gcbf;
   nii_view = getappdata(fig, 'nii_view');
   nii = nii_view.nii;

   old_pointer = get(fig,'Pointer');
   set(fig,'Pointer','watch');

   [nii orient] = rri_orient(nii);

   if isequal(orient, [1 2 3])		% do nothing
      set(fig,'Pointer',old_pointer);
      return;
   end

   oldopt = view_nii(fig);
   opt.setarea = oldopt.area;
   opt.usecolorbar = oldopt.usecolorbar;
   opt.usecrosshair = oldopt.usecrosshair;
   opt.usestretch = oldopt.usestretch;
   opt.useimagesc = oldopt.useimagesc;
   opt.useinterp = oldopt.useinterp;
   opt.command = 'updatenii';

   view_nii(fig, nii, opt);
   set(fig,'Pointer',old_pointer);
   reset_zoom(fig);

   return;					% orient


%----------------------------------------------------------------
function save_disp

   [filename pathname] = uiputfile('*.*', 'Save displayed image as (*.nii or *.img)');

   if isequal(filename,0) | isequal(pathname,0)
      return;
   else
      out_imgfile = fullfile(pathname, filename);	% original image file
   end

   old_pointer = get(gcbf,'Pointer');
   set(gcbf,'Pointer','watch');

   nii_view = getappdata(gcbf, 'nii_view');
   nii = nii_view.nii;

   try
      save_nii(nii, out_imgfile);
   catch
      msg = 'File can not be saved.';
      msgbox(msg, 'File write error', 'modal');
   end

   set(gcbf,'Pointer',old_pointer);

   return;					% save_disp

