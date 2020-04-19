library(bsts)
library(tidyverse)
library(zoo)

dat_train <- read_csv("data/train_shoreline.csv")
dat_test <- read_csv("data/test_shoreline.csv")

#### Monthly aggregation

# Train data
shore_train <- zoo(dat_train$shoreline,
                   strptime(dat_train$time_Y_m_d, '%Y-%m-%d')) %>% 
  # Aggregating into monthly data
  aggregate(as.yearmon, mean, na.rm = TRUE)

plot(shore_train)

# Local Linear Trend with Monthly Season
ss <- list()
ss <- AddLocalLinearTrend(ss, shore_train)
ss <- AddSeasonal(ss, shore_train, nseasons = 12, season.duration = 1)
model1 <- bsts(shore_train,
               state.specification = ss,
               niter = 1000)

# Plot fitted data based on model
plot(model1)
# Plot components: Local Trend and Seasonal componet
plot(model1, "components")

# Plot prediction
pred1 <- predict(model1, horizon = 36)
plot(pred1, plot.original = 156)


# Adding Semilocal linear trend with Monthly Season
ss2 <- list()
ss2 <- AddSemilocalLinearTrend(ss2, shore_train)
ss2 <- AddSeasonal(ss2, shore_train, nseasons = 12, season.duration = 1)
model2 <- bsts(shore_train, state.specification = ss2, niter = 1000)
pred2 <- predict(model2, horizon = 36)

plot(model2)

plot(model2, "components")
plot(model2, "forecast.distribution")

plot(pred2, plot.original = 156)

CompareBstsModels(list("Model 1" = model1,
                       "Model2" = model2),
                  colors = c("black", "red"))

##### Aggregation by Weekly data
dat_train_week <- dat_train %>% 
    group_by(week = cut(time_Y_m_d, "week")) %>%
    summarise(shoreline = mean(shoreline, na.rm = TRUE)) %>%
    mutate(week = as.Date(as.character(week)))

shore_train_week <-zoo(dat_train_week$shoreline,
                       strptime(dat_train_week$week, '%Y-%m-%d'))

plot(shore_train_week)

# Local Linear Trend with Weekly Season
ss1_week <- list()
ss1_week <- AddLocalLinearTrend(ss1_week, shore_train_week)
ss1_week <- AddSeasonal(ss1_week, shore_train_week, nseasons = 52, season.duration = 1)
model1_week <- bsts(shore_train_week,
                    state.specification = ss1_week,
                    niter = 500)
