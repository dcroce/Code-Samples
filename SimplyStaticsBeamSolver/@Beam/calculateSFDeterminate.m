% STATICALLY DETERMINATE BEAMS
function calculateSFDeterminate(beam)

    % The b vector will always be of this form. The
    % second component needs to have additional moment
    % components added to it (below)
    bVect = [-beam.Ftot; 0];

    % The equations matrix
    A = zeros(2, 2);

    % - NO SUPPORTS - %
    if beam.f + beam.m == 0
        error('There are no supports on the beam!');

    % - SINGLE PIN/ROLLER - %
    elseif beam.f == 1 && beam.m == 0 
        error('The beam is not static! Reconfigure your supports.');

    % - PIN/ROLLER COMBINATION - %
    elseif beam.f == 2

        sup1 = beam.SupportStruct(1).Support;
        sup2 = beam.SupportStruct(2).Support;

        % Check to see if it's two pins instead of pin/roller
        if strcmpi(sup1.Type, 'pin') && strcmpi(sup2.Type, 'pin')
            % Not solvable because of the x components
            error('A two pin setup does not have solvable x forces! Reconfigure your supports.');
        end

        % Check to see if it's two rollers instead of pin/roller
        if strcmpi(sup1.Type, 'roller') && strcmpi(sup2.Type, 'roller')
            error('A two roller setup is not static! Reconfigure your supports.');
        end

        A(1,:) = [1 1]; % Both forces sum to Ftot
        supPos1 = beam.SupportStruct(1).Position; % Normalized positions of supports
        supPos2 = beam.SupportStruct(2).Position;

        % Solve for moment about first point

        % (1) Gather torques from all external loadings
        Ttot = getExternalTorque(beam, supPos1); % in absolute terms

        % (2) Set up the matrix equation
        bVect(2) = -Ttot; % modify b vector
        A(2,2) = (supPos2 - supPos1) .* beam.L; % weight of F2 about 0

        solVect = A \ bVect;

        % (3) Assign Values
        force1 = solVect(1);
        force2 = solVect(2);

        beam.SupportStruct(1).Force = force1;
        beam.SupportStruct(2).Force = force2;
        
        sup1.Fy = force1;
        sup2.Fy = force2;

    % - CANTILEVER - %
    else
        A(1,:) = [1 0]; % The force is immediately solved
        supPos = beam.SupportStruct(1).Position; % Position of the support

        % Solve for moment about fixed end

        % (1) Gather torques from all external loadings
        Ttot = getExternalTorque(beam, supPos); % in absolute units

        % (2) Set up the matrix equation
        bVect(2) = -Ttot;
        A(2,2) = 1;

        solVect = A \ bVect;

        % (3) Assign Values
        force = solVect(1);
        moment = solVect(2);

        beam.SupportStruct(1).Force = force;

        fixedend = beam.SupportStruct(1).Support;
        fixedend.Fy = force;
        
        % Convert rotation of moment to moment conventions for beam
        if fixedend.Position == 0
            beam.SupportStruct(1).Moment = -moment;
            fixedend.M = -moment;
        else
            beam.SupportStruct(1).Moment = moment;
            fixedend.M = moment;
        end
        
    end
end
