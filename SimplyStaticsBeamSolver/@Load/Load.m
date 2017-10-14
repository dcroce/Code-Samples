classdef (Abstract) Load < handle
    
    properties (Abstract)
        Type; % String - what type of loading this is
    end
    
    properties
        Beam; % The Beam object this load will be applied to
        Position; % Normalized double - where the load is on the beam
                 % [*] For the distributed load, it's where the load is
                 % functionally applied (reduced to point load)
        Magnitude; % The signed loading.
                   % [*] For the distributed load, it's the equivalent
                   % magnitude of the load.
                   % [*] (+) is UP and CCW
    end
    
    methods
        
        % Constructor
        function obj = Load(beam, position, magnitude)
            if nargin == 0
                
            elseif nargin == 3
                obj.Beam = beam;
                obj.Position = position;
                obj.Magnitude = magnitude;
            else
                error('Wrong number of inputs to Load()!');
            end
        end
        
    end
    
end
