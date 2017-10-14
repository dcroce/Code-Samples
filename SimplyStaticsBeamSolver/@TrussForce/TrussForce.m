classdef TrussForce < handle
    %TrussForce
    
    properties
        Position;
        amountxy = [0,0];
        guinumber;
    end
    
    properties(Access = public)
        node;
    end
    
    methods
        function obj = TrussForce(position,amountxy)
            obj.Position = position;
            obj.amountxy = amountxy;
            %obj.amountxy = [-amountxy(2),-amountxy(1)];  
        end
        
        
        function plot(obj)
            hold on
            scale = 1.5;
            x1 = obj.Position(1);
            x2 = x1 + sign(obj.amountxy(1))*scale;
            y1 = obj.Position(2);
            y2 = y1 + sign(obj.amountxy(2))*scale;
            plot([x1,x2],[y1,y2],'g-','LineWidth',4)
        end
        
        
    end   
end

