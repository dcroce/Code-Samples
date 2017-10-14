classdef PointForce < Load
    
    properties
        Type = 'pointforce';
    end
    
    methods
        
        % Constructor
        function obj = PointForce(beam, position, magnitude)
            if nargin ~= 3
                error('Wrong number of inputs to PointForce()!');
            end
            
            obj = obj@Load(beam, position, magnitude);
            
            beam.addLoad(obj);
        end
        
    end
    
end
