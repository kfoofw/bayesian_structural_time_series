# https://rstudio-pubs-static.s3.amazonaws.com/257314_131e2c97e7e249448ca32e555c9247c6.html

library(tidyverse, quietly = TRUE)
library(bsts, quietly = TRUE)    
data(iclaims)
.data <- initial.claims
claims <- .data$iclaimsNSA
plot(claims, ylab = "")

(model_components <- list())

# Adding a linear trend component
model_components <- AddLocalLinearTrend(model_components, y = claims)
# Adding a weekly seasonal and yearly seasonal component
model_components <- AddSeasonal(model_components, y = claims, nseasons  = 52)

# Fit the model
fit <- bsts(claims, model_components, niter = 2000)

burnin <- 500 # Throw away first 500

# Create tibble and plot
compiled_tb <- tibble(
  date = as.Date(time(claims)),
  trend = colMeans(fit$state.contributions[-(1:burnin),"trend",]),
  seasonality = colMeans(fit$state.contributions[-(1:burnin),"seasonal.52.1",])) %>%
  gather("component", "value", trend, seasonality) 

compiled_tb %>%
  ggplot(aes(x = date, y= value)) + 
  geom_line() + theme_bw() + 
  theme(legend.title = element_blank()) + ylab("") + xlab("") +
  facet_grid(component ~ ., scales="free") + guides(colour=FALSE) +
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

# plotting predictions with quantiles
pred <- predict(fit, horizon = 100, burn = burnin, quantiles = c(.05, .95))
plot(pred)
  
# Plotting errors but this seems to have issue. use plot(fit, "prediction.errors")
errors <- bsts.prediction.errors(fit, burn = 1000)
# PlotDynamicDistribution(errors)
plot(fit, "prediction.errors")

# Fit regressors
fit2 <- bsts(iclaimsNSA ~ ., state.specification = model_components, 
             data = initial.claims, niter = 1000)
# Find the posterior sample means
colMeans(fit2$coefficients)
