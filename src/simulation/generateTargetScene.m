function targets = generateTargetScene()

% Number of targets
targets.numTargets = 3;

% Target coordinates (meters)
targets.x = [-500, 0, 500];
targets.y = [1000, 1500, 1000];

% Reflectivity / RCS
targets.rcs = [1, 1, 1];

end