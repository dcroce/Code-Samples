classdef TrussBeam < handle
    %Beam
    
    properties
        E;
        A;
        Material;%not sure if will use
        Point1;
        Point2;
        disp1;
        disp2;
        guinumber;
        yield;
    end
    
    properties (Access = public)
        Con = [0,0];
    end
    
    properties (Dependent = true)
       L;
       Norm;
       Stress;
       TorC;
       L2;
       FOS;
       Force;
    end
    
    methods
        function obj = TrussBeam(Point1,Point2,E,A)
            obj.Point1 = Point1;
            obj.Point2 = Point2;
            obj.E = E;
            obj.A = A;
        end
        
        
        function l = get.L(obj)
           x1 = obj.Point1(1,1);
           y1 = obj.Point1(1,2);
           x2 = obj.Point2(1,1);
           y2 = obj.Point2(1,2);
           l = sqrt((x1-x2)^2 + (y1-y2)^2); 
        end
        
        
        function N = get.Norm(obj)
           x1 = obj.Point1(1,1);
           y1 = obj.Point1(1,2);
           x2 = obj.Point2(1,1);
           y2 = obj.Point2(1,2);
           N = [(x2-x1)/obj.L,(y2-y1)/obj.L];  
        end
        
        
        function plot(obj)
            plot([obj.Point1(1),obj.Point2(1)],[obj.Point1(2),obj.Point2(2)],'black','LineWidth',5)
        end
        
        
        function dispplot(obj)
            plot([obj.disp1(1),obj.disp2(1)],[obj.disp1(2),obj.disp2(2)],'red','LineWidth',5)
        end
         
        
        function L = get.L2(obj)
           x1 = obj.disp1(1);
           y1 = obj.disp1(2);
           x2 = obj.disp2(1);
           y2 = obj.disp2(2);
           L = sqrt((x1-x2)^2 + (y1-y2)^2); 
        end
            
        
        function S = get.Stress(obj)
           dl = abs(obj.L2 - obj.L);
           S = round(dl*obj.E/(obj.L*10^5))/10;
        end
        
        
        function tc = get.TorC(obj)
            if obj.L2 > obj.L
                tc = 'T';
            else
                tc = 'C';
            end
        end
        
        
        function x = get.FOS(obj)
           x = round((obj.yield/(10^5))/obj.Stress)/10; 
        end
        
        
        function f = get.Force(obj)
            f = round(obj.Stress*10^4*obj.A)/10;
        end
               
        
    end
end

