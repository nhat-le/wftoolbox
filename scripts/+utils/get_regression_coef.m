function [b, CI] = get_regression_coef(data, xCenter, yCenter, roisize, Xmat, window)
traces = utils.get_single_trace(data, xCenter, yCenter, roisize);
y = traces(window + 1:end);
% split into parts
mdl = fitlm(Xmat, y, 'Intercept', false);
b = mdl.Coefficients.Estimate;
CI = mdl.coefCI;

end