classdef Roller < Support
    
    properties
        Fy = []; % The y force of the roller
        Type = 'roller';
    end
    
    methods
        
        % Constructor
        function obj = Roller(beam, position)
            if nargin ~= 2
                error('Wrong number of inputs to Roller()!');
            end
            
            obj = obj@Support(beam, position);
        end
        
    end
    
end
