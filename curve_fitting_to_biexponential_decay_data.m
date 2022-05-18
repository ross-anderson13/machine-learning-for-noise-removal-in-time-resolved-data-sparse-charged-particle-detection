%% clear commands
clc
clear
close all


%% state FWHM
FWHM=100;


%% import time
load("G:\My Drive\analytic_training_data_seqpar\6\time_analytic.txt");


%% import noisy data
training_input=load("G:\My Drive\analytic_training_data_seqpar\6\noisy_data_analytic.txt");


%% import noise-free data
training_output=load("G:\My Drive\analytic_training_data_seqpar\6\clean_data_analytic.txt");


%% import network output data
load("G:\My Drive\analytic_training_data_seqpar\6\training_predict_matrix.txt")

no_of_points=length(time_analytic); %find length of array

training_predict_new=zeros(length(training_predict_matrix)/no_of_points,no_of_points);  %initialise matrix

%populate matrix
for n=1:length(training_predict_matrix)/no_of_points
    if n==1
        training_predict_new(n,:)=training_predict_matrix(1:no_of_points);
    else
        training_predict_new(n,:)=training_predict_matrix(no_of_points*(n-1)+1:no_of_points*n);
    end
end


%% import parameters structure
parameters=readtable("G:\My Drive\analytic_training_data_seqpar\6\parameters_analytic.txt");
parameters=table2struct(parameters);


%% for-loop to perform curve fitting for all predictions
parameters_tau(1,10)=struct();

