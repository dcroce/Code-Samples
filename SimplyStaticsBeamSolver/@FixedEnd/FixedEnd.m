classdef FixedEnd < Support
    
    properties
        Fx = 0; % Always true because loads are only vertical
        Fy = []; % The y force of the support; (+) is up
        M = []; % The moment of the support; (+) is "smiley", (-) is "sad"
        Type = 'fixedend';
    end
    
    methods
        
        % Constructor
        function obj = FixedEnd(beam, position)
            if nargin ~= 2
                error('Wrong number of inputs to FixedEnd()!');
            end
            
            if position ~= 0 && position ~= 1
                error('Fixed ends must be at the ends of the beam!');
            end
            
            obj = obj@Support(beam, position);
        end
        
    end
    
end
