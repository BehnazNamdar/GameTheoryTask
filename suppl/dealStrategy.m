function y = dealStrategy(x,grs)

switch grs 
    case 'g'   % generous
        
        if x == 0 
            y = 2;
        elseif x == 1
            y = 3;
        else 
            minimum = floor(((20 + 2 * x)* 0.5 ) - 10 + x) ;
            maximum = floor(((20 + 2 * x)* 0.6 ) - 10 + x) ;
            y = randsample([minimum: maximum- 1], 1);
        end

    case 'r'    % recip
        
        if x == 0 
            y = 1;
        elseif x == 1
            y = 2;
        else 
            minimum = x  ;
            maximum = floor(((20 + 2 * x)* 0.5 ) - 10 + x) ;
            y = randsample([minimum + 1 : maximum - 1] , 1);
        end
        
    case 's'    % selfish 
        
        if x == 0 
            y = 0;
        elseif x == 1
            y = randi([0,1]);
        else 
            y = floor(x * (randsample([50:100],1)/100));
        end


end

