function [t,data,data_noisy,parameters] = training_data_analytic(t_start,t_step,t_end,FWHM)


%% random tau generation
tau_lower = 50;     %set a lower limit for tau1
tau_upper = 2000;    %set an upper limit for tau1

tau = tau_lower+randi(tau_upper-tau_lower);   %sets tau equal to an integer value between tau_lower and tau_upper

t = t_start:t_step:t_end-t_step;  %crop last value to set array length to 1x40


%% 
FWHM = FWHM/(2*sqrt(2*log(2)));   %change from standard dev to FWHM
data = (1/2)*exp(-(1/tau)*(t-(((1/tau)*FWHM^2)/2))).*(1 + erf((t-((1/tau)*FWHM^2))/(sqrt(2)*FWHM)));  %transient decay analytical equation
data = data/max(data);    %normalise


%% adding random noise
percent_noise = 50;   %set noise level

%randomly add/subtract noise to transient
random_noise = (rand(1,length(data))/100)*percent_noise;
plusorminus = (-1).^(randi(2,1,length(data)));
data_noisy = data+(random_noise.*plusorminus);


%% parameters 
parameters.tau = tau;     %save tau for later use


end
