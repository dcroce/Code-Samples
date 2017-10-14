% ONE FIXED END, ONE ROLLER
function calculateSupportForcesID1FER(beam)
    % For this case we need to use beam elasticity to solve for
    % reactions - this will also give us the equation for position

    % The b vector will always be of this form. The
    % third component needs to have additional moment
    % components added to it (below). The second component
    % is tbd by the elasticity equation.
    bVect = [-beam.Ftot; 0; 0];

    % The equations matrix
    A = zeros(3, 3);

    A(1,:) = [1 1 0]; % Sum of forces
    sup1 = beam.SupportStruct(1).Support; % The support objects
    sup2 = beam.SupportStruct(2).Support;

    if strcmpi(sup1.Type, 'fixedend')
        % all normalized units
        fePos = beam.SupportStruct(1).Position; % fixed end position
        rPos = beam.SupportStruct(2).Position; % roller position
        freePos = abs(1 - fePos); % free end position

    else
        rPos = beam.SupportStruct(1).Position;
        fePos = beam.SupportStruct(2).Position;
        freePos = 1 - fePos;
    end

    % (1) Gather torques from all external loadings
    Ttot = getExternalTorque(beam, fePos); % absolute units

    % (2) Modify matrix equation
    bVect(3) = -Ttot;
    
    % Moment due to the roller support
    A(3,3) = 1;
    A(3,2) = (rPos - fePos) .* beam.L;

    % (3) Release redundant support (Make it F2, the roller force)
    rPosDeltaTot = 0; % The total external deflection corresponding to 
                      % position of the roller

    % Add the deflections at the roller
    totLandmarks = size(beam.LandmarkStruct, 2);

    for lIndex = 1:totLandmarks
        landmark = beam.LandmarkStruct(lIndex);

        % Case: Landmark is a point force
        if strcmpi(landmark.Type, 'pointforce')

            pfPos = landmark.Position;
            mag = landmark.Landmark.Magnitude;

            % Fixed end on left or right
            if freePos == 1
                if rPos < pfPos % if roller is between force and FE
                    rPosDeltaTot = rPosDeltaTot +...
                               (mag / 6) .* ((rPos .* beam.L) .^ 2) .* ((3 .* pfPos - rPos) .* beam.L);
                else
                    rPosDeltaTot = rPosDeltaTot +...
                               (mag / 6) .* ((pfPos .* beam.L) .^ 2) .* ((3 .* rPos - pfPos) .* beam.L);
                end

            else
                if rPos > pfPos % if roller is between force and FE
                    rPosDeltaTot = rPosDeltaTot +...
                               (mag / 6) .* (((1 - rPos) .* beam.L) .^ 2) .* ((3 .* (1 - pfPos) - (1 - rPos)) .* beam.L);
                else
                    rPosDeltaTot = rPosDeltaTot +...
                               (mag / 6) .* (((1 - pfPos) .* beam.L) .^ 2) .* ((3 .* (1 - rPos) - (1 - pfPos)) .* beam.L);
                end

            end

        % Case: Landmark is an external moment
        elseif strcmpi(landmark.Type, 'moment')

            mag = landmark.Landmark.Magnitude;
            mPos = landmark.Position;

            if freePos == 1
                if rPos < mPos
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (-mag / 2) .* (rPos .* beam.L) .^ 2;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (mag / 2) .* (rPos .* beam.L) .^ 2;
                    end
                    
                else
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (-mag / 2) .* (mPos .* beam.L) .* ...
                                       (2 .* rPos - mPos) .* beam.L;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (mag / 2) .* (mPos .* beam.L) .* ...
                                       (2 .* rPos - mPos) .* beam.L;
                    end
                end
                
            else
                
                if rPos > mPos
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (mag / 2) .* (beam.L - rPos .* beam.L) .^ 2;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (-mag / 2) .* (beam.L - rPos .* beam.L) .^ 2;
                    end
                   
                else
                    if strcmpi(landmark.Landmark.Direction, 'cw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (mag / 2) .* ((1 - mPos) .* beam.L) .* ...
                                       (2 .* (1 - rPos) - (1 - mPos)) .* beam.L;
                    elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                        rPosDeltaTot = rPosDeltaTot +...
                                       (-mag / 2) .* ((1 - mPos) .* beam.L) .* ...
                                       (2 .* (1 - rPos) - (1 - mPos)) .* beam.L;
                    end
                end
            end

        % Case: Landmark is a distributed load
        elseif strcmpi(landmark.Type, 'distload')

            loadStart = landmark.Landmark.Range(1);
            loadEnd = landmark.Landmark.Range(2);
            mag = landmark.Landmark.Magnitude;

            % Explanation: For any distributed load, you have a
            % piecewise equation of at most 3 parts. We're just
            % relating them all to each other here using continuity
            % rules. No logic for boundary conditions is explained
            % - it's just math.

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

            % -TOTAL DEFLECTION EQUATION-
            syms delta(x);

            % Subcase: Fixed end on left
            if freePos == 1

                v1(x) = -mag;
                v3(x) = 0;

                % Boundary Condition
                Cv2 = -mag - subs(int(w(x)), x, loadStart .* beam.L);
                v2(x) = int(w(x)) + Cv2;

                m3(x) = 0;

                % Boundary Condition
                Cm2 = subs(-int(v2(x)), x, loadEnd .* beam.L);
                m2(x) = int(v2(x)) + Cm2;

                % Boundary Condition
                Cm1 = subs(m2(x), x, loadStart .* beam.L) - ...
                      subs(v1(x), x, 0) .* (loadStart .* beam.L);
                m1(x) = subs(v1(x), x, 0) .* x + Cm1;

                % Boundary Condition
                Ctheta1 = subs(-int(m1(x)), x, 0);
                theta1(x) = int(m1(x)) + Ctheta1;

                % Boundary Condition
                Ctheta2 = subs(theta1(x), x, loadStart .* beam.L) - ...
                          subs(int(m2(x)), x, loadStart .* beam.L);
                theta2(x) = int(m2(x)) + Ctheta2;

                theta3(x) = subs(theta2(x), x, loadEnd .* beam.L);

                % Boundary Condition
                Cdelta1 = subs(-int(theta1(x)), x, 0);
                delta1(x) = int(theta1(x)) + Cdelta1;

                % Boundary Condition
                Cdelta2 = subs(delta1(x), x, loadStart .* beam.L) - ...
                          subs(int(theta2(x)), x, loadStart .* beam.L);
                delta2(x) = int(theta2(x)) + Cdelta2;

                % Boundary Condition
                Cdelta3 = subs(delta2(x), x, loadEnd .* beam.L) - ...
                          subs(int(theta3(x)), x, loadEnd .* beam.L);
                delta3(x) = int(theta3(x)) + Cdelta3;

            % Subcase: Fixed End on Right
            else

                v1(x) = 0;
                v3(x) = mag;

                % Boundary Condition
                Cv2 = subs(-int(w(x)), x, loadStart .* beam.L);
                v2(x) = int(w(x)) + Cv2;

                m1(x) = 0;

                % Boundary Condition
                Cm2 = -subs(int(v2(x)), x, loadStart .* beam.L);
                m2(x) = int(v2(x)) + Cm2;

                % Boundary Condition
                Cm3 = subs(m2(x), x, loadEnd .* beam.L) - ...
                      subs(v3(x), x, beam.L) .* loadEnd .* beam.L;
                m3(x) = subs(v3(x), x, beam.L) .* x + Cm3;

                % Boundary Condition
                Ctheta3 = -subs(int(m3(x)), x, beam.L);
                theta3(x) = int(m3(x)) + Ctheta3;

                % Boundary Condition
                Ctheta2 = subs(theta3(x), x, loadEnd .* beam.L) - ...
                          subs(int(m2(x)), x, loadEnd .* beam.L);
                theta2(x) = int(m2(x)) + Ctheta2;

                theta1(x) = subs(theta2(x), x, loadStart .* beam.L);

                % Boundary Condition
                Cdelta3 = -subs(int(theta3(x)), x, beam.L);
                delta3(x) = int(theta3(x)) + Cdelta3;

                % Boundary Condition
                Cdelta2 = subs(delta3(x), x, loadEnd .* beam.L) - ...
                          subs(int(theta2(x)), x, loadEnd .* beam.L);
                delta2(x) = int(theta2(x)) + Cdelta2;

                % Boundary Condition
                Cdelta1 = subs(delta2(x), x, loadStart .* beam.L) - ...
                          subs(int(theta1(x)), x, loadStart .* beam.L);
                delta1(x) = int(theta1(x)) + Cdelta1;

            end

            delta(x) = piecewise(0 <= x < loadStart .* beam.L, delta1(x),...
                                 loadStart .* beam.L <= x <= loadEnd .* beam.L, delta2(x),...
                                 loadEnd .* beam.L < x <= beam.L, delta3(x),...
                                 0);

            % Adding the deflection to the total
            rPosDeltaTot = rPosDeltaTot + subs(delta(x), x, rPos .* beam.L);
        end
    end

    if beam.Ftot > 0 % if sum of forces renders the roller useless
        Froller = 0;

    else
        % We know that deflection at the roller is 0;
        if fePos == 0 % Fixed End on the left
            % This is a solved result
            Froller = (-3 / (rPos .* beam.L) ^ 3) .* rPosDeltaTot;

        else % Fixed End on the right
            Froller = (-3 / ((1 - rPos) .* beam.L) ^ 3) .* rPosDeltaTot;
        end
    end

    A(2,2) = 1;
    bVect(2) = Froller; % We've solved this result completely

    solVect = A \ bVect;

    fixedEndForce = solVect(1);
    rollerForce = solVect(2);
    fixedEndMoment = solVect(3);

    % Assigning all variables
    if strcmpi(sup1.Type,'fixedend')
        beam.SupportStruct(1).Force = fixedEndForce;
        beam.SupportStruct(2).Force = rollerForce;

        sup1.Fy = fixedEndForce;
        
        if sup1.Position == 0
            beam.SupportStruct(1).Moment = -fixedEndMoment;
            sup1.M = -fixedEndMoment;
        else
            beam.SupportStruct(1).Moment = fixedEndMoment;
            sup1.M = fixedEndMoment;
        end
        
        sup2.Fy = rollerForce;
        
    else
        beam.SupportStruct(2).Force = fixedEndForce;
        beam.SupportStruct(1).Force = rollerForce;

        sup2.Fy = fixedEndForce;
        
        if sup2.Position == 0
            beam.SupportStruct(2).Moment = -fixedEndMoment;
            sup2.M = -fixedEndMoment;
        else
            beam.SupportStruct(2).Moment = fixedEndMoment;
            sup2.M = fixedEndMoment;
        end
        
        sup1.Fy = rollerForce;
    end
end
