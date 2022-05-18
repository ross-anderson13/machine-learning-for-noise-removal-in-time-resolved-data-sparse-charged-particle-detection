function [t,data,data_noisy,parameters] = training_data_analytic_seqpar(t_start,t_step,t_end,FWHM)


%% random tau generation
tau1_lower = 50;     %set a lower limit for tau1
tau1_upper = 1250;    %set an upper limit for tau1

tau1 = tau1_lower+randi(tau1_upper-tau1_lower);   %sets tau1 equal to an integer value between tau1_lower and tau1_upper


tau2_lower = round(1.5*tau1);  %set a minimum value for second tau to be 150% of the first tau
tau2_upper = 1.6*tau1_upper;  %set a maximum value for second tau to be 160% of maximum first tau, tau2_upper cannot exceed 2000

tau2 = tau2_lower+randi(tau2_upper-tau2_lower);   %sets tau2 equal to an integer value between tau2_lower and tau2_upper

t = t_start:t_step:t_end-t_step;  %crop last value to set array length to 1x40



%% choose sequential or parallel decay
%if seqpar is equal to 1, we have sequential decay
%if seqpar is equal to 0, we have parallel decay
seqpar = round(rand);

if seqpar==0    %parallel decay
    seqpar_string = "parallel";
    data1 = decay(t,tau1,FWHM);   %use decay function to produce transient using tau1
    data2 = decay(t,tau2,FWHM);   %use decay function to produce transient using tau2
    data = data1+data2;
    data = data/max(data);    %normalise
    
elseif seqpar==1    %sequential decay
    seqpar_string = "sequential";
    data1 = decay(t,tau1,FWHM);   %use decay function to produce transient using tau1
    tau_combined = (tau1*tau2)/(tau1+tau2);   %create a combined time constant
    data2 = decay(t,tau_combined,FWHM);   %use decay function to produce transient using combined tau
    data = data1-data2;   %combine
    data = data/max(data);    %normalise
end


%% adding random noise
percent_noise = 50;   %set noise level

%randomly add/subtract noise to transient
random_noise = (rand(1,length(data))/100)*percent_noise;
plusorminus = (-1).^(randi(2,1,length(data)));
data_noisy = data+(random_noise.*plusorminus);


%% parameters 
parameters.tau1 = tau1;     %save tau1
parameters.tau2 = tau2;     %save tau2
parameters.seqpar=seqpar_string;    %save whether decay is parallel or sequential


end
