%% clear commands
clc
clear
close all


%% import time
load("G:\My Drive\analytic_training_data\44\time_analytic.txt");


%% import noisy data
load("G:\My Drive\analytic_training_data\44\training_input.txt")


%% import noise-free data
load("G:\My Drive\analytic_training_data\44\training_output.txt")


%% import network output data
load("G:\My Drive\analytic_training_data\44\training_predict_matrix.txt")

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
parameters=readtable("G:\My Drive\analytic_training_data\44\parameters_analytic.txt");
parameters=table2struct(parameters);    


%% for-loop to perform curve fitting for all predictions
parameters_tau(1,10)=struct();

for N=1:height(training_predict_new)/2
    
    
%% fitting input
[xData, yData]=prepareCurveData(time_analytic,training_input(N,:)');

%set up fittype and options
ft=fittype("A1*decay(x,tau,100)", "independent", "x", "dependent", "y"); 
opts=fitoptions("Method", "NonlinearLeastSquares");
opts.Algorithm="Levenberg-Marquardt";
opts.Display="Off";
opts.MaxIter = 1000000;
opts.StartPoint=[1, 50];    

%fit model to data
[fitresult_input, ~]=fit(xData,yData,ft,opts);

%extract variables
confint_data_input=confint(fitresult_input);
coeffval_input=coeffvalues(fitresult_input);

boundaries_input=confint(fitresult_input);
boundaries_input=boundaries_input(:,2);

%set tau guess
tau_guess_input=coeffval_input(2);


%% fitting output
[xData, yData]=prepareCurveData(time_analytic,training_output(N,:)');

%set up fittype and options
ft=fittype("A1*decay(x,tau,100)", "independent", "x", "dependent", "y");
opts=fitoptions("Method", "NonlinearLeastSquares");
opts.Algorithm="Levenberg-Marquardt";
opts.Display="Off";
opts.MaxIter = 1000000;
opts.StartPoint=[1, 50];    

%fit model to data.
[fitresult_output, ~]=fit(xData,yData,ft,opts);

%extract variables
confint_data_output=confint(fitresult_output);
coeffval_output=coeffvalues(fitresult_output);

boundaries_output=confint(fitresult_output);
boundaries_output=boundaries_output(:,2);

%set tau guess
tau_guess_output=coeffval_output(2);


%% fitting prediction
[xData, yData]=prepareCurveData(time_analytic,training_predict_new(N,:)');

%set up fittype and options
ft=fittype("A1*decay(x,tau,100)", "independent", "x", "dependent", "y");
opts=fitoptions("Method", "NonlinearLeastSquares");
opts.Algorithm="Levenberg-Marquardt";
opts.Display="Off";
opts.MaxIter = 1000000;
opts.StartPoint=[1, 50];    

%fit model to data.
[fitresult_predict, gof]=fit(xData,yData,ft,opts);

%extract variables
confint_data_predict=confint(fitresult_predict);
coeffval_predict=coeffvalues(fitresult_predict);

boundaries_predict=confint(fitresult_predict);
boundaries_predict=boundaries_predict(:,2);

%set tau guess
tau_guess_predict=coeffval_predict(2);


%% parameters_tau
parameters_tau(N).noisy=tau_guess_input;
parameters_tau(N).clean=tau_guess_output;
parameters_tau(N).predict=tau_guess_predict;
parameters_tau(N).noisy_low_boundary=boundaries_input(1);
parameters_tau(N).noisy_high_boundary=boundaries_input(2);
parameters_tau(N).clean_low_boundary=boundaries_output(1);
parameters_tau(N).clean_high_boundary=boundaries_output(2);
parameters_tau(N).predict_low_boundary=boundaries_predict(1);
parameters_tau(N).predict_high_boundary=boundaries_predict(2);


%% loading bar
howlong=N;
percentage_done=(howlong/(height(training_predict_new)/2))*100

end


%% parameters
parameters_tau_matrix=struct2array(parameters_tau);
parameters_tau_matrix=reshape(parameters_tau_matrix, [9,height(training_predict_new)/2])';
sum(parameters_tau_matrix(:) == 1);


%% plotting scattergraph
n=10;
m=30;
figure()
plot(parameters_tau_matrix(:,2),parameters_tau_matrix(:,1),'.')
hold on
plot(parameters_tau_matrix(:,2),parameters_tau_matrix(:,2),'-','LineWidth',2,"color", [0.8500, 0.3250, 0.0980])
plot(parameters_tau_matrix(:,2),parameters_tau_matrix(:,3),'.')
errorbar(parameters_tau_matrix(n:m,2),parameters_tau_matrix(n:m,1),parameters_tau_matrix(n:m,1)-parameters_tau_matrix(n:m,5),parameters_tau_matrix(n:m,1)-parameters_tau_matrix(n:m,6),'.')
xlabel('True Time Constant (fs)')
ylabel('Fitted Time Constant (fs)')
grid on
legend('Noisy','Truth','Network output',"Noisy error",'location','northwest')
ylim([0 3000])

