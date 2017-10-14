classdef Support < handle
    
    properties (Abstract)
        Type; % String - the type of support
    end
    
    properties
        Position; % Normalized Double - where the support is
        Beam; % The beam the support is attached to
    end
    
    methods
        
        % Constructor
        function obj = Support(beam, position)
            if nargin == 2
                obj.Position = position;
                obj.Beam = beam;
                
                beam.addSupport(obj);
            else
                error('Wrong number of inputs to Support()!');
            end
        end
        
    end
    
end
