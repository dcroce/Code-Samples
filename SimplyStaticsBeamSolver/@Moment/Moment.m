classdef Moment < Load
    
    properties
        Type = 'moment';
        Direction; % This should be a string where you specify 'CW' or 'CCW'
    end
    
    methods
        
        % Constructor
        function obj = Moment(beam, position, magnitude, dir)
            if nargin ~= 4
                error('Wrong number of inputs to Moment()!');
                
            elseif ~strcmpi(dir, 'cw') && ~strcmpi(dir, 'ccw')
                error('Moment must be initialized with direction cw or ccw!');
                
            elseif magnitude < 0
                error('The magnitude of the moment should be positive!');
            end
            
            obj = obj@Load(beam, position, magnitude);
            obj.Direction = dir;
            
            beam.addLoad(obj);
        end
        
    end
    
end