for N=1:height(training_predict_new)/2

    
%% fitting input
[xData, yData]=prepareCurveData(time_analytic,training_input(N,:)');

%set up fittype and options
%firstly assume parallel model
ft=fittype("A1*decay(x,tau1,"+FWHM+")+A2*decay(x,tau2,"+FWHM+")", "independent", "x", "dependent", "y");   
opts=fitoptions("Method", "NonlinearLeastSquares");
opts.Algorithm="Levenberg-Marquardt";
opts.Display="Off";
opts.MaxFunEvals = 10000000;
opts.MaxIter = 10000000;
opts.StartPoint=[0.5,0.5,1000,2000];

%fit model to data
[fitresult_input, ~]=fit(xData,yData,ft,opts);

confint_data_input=confint(fitresult_input);

%check to see if any amplitudes are negative
if confint_data_input(1)<0 || confint_data_input(2)<0
    %assume sequential model
    [xData, yData]=prepareCurveData(time_analytic,training_input(N,:)');
    %set up fittype and options
    ft=fittype("A1*decay(x,tau1,"+FWHM+")+A2*decay(x,(tau1*tau2)/(tau1+tau2),"+FWHM+")", "independent", "x", "dependent", "y");   
    opts=fitoptions("Method", "NonlinearLeastSquares");
    opts.Algorithm="Levenberg-Marquardt";
    opts.Display="Off";
    opts.MaxFunEvals = 10000000;
    opts.MaxIter = 10000000;
    opts.StartPoint=[0.5,0.5,1000,2000];

    [fitresult_input, ~]=fit(xData,yData,ft,opts);

end

%extract variables
coeffval_input=coeffvalues(fitresult_input);

boundaries_input=confint(fitresult_input);
boundaries_input=boundaries_input(:,2);

a1_input=coeffval_input(1);
a2_input=coeffval_input(2);
tau1_guess_input=coeffval_input(3);
tau2_guess_input=coeffval_input(4);


%% fitting output
[xData, yData]=prepareCurveData(time_analytic,training_output(N,:)');

%set up fittype and options
%firstly assume parallel model
ft=fittype("A1*decay(x,tau1,"+FWHM+")+A2*decay(x,tau2,"+FWHM+")", "independent", "x", "dependent", "y");   
opts=fitoptions("Method", "NonlinearLeastSquares");
opts.Algorithm="Levenberg-Marquardt";
opts.Display="Off";
opts.MaxFunEvals = 10000000;
opts.MaxIter = 10000000;
opts.StartPoint=[0.5,0.5,1000,2000];

%fit model to data
[fitresult_output, ~]=fit(xData,yData,ft,opts);

confint_data_output=confint(fitresult_output);

%check to see if any amplitudes are negative
if confint_data_output(1)<0 || confint_data_output(2)<0
    %assume sequential model
    [xData, yData]=prepareCurveData(time_analytic,training_output(N,:)');
    %set up fittype and options
    ft=fittype("A1*decay(x,tau1,"+FWHM+")+A2*decay(x,(tau1*tau2)/(tau1+tau2),"+FWHM+")", "independent", "x", "dependent", "y");
    opts=fitoptions("Method", "NonlinearLeastSquares");
    opts.Algorithm="Levenberg-Marquardt";
    opts.Display="Off";
    opts.MaxFunEvals = 10000000;
    opts.MaxIter = 10000000;
    opts.StartPoint=[0.5,0.5,1000,2000];
    
    [fitresult_output, ~]=fit(xData,yData,ft,opts);
end


%extract variables
coeffval_output=coeffvalues(fitresult_output);

boundaries_output=confint(fitresult_output);
boundaries_output=boundaries_output(:,2);

a1_output=coeffval_output(1);
a2_output=coeffval_output(2);
tau1_guess_output=coeffval_output(3);
tau2_guess_output=coeffval_output(4);


%% fitting prediction
[xData, yData]=prepareCurveData(time_analytic,training_predict_new(N,:)');

%set up fittype and options
%firstly assume parallel model
ft=fittype("A1*decay(x,tau1,"+FWHM+")+A2*decay(x,tau2,"+FWHM+")", "independent", "x", "dependent", "y");   
opts=fitoptions("Method", "NonlinearLeastSquares");
opts.Algorithm="Levenberg-Marquardt";
opts.Display="Off";
opts.MaxFunEvals = 10000000;
opts.MaxIter = 10000000;
opts.StartPoint=[0.5,0.5,1000,2000];

%fit model to data.
[fitresult_predict, gof]=fit(xData,yData,ft,opts);
    
confint_data_predict=confint(fitresult_predict);

%check to see if any amplitudes are negative
if confint_data_predict(1)<0 || confint_data_predict(2)<0
    %assume sequential model
    %set up fittype and options
    [xData, yData]=prepareCurveData(time_analytic,training_predict_new(N,:)');
    ft=fittype("A1*decay(x,tau1,"+FWHM+")+A2*decay(x,(tau1*tau2)/(tau1+tau2),"+FWHM+")", "independent", "x", "dependent", "y");
    opts=fitoptions("Method", "NonlinearLeastSquares");
    opts.Algorithm="Levenberg-Marquardt";
    opts.Display="Off";
    opts.MaxFunEvals = 10000000;
    opts.MaxIter = 10000000;
    opts.StartPoint=[0.5,0.5,1000,2000];

    [fitresult_predict, ~]=fit(xData,yData,ft,opts);

end


%extract variables
coeffval_predict=coeffvalues(fitresult_predict);

boundaries_predict=confint(fitresult_predict);
boundaries_predict=boundaries_predict(:,2);

a1_predict=coeffval_predict(1);
a2_predict=coeffval_predict(2);
tau1_guess_predict=coeffval_predict(3);
tau2_guess_predict=coeffval_predict(4);


%% parameters
parameters_tau(N).tau1_noisy=tau1_guess_input;
parameters_tau(N).tau2_noisy=tau2_guess_input;
parameters_tau(N).tau1_clean=tau1_guess_output;
parameters_tau(N).tau2_clean=tau2_guess_output;
parameters_tau(N).tau1_predict=tau1_guess_predict;
parameters_tau(N).tau2_predict=tau2_guess_predict;


%% loading bar
howlong=N;
percentage_done=(howlong/(height(training_predict_new)/2))*100


end

