classdef Pin < Support
    
    properties
        Fy = [];
        Fx = 0; % True since we are always considering vertical loads
        Type = 'pin';
    end
    
    methods
        
        % Constructor
        function obj = Pin(beam, position)
            if nargin ~= 2
                error('Wrong number of inputs to Pin()!');
            end
            
            obj = obj@Support(beam, position);
        end
        
    end
    
end
