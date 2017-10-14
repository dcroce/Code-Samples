classdef Beam < handle
    
    properties
        LoadStruct; % A struct of all loads on the beam
        SupportStruct; % A struct of all supports on the beam
        LandmarkStruct; % A struct of all loads + positions
        
        I = 1; % The moment of inertia about the xx axis of the cross section
        E = 1; % Young's Modulus for the beam
        L; % The length of the beam
        
        f = 0; % The number of support force unknowns
        m = 0; % The number of support moment unknowns
        Ftot = 0; % The total external force on the beam
        
        xvals; % The xvalues of the shear and moment plots
        vvals; % The shear values of the beam
        mvals; % The moment values of the beam
    end
    
    methods
        
        % Constructor
        function obj = Beam(l,E,I,varargin)
            
            if nargin == 1
                obj.LoadStruct = struct('Load',{},...
                                        'Position',[],...
                                        'Type',{},...
                                        'Magnitude',[],...
                                        'Direction',{});
                obj.SupportStruct = struct('Support',{},...
                                           'Type',{},...
                                           'Position',[],...
                                           'Force',[],...
                                           'Moment',[]);
                obj.LandmarkStruct = struct('Landmark', {},...
                                            'Type', {},...
                                            'Position', [],...
                                            'Direction',{});
                obj.L = l;
                
            elseif nargin == 3
                obj.LoadStruct = struct('Load',{},...
                                        'Position',[],...
                                        'Type',{},...
                                        'Magnitude',[]);
                obj.SupportStruct = struct('Support',{},...
                                           'Type',{},...
                                           'Position',[],...
                                           'Force',[],...
                                           'Moment',[]);
                obj.LandmarkStruct = struct('Landmark', {},...
                                            'Type', {},...
                                            'Position', []);
                obj.L = l;
                obj.I = I;
                obj.E = E;
                
            else
                error('Wrong number of inputs to Beam()!');
            end
        end
        
        % Adds the support at the specified location
        function addSupport(beam, support)
            newSupIndex = size(beam.SupportStruct, 2) + 1;
            newLIndex = size(beam.LandmarkStruct, 2) + 1;
            
            beam.SupportStruct(newSupIndex).Support = support;
            beam.SupportStruct(newSupIndex).Type = support.Type;
            beam.SupportStruct(newSupIndex).Position = support.Position;
            
            beam.LandmarkStruct(newLIndex).Landmark = support;
            beam.LandmarkStruct(newLIndex).Type = support.Type;
            beam.LandmarkStruct(newLIndex).Position = support.Position;
        end
        
        % Removes a support from the beam
        function removeSupport(beam, support)
            totSupports = size(beam.SupportStruct, 2);
            totLandmarks = size(beam.LandmarkStruct, 2);
            
            for supIndex = 1:totSupports
                if isequal(beam.SupportStruct(supIndex).Support, support)
                    beam.SupportStruct(supIndex) = [];
                    break;
                end
            end
            
            for lIndex = 1:totLandmarks
                if isequal(beam.LandmarkStruct(lIndex).Landmark, support)
                    beam.LandmarkStruct(lIndex) = [];
                    break;
                end
            end
        end
        
        % Changes a support Position
        function changeSupportPos(beam, support, newPos)
            totSupports = size(beam.SupportStruct, 2);
            totLandmarks = size(beam.LandmarkStruct, 2);
            
            for supIndex = 1:totSupports
                if isequal(beam.SupportStruct(supIndex).Support, support)
                    beam.SupportStruct(supIndex).Position = newPos;
                    beam.SupportStruct(supIndex).Support.Position = newPos;
                    break;
                end
            end
            
            for lIndex = 1:totLandmarks
                if isequal(beam.LandmarkStruct(lIndex).Landmark, support)
                    beam.LandmarkStruct(lIndex).Position = newPos;
                    break;
                end
            end
        end
        
        % Adds a load at the specified location
        function addLoad(beam, load)
            newLoadIndex = size(beam.LoadStruct, 2) + 1;
            newLIndex = size(beam.LandmarkStruct, 2) + 1;
            
            beam.LoadStruct(newLoadIndex).Load = load;
            beam.LoadStruct(newLoadIndex).Type = load.Type;
            beam.LoadStruct(newLoadIndex).Position = load.Position;
            beam.LoadStruct(newLoadIndex).Magnitude = load.Magnitude;
            
            beam.LandmarkStruct(newLIndex).Landmark = load;
            beam.LandmarkStruct(newLIndex).Type = load.Type;
            beam.LandmarkStruct(newLIndex).Position = load.Position;
            
            if strcmpi(load.Type,'moment')
                beam.LoadStruct(newLoadIndex).Direction = load.Direction;
                beam.LandmarkStruct(newLIndex).Direction = load.Direction;
            end
        end
        
        % Removes a load from the beam
        function removeLoad(beam, load)
            totLoads = size(beam.LoadStruct, 2);
            totLandmarks = size(beam.LandmarkStruct, 2);
            
            for loadIndex = 1:totLoads
                if isequal(beam.LoadStruct(loadIndex).Load, load)
                    beam.LoadStruct(loadIndex) = [];
                    break;
                end
            end
            
            for lIndex = 1:totLandmarks
                if isequal(beam.LandmarkStruct(lIndex).Landmark, load)
                    beam.LandmarkStruct(lIndex) = [];
                    break;
                end
            end
        end
        
        % Changes a load's magnitude
        function changeLoadMagnitude(beam, load, newMag)
            totSupports = size(beam.LoadStruct, 2);
            
            for loadIndex = 1:totSupports
                if isequal(beam.LoadStruct(loadIndex).Load, load)
                    beam.LoadStruct(loadIndex).Magnitude = newMag;
                    beam.LoadStruct(loadIndex).Load.Magnitude = newMag;
                    return;
                end
            end
        end
        
        % Changes a load's position
        function changeLoadPosition(beam, load, newPos)
            totSupports = size(beam.LoadStruct, 2);
            totLandmarks = size(beam.LandmarkStruct, 2);
            
            for loadIndex = 1:totSupports
                if isequal(beam.LoadStruct(loadIndex).Load, load)
                    beam.LoadStruct(loadIndex).Position = newPos;
                    beam.LoadStruct(loadIndex).Load.Position = newPos;
                    break;
                end
            end
            
            for lIndex = 1:totLandmarks
                if isequal(beam.LandmarkStruct(lIndex).Landmark, support)
                    beam.LandmarkStruct(lIndex).Position = newPos;
                    break;
                end
            end
        end
        
        % Prepares the beam for analysis
        function degIndeterminacy = prepareBeam(beam)
            
            % Reset all these variables
            beam.f = 0;
            beam.m = 0;
            beam.Ftot = 0;
            
            numLoads = size(beam.LoadStruct, 2);
            numSupports = size(beam.SupportStruct, 2);
            
            % Find how many unknowns there are. I exclude x unknowns
            % because they are typically trivial for transverse loadings.
            for supportIndex = 1:numSupports
                if strcmpi(beam.SupportStruct(supportIndex).Type, 'fixedend')
                    beam.f = beam.f + 1;
                    beam.m = beam.m + 1;
                    
                elseif strcmpi(beam.SupportStruct(supportIndex).Type, 'pin')
                    beam.f = beam.f + 1;
                    
                elseif strcmpi(beam.SupportStruct(supportIndex).Type, 'roller')
                    beam.f = beam.f + 1;
                    
                end
            end
            
            % Find the total external force
            for loadIndex = 1:numLoads
                if strcmpi(beam.LoadStruct(loadIndex).Type, 'distload') ||...
                   strcmpi(beam.LoadStruct(loadIndex).Type, 'pointforce')
               
                    load = beam.LoadStruct(loadIndex).Load;
                    beam.Ftot = beam.Ftot + load.Magnitude;
                end
            end
            
            if beam.m + beam.f <= 2
                degIndeterminacy = 0;
            else
                degIndeterminacy = beam.m + beam.f - 2;
            end
        end
        
        % Returns the external torque about a position (absolute)
        function Ttot = getExternalTorque(beam, position)
            numLoads = size(beam.LoadStruct, 2); % Number of loads
            Ttot = 0;

            for loadIndex = 1:numLoads
                load = beam.LoadStruct(loadIndex);

                if strcmpi(load.Type, 'pointforce') || strcmpi(load.Type, 'distload')
                    currTorque = load.Magnitude * (load.Position - position) * beam.L;
                    Ttot = Ttot + currTorque;
                    
                elseif strcmpi(load.Type, 'moment')
                    dir = load.Direction;
                    
                    if strcmpi(dir,'cw')
                        currTorque = -load.Magnitude;
                        
                    elseif strcmpi(dir,'ccw')
                        currTorque = load.Magnitude;
                        
                    end
                    
                    Ttot = Ttot + currTorque;
                end
            end
        end
        
        % Returns the TOTAL, ABSOLUTE moment at a position (Includes
        % support reactions, only run this after those are solved)
        function moment = getTotalMoment(beam, position)
            numLandmarks = size(beam.LandmarkStruct, 2);
            moment = 0;
            
            for landmarkIndex = 1:numLandmarks
                landmark = beam.LandmarkStruct(landmarkIndex);
                
                if strcmpi(landmark.Type, 'pointforce') || strcmpi(landmark.Type, 'distload')
                    moment = moment + (landmark.Landmark.Magnitude .* ...
                                      (landmark.Position - position) .* beam.L);

                elseif strcmpi(landmark.Type, 'moment')
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        moment = moment - landmark.Landmark.Magnitude;

                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        moment = moment + landmark.Landmark.Magnitude;

                    end

                elseif strcmpi(landmark.Type, 'roller') || strcmpi(landmark.Type, 'pin')
                    moment = moment + landmark.Landmark.Fy .* ...
                                      (landmark.Position - position) .* beam.L;

                elseif strcmpi(landmark.Type, 'fixedend')
                    mom = landmark.Landmark.M;

                    if landmark.Landmark.Position ~= position
                        moment = moment + mom;
                    else
                        moment = mom;
                        return;
                    end

                    moment = moment + landmark.Landmark.Fy .* ...
                                      (landmark.Position - position) .* beam.L;
                end
            end
        end
        
    end
end
