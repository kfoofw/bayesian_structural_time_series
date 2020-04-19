library(bsts)
library(CausalImpact)
library(tidyverse)
library(zoo)

# Los Angeles City data: PM 2.5
dat <- read_csv("data/airquality_losangeles.csv")

dat_pm25_wk <- dat %>% 
  mutate(date = as.Date(date)) %>%
  group_by(week = cut(date, "week")) %>%
  summarise(pm25 = mean(pm25, na.rm = TRUE)) %>%
  mutate(week = as.Date(as.character(week)))

# Create row index
dat_pm25_wk <- dat_pm25_wk %>%
  mutate(index = row_number())

# Visual plot to see data trend
ggplot(dat_pm25_wk, aes(x = week, y = pm25))+
  geom_point()

# Missing Data for Nov to Dec 2015
dat_pm25_wk %>%
  filter(is.na(pm25))

# Note erroneous data outlier where pm25 was 822
dat_pm25_wk %>%
  filter(pm25 > 500)

# Filter data to exclude time period before mid Jan 2016.
dat_pm25_wk_trunc <- dat_pm25_wk %>%
  filter(week > as.Date("2016-01-04"))

# Visual plot to see data trend
ggplot(dat_pm25_wk_trunc, aes(x = week, y = pm25))+
  geom_point() + 
  geom_line()

# Create ts zoo data
ts_pm25_wk <- zoo(dat_pm25_wk_trunc$pm25, dat_pm25_wk_trunc$week)

plot(ts_pm25_wk)

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

##### 
# Causal impact of social distancing
library(CausalImpact)

pre.period <- as.Date(c("2016-01-11", "2020-03-10"))
post.period <- as.Date(c("2020-03-11", "2020-04-16"))

# Create bsts model based on pre-period data while imputing NA points on post period
# Choose model 3
dat_pm25_wk_trunc_causal <- dat_pm25_wk_trunc %>% 
  mutate(pm25 = replace(pm25, week >= as.Date("2020-03-01"), NA))

# Obtain post period data
dat_pm25_wk_trunc_post <- dat_pm25_wk_trunc %>% 
  filter(week >= as.Date("2020-03-01"))

# Create zoo object based on index data
ts_pm25_wk_pre <- zoo(dat_pm25_wk_trunc_causal$pm25, dat_pm25_wk_trunc_causal$week)

# Local trend, weekly-seasonal
ss3_causal <- AddSemilocalLinearTrend(list(), ts_pm25_wk_pre)
# Add weekly seasonal
ss3_causal <- AddSeasonal(ss3_causal, ts_pm25_wk_pre, nseasons = 52)
causal_model3 <- bsts(ts_pm25_wk_pre,
                      state.specification = ss3_causal,
                      niter = 1000)
plot(causal_model3)
plot(causal_model3, "components")


impact <- CausalImpact(bsts.model = causal_model3,
                       post.period.response = dat_pm25_wk_trunc_post$pm25)
plot(impact)


