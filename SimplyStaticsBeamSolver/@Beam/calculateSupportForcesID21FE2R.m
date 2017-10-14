% 1 FIXED END 2 ROLLERS
function calculateSupportForcesID21FE2R(beam)

    % Check if there are only 2 rollers
    rollerCount = 0;

    for supIndex = 1:3
        type = beam.SupportStruct(supIndex).Type;

        if strcmpi(type, 'roller')
            rollerCount = rollerCount + 1;
        end
    end

    if rollerCount ~= 2
        error('This setup has indeterminate x forces! Reconfigure your supports.');
    end

    % First component is fixed end force, next two are the rollers, last is
    % the fixed end moment
    bVect = [-beam.Ftot; 0; 0; 0];
    
    % Equations matrix
    % Row 2 will be the deflection equation for roller1
    % Row 3 will be the deflection equation for roller2
    A = zeros(4,4);

    A(1,:) = [1 1 1 0]; % Sum of forces
    
    % The support objects
    sup1 = beam.SupportStruct(1).Support;
    sup2 = beam.SupportStruct(2).Support;
    sup3 = beam.SupportStruct(3).Support;
    
    % Checking which support is the fixed end; assigning rollers. roller1
    % is going to be to the left of roller2
    if strcmpi(sup1.Type, 'fixedend')
        fePos = sup1.Position;
        
        if sup2.Position < sup3.Position
            roller1 = sup2;
            roller2 = sup3;
            r1Pos = sup2.Position;
            r2Pos = sup3.Position;
        else
            roller1 = sup3;
            roller2 = sup2;
            r1Pos = sup3.Position;
            r2Pos = sup2.Position;
        end
        
    elseif strcmpi(sup2.Type, 'fixedend')
        fePos = sup2.Position;
        
        if sup1.Position < sup3.Position
            roller1 = sup1;
            roller2 = sup3;
            r1Pos = sup1.Position;
            r2Pos = sup3.Position;
        else
            roller1 = sup3;
            roller2 = sup1;
            r1Pos = sup3.Position;
            r2Pos = sup1.Position;
        end
        
    else
        fePos = sup3.Position;
        
        if sup1.Position < sup2.Position
            roller1 = sup1;
            roller2 = sup2;
            r1Pos = sup1.Position;
            r2Pos = sup2.Position;
        else
            roller1 = sup2;
            roller2 = sup1;
            r1Pos = sup2.Position;
            r2Pos = sup1.Position;
        end
    end
    
    % Check to see if Ftot > 0, which would make this a
    % cantilever problem and render the rollers useless
    if beam.Ftot > 0
        removeSupport(beam, roller1);
        removeSupport(beam, roller2);
        
        calculateSupportForces(beam);
        
        addSupport(beam, roller1);
        addSupport(beam, roller2);
        
        roller1.Fy = 0;
        roller2.Fy = 0;
        beam.SupportStruct(2).Support.Fy = 0;
        beam.SupportStruct(3).Support.Fy = 0;
        return;
    end
    
    % (1) Gather torques from all external loadings
    Ttot = getExternalTorque(beam, fePos); % absolute units
    
    % (2) Modify matrix equation
    bVect(4) = -Ttot;
    A(4,:) = [0 ((r1Pos - fePos) .* beam.L) ((r2Pos - fePos) .* beam.L) 1]; % Sum of moments about the fixed end
    
    % (3) Release the rollers. The two constraints are the deflections at
    % the two rollers
    r1PosDeltaTot = 0;
    r2PosDeltaTot = 0;
    
    % Add the deflections at the rollers
    totLandmarks = size(beam.LandmarkStruct, 2);
    
    for lIndex = 1:totLandmarks
        landmark = beam.LandmarkStruct(lIndex);
        
        % Case: Landmark is a point force
        if strcmpi(landmark.Type, 'pointforce')
            pfPos = landmark.Position;
            mag = landmark.Landmark.Magnitude;

            if fePos == 0
                if r1Pos < pfPos
                    r1PosDeltaTot = r1PosDeltaTot + ...
                                    (mag / 6) .* ((r1Pos .* beam.L) .^ 2) .* ...
                                    (3 * pfPos - r1Pos) .* beam.L;
                else
                    r1PosDeltaTot = r1PosDeltaTot + ...
                                    (mag / 6) .* ((pfPos .* beam.L) .^ 2) .* ...
                                    (3 * r1Pos - pfPos) .* beam.L;
                end
                
                if r2Pos < pfPos
                    r2PosDeltaTot = r2PosDeltaTot + ...
                                    (mag / 6) .* ((r2Pos .* beam.L) .^ 2) .* ...
                                    (3 * pfPos - r2Pos) .* beam.L;
                else
                    r2PosDeltaTot = r2PosDeltaTot + ...
                                    (mag / 6) .* ((pfPos .* beam.L) .^ 2) .* ...
                                    (3 * r2Pos - pfPos) .* beam.L;
                end
            
            else
                if r1Pos < pfPos
                    r1PosDeltaTot = r1PosDeltaTot + ...
                                    (mag / 6) .* (((1 - pfPos) .* beam.L) .^ 2) .* ...
                                    (3 * (1 - r1Pos) - (1 - pfPos)) .* beam.L;
                    
                else
                    r1PosDeltaTot = r1PosDeltaTot + ...
                                    (mag / 6) .* (((1 - r1Pos) .* beam.L) .^ 2) .* ...
                                    (3 * (1 - pfPos) - (1 - r1Pos)) .* beam.L;
                end
                
                if r2Pos < pfPos
                    r2PosDeltaTot = r2PosDeltaTot + ...
                                    (mag / 6) .* (((1 - pfPos) .* beam.L) .^ 2) .* ...
                                    (3 * (1 - r2Pos) - (1 - pfPos)) .* beam.L;
                    
                else
                    r2PosDeltaTot = r2PosDeltaTot + ...
                                    (mag / 6) .* (((1 - r2Pos) .* beam.L) .^ 2) .* ...
                                    (3 * (1 - pfPos) - (1 - r2Pos)) .* beam.L;
                end
            end
            
        % Case: Landmark is an external moment
        elseif strcmpi(landmark.Type, 'moment')
            mPos = landmark.Position;
            mag = landmark.Landmark.Magnitude;
            
            if fePos == 0
                if r1Pos < mPos
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (-mag / 2) .* (r1Pos .* beam.L) .^ 2;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (mag / 2) .* (r1Pos .* beam.L) .^ 2;
                    end
                    
                else
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (-mag / 2) .* (mPos .* beam.L) .* ...
                                         (2 .* r1Pos - mPos) .* beam.L;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (mag / 2) .* (mPos .* beam.L) .* ...
                                         (2 .* r1Pos - mPos) .* beam.L;
                    end
                end
                
                if r2Pos < mPos
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (-mag / 2) .* (r2Pos .* beam.L) .^ 2;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (mag / 2) .* (r2Pos .* beam.L) .^ 2;
                    end
                else
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (-mag / 2) .* (mPos .* beam.L) .* ...
                                         (2 .* r2Pos - mPos) .* beam.L;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (mag / 2) .* (mPos .* beam.L) .* ...
                                         (2 .* r2Pos - mPos) .* beam.L;
                    end
                end
                
            else
                if r1Pos < mPos
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (mag / 2) .* ((1 - mPos) .* beam.L) .* ...
                                         (2 .* (1 - r1Pos) - (1 - mPos)) .* beam.L;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (-mag / 2) .* ((1 - mPos) .* beam.L) .* ...
                                         (2 .* (1 - r1Pos) - (1 - mPos)) .* beam.L;
                    end
                else
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (mag / 2) .* ((1 - r1Pos) .* beam.L) .^ 2;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r1PosDeltaTot = r1PosDeltaTot + ...
                                         (-mag / 2) .* ((1 - r1Pos) .* beam.L) .^ 2;
                    end
                end
                
                if r2Pos < mPos
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (mag / 2) .* ((1 - mPos) .* beam.L) .* ...
                                         (2 .* (1 - r2Pos) - (1 - mPos)) .* beam.L;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (-mag / 2) .* ((1 - mPos) .* beam.L) .* ...
                                         (2 .* (1 - r2Pos) - (1 - mPos)) .* beam.L;
                    end
                else
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (mag / 2) .* ((1 - r2Pos) .* beam.L) .^ 2;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        r2PosDeltaTot = r2PosDeltaTot + ...
                                         (-mag / 2) .* ((1 - r2Pos) .* beam.L) .^ 2;
                    end
                end
            end
            
        % Case: Landmark is a distributed load
        elseif strcmpi(landmark.Type, 'distload')
            loadStart = beam.L * landmark.Landmark.Range(1);
            loadEnd = beam.L * landmark.Landmark.Range(2);

            mag = landmark.Landmark.Magnitude;

            % -Distribution equation-
            syms w(x);
            w(x) = sym(landmark.Landmark.Distribution);

            % -Shear equations-
            syms v1(x);
            syms v2(x);
            syms v3(x);

            % -Moment equations-
            syms m1(x);
            syms m2(x);
            syms m3(x);

            % -Theta equations-
            syms theta1(x);
            syms theta2(x);
            syms theta3(x);

            % -Deflection equations-
            syms delta1(x);
            syms delta2(x);
            syms delta3(x);

            % -TOTAL DEFLECTION/ANGLE EQUATION-
            syms delta(x);
            
            if fePos == 0
                v1(x) = -mag;
                v3(x) = 0;

                % Boundary Condition
                Cv2 = -mag - subs(int(w(x)), x, loadStart);
                v2(x) = int(w(x)) + Cv2;

                m3(x) = 0;

                % Boundary Condition
                Cm2 = subs(-int(v2(x)), x, loadEnd);
                m2(x) = int(v2(x)) + Cm2;

                % Boundary Condition
                Cm1 = subs(m2(x), x, loadStart) - ...
                      subs(v1(x), x, 0) .* loadStart;
                m1(x) = subs(v1(x), x, 0) .* x + Cm1;

                % Boundary Condition
                Ctheta1 = subs(-int(m1(x)), x, 0);
                theta1(x) = int(m1(x)) + Ctheta1;

                % Boundary Condition
                Ctheta2 = subs(theta1(x), x, loadStart) - ...
                          subs(int(m2(x)), x, loadStart);
                theta2(x) = int(m2(x)) + Ctheta2;

                theta3(x) = subs(theta2(x), x, loadEnd);

                % Boundary Condition
                Cdelta1 = subs(-int(theta1(x)), x, 0);
                delta1(x) = int(theta1(x)) + Cdelta1;

                % Boundary Condition
                Cdelta2 = subs(delta1(x), x, loadStart) - ...
                          subs(int(theta2(x)), x, loadStart);
                delta2(x) = int(theta2(x)) + Cdelta2;

                % Boundary Condition
                Cdelta3 = subs(delta2(x), x, loadEnd) - ...
                          subs(int(theta3(x)), x, loadEnd);
                delta3(x) = int(theta3(x)) + Cdelta3;

                delta(x) = piecewise(0 <= x < loadStart, delta1(x),...
                                     loadStart <= x <= loadEnd, delta2(x),...
                                     loadEnd < x <= beam.L, delta3(x),...
                                     0);
                                 
                r1PosDeltaTot = r1PosDeltaTot + subs(delta(x), x, r1Pos .* beam.L);
                r2PosDeltaTot = r2PosDeltaTot + subs(delta(x), x, r2Pos .* beam.L);
                
            else
                v1(x) = 0;
                v3(x) = mag;

                % Boundary Condition
                Cv2 = -subs(int(w(x)), x, loadStart);
                v2(x) = int(w(x)) + Cv2;

                m1(x) = 0;

                % Boundary Condition
                Cm2 = subs(-int(v2(x)), x, loadStart);
                m2(x) = int(v2(x)) + Cm2;

                % Boundary Condition
                Cm3 = subs(m2(x), x, loadEnd) - ...
                      subs(v3(x), x, beam.L) .* loadEnd;
                m3(x) = subs(v3(x), x, beam.L) .* x + Cm3;

                % Boundary Condition
                Ctheta3 = subs(-int(m3(x)), x, beam.L);
                theta3(x) = int(m3(x)) + Ctheta3;

                % Boundary Condition
                Ctheta2 = subs(theta3(x), x, loadEnd) - ...
                          subs(int(m2(x)), x, loadEnd);
                theta2(x) = int(m2(x)) + Ctheta2;

                theta1(x) = subs(theta2(x), x, loadStart);
                
                % Boundary Condition
                Cdelta3 = subs(-int(theta3(x)), x, beam.L);
                delta3(x) = int(theta3(x)) + Cdelta3;

                % Boundary Condition
                Cdelta2 = subs(delta3(x), x, loadEnd) - ...
                          subs(int(theta2(x)), x, loadEnd);
                delta2(x) = int(theta2(x)) + Cdelta2;

                % Boundary Condition
                Cdelta1 = subs(delta2(x), x, loadStart) - ...
                          subs(int(theta1(x)), x, loadStart);
                delta1(x) = int(theta1(x)) + Cdelta1;
                
                delta(x) = piecewise(0 <= x < loadStart, delta1(x),...
                                     loadStart <= x <= loadEnd, delta2(x),...
                                     loadEnd < x <= beam.L, delta3(x),...
                                     0);
                                 
                r1PosDeltaTot = r1PosDeltaTot + subs(delta(x), x, r1Pos .* beam.L);
                r2PosDeltaTot = r2PosDeltaTot + subs(delta(x), x, r2Pos .* beam.L);
            end
            
        end
    end
    
    % Deflection about roller1
    if fePos == 0
        A(2,2) = -((r1Pos .* beam.L) .^ 3) / 3;
        A(2,3) = -(((r1Pos .* beam.L) .^ 2) / 6) .* (3 .* r2Pos - r1Pos) .* beam.L;
    else
        A(2,2) = -(((1 - r1Pos) .* beam.L) .^ 3) / 3;
        A(2,3) = -((((1 - r2Pos) .* beam.L) .^ 2) / 6) .* ...
                  (3 .* (1 - r1Pos) - (1 - r2Pos)) .* beam.L;
    end
    
    bVect(2) = r1PosDeltaTot;
    
    % Deflection about roller2
    if fePos == 0
        A(3,2) = -(((r1Pos .* beam.L) .^ 2) / 6) .* (3 .* r2Pos - r1Pos) .* beam.L;
        A(3,3) = -((r2Pos .* beam.L) .^ 3) / 3;
    else
        A(3,2) = -((((1 - r2Pos) .* beam.L) .^ 2) / 6) .* ...
                  (3 .* (1 - r1Pos) - (1 - r2Pos)) .* beam.L;
        A(3,3) = -(((1 - r2Pos) .* beam.L) .^ 3) / 3;
    end
    
    bVect(3) = r2PosDeltaTot;
    
    % Solving the matrix
    solVect = A \ bVect;
    
    feForce = solVect(1);
    r1Force = solVect(2);
    r2Force = solVect(3);
    feMoment = solVect(4);
    
    % Assigning Values
    if fePos == sup1.Position
        beam.SupportStruct(1).Force = feForce;
        beam.SupportStruct(1).Support.Fy = feForce;
        
        if sup1.Position == 0
            beam.SupportStruct(1).Moment = -feMoment;
            beam.SupportStruct(1).Support.M = -feMoment;
        else
            beam.SupportStruct(1).Moment = feMoment;
            beam.SupportStruct(1).Support.M = feMoment;
        end
        
        if r1Pos == sup2.Position
            beam.SupportStruct(2).Force = r1Force;
            beam.SupportStruct(3).Force = r2Force;
            beam.SupportStruct(2).Support.Fy = r1Force;
            beam.SupportStruct(3).Support.Fy = r2Force;
            
        else
            beam.SupportStruct(3).Force = r1Force;
            beam.SupportStruct(2).Force = r2Force;
            beam.SupportStruct(3).Support.Fy = r1Force;
            beam.SupportStruct(2).Support.Fy = r2Force;
        end
        
    elseif fePos == sup2.Position
        beam.SupportStruct(2).Force = feForce;
        beam.SupportStruct(2).Support.Fy = feForce;
        
        if sup2.Position == 0
            beam.SupportStruct(2).Moment = -feMoment;
            beam.SupportStruct(2).Support.M = -feMoment;
        else
            beam.SupportStruct(2).Moment = feMoment;
            beam.SupportStruct(2).Support.M = feMoment;
        end
        
        if r1Pos == sup1.Position
            beam.SupportStruct(1).Force = r1Force;
            beam.SupportStruct(3).Force = r2Force;
            beam.SupportStruct(1).Support.Fy = r1Force;
            beam.SupportStruct(3).Support.Fy = r2Force;
            
        else
            beam.SupportStruct(3).Force = r1Force;
            beam.SupportStruct(1).Force = r2Force;
            beam.SupportStruct(3).Support.Fy = r1Force;
            beam.SupportStruct(1).Support.Fy = r2Force;
        end
        
    else
        beam.SupportStruct(3).Force = feForce;
        beam.SupportStruct(3).Support.Fy = feForce;
        
        if sup3.Position == 0
            beam.SupportStruct(3).Support.M = -feMoment;
            beam.SupportStruct(3).Moment = -feMoment;
        else
            beam.SupportStruct(3).Support.M = feMoment;
            beam.SupportStruct(3).Moment = feMoment;
        end
        
        if r1Pos == sup1.Position
            beam.SupportStruct(1).Force = r1Force;
            beam.SupportStruct(2).Force = r2Force;
            beam.SupportStruct(1).Support.Fy = r1Force;
            beam.SupportStruct(2).Support.Fy = r2Force;
            
        else
            beam.SupportStruct(2).Force = r1Force;
            beam.SupportStruct(1).Force = r2Force;
            beam.SupportStruct(2).Support.Fy = r1Force;
            beam.SupportStruct(1).Support.Fy = r2Force;
        end
    end
    
end
