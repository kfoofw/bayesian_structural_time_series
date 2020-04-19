library(bsts)
library(CausalImpact)
library(tidyverse)
library(zoo)


dat <- read_csv("data/airquality_northvan.csv")

dat_pm25_wk <- dat %>% 
  mutate(date = as.Date(date)) %>%
  group_by(week = cut(date, "week")) %>%
  summarise(pm25 = mean(pm25, na.rm = TRUE)) %>%
  mutate(week = as.Date(as.character(week)))

# Create row index
dat_pm25_wk <- dat_pm25_wk %>%
  mutate(index = row_number())

# Missing NA for 1 week
dat_pm25_wk %>%
  filter(is.na(pm25))

# Calculate mean of before and after week for the NA week data
imputed_mean <- dat_pm25_wk %>% 
  filter(index ==138 |index == 140) %>%
  summarise(mean_impute = mean(pm25)) %>%
  pull()

# Replace data with ifelse condition 
dat_pm25_wk <- dat_pm25_wk %>%
  mutate(pm25 = replace(pm25, is.na(pm25), imputed_mean))

# Check if missing data still exists
dat_pm25_wk %>%
  filter(is.na(pm25))

# Create ts zoo data
ts_pm25_wk <- zoo(dat_pm25_wk$pm25, dat_pm25_wk$week)

plot(ts_pm25_wk)

ggplot(dat_pm25_wk, aes(x = week, y = pm25))+
  geom_point()

# Local trend, weekly-seasonal
ss <- AddLocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss <- AddSeasonal(ss, ts_pm25_wk, nseasons = 52)
model1 <- bsts(ts_pm25_wk,
               state.specification = ss,
               niter = 1000)
plot(model1)
plot(model1, "components")

# Local trend, weekly-seasonal, monthly-seasonal
ss2 <- AddLocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss2 <- AddSeasonal(ss2, ts_pm25_wk, nseasons = 52)
# Add monthly seasonal
ss2 <- AddSeasonal(ss2, ts_pm25_wk, nseasons = 13, season.duration = 4)
model2 <- bsts(ts_pm25_wk,
               state.specification = ss2,
               niter = 1000)
plot(model2)
plot(model2, "components")

# Local trend, weekly-seasonal
ss3 <- AddSemilocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss3 <- AddSeasonal(ss3, ts_pm25_wk, nseasons = 52)
model3 <- bsts(ts_pm25_wk,
               state.specification = ss3,
               niter = 1000)
plot(model3)
plot(model3, "components")

# Local trend, weekly-seasonal, monthly-seasonal
ss4 <- AddSemilocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss4 <- AddSeasonal(ss4, ts_pm25_wk, nseasons = 52)
# Add monthly seasonal
ss4 <- AddSeasonal(ss4, ts_pm25_wk, nseasons = 13, season.duration = 4)
model4 <- bsts(ts_pm25_wk,
               state.specification = ss4,
               niter = 1000)
plot(model4)
plot(model4, "components")


CompareBstsModels(list("Model 1" = model1,
                       "Model 2" = model2,
                       "Model 3" = model3,
                       "Model 4" = model4),
                  colors = c("black", "red","blue","green"))
