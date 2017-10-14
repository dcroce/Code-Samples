function calculateSupportForcesID22FE(beam)

    % First two components are end forces, last two are the moments
    bVect = [-beam.Ftot; 0; 0; 0];

    % Equations matrix
    A = zeros(4,4);

    A(1,:) = [1 1 0 0]; % Sum of forces
    sup1 = beam.SupportStruct(1).Support; % The support objects
    sup2 = beam.SupportStruct(2).Support;

    % Left/Right fixed ends
    if sup1.Position == 0
        feLeft = sup1;
        feRight = sup2;

    else
        feLeft = sup2;
        feRight = sup1;
    end

    % (1) Gather torques from all external loadings
    Ttot = getExternalTorque(beam, feLeft.Position); % absolute units

    % (2) Modify matrix equation
    bVect(4) = -Ttot;
    A(4,:) = [0 beam.L 1 1]; % Sum of moments about left end

    % (3) Release right fixed end. You need two constraints.
    rfePosDeltaTot = 0; % The total external deflection corresponding to 
                        % position of right end
    rfePosThetaTot = 0; % The total external angle corresponding to 
                        % position of left end

    % Add the deflections/angles at the right end
    totLandmarks = size(beam.LandmarkStruct, 2);

    for lIndex = 1:totLandmarks
        landmark = beam.LandmarkStruct(lIndex);

        % Case: Landmark is a point force
        if strcmpi(landmark.Type, 'pointforce')
            pfPos = landmark.Position;
            mag = landmark.Landmark.Magnitude;

            rfePosDeltaTot = rfePosDeltaTot + ...
                             (mag / 6) .* ((pfPos .* beam.L) .^ 2) .* ...
                             (3 - pfPos) .* beam.L;
            rfePosThetaTot = rfePosThetaTot + ...
                             (mag / 2) .* (pfPos .* beam.L) .^ 2;

        % Case: Landmark is an external moment
        elseif strcmpi(landmark.Type, 'moment')
            mPos = landmark.Position;
            mag = landmark.Landmark.Magnitude;

            if strcmpi(landmark.Landmark.Direction, 'cw')
                rfePosDeltaTot = rfePosDeltaTot + ...
                                 (-mag / 2) .* (mPos .* beam.L) .* ...
                                 (2 - mPos) .* beam.L;
                rfePosThetaTot = rfePosThetaTot + ...
                                 -mag .* (mPos .* beam.L);
            elseif strcmpi(landmark.Landmark.Direction, 'ccw')
                rfePosDeltaTot = rfePosDeltaTot + ...
                                 (mag / 2) .* (mPos .* beam.L) .* ...
                                 (2 - mPos) .* beam.L;
                rfePosThetaTot = rfePosThetaTot + ...
                                 mag .* (mPos .* beam.L);
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
            syms theta(x);
            syms delta(x);

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
                  subs(v1(x), x, 0) .* (loadStart);
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

            theta(x) = piecewise(0 <= x < loadStart, theta1(x),...
                                 loadStart <= x <= loadEnd, theta2(x),...
                                 loadEnd < x <= beam.L, theta3(x),...
                                 0);
            delta(x) = piecewise(0 <= x < loadStart, delta1(x),...
                                 loadStart <= x <= loadEnd, delta2(x),...
                                 loadEnd < x <= beam.L, delta3(x),...
                                 0);

            rfePosThetaTot = rfePosThetaTot + subs(theta(x), x, beam.L);                 
            rfePosDeltaTot = rfePosDeltaTot + subs(delta(x), x, beam.L);
        end
    end

    % Deflection equation
    A(2,2) = -((beam.L) .^ 3) / 3;
    A(2,4) = -((beam.L) .^ 2) / 2;
    bVect(2) = rfePosDeltaTot;

    % Angle equation
    A(3,2) = -((beam.L) .^ 2) ./ 2;
    A(3,4) = -beam.L;
    bVect(3) = rfePosThetaTot;

    % Solving the matrix
    solVect = A \ bVect;

    leftForce = solVect(1);
    rightForce = solVect(2);
    leftMoment = solVect(3);
    rightMoment = solVect(4);

    % Assigning values
    if beam.SupportStruct(1).Position == 0
        beam.SupportStruct(1).Force = leftForce;
        beam.SupportStruct(1).Moment = -leftMoment;
        beam.SupportStruct(2).Force = rightForce;
        beam.SupportStruct(2).Moment = rightMoment;

        feLeft.Fy = leftForce;
        feLeft.M = -leftMoment;
        feRight.Fy = rightForce;
        feRight.M = rightMoment;

    else
        beam.SupportStruct(2).Force = leftForce;
        beam.SupportStruct(2).Moment = -leftMoment;
        beam.SupportStruct(1).Force = rightForce;
        beam.SupportStruct(1).Moment = rightMoment;

        feLeft.Fy = leftForce;
        feLeft.M = -leftMoment;
        feRight.Fy = rightForce;
        feRight.M = rightMoment;
    end
end
