# http://www.unofficialgoogledatascience.com/2017/07/fitting-bayesian-structural-time-series.html?m=1
library(bsts)
data(iclaims)

# Nowcasting 
# Model has 3 state components: 
# trend, seasonal, regression
ss <- AddLocalLinearTrend(list(), initial.claims$iclaimsNSA)
ss <- AddSeasonal(ss, initial.claims$iclaimsNSA, nseasons = 52)
model1 <- bsts(initial.claims$iclaimsNSA,
               state.specification = ss,
               niter = 1000)
model1

plot(model1)
plot(model1, "components")  # plot(model1, "comp") works too!
# plot(model1, "help") # see available plotting data
# plot(model1, "residuals")

# Forecasting
pred1 <- predict(model1, horizon = 12)
plot(pred1, plot.original = 156)

# Fit a bsts model with expected model size 1, the default.
model2 <- bsts(iclaimsNSA ~ .,
               state.specification = ss,
               niter = 1000,
               data = initial.claims)

# Fit a bsts model with expected model size 5, to include more coefficients.
model3 <- bsts(iclaimsNSA ~ .,
               state.specification = ss,
               niter = 1000,
               data = initial.claims,
               expected.model.size = 5)  # Passed to SpikeSlabPrior.

# Plotting components breakdown
plot(model2, "comp")
plot(model3, "comp")

# Coefficient
plot(model2, "coef")
plot(model3, "coef")

# Checking one step ahead error
bsts.prediction.errors(model1)

# Comparing models
CompareBstsModels(list("Model 1" = model1,
                       "Model 2" = model2,
                       "Model 3" = model3),
                  colors = c("black", "red", "blue"))

# Long Term Forecasting
library(tidyquant)

Stocks <- tq_get(c("^GSPC","^IXIC","^DJI"), get = "stock.prices", from = "2012-07-01", to = "2017-07-01")

sp500 <- Stocks %>% 
  filter(symbol %in% "^GSPC") %>%
  select(date, close) 
  
sp500 <- zoo(sp500$close, sp500$date)

# Adding Local Linear trend. Essentially it is a non-stationary random walk model where the variance continues to grow with t
ss1 <- AddLocalLinearTrend(list(), sp500)
model1 <- bsts(sp500, state.specification = ss1, niter = 1000)
pred1 <- predict(model1, horizon = 360)

# Add stationary AR process
ss3 <- AddAutoAr(list(), sp500)
model3 <- bsts(sp500, state.specification = ss3, niter = 1000)
pred3 <- predict(model3, horizon = 360)

# Adding Semilocal linear trend. Hybrid model
ss2 <- AddSemilocalLinearTrend(list(), sp500)
model2 <- bsts(sp500, state.specification = ss2, niter = 1000)
pred2 <- predict(model2, horizon = 360)


# Local linear model with random walk. High local flexibility but a lot of variance
plot(pred1, plot.original = 360, ylim = range(pred1))
# Stationary AR where the trend component
plot(pred3, plot.original = 360, ylim = range(pred1))
# Semi Local linear has a lot more flexibility but exponential variance
plot(pred2, plot.original = 360, ylim = range(pred1))
