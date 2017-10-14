function calculateShearMomentDiagrams(beam)
    
    totLandmarks = size(beam.LandmarkStruct, 2);
    
    % Should already have been ordered - this is a redundancy just in case
    [~, ord] = sort([beam.LandmarkStruct.Position]);
    beam.LandmarkStruct = beam.LandmarkStruct(ord);
    
    syms v(x);
    v(x) = 0; % Shear equation
    
    % Loop through the landmarks to make the shear diagram
    for lindex = 1:totLandmarks
        landmark = beam.LandmarkStruct(lindex);
        pos = landmark.Position;
        
        if strcmpi(landmark.Type, 'pointforce')
            mag = landmark.Landmark.Magnitude;
            
            v(x) = v(x) + piecewise(pos .* beam.L <= x <= beam.L, mag, 0);
        
        elseif strcmpi(landmark.Type, 'distload')
            mag = landmark.Landmark.Magnitude;
            loadStart = landmark.Landmark.Range(1);
            loadEnd = landmark.Landmark.Range(2);
            
            syms w(x);
            w(x) = sym(landmark.Landmark.Distribution); % dist function
            const = -subs(int(w(x)), x, loadStart .* beam.L);
            v(x) = v(x) + piecewise(loadStart .* beam.L <= x <= loadEnd .* beam.L, int(w(x)) + const,...
                                    loadEnd .* beam.L <= x <= beam.L, mag,...
                                    0);
            
        elseif strcmpi(landmark.Type, 'roller') || strcmpi(landmark.Type, 'pin')
            mag = landmark.Landmark.Fy;
            
            v(x) = v(x) + piecewise(pos .* beam.L <= x <= beam.L, mag, 0);
            
        elseif strcmpi(landmark.Type, 'fixedend')
            force = landmark.Landmark.Fy;
            v(x) = v(x) + piecewise(pos .* beam.L <= x <= beam.L, force, 0);
            
        end
    end

    shearFunc = v(x);
    
    % Use numerical integration to get moment diagram data points
    xvals = linspace(0, beam.L, 1000);
    vvals = subs(shearFunc, xvals);
    mvals = cumtrapz(xvals, vvals); % Constructing the array of moments
    
    % Loop through for moment discontinuities
    numLandmarks = size(beam.LandmarkStruct, 2);
    
    for landmarkIndex = 1:numLandmarks
        landmark = beam.LandmarkStruct(landmarkIndex);
        
        if strcmpi(landmark.Type, 'moment')
            moment = landmark.Landmark.Magnitude;
            position = landmark.Position .* beam.L;
            
            index = find(xvals >= position, 1, 'first'); % first position where moment applies
            mvals(index:end) = mvals(index:end) + moment;
            
        elseif strcmpi(landmark.Type, 'fixedend')
            moment = landmark.Landmark.M;
            position = landmark.Landmark.Position .* beam.L;
            
            if position == 0
                mvals = mvals + moment;
            end
        end
    end
    
    m0 = getTotalMoment(beam, 0); % Retrieves the moment boundary condition
    difference = mvals(1) - m0;
    mvals = mvals - difference;
    
    % Assignment
    beam.xvals = xvals;
    beam.vvals = vvals;
    beam.mvals = mvals;
    
    % Fixing Piecewise Display Issues
    beam.vvals(1000) = beam.vvals(999);
    beam.vvals(1) = beam.vvals(2);
end
