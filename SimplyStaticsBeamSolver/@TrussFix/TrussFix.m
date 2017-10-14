classdef TrussFix < handle
    %TrussFix
    
    properties
        Position;
        Directions;
        guinumber;
    end
    
    properties(Access = public)
       node;
       ReactionForce = [];
    end
    
    methods
        function obj = TrussFix(Position,Directions)
            obj.Position = Position;
            obj.Directions = Directions;
        end
            
        
        function plot(obj)
            hold on
            if sum(obj.Directions) == 2
                plot(obj.Position(1),obj.Position(2),'bx','MarkerSize',27,'LineWidth',5)
            else
                plot(obj.Position(1),obj.Position(2),'cx','MarkerSize',27,'LineWidth',5)
            end
            
        end
        
        
    end 
end

