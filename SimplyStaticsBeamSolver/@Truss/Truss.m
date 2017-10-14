classdef Truss < handle
    %Truss
    
    properties (SetAccess = protected)
        Beam;
        Force;
        Fixture;
        F_final;
    end
    
    properties(Dependent = true,Access = public)
        norms;
        Con;
        Loc;
        M1;
        ExtensionMatrix;
        M;
        ForceVector;
        nodeloads;
        A;
        E;
        L;
    end
    
    methods
        function obj = Truss()
        end
        
        function y = addBeam(y,beam)
            if isa(beam,'TrussBeam')
                for i = 1:length(y.Beam)
                    if isequal(beam.Point1,y.Beam(i).Point1) && isequal(beam.Point2,y.Beam(i).Point2)
                        error('Beam is already used in truss')
                    end
                end
                y.Beam = [y.Beam;beam];
            else
                error('add beams of class TrussBeam');
            end
        end
        
        
        function y = removeBeam(y,beamnumber)
            y.Beam(beamnumber) = [];
        end
        
        
        function y = addForce(y,force)
            if isa(force,'TrussForce')
                y.Force = [y.Force;force];
            else
                error('add Forces of class TrussForce');
            end
        end
        
        
        function y = removeForce(y,forcenumber)
            y.Force(forcenumber) = [];
        end
        
        
        function y = addFixture(y,fix)
            if isa(fix,'TrussFix')
                y.Fixture = [y.Fixture;fix];
            else
                error('add Fixtures of class TrussFix');
            end  
        end
        
        
        function y = removeFixture(y,fixnumber)
            y.Fixture(fixnumber) = [];
        end
        
        
        function sol = solve(obj)
            disp1d = obj.M\obj.F_final; 
            Nn = max(max(obj.Con));
            sol = zeros(Nn,2);
            dispx = [];
            dispy = [];
            for i = 1:2:Nn*2-1
                dispx = [dispx;disp1d(i)];
                dispy = [dispy;disp1d(i+1)];
            end
            sol(:,1) = dispx;
            sol(:,2) = dispy;
            loc = obj.Loc;
            loc = loc';
            for i = 1:length(obj.Beam)
                for k = 1:length(loc)
                    %consider multiplying my 10^3 for more floats
                    if isequal(obj.Beam(i).Point1,loc(k,:))
                        obj.Beam(i).disp1 = obj.Beam(i).Point1 + sol(k,:);
                    end
                    if isequal(obj.Beam(i).Point2,loc(k,:))
                        obj.Beam(i).disp2 = obj.Beam(i).Point2 + sol(k,:);
                    end
                end
            end
            obj.nodeloads;
        end
        
        
        function n = get.norms(obj)
            n = [];
            for i = 1:length(obj.Beam)
                n = [n;obj.Beam(i).Norm];%gets norms from all of the beams
            end%assemble to matrix that truss can use easily
            n = n';
        end
        
        
        function l = get.Loc(obj)
            %gets locations of all teh nodes created by beam points
            nodes = [];
            Beampoints = [];
            for i = 1:length(obj.Beam)
                Beampoints = [Beampoints;obj.Beam(i).Point1;obj.Beam(i).Point2];
            end
            for j = 1:length(Beampoints)
                for k = 1:length(Beampoints)
                    if j == 1
                        nodes = Beampoints(1,:);
                        break
                    end
                    [check,~] = size(nodes);
                    if k > check
                        nodes = [nodes;Beampoints(j,:)];
                        break
                    end
                    if isequal(nodes(k,:),Beampoints(j,:))
                        break
                    end
                end
            end
            l = nodes';
        end
        
        
        function c = get.Con(obj)
            %assigns node values to forces fixes and beams and creates a
            %beam connectivity matrix for easy use later
            loc = obj.Loc;
            loc = loc';
            for i = 1:length(obj.Beam)
                for k = 1:length(loc)
                    if isequal(obj.Beam(i).Point1,loc(k,:))
                        obj.Beam(i).Con(1) = k;
                    end
                    if isequal(obj.Beam(i).Point2,loc(k,:))
                        obj.Beam(i).Con(2) = k;
                    end
                end
            end
            for i = 1:length(obj.Force)
                for k = 1:length(loc)
                    if isequal(obj.Force(i).Position,loc(k,:))
                        obj.Force(i).node = k;
                        break
                    end
                end
            end
            for i = 1:length(obj.Fixture)
                for k = 1:length(loc)
                    if isequal(obj.Fixture(i).Position,loc(k,:))
                        obj.Fixture(i).node = k;
                        break
                    end
                end
            end
            c = [];
            for i = 1:length(obj.Beam)
                c = [c;obj.Beam(i).Con];
            end
            c = c';
        end
        
        
        function EM = get.ExtensionMatrix(obj)
            Nb = length(obj.Beam);
            Nn = max(max(obj.Con));
            EM = zeros(2*Nn,Nb);
            for i = 1:Nb
                n1 = 2*(obj.Con(1,i)-1) + 1;
                n2 = 2*(obj.Con(2,i)-1) + 1;
                EM(n1 + 0 ,i) = obj.norms(1,i);
                EM(n1 + 1 ,i) = obj.norms(2,i);
                EM(n2 + 0 ,i) = -obj.norms(1,i);
                EM(n2 + 1 ,i) = -obj.norms(2,i);
            end
        end
        
        
        function m1 = get.M1(obj)
            UnitMat = obj.ExtensionMatrix;
            Nb = length(obj.Beam);
            const = -obj.A.*obj.E./obj.L;
            constMat = spdiags(const(:),0,Nb,Nb); 
            m1 =UnitMat*constMat*UnitMat';
        end
        
        
        function f = get.ForceVector(obj)
            Nn = max(max(obj.Con));
            f = zeros(Nn*2,1);
            for i = 1:length(obj.Force)
                node = obj.Force(i).node;
                x = obj.Force(i).amountxy(1);
                y = obj.Force(i).amountxy(2);
                f(node*2-1) =f(node*2-1) -x;
                f(node*2) =f(node*2) -y;
            end
        end
        
        
        function m = get.M(obj)
            %applying fixed boundary conditions
            m = obj.M1;
            obj.F_final = obj.ForceVector;
            for i = 1:length(obj.Fixture)
                istnode = 2*(obj.Fixture(i).node-1) +1;
                if obj.Fixture(i).Directions(1) ~= 0
                    obj.F_final(istnode + 0) = 0;
                    m(istnode + 0,:) = 0;
                    m(istnode + 0,istnode+0) = 1;
                end 
                if obj.Fixture(i).Directions(2) ~=0
                    obj.F_final(istnode + 1) = 0;
                    m(istnode + 1,:) = 0;
                    m(istnode + 1,istnode+1) = 1;
                end 
            end      
        end
        
        
        function plot(obj)
            for i = 1:length(obj.Beam)
               hold on
               obj.Beam(i).plot          
            end
        end
        
        
        function dispplot(obj)
            for i = 1:length(obj.Beam)
               %hold on
               %obj.Beam(i).plot
               hold on
               obj.Beam(i).dispplot    
            end  
        end
        
        
        function Clear(obj)
           for i = 1:length(obj.Beam)
              obj.removeBeam(1); 
           end
           for i = 1:length(obj.Fixture)
              obj.removeFixture(1); 
           end
           for i = 1:length(obj.Force)
              obj.removeForce(1); 
           end 
        end
        
        
        function nl = get.nodeloads(obj)
            nl = [];
            for i = 1:length(obj.Fixture)
                node = obj.Fixture(i).node;
                Fx = [];
                Fy = [];
                for j = 1:length(obj.Beam)
                    if obj.Beam(j).Con(1) == node
                        dir = 1;
                        if isequal(obj.Beam(j).TorC,'C')
                            dir = -1;
                        end
                        Fx = [Fx,obj.Beam(j).Norm(1)*obj.Beam(j).Force*dir];
                        Fy = [Fy,obj.Beam(j).Norm(2)*obj.Beam(j).Force*dir];
                    elseif obj.Beam(j).Con(2) == node
                        dir = 1;
                        if isequal(obj.Beam(j).TorC,'C')
                            dir = -1;
                        end
                        Fx = [Fx,-obj.Beam(j).Norm(1)*obj.Beam(j).Force*dir];
                        Fy = [Fy,-obj.Beam(j).Norm(2)*obj.Beam(j).Force*dir];      
                    end
                end
                Fxtot = round(sum(Fx),1);
                Fytot = round(sum(Fy),1);
                obj.Fixture(i).ReactionForce = [];
                if isequal(obj.Fixture(i).Directions,[1,1]) 
                    obj.Fixture(i).ReactionForce = [-Fxtot,-Fytot];
                elseif isequal(obj.Fixture(i).Directions,[1,0]) 
                    obj.Fixture(i).ReactionForce = [-Fxtot,0];
                else  
                    obj.Fixture(i).ReactionForce = [0,-Fytot];
                end
                nl = [nl;-Fxtot,-Fytot];
            end
            
        end
        
        function A = get.A(obj)
            A = zeros(1,length(obj.Beam));
            for i = 1:length(obj.Beam)
                A(1,i) = obj.Beam(i).A;
            end
        end
        
        function E = get.E(obj)
            E = zeros(1,length(obj.Beam));
            for i = 1:length(obj.Beam)
                E(1,i) = obj.Beam(i).E;
            end
        end
        
        function L = get.L(obj)
            L = zeros(1,length(obj.Beam));
            for i = 1:length(obj.Beam)
                L(1,i) = obj.Beam(i).L;
            end
        end
        
        
    
    end
end

