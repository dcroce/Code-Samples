classdef Setup < handle
    
    properties
        beam_obj; % The Beam being considered in the setup
        SetupGUI = []; % The GUI object associated with the setup
    end
    
    methods
        
        % Constructor
        function obj = Setup(beam)
            if nargin == 1
                obj.beam_obj = beam;
            elseif nargin == 0
                
            else
                error('Wrong number of inputs to Setup()!');
            end
        end
    end
    
    methods (Static)
        

        % GUI Code
        function StartGUI()
            
            % Initialization of figure, panels, variables
            setup_obj = Setup() ;
            gui_fig = figure('Units', 'normalized','Position', [0 0 1 1]);
            
            tabgp = uitabgroup(gui_fig,'Position',[0 0 1 1]);
            tab_beam = uitab(tabgp,'Title','Beam Solver');
            tab_truss = uitab(tabgp,'Title','Truss Solver');
            
            [numx,texx] = xlsread('crossSectionSI.xlsx'); %numx in units of mm^4
            xsectionOptions = char(transpose(texx(3:178,1)));
            
            [numm,texm] = xlsread('Materials Table SI.xlsx'); %numm in units of GPa
            materialsOptions = char(transpose(texm(:,1)));
            
            
            inputPanel = uipanel('Parent',tab_beam,...
                         'Position', [0 0 0.15 1],...
                         'Title', 'Input Data') ;% the beam panel
                     
            supportPanel = uipanel('Parent',tab_beam,...
                         'Position', [0.15 0 0.45 1],...
                         'Title', 'Supports and Loadings');% the middle panel
                     
            dataPanel = uipanel('Parent',tab_beam,...
                         'Position', [0.6 0 0.4 1],...
                         'Title','Moment and Shear Diagrams');% the data panel
                     
            % INPUT PANEL WORK
                     
            materialText = uicontrol(inputPanel,'Style','text',...
                                'String','Select Material',...
                                'Units','normalized',...
                                'Position',[0,.85,1,.1]);
                            
            materialMenu = uicontrol(inputPanel,'Style','popupmenu',...
                                'String',{materialsOptions},...
                                'Value',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.17,.8,.7,.1]);
                            
            xsectionText = uicontrol(inputPanel,'Style','text',...
                                'String','Select Cross Section',...
                                'Units','normalized',...
                                'Position',[0,.65,1,.1]);
                            
            xsectionMenu = uicontrol(inputPanel,'Style','popupmenu',...
                                'String',{xsectionOptions},...
                                'Value',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.17,.6,.7,.1]);
                            
            lengthText = uicontrol(inputPanel,'Style','text',...
                                'String','Enter a length (m)',...
                                'Units','normalized',...
                                'Position',[0,.48,1,.1]);
            lengthEdit = uicontrol(inputPanel,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.3,.46,.4,.07]);
                            
            submitButton = uicontrol('Parent',inputPanel, 'String','Create Beam',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.2 0.275 0.6 0.1],'Callback',@create_beam_callback);
                         
            clear_all_Button = uicontrol('Parent',inputPanel, 'String','Clear All ',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.2 0.075 0.6 0.1],'Callback',@clear_all_callback);
                         
                         
            function create_beam_callback(hObject,eventdata)
                    length = str2double(lengthEdit.String);
                    if length <= 0
                        errordlg('Enter a length greater than 0!','Input Data Error','modal')
                        return
                    elseif isnan(length)
                        errordlg('You must enter a number!','Input Data Error','modal')
                        return
                    else
                    I_value = numx(xsectionMenu.Value)*10^-12; %in m^4
                    E_value = numm(materialMenu.Value)*10^9; %in Pa
                    
                    setup_obj.beam_obj = Beam(length,E_value,I_value);
                    
                    cla(supportAxes)
                    plot(supportAxes,[0 length],[0 0],'k-','LineWidth',15);
                    supportAxes.XLim = [0-.05*length 1.05*length];
                    supportAxes.YLim = [-1 1];
                    supportAxes.XTick = [0 length];
                    supportAxes.YTick = [];
                    hold on
                    end
                    
            end
            
            % SUPPORT PANEL WORK
            supportAxes = axes('Parent',supportPanel,'Box','on',...
                               'Position',[.1 .47 .8 .5],...
                               'XLim',[0 1],...
                               'XTick',[0 1],'YLim',[-1 1],...
                               'YTick',[]);                
            
            supportGroup = uibuttongroup('Parent',supportPanel,...
                                'Title','Add Support','TitlePosition','centertop',...
                                'Units','normalized',...
                                'Position',[0,0,.4,.4]);              
            supportButtons{1} = uicontrol(supportGroup,'Style','radiobutton',...
                                'String','Pin',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.1,.9,.5,.1]);
            supportButtons{2} = uicontrol(supportGroup,'Style','radiobutton',...
                                'String','Roller',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.1,.8,.5,.1]);
            supportButtons{3} = uicontrol(supportGroup,'Style','radiobutton',...
                                'String','Fixed End',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.1,.7,.5,.1]);
                            
            supportPosText = uicontrol(supportGroup,'Style','text',...
                                'String','Input Support Position (m)',...
                                'Units','normalized',...
                                'Position',[0,.5,1,.1]); 
                            
            supportPosEdit = uicontrol(supportGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.15,.35,.7,.15]);
                            
             supportButton = uicontrol('Parent',supportPanel, 'String','Add Support',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.075 0.03 0.25 0.05],'Callback',@add_support_callback);  
                                      
                         
            function add_support_callback(hObject,eventdata)
                if isempty(setup_obj.beam_obj)
                    errordlg('Create beam before adding supports!','Add Support Error','modal')
                    return
                elseif size(setup_obj.beam_obj.SupportStruct,2) >= 4
                    errordlg('Cannot have more than 4 supports!','Add Support Error','modal')
                    return
                else
                    
                    support_position = str2double(supportPosEdit.String);
                    normal_position = support_position/setup_obj.beam_obj.L;
                    
                    %normalized position
                    if normal_position > 1 || normal_position < 0 || isnan(support_position)
                        errordlg('Enter a valid position between 0 and the beam length','Add Support Error','modal')
                        return
                    else
                        for i = 1:size(setup_obj.beam_obj.SupportStruct,2)
                            if normal_position == setup_obj.beam_obj.SupportStruct(i).Position    
                            errordlg('Already a support at that position','Add Support Error','modal')
                            return
                            end
                        end
                        if supportButtons{1}.Value == 1
                            %Add Pin support at support position
                            Pin(setup_obj.beam_obj, normal_position);

                            %add pin to plot
                            hold(supportAxes,'on')
                            h = plot(supportAxes,support_position,-.14,'^','MarkerSize',23,...
                                'MarkerFaceColor','b','MarkerEdgeColor','b') ;
                            uistack(h,'bottom')

                        elseif supportButtons{2}.Value == 1
                            %Add Roller support at support position
                            Roller(setup_obj.beam_obj, normal_position);
                            
                            %add roller to plot
                            hold(supportAxes,'on')
                            h = plot(supportAxes,support_position,-.12,'.','MarkerSize',80,...
                                'MarkerFaceColor','b','MarkerEdgeColor','b') ;
                            uistack(h,'bottom')

                        elseif supportButtons{3}.Value == 1
                            %Add Fixed End at support position
 
                            if normal_position ==1 || normal_position == 0
                               FixedEnd(setup_obj.beam_obj, normal_position); 

                                %add roller to plot
                                hold(supportAxes,'on')
                                h = plot(supportAxes,[support_position support_position],[-.5 .5],...
                                    'Color','b','LineWidth',5) ;
                                uistack(h,'bottom')

                            else
                                errordlg('Must add fixed end at position 0 or at the length of beam!','Add Support Error','modal')
                                return
                            end 
                        end
                    end
                end
            end
            
            %ADD LOAD SUBPANEL
            
            loadingGroup = uibuttongroup('Parent',supportPanel,...
                                'Title','Add Loading','TitlePosition','centertop',...
                                'Units','normalized',...
                                'Position',[.4,0,.6,.4]);
                            
            loadingButton = uicontrol('Parent',supportPanel, 'String','Add Loading',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.5 0.03 0.4 0.05],'Callback',@add_loading_callback);     
                            
            loadingMenu = uicontrol('Parent',supportPanel, 'Style','popupmenu',...
                                'String',{'Select a Load','Point Load','Point Moment','Distributed Load'},...
                                'Value',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.5,.27,.4,.1],...
                                'Callback',@loading_panel_callback);
                            
                            
            function loading_panel_callback(hObject,eventData)
                if loadingMenu.Value == 2 %point load
                    
                    loadingGroup = uibuttongroup('Parent',supportPanel,...
                                'Title','Add Loading','TitlePosition','centertop',...
                                'Units','normalized',...
                                'Position',[.4,0,.6,.4]);
                            
                    loadingPosText = uicontrol(loadingGroup,'Style','text',...
                                'String','Input Position (m)',...
                                'Units','normalized',...
                                'Position',[.1,.75,.3,.1]); 
                            
                    loadingPosEdit = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.1,.6,.3,.15]);
                            
                    loadingMagText = uicontrol(loadingGroup,'Style','text',...
                                'String','Input Magnitude (N)',...
                                'Units','normalized',...
                                'Position',[.1,.45,.3,.1]); 
                            
                    loadingMagEdit = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.1,.3,.3,.15]); 
                            
                    loadingButtons{1} = uicontrol(loadingGroup,'Style','radiobutton',...
                                'String','Up',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.6,.6,.3,.1]);
                    loadingButtons{2} = uicontrol(loadingGroup,'Style','radiobutton',...
                                'String','Down',...
                                'Value',1,...
                                'Units','normalized',...
                                'Position',[.6,.4,.3,.1]);
                            
                    loadingButton = uicontrol('Parent',supportPanel, 'String','Add Loading',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.5 0.03 0.4 0.05],'Callback',@add_loading_callback,...
                             'BackgroundColor',[0.9400 0.9400 0.9400]);
                    
                    uistack(loadingButton,'top')        
                    uistack(loadingMenu,'top')
                    
                            
                elseif loadingMenu.Value ==3 %point moment
                    
                    loadingGroup = uibuttongroup('Parent',supportPanel,...
                                'Title','Add Loading','TitlePosition','centertop',...
                                'Units','normalized',...
                                'Position',[.4,0,.6,.4]);
                    
                    loadingPosText = uicontrol(loadingGroup,'Style','text',...
                                'String','Input Position (m)',...
                                'Units','normalized',...
                                'Position',[.1,.75,.3,.1]); 
                            
                    loadingPosEdit = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.1,.6,.3,.15]);
                            
                    loadingMagText = uicontrol(loadingGroup,'Style','text',...
                                'String','Input Magnitude (Nm)',...
                                'Units','normalized',...
                                'Position',[.095,.45,.31,.1]); 
                            
                    loadingMagEdit = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.1,.3,.3,.15]); 
                            
                    loadingButtons{1} = uicontrol(loadingGroup,'Style','radiobutton',...
                                'String','CW',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.6,.6,.3,.1]);
                    loadingButtons{2} = uicontrol(loadingGroup,'Style','radiobutton',...
                                'String','CCW',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.6,.4,.3,.1]);
                            
                    uistack(loadingMenu,'top')
                    uistack(loadingButton,'top')
                            
                elseif loadingMenu.Value == 4
                    
                    loadingGroup = uibuttongroup('Parent',supportPanel,...
                                'Title','Add Loading','TitlePosition','centertop',...
                                'Units','normalized',...
                                'Position',[.4,0,.6,.4]);
                    
                    loadingPosText1 = uicontrol(loadingGroup,'Style','text',...
                                'String','Input Start Position (m)',...
                                'Units','normalized',...
                                'Position',[.09,.75,.32,.1]);
                            
                    loadingPosText2 = uicontrol(loadingGroup,'Style','text',...
                                'String','Input End Position (m)',...
                                'Units','normalized',...
                                'Position',[.59,.75,.32,.1]);
                            
                    loadingPosEdit1 = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.1,.6,.3,.15]);
                            
                    loadingPosEdit2 = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.6,.6,.3,.15]);
                            
                    loadingMagText = uicontrol(loadingGroup,'Style','text',...
                                'String','Input Function of x (N/m)',...
                                'Units','normalized',...
                                'Position',[.25,.45,.5,.1]); 
                            
                    loadingMagEdit = uicontrol(loadingGroup,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.25,.3,.5,.15]);
                            
                    uistack(loadingMenu,'top')
                    uistack(loadingButton,'top')
  
                else
                    
                loadingGroup = uibuttongroup('Parent',supportPanel,...
                                'Title','Add Loading','TitlePosition','centertop',...
                                'Units','normalized',...
                                'Position',[.4,0,.6,.4]);
                            
                 uistack(loadingMenu,'top')
                 uistack(loadingButton,'top')
                                                       
                end   
            end
            
            function add_loading_callback(hObject,eventdata)
                if isempty(setup_obj.beam_obj)
                    errordlg('Create beam before adding a loading','Add Loading Error','modal')
                    return
                else
                    if loadingMenu.Value == 2
                        
                        %initial
                        loadingPosEdit = loadingGroup.Children(5);
                        loadingMagEdit = loadingGroup.Children(3);

                        %normalized position
                        load_position = str2double(loadingPosEdit.String);
                        normal_position = load_position/setup_obj.beam_obj.L;
                        
                        if normal_position > 1 || normal_position < 0 || isnan(load_position)
                            errordlg('Enter valid position between 0 and the length of the beam!','Add Loading Error','modal')
                            return
                        else
                            load_mag = str2double(loadingMagEdit.String);
                            if load_mag <= 0 
                                errordlg('Enter a magnitude greater than 0!','Add Loading Error','modal')
                                return
                            elseif isnan(load_mag)
                                errordlg('Enter a postive number greater than 0!','Add Loading Error','modal')
                                return
                            elseif loadingGroup.Children(2).Value == 1
                                load_mag = -1*load_mag ;
                            end
                            %Add Point load at position
                            
                            PointForce(setup_obj.beam_obj, normal_position, load_mag);

                        end

                    elseif loadingMenu.Value == 3
                        %initialize
                        loadingPosEdit = loadingGroup.Children(5) ;
                        loadingMagEdit = loadingGroup.Children(3) ;
                        
                        %normalized position
                        load_position = str2double(loadingPosEdit.String);
                        normal_position = load_position/setup_obj.beam_obj.L;
                        if normal_position > 1 || normal_position < 0 || isnan(load_position)
                        errordlg('Enter a valid position between 0 and the length of the beam','Add Loading Error','modal')
                        return
                        end
                        
                        load_mag = str2double(loadingMagEdit.String);
                        if load_mag <= 0 
                                errordlg('Enter a magnitude greater than 0!','Add Loading Error','modal')
                                return
                        elseif isnan(load_mag)
                            errordlg('Enter a positive number!','Add Loading Error','modal')
                                return
                        end

                        if loadingGroup.Children(1).Value == 1
                            dir = 'ccw' ;
                        else
                            dir = 'cw' ;
                        end
                                                           
                        %Add moment support at  position
                        Moment(setup_obj.beam_obj, normal_position, load_mag, dir);

                     elseif loadingMenu.Value == 4
                        %initialize
                        loadingMagEdit = loadingGroup.Children(1);
                        loadingPosEdit1 = loadingGroup.Children(4);
                        loadingPosEdit2 = loadingGroup.Children(3);
                        
                        %Add distributed load at position
                        load_start = str2double(loadingPosEdit1.String);
                        load_end = str2double(loadingPosEdit2.String);
                        norm_start = load_start/setup_obj.beam_obj.L;
                        norm_end = load_end/setup_obj.beam_obj.L;
                        
                        if norm_end <= norm_start
                            errordlg('End point must be greater than starting point','Add Loading Error','modal')
                        elseif norm_end > 1 || norm_start < 0 || isnan(norm_end) || isnan(norm_start)
                            errordlg('Enter a valid range!','Add Loading Error','modal')
                        else
                            %add distributed load
                            range = [norm_start,norm_end];
                            
                            try
                                backend_distfunc = str2func(strcat('@(x) -1*(',loadingMagEdit.String,')'));
                                dummytest = backend_distfunc([0 0]);
                                DistLoad(setup_obj.beam_obj, range, backend_distfunc);
                            catch
                                errordlg('Ensure your function input is valid and formatted correctly!');
                                return;
                            end
                        end
                        
                    else
                        errordlg('Must select a load!','Add Loading Error','modal')    
                    end
                            
                    %find max force  
                    loads = [];
                    num_loads = length(setup_obj.beam_obj.LoadStruct);
                    
                    for i = 1:num_loads
                        if isa(setup_obj.beam_obj.LoadStruct(i).Load,'PointForce')
                            loads(i) = setup_obj.beam_obj.LoadStruct(i).Load.Magnitude;
                        elseif isa(setup_obj.beam_obj.LoadStruct(i).Load,'DistLoad')
                            % find max of the distload
                            try
                                load_range = setup_obj.beam_obj.LoadStruct(i).Load.Range*setup_obj.beam_obj.L;
                                load_func = setup_obj.beam_obj.LoadStruct(i).Load.Distribution;

                                xx = linspace(load_range(1),load_range(2),100);
                                options = abs(load_func(xx));
                                loads(i) = max(options);
                                
                            catch
                                errordlg('Ensure your function input is valid and formatted correctly!');
                                return
                            end
                            
                        end    
                    end
                    
                    load_scale = max(abs(loads))+.2;
                    lines = supportAxes.Children ;
                  
                    % delete all red lines for loads and replot
                    for kk=size(lines,1):-1:1 
                        if lines(kk).Color == [1 0 0]
                            delete(supportAxes.Children(kk)) ;                            
                        end                        
                    end
                            
                        
                    
                    
                    for i = 1:num_loads
                        if isa(setup_obj.beam_obj.LoadStruct(i).Load,'PointForce')
                            
                            %Plot Point force
                            load_position = setup_obj.beam_obj.LoadStruct(i).Position*setup_obj.beam_obj.L;
                            load_magnitude = setup_obj.beam_obj.LoadStruct(i).Magnitude;
                            
                            if load_magnitude < 0
                                if load_magnitude/load_scale > -.07
                                    load_magnitude = -.07*load_scale ;
                                end
                                hold(supportAxes,'on')
                                plot(supportAxes,[load_position load_position],[-.07 load_magnitude/load_scale],...
                                    '-^r','LineWidth',1.5,'MarkerFaceColor','r','MarkerIndices',[1])
                            else
                                if load_magnitude/load_scale < 0.07
                                    load_magnitude = .07*load_scale ;
                                end
                                hold(supportAxes,'on')
                                plot(supportAxes,[load_position load_position],[.07 load_magnitude/load_scale],...
                                    '-rv','LineWidth',1.5,'MarkerFaceColor','r','MarkerIndices',[1])
                            end
                            
                        elseif isa(setup_obj.beam_obj.LoadStruct(i).Load,'Moment')
                            load_position = setup_obj.beam_obj.LoadStruct(i).Position*setup_obj.beam_obj.L;
                            load_dir = setup_obj.beam_obj.LoadStruct(i).Direction;
                            
                            if strcmpi(load_dir,'ccw')
                                th = linspace( pi/2, -pi, 100);
                                R = .1 ;  
                                x = .5*R*setup_obj.beam_obj.L*cos(th) + load_position;
                                y = R*sin(th);

                                hold(supportAxes,'on')
                                plot(supportAxes,x,y,...
                                        '-r<','LineWidth',1.5,'MarkerFaceColor','r','MarkerIndices',[1])
                                
                            else
                                th = linspace( 0, -3*pi/2, 100);
                                R = .1 ;  
                                x = .5*R*setup_obj.beam_obj.L*cos(th) + load_position;
                                y = R*sin(th);

                                hold(supportAxes,'on')
                                plot(supportAxes,x,y,'-r>',...
                                     'LineWidth',1.5,'MarkerFaceColor','r','MarkerIndices',[100])
                            end
                            
                        elseif isa(setup_obj.beam_obj.LoadStruct(i).Load,'DistLoad')
                            % plot distributed load
                            load_range = setup_obj.beam_obj.LoadStruct(i).Load.Range*setup_obj.beam_obj.L;
                            load_func = setup_obj.beam_obj.LoadStruct(i).Load.Distribution;
                            
                            range_length = load_range(2) - load_range(1) ;
                            num_arrows = ceil(range_length/setup_obj.beam_obj.L*20) ;
                            xx = linspace(load_range(1),load_range(2),num_arrows) ;
                            points = -1*load_func(xx);
                            
                               if length(points) == 1 %constant function
                                   points = points*ones(1,length(xx)) ;
                               end
                                                   
                               for k =1:length(xx)
                                       load_magnitude = points(k) ;       
                                         if load_magnitude/load_scale <= -0.07
                                            hold(supportAxes,'on')
                                            plot(supportAxes,[xx(k) xx(k)],[-.07 load_magnitude/load_scale],...
                                            '-^r','LineWidth',1.5,'MarkerFaceColor','r','MarkerIndices',[1])
                                         elseif load_magnitude/load_scale >= 0.07
                                            hold(supportAxes,'on')
                                            plot(supportAxes,[xx(k) xx(k)],[.07 load_magnitude/load_scale],...
                                            '-rv','LineWidth',1.5,'MarkerFaceColor','r','MarkerIndices',[1])
                                         end

                               end
                               
                           
                            hold(supportAxes,'on')
                            plot(supportAxes,xx,points/load_scale,...
                                        '-r','LineWidth',1.5,'Marker','.',...
                                        'MarkerFaceColor','red','MarkerEdgeColor','red',...
                                        'MarkerIndices',[1 length(xx)])
                                    
                        end    
                    end 
                end
            end
            
            % MOMENT AND SHEAR DIAGRAM PANEL
            shearAxes = axes('Parent',dataPanel,'Box','on',...
                               'Position',[.1 .06 .6 .4]);
                               
            shearAxes.Title.String = 'Shear Diagram';
            shearAxes.XLabel.String = 'Length (m)';
            shearAxes.YLabel.String = 'Shear Force (N)';
            
            momentAxes = axes('Parent',dataPanel,'Box','on',...
                               'Position',[.1 .56 .6 .4]);
            
            momentAxes.Title.String = 'Moment Diagram';
            momentAxes.XLabel.String = 'Length (m)';
            momentAxes.YLabel.String = 'Moment (Nm)';
                           
            calcButton = uicontrol('Parent',dataPanel, 'String','Calculate',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.75 0.5 0.2 0.1],'Callback',@calculate_callback);
                         
            clc_support_Button = uicontrol('Parent',dataPanel, 'String','Clear Supports',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.75 0.2 0.2 0.1],'Callback',@clc_support_callback) ;
                         
            clc_load_Button = uicontrol('Parent',dataPanel, 'String','Clear Loads',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.75 0.05 0.2 0.1],'Callback',@clc_load_callback) ;
                         
            clc_graphs_Button = uicontrol('Parent',dataPanel, 'String','Clear Diagrams',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.75 0.35 0.2 0.1],'Callback',@clc_graph_callback) ;
              
            beamsolver_feed = {} ;             
                         
            calc_feed = uicontrol('Parent',dataPanel,'Style','listbox',...
                                'String',beamsolver_feed,...
                                'Value',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[0.72 0.65 0.26 0.3]);
                            
            feed_text = uicontrol(dataPanel,'Style','text',...
                                'String','Beam Info',...
                                'Units','normalized',...
                                'Position',[.72,.95,.26,.05]);
  
            function calculate_callback(hObject,eventdata)
                %clear previous plots
                
                beam = setup_obj.beam_obj ;
                if isempty(beam)
                    errordlg('Create a beam before calculation!','Calculate Error','modal')
                    return
                end
                prepareBeam(beam) ;
                
                %Check if position is determinate
                % - NO SUPPORTS/LOADS - %
        
                if beam.f + beam.m == 0
                    errordlg('There are no supports on the beam!','Calculate Error','modal');
                    return
                
                elseif size(beam.LoadStruct,2) == 0
                    errordlg('There are no loads on this beam! Add loads before calculation.','Calculate Error','modal')
                    return
                    
                % - SINGLE PIN/ROLLER - %
                
                elseif beam.f == 1 && beam.m == 0 
                    errordlg('The beam is not static! Reconfigure your supports.','Calculate Error','modal');
                return
                
                % - Unsolvable in C85 - %
                elseif beam.f == 3 && beam.m == 0
                    errordlg('This case is not solvable by techniques taught in ME C85. We apologize for the inconvenience!','Calculate Error','modal');
                    return
                    
                elseif beam.f == 4 && beam.m == 0
                    errordlg('This case is not solvable by techniques taught in ME C85. We apologize for the inconvenience!','Calculate Error','modal');
                    return
                    
                % - PIN/ROLLER COMBINATION - %
                elseif beam.f == 2

                sup1 = beam.SupportStruct(1).Support;
                sup2 = beam.SupportStruct(2).Support;

                 % Check to see if it's two pins instead of pin/roller
                    if strcmpi(sup1.Type, 'pin') && strcmpi(sup2.Type, 'pin')
                        % Not solvable because of the x components
                        errordlg('A two pin setup does not have solvable x forces! Reconfigure your supports.','Calculate Error','modal');
                        return
                    end

                    % Check to see if it's two rollers instead of pin/roller
                    if strcmpi(sup1.Type, 'roller') && strcmpi(sup2.Type, 'roller')
                        errordlg('A two roller setup is not static! Reconfigure your supports.','Calculate Error','modal');
                        return
                    end
                    
                elseif beam.m > 2 || (beam.m == 2 && beam.f > 2) || (beam.m == 1 && beam.f > 3) || (beam.m == 0 && beam.f > 4)
                    errordlg('The solver can only resolve beams that are statically determinate to the second degree or lower!','Calculate Error','modal');
                    return
                end

                if isempty(shearAxes.Children) == 0
                    beamsolver_feed{end+1,1} = '---------------------------' ;
                    beamsolver_feed{end+1,1} = '' ;
                end
                
                %graph moment/shear diagrams
                calculateSupportForces(beam) ;
                calculateShearMomentDiagrams(beam);
                hold(shearAxes,'on')
                plot(shearAxes,beam.xvals,beam.vvals) ;
                shearAxes.Title.String = 'Shear Diagram';
                shearAxes.XLabel.String = 'Length (m)';
                shearAxes.YLabel.String = 'Shear Force (N)';
                
                hold(momentAxes,'on')
                plot(momentAxes,beam.xvals,beam.mvals)
                momentAxes.Title.String = 'Moment Diagram';
                momentAxes.XLabel.String = 'Length (m)';
                momentAxes.YLabel.String = 'Moment (Nm)';
                
                %insert info into feed
                supportstruct = setup_obj.beam_obj.SupportStruct ;
                    for ii = 1:length(supportstruct)
                        if strcmpi(supportstruct(ii).Support.Type,'fixedend')
                            beamsolver_feed{end+1,1} = ['---Fixed End---'] ;
                        elseif strcmpi(supportstruct(ii).Support.Type,'pin')
                            beamsolver_feed{end+1,1} = ['---Pin---'] ;
                        else
                            beamsolver_feed{end+1,1} = ['---Roller---'] ;
                        end
                        beamsolver_feed{end+1,1} = ['Position: ',num2str(supportstruct(ii).Support.Position .* setup_obj.beam_obj.L),' m'];
                        beamsolver_feed{end+1,1} = ['Fy: ',num2str(round(supportstruct(ii).Support.Fy,2)), ' N'];
                        if isa(supportstruct(ii).Support,'FixedEnd')
                            beamsolver_feed{end+1,1} = ['M: ',num2str(round(supportstruct(ii).Support.M,2)),' Nm'];
                        end
                        beamsolver_feed{end+1,1} = '' ;

                    end
                    
                [max_shear,shear_I] = max(abs(beam.vvals)) ;
                max_shear_pos = beam.xvals(shear_I) ;
                [max_moment,moment_I] = max(abs(beam.mvals)) ;
                max_moment_pos = beam.xvals(moment_I) ;
                
                
                beamsolver_feed{end+1} = ['---Max Moment---'] ;
                beamsolver_feed{end+1} = ['Magnitude: ', num2str(round(double(max_moment),2)),' Nm'] ;
                beamsolver_feed{end+1} = ['Position: ', num2str(round(max_moment_pos,2)),' m'] ;
                beamsolver_feed{end+1,1} = '' ;
                
                beamsolver_feed{end+1} = ['---Max Shear---'] ;
                beamsolver_feed{end+1} = ['Magnitude: ', num2str(round(double(max_shear),2)),' Nm'] ;
                beamsolver_feed{end+1} = ['Position: ', num2str(round(max_shear_pos,2)),' m'] ;
                beamsolver_feed{end+1,1} = '' ;    
                    
                set(calc_feed,'String',beamsolver_feed)
                end
            
            % CLEAR Function Callbacks
            
            function clear_all_callback(hObject,eventdata)
                setup_obj = Setup() ;
                cla(supportAxes)
                cla(shearAxes)
                cla(momentAxes)
                beamsolver_feed = {} ;
                set(calc_feed,'String',beamsolver_feed)
                set(calc_feed,'Value',1)
                
            end
                
            function clc_support_callback(hObject,eventdata)
                %use remove support
                if isempty(setup_obj.beam_obj) || isempty(setup_obj.beam_obj.SupportStruct)
                    errordlg('No supports to clear!','Clear Supports Error','modal')
                else
                num_supports = length(setup_obj.beam_obj.SupportStruct);
                    for i = num_supports:-1:1  
                        support = setup_obj.beam_obj.SupportStruct(i).Support ;
                        removeSupport(setup_obj.beam_obj, support)
                    end

 
                %clear blue from supportAxes
                
                lines = supportAxes.Children ;  
                    % delete all blue lines for supports
                    for kk=size(lines,1):-1:1
                        if lines(kk).Color == [0 0 0]
                            continue
                        elseif lines(kk).Color == [0 0 1]
                            delete(supportAxes.Children(kk)) ;
                        elseif lines(kk).MarkerFaceColor == [0 0 1]
                            delete(supportAxes.Children(kk)) ;                            
                        end                        
                    end
                end
            end
            
            function clc_load_callback(hObject,eventdata)
                %use remove load
                if isempty(setup_obj.beam_obj) || isempty(setup_obj.beam_obj.LoadStruct)
                    errordlg('No loads to clear!','Clear Loads Error','modal')
                else
                num_loads = length(setup_obj.beam_obj.LoadStruct);
                    for i = num_loads:-1:1  
                        load = setup_obj.beam_obj.LoadStruct(i).Load ;
                        removeLoad(setup_obj.beam_obj, load)
                    end

                %clear red from supportAxes
                
                lines = supportAxes.Children ;  
                    % delete all red lines for loads
                    for kk=size(lines,1):-1:1 
                        if lines(kk).Color == [1 0 0]
                            delete(supportAxes.Children(kk)) ;                            
                        end                        
                    end
                end
                
            end
            
            function clc_graph_callback(hObject,eventdata)
                cla(shearAxes)
                cla(momentAxes)
                beamsolver_feed = {} ;
                set(calc_feed,'String',beamsolver_feed)
                set(calc_feed,'Value',1)
                
            end
            
            

            %%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%
            %%%%%TRUSS GUI%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%
            
            TrussGUI_obj = Truss();
            numbeams = 1;
            b = {};
            Bmenu = {};
            BDelete = {};
            fo = {};
            fi = {};
            numfo = 1;
            numfi = 1;
            Fomenu = {};
            FoDelete = {};
            Fimenu = {};
            FiDelete = {};
            beammodeon = 0;
            beampointcounter = 0;
            BeamCreatorPanel = uipanel('Parent',tab_truss,...
                         'Position', [0 .25 0.125 .75],...
                         'Title', 'Add Beams') ;
                     
            %%%% BEAM PANEL
            
            TrussMaterialText = uicontrol(BeamCreatorPanel,'Style','text',...
                                'String','Select Material',...
                                'Units','normalized',...
                                'Position',[0,.9,1,.07]);
                            
            TrussMaterialMenu = uicontrol(BeamCreatorPanel,'Style','popupmenu',...
                                'String',{materialsOptions},...
                                'Value',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.23,.82,.5,.1]);
                            
            AreaText = uicontrol(BeamCreatorPanel,'Style','text',...
                                'String','Cross Sectional Area (m^2)',...
                                'Units','normalized',...
                                'Position',[0,.79,1,.07]);    
                            
            AreaEdit = uicontrol(BeamCreatorPanel,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.2,.76,.55,.05]);
                            
            AddBeamButton = uicontrol('Parent',BeamCreatorPanel, 'String','Add Beam',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.2,.65,.55,.07],...
                             'CallBack',@AddBeam_Callback) ;
                         
            function AddBeam_Callback(h,d)
                E_value = numm(TrussMaterialMenu.Value,1)*10^9;
                Material = texm(TrussMaterialMenu.Value);
                A_value = str2double(AreaEdit.String);
                if isnan(A_value)
                    helpdlg('please input a cross sectional area')
                    return
                end
                points = [];
                for numtrussbuttons = 1:length(TrussButton)
                   if TrussButton{numtrussbuttons}.Value == 1
                       point = TrussButton{numtrussbuttons}.UserData;
                       points = [points;point];
                       TrussButton{numtrussbuttons}.Value = 0;
                   end
                end
                if length(points) == 2 
                hold on
                b{numbeams} = TrussBeam(points(1,:),points(2,:),E_value,A_value);
                b{numbeams}.Material = Material;
                b{numbeams}.guinumber = numbeams;
                b{numbeams}.yield = numm(TrussMaterialMenu.Value,2);
                b{numbeams}.plot
                TrussGUI_obj.addBeam(b{numbeams});
                beamsgca = get(gca,'Children');
                set(beamsgca(1),'UserData',numbeams);
                set(beamsgca(1),'ButtonDownFcn',@beam_feed);
                Bmenu{numbeams} = uicontextmenu;
                set(beamsgca(1),'UicontextMenu',Bmenu{numbeams});
                BDelete{numbeams} = uimenu('Parent',Bmenu{numbeams},...
                            'Label','Delete Beam',...
                            'Callback',@deletebeam);
                set(TrussPlot,'XLim',[-1,31])
                set(TrussPlot,'YLim',[-1,31])
                set(TrussPlot,'XTick',[-1:31])
                set(TrussPlot,'YTick',[-1:31])
                grid on
                numbeams = numbeams +1;
                else
                    helpdlg('Please choose only two points')
                end
            end
            
            function deletebeam(h,d)
                todelete = h.Parent.Parent.CurrentObject;
                todeletenumber = todelete.UserData;
                set(todelete,'Visible','off');
                for nb = 1:length(TrussGUI_obj.Beam)
                    if TrussGUI_obj.Beam(nb).guinumber == todeletenumber
                        TrussGUI_obj.removeBeam(nb);
                        break
                    end     
                end    
            end
            
            function beam_feed(h,d)
                bintruss = 1;
                for nbn = 1:length(TrussGUI_obj.Beam)
                    if TrussGUI_obj.Beam(nbn).guinumber == h.UserData
                        beamref = TrussGUI_obj.Beam(nbn);
                        break
                    end
                    bintruss = bintruss+1;
                end
                mat = beamref.Material;
                if isequal(feed,{})
                    feed = {['________Beam ' num2str(bintruss) ':_______' ]};
                else
                    feed{end+1,1} = ['________Beam ' num2str(bintruss) ':_______' ];  
                end
                feed{end+1,1} = ['Material - ' mat{1}];
                feed{end+1,1} = ['Area - ' num2str(beamref.A) ' m^2'];
                set(FeedBox,'String',feed)
            end
            
            BeamModeButton = uicontrol(BeamCreatorPanel,'String','Easy Beam Mode',...
                                'Style','pushbutton','Units','Normalized',...
                                'ToolTipString','Place Beams Easily',...
                                'Position',[.15,.53,.65,.07],...
                                'Callback',@BeamMode);
                            
            function BeamMode(h,d)
                beammodeon = ~beammodeon;
                onoff = 'OFF';
                if beammodeon
                    onoff = 'ON';
                    beampointcounter = 0;
                end
                if isequal(feed,{})
                    feed = {['Easy Beam Mode is ' onoff ]};
                else
                    feed{end+1,1} = ['Easy Beam Mode is ' onoff ];
                end
                set(FeedBox,'String',feed)
                
            end
                                  
            ClearButton = uicontrol('Parent',BeamCreatorPanel, 'String','Clear All Features',...
                             'Style','pushbutton','Units','Normalized',...
                             'ToolTipString','Clears all beams, forces, and supports',...
                             'Position',[0.15,.4,.65,.07],...
                             'Callback',@Clear_All) ;
                         
            function Clear_All(h,d)
                allchildren = get(gca,'Children');
                for numchildren = 1:length(allchildren)
                    set(allchildren(numchildren),'Visible','off');
                end
                TrussGUI_obj.Clear
                numbeams = 1;
                b = {};
                Bmenu = {};
                BDelete = {};
                fo = {};
                fi = {};
                numfo = 1;
                numfi = 1;
                Fomenu = {};
                FoDelete = {};
                Fimenu = {};
                FiDelete = {};  
            end
                         
            SolveButton = uicontrol('Parent',BeamCreatorPanel, 'String','Solve',...
                             'Style','pushbutton','Units','Normalized',...
                             'ToolTipString','Solves for the current scenario and pauses editing',...
                             'Position',[0.2,.2,.55,.1],...
                             'Callback',@solve) ;
                         
            function solve(h,d)
                goodtosolve = 1;
                loc = TrussGUI_obj.Loc;
                loc = loc';
                for nforce = 1:length(TrussGUI_obj.Force)
                    check = 0;
                    for nloc = 1:length(loc)
                        if isequal(TrussGUI_obj.Force(nforce).Position,loc(nloc,:))
                            check = 1;
                            break
                        end
                    end
                    if check == 0
                        goodtosolve = 0;
                    end
                end
                for nfix = 1:length(TrussGUI_obj.Fixture)
                    check = 0;
                    for nloc = 1:length(loc)
                        if isequal(TrussGUI_obj.Fixture(nfix).Position,loc(nloc,:))
                            check = 1;
                            break
                        end
                    end
                    if check == 0
                        goodtosolve = 0;
                    end
                end
                if goodtosolve
                    disp = TrussGUI_obj.solve;
                    if isnan(disp(1))
                        helpdlg('Solution is underdetermined or underconstrianed; Beams need to be attached to nodes');
                        return
                    else
                        if abs(disp(3)) > 1000
                            helpdlg('Solution is underdetermined or underconstrianed; Beams need to be attached to nodes');
                        end
                        FOSlist = [];
                        dispmag = sqrt(disp(:,1).^2 + disp(:,2).^2);
                        [mdisp,dnode] = max(dispmag);
                        dnodelocx = loc(dnode,1);
                        dnodelocy = loc(dnode,2);
                        for nbems = 1:length(TrussGUI_obj.Beam)
                            hold on
                            TrussGUI_obj.Beam(nbems).dispplot;
                            beam = get(gca,'Children');
                            set(beam(1),'ButtonDownFcn',@sol_feed);
                            set(beam(1),'Tag',num2str(nbems));
                            FOSlist = [FOSlist;TrussGUI_obj.Beam(nbems).FOS];
                        end
                        for ntbuttons = 1:length(TrussButton)
                            set(TrussButton{ntbuttons},'Visible','off');
                        end
                        if isequal(feed,{})
                            feed = {['________Success!_______' ]};
                        else
                            feed{end+1,1} = ['________Success!_______' ];
                        end
                        feed{end+1,1} = ['Min FOS - ' num2str(min(FOSlist))];
                        feed{end+1,1} = ['Max Displacement - ' num2str(round((mdisp*1000),4)) 'm'];
                        feed{end+1,1} = ['at ' '(' num2str(dnodelocx) ',' num2str(dnodelocy) ')'];
                        if mdisp < (1*10^-4)
                            feed{end+1,1} = ['Solutions with low displacements'];
                            feed{end+1,1} = ['may have calculation inaccuracies'];
                        end
                        set(FeedBox,'String',feed);
                    end
                else
                    helpdlg('Please remove any floating beams, supports or forces')
                end
            end
            
            function sol_feed(h,d)
                istbeamnumber = str2num(h.Tag);
                beamref = TrussGUI_obj.Beam(istbeamnumber);
                mat = beamref.Material;
                if isequal(feed,{})
                    feed = {['_____Solved Beam ' h.Tag ':____' ]};
                else
                    feed{end+1,1} = ['_____Solved Beam ' h.Tag ':____' ];  
                end
                feed{end+1,1} = ['Material - ' mat{1}];
                feed{end+1,1} = ['Area - ' num2str(beamref.A) ' m^2'];
                feed{end+1,1} = ['Stress - ' num2str(beamref.Stress) '(MPa) in ' beamref.TorC];
                feed{end+1,1} = ['FOS - ' num2str(beamref.FOS) '  Force: ' num2str(beamref.Force) 'KN']; 
                set(FeedBox,'String',feed)
            end
            
            ClearSol = uicontrol(BeamCreatorPanel,'String','Clear Solution Plot',...
                            'Style','pushbutton','Units','Normalized',...
                            'ToolTipString','Clears the red solution lines and allows you to resume editting the truss',...
                            'Position',[0.15,.05,.65,.1],...
                            'Callback',@Clear_Sol);
                        
            function Clear_Sol(h,d)
                gcadata = get(gca,'Children');
                for nbeam = 1:length(TrussGUI_obj.Beam)
                    todelete = gcadata(nbeam);
                    CheckRealBeam = get(todelete,'UserData');
                    if isequal(CheckRealBeam,[])
                        set(todelete,'Visible','off');
                    end
                end
                for ntbuttons = 1:length(TrussButton)
                       set(TrussButton{ntbuttons},'Visible','on')
                end 
            end
        
            %%% Support Panel
            SupportPanel = uipanel('Parent',tab_truss,...
                         'Position', [0 0 0.125 .25],...
                         'Title', 'Add Supports') ;
 
            TrussSupportButtons{1} = uicontrol(SupportPanel,'Style','checkbox',...
                                'String','x',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.25,.625,.25,.25]);
            TrussSupportButtons{2} = uicontrol(SupportPanel,'Style','checkbox',...
                                'String','y',...
                                'Value',0,...
                                'Units','normalized',...
                                'Position',[.625,.625,.25,.25]);
            
            TrussSupportPosText = uicontrol(SupportPanel,'Style','text',...
                                'String','Position',...
                                'Units','normalized',...
                                'Position',[0,.5,1,.1]) ; 
                    
            TrussSupportPosEdit = uicontrol(SupportPanel,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.15,.30,.7,.15]);
                            
            AddsupportButton = uicontrol('Parent',SupportPanel, 'String','Add Support',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.2 0.1 0.6 0.1],'Callback',@add_fixture_callback) ; 
                         
            function add_fixture_callback(h,d)
                hold on
                xfix = get(TrussSupportButtons{1},'Value');
                yfix = get(TrussSupportButtons{2},'Value');
                if xfix+yfix<1
                     helpdlg('support in at least 1 direction')
                else
                if isequal(h.UserData,[])
                    [xpos,ypos] = pos(TrussSupportPosEdit.String);
                else
                    xpos = h.UserData(1);
                    ypos = h.UserData(2); 
                end
                if isnan(xpos) || isnan(ypos)
                    helpdlg('give a position as x,y')
                else    
                    fi{numfi} = TrussFix([xpos,ypos],[xfix,yfix]);
                    fi{numfi}.guinumber = numfi;
                    fi{numfi}.plot
                    TrussGUI_obj.addFixture(fi{numfi});
                    fixgca = get(gca,'Children');
                    set(fixgca(1),'UserData',numfi)
                    set(fixgca(1),'ButtonDownFcn',@fix_feed);
                    Fimenu{numfi} = uicontextmenu;
                    set(fixgca(1),'UicontextMenu',Fimenu{numfi});
                    FiDelete{numfi} = uimenu('Parent',Fimenu{numfi},...
                        'Label','Delete Support',...
                        'Callback',@deletefix);   
                    set(TrussPlot,'XLim',[-1,31])
                    set(TrussPlot,'YLim',[-1,31])
                    set(TrussPlot,'XTick',[-1:31])
                    set(TrussPlot,'YTick',[-1:31])
                    grid on
                    numfi = numfi +1;
                end
                end
            end
            
            function deletefix(h,d)
                todelete = h.Parent.Parent.CurrentObject;
                todeletenumber = todelete.UserData;
                set(todelete,'Visible','off');
                for nf = 1:length(TrussGUI_obj.Fixture)
                    if TrussGUI_obj.Fixture(nf).guinumber == todeletenumber
                        TrussGUI_obj.removeFixture(nf);
                        break
                    end     
                end    
            end
            
            function fix_feed(h,d)
                fixintruss = 1;
                for nbf = 1:length(TrussGUI_obj.Fixture)
                    if TrussGUI_obj.Fixture(nbf).guinumber == h.UserData
                        fixref = TrussGUI_obj.Fixture(nbf);
                        break
                    end
                    fixintruss = fixintruss+1;
                end
                if sum(fixref.Directions) == 2
                    FixStrOut = 'Fixed Support';
                elseif fixref.Directions(1) == 1
                    FixStrOut = 'Y Direction Roller';
                else
                    FixStrOut = 'X Direction Roller';
                end
                
                if isequal(feed,{})
                    feed = {['_____' FixStrOut ' ' num2str(fixintruss) ':____' ]};
                else
                    feed{end+1,1} = ['_____' FixStrOut ' ' num2str(fixintruss) ':____' ];  
                end
                if ~isequal(fixref.ReactionForce,[])
                    feed{end+1,1} = ['Reaction Forces:'];
                    feed{end+1,1} = ['RFx: ' num2str(fixref.ReactionForce(1)) ' KN'];
                    feed{end+1,1} = ['RFy: ' num2str(fixref.ReactionForce(2)) ' KN'];
                end
                set(FeedBox,'String',feed);  
            end
                         
            %%%% force panel  
            ForcePanel = uipanel('Parent',tab_truss,...
                         'Position', [.125 0 0.125 .25],...
                         'Title', 'Add Loadings') ;
                     
            FxText = uicontrol(ForcePanel,'Style','text',...
                                'String','Fx(KN)',...
                                'Units','normalized',...
                                'Position',[.2,.75,.25,.125]);
                            
            FyText = uicontrol(ForcePanel,'Style','text',...
                                'String','Fy(KN)',...
                                'Units','normalized',...
                                'Position',[.59,.75,.25,.125]);
                            
            FxEdit = uicontrol(ForcePanel,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.2,.62,.25,.16]);
                            
            FyEdit = uicontrol(ForcePanel,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.6,.62,.25,.16]);
              
            ForcePosText = uicontrol(ForcePanel,'Style','text',...
                                'String','Position',...
                                'Units','normalized',...
                                'Position',[0,.5,1,.1]) ; 
                    
            ForcePosEdit = uicontrol(ForcePanel,'Style','edit',...
                                'Max',1,'Min',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[.15,.30,.7,.15]);
                            
            AddForceButton = uicontrol(ForcePanel, 'String','Add Force',...
                             'Style','pushbutton','Units','Normalized',...
                             'Position',[0.2 0.1 0.6 0.1],'Callback',@add_force_callback) ;
            
            function add_force_callback(h,d)
                hold on
                Fx_value = str2double(FxEdit.String)*1000;
                Fy_value = str2double(FyEdit.String)*1000;
                
                if isnan(Fx_value) && isnan(Fy_value)
                    helpdlg('please use a real force value')
                    return
                elseif isnan(Fx_value)
                    Fx_value = 0;
                elseif isnan(Fy_value)
                    Fy_value = 0;
                end
                    
                if isequal(h.UserData,[])
                    [xpos,ypos] = pos(ForcePosEdit.String);
                else
                    xpos = h.UserData(1);
                    ypos = h.UserData(2); 
                end
                
                if isnan(xpos) || isnan(ypos)
                    helpdlg('give a position as x,y')
                else    
                    fo{numfo} = TrussForce([xpos,ypos],[Fx_value,Fy_value]);
                    fo{numfo}.guinumber = numfo;
                    fo{numfo}.plot
                    TrussGUI_obj.addForce(fo{numfo});
                    forcegca = get(gca,'Children');
                    set(forcegca(1),'UserData',numfo);
                    set(forcegca(1),'ButtonDownFcn',@force_feed);
                    Fomenu{numfo} = uicontextmenu;
                    set(forcegca(1),'UicontextMenu',Fomenu{numfo});
                    FoDelete{numfo} = uimenu('Parent',Fomenu{numfo},...
                        'Label','Delete Force',...
                        'Callback',@deleteforce);     
                    set(TrussPlot,'XLim',[-1,31])
                    set(TrussPlot,'YLim',[-1,31])
                    set(TrussPlot,'XTick',[-1:31])
                    set(TrussPlot,'YTick',[-1:31])
                    grid on
                    numfo = numfo +1;
                end
            end
            
            function deleteforce(h,d)
                todelete = h.Parent.Parent.CurrentObject;
                todeletenumber = todelete.UserData;
                set(todelete,'Visible','off');
                for nf = 1:length(TrussGUI_obj.Force)
                    if TrussGUI_obj.Force(nf).guinumber == todeletenumber
                        TrussGUI_obj.removeForce(nf);
                        break
                    end     
                end    
            end    
            
            function force_feed(h,d)
                forceintruss = 1;
                for nbf = 1:length(TrussGUI_obj.Force)
                    if TrussGUI_obj.Force(nbf).guinumber == h.UserData
                        forceref = TrussGUI_obj.Force(nbf);
                        break
                    end
                    forceintruss = forceintruss+1;
                end
                if isequal(feed,{})
                    feed = {['________Force ' num2str(forceintruss) ':_______' ]};
                else
                    feed{end+1,1} = ['________Force '  num2str(forceintruss) ':_______' ];  
                end
                feed{end+1,1} = ['X:  ' num2str(forceref.amountxy(1)/1000) ' KN'];
                feed{end+1,1} = ['Y:  ' num2str(forceref.amountxy(2)/1000) ' KN'];
                set(FeedBox,'String',feed);     
            end
                         
            %%% TRUSS
            TrussPanel = uipanel('Parent',tab_truss,...
                         'Position', [.25 0 0.75 1],...
                         'Title','Truss Plot') ;
                     
            TrussPlot = axes('Parent',TrussPanel,'Box','on',...
                               'XLim',[-1,31],...
                               'YLim',[-1,31],...
                               'XTick',[-1:31],...
                               'YTick',[-1:31],...
                               'Position',[.03 .05 .95 .93]);
                        grid on
                        
            %%%%CREATE TRUSS BUTTONS           
            n = 0; 
            gridd = 31;
            for i = 1:gridd
                for j =1:gridd
                    n = n+1;
                    TrussButtonmenu{n} = uicontextmenu;
                    xp = floor((n-1)/gridd);
                    yp = mod((n-1),gridd);
            TrussButton{n} = uicontrol(TrussPanel,'Style','checkbox',...
                                'Value',0,...
                                'Units','normalized',...
                                'UserData',[xp,yp],...
                                'ToolTipString',['(' num2str(xp) ',' num2str(yp) ')' ],...
                                'Position',[.051+.02967*(i-1),.068+.02917*(j-1),.016,.02]);
                    set(TrussButton{n},'CallBack',@BeamModeReact);
                    set(TrussButton{n},'UicontextMenu',TrussButtonmenu{n});
                    AddFixOption{n} = uimenu(TrussButtonmenu{n},...
                            'Label','Add Support',...
                            'UserData',[xp,yp],...
                            'Callback',@add_fixture_callback);
                    AddForceOption{n} = uimenu(TrussButtonmenu{n},...
                            'Label','Add Force',...
                            'UserData',[xp,yp],...
                            'Callback',@add_force_callback);
                end
            end
            
            function BeamModeReact(h,d)
                if beammodeon
                    beampointcounter = beampointcounter +1;
                    if beampointcounter == 2
                        AddBeam_Callback;
                        beampointcounter = 0;
                    end
                end
            end
            
            %Helper function for dealing with wierd string inputs
            function [x,y] = pos(position_string)
               if length(position_string)<3
                   x = nan;
                   y = nan;
               else
                   if isequal(position_string(1),'[') || isequal(position_string(1),'(') || isequal(position_string(1),'{')
                       position_string(1) = '';
                       position_string(end) = '';
                   end 
                   for strlen = 1:length(position_string)
                       if isequal(position_string(strlen),',')
                           x = str2double(position_string(1:strlen-1));
                           y = str2double(position_string(strlen+1:end));
                       end
                   end
               end    
            end
            
            %%% Feature Panel   UNUSED    
            feed = {'Welcome to the Truss Solver';'_____INSTRUCTIONS____';'Right click check boxes to';'add supports and forces.';'';'Left click features for info.';'';'Right click features to delete.'};
            FeedPanel = uipanel('Parent',tab_truss,...
                         'Position', [.125 .25 0.125 .75],...
                         'Title', 'Feed') ;
                     
            FeedBox = uicontrol(FeedPanel,'Style','listbox',...
                                'String',feed,...
                                'Value',1,...
                                'BackgroundColor','white',...
                                'Units','normalized',...
                                'Position',[0,.05,1,.95]);
            DeleteFeed = uicontrol('Parent',FeedPanel, 'String','Clear Feed',...
                             'Style','pushbutton','Units','Normalized',...
                             'ToolTipString','Clear the text feed above',...
                             'Position',[0,0,1,.05],...
                             'Callback',@clear_feed);
                         
            function clear_feed(h,d)
               feed = {}; 
               set(FeedBox,'String',feed)
               set(FeedBox,'Value',1)
            end        
                                    
        end
        
    end
    
    
end