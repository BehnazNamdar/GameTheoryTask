function pay = dealPayStrategy(x,y,payStrategy)

if y <= x 
    grs = 's';
elseif x < y && y < ((20 + 2 * x)* 0.5 ) - 10 + x  
    grs = 'r';
elseif ((20 + 2 * x)* 0.5 ) - 10 + x  <= y 
    grs = 'g';
end

% Define the ranges for the number of coins
coin = {1:3, 4:7, 8:10};


% Define the probability distribution
if payStrategy == 1  % Cooperative
    
    switch grs 
        case 'g'   % generous
            prob_distribution = [0.2, 0.2, 0.6]; % Probability of giving 1-3, 4-7, and 8-10 
        case 'r'    % recip
            prob_distribution = [0.2, 0.6, 0.2];
        case 's'    % selfish
            prob_distribution = [0.6, 0.2, 0.2];
    end

elseif payStrategy == 2  % Non-cooperative
    
    switch grs 
        case 'g'   % generous
            prob_distribution = [0.33, 0.33, 0.33]; % Probability of giving 1-3, 4-7, and 8-10 
        case 'r'    % recip
            prob_distribution = [0.4, 0.5, 0.1];
        case 's'    % selfish
            prob_distribution = [0.8, 0.2, 0.0];
    end

end

% Choose a range based on the probability distribution
range_idx = randsample(3, 1, true, prob_distribution);

% Choose a random number of coins within the chosen range
pay = randsample(coin{range_idx}, 1);



