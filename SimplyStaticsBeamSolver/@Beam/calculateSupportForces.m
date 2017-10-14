function calculateSupportForces(beam)
            
    % Orders all landmarks/loads/supports in order of position left to right
    [~, ord1] = sort([beam.LandmarkStruct.Position]);
    beam.LandmarkStruct = beam.LandmarkStruct(ord1);
    [~, ord2] = sort([beam.LoadStruct.Position]);
    beam.LoadStruct = beam.LoadStruct(ord2);
    [~, ord3] = sort([beam.SupportStruct.Position]);
    beam.SupportStruct = beam.SupportStruct(ord3);

    % Initializing key values + determining degree of indeterminacy
    degIndeterminacy = prepareBeam(beam);
    
    % --- STATICALLY DETERMINATE BEAMS --- %
    if degIndeterminacy == 0
        
        % Function that calculates support forces for degree indeterminacy
        % of 0
        calculateSFDeterminate(beam);

    % --- STATICALLY INDETERMINATE BEAMS: DEGREE 1 --- %
    elseif degIndeterminacy == 1
        
        % - FIXED END + ROLLER SUPPORT - %
        if beam.f == 2 && beam.m == 1
            
            % Function that calculates support forces for a fixed end +
            % roller configuration
            calculateSupportForcesID1FER(beam)
            
        % - 2 ROLLERS 1 PIN - %
        elseif beam.f == 3 && beam.m == 0
            
            error('This case is not solvable by techniques taught in ME C85. We apologize for the inconvenience!');
            
        else
            error('Beam is either non-static or is indeterminate!');
        end

    % --- STATICALLY INDETERMINATE BEAMS: DEGREE 2 --- %
    elseif degIndeterminacy == 2
        
        % - 2 FIXED ENDS - %
        if beam.f == 2 && beam.m == 2
            
            % Function that calculates support forces for 2 fixed ends
            calculateSupportForcesID22FE(beam);
            
        % - 1 FIXED END + 2 ROLLERS - %
        elseif beam.f == 3 && beam.m == 1
            
            % Function that calculates support forces for 1 fixed end + 2
            % rollers
            calculateSupportForcesID21FE2R(beam)
            
        % - 1 PIN 3 ROLLERS - %
        elseif beam.f == 4 && beam.m == 0
            
            error('This case is not solvable by techniques taught in ME C85. We apologize for the inconvenience!');
            
        else
            error('Beam is either non-static or is indeterminate!');
        end

    % --- STATICALLY INDETERMINATE BEAMS: DEGREE 3+ --- %
    else
        error('The solver can only resolve beams that are statically determinate to the second degree or lower!');
    end

end
