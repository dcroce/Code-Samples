classdef DistLoad < Load
    
    properties
        Range; % normalized 1x2 double - the interval of the load
        Distribution; % an ABSOLUTE anonymous function representing load distribution
        Type = 'distload';
    end
    
    methods
        
        % Constructor
        function obj = DistLoad(beam, range, distribution)
            if nargin ~= 3
                error('Wrong number of inputs to DistLoad()!');
            end
            
            syms x;
            centFunc = sym(distribution) * x;
            centFunc = matlabFunction(centFunc);
            
            obj = obj@Load(beam,...
                           (integral(centFunc,... % x-centroid of loading curve area
                               range(1),...
                               range(2),...
                               'ArrayValued',...
                               true) / ...
                           integral(distribution,...
                               range(1),...
                               range(2),...
                               'ArrayValued',...
                               true)),...
                           (integral(distribution,... % Area under load curve
                           beam.L .* range(1),...
                           beam.L .* range(2),...
                           'ArrayValued',...
                           true)));
                           
            obj.Beam = beam;
            obj.Distribution = distribution;
            obj.Range = range;
            
            beam.addLoad(obj);
        end
        
    end
    
end
