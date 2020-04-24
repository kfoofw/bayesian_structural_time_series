library(bsts)
library(CausalImpact)
library(tidyverse)
library(zoo)

# Los Angeles City data: PM 2.5
dat <- read_csv("data/airquality_losangeles.csv")
dat <- dat %>%
  mutate(date = as.Date(date))

# Visual plot to see data trend
ggplot(dat, aes(x = date, y = pm25))+
  geom_point(alpha= 0.3) +
  labs(title = "LA PM2.5 data from 2014 to 2020",
       x = "Date",
       y = "PM 2.5")

# Missing data
dat %>%
  filter(is.na(pm25))

# Note erroneous data outlier where pm25 was 822. Outlier of 822 was known on 2016-01-04
dat %>%
  filter(pm25 > 500)

# Convert data to aggregation by week
dat_pm25_wk <- dat %>% 
  filter(date > as.Date("2016-01-12")) %>%
  group_by(week = cut(date, "week")) %>%
  summarise(pm25 = mean(pm25, na.rm = TRUE)) %>%
  mutate(week = as.Date(as.character(week)))

# Create row index
dat_pm25_wk <- dat_pm25_wk %>%
  mutate(index = row_number())

# Visual plot to see data trend
ggplot(dat_pm25_wk, aes(x = week, y = pm25))+
  geom_vline(xintercept = as.Date("2020-03-04"), color = "blue", lty = "dashed") +
  geom_point(color = "red") + 
  geom_line(alpha = 0.4) + 
  labs(title = "LA PM2.5 data from mid Jan 2016 to April 2020",
       subtitle = "Public Health Emergency declared on 4th March 2020 (dotted blue line)",
       x = "Date",
       y = "PM 2.5")

# Post Intervention Period is filled with NA
dat_pm25_wk_causal <- dat_pm25_wk %>% 
  mutate(pm25 = replace(pm25, week >= as.Date("2020-03-04"), NA))

# Create ts zoo data
ts_pm25_wk <- zoo(dat_pm25_wk_causal$pm25, dat_pm25_wk_causal$week)

plot(ts_pm25_wk)

# Local trend, weekly-seasonal
ss <- AddLocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss <- AddSeasonal(ss, ts_pm25_wk, nseasons = 52)
model1 <- bsts(ts_pm25_wk,
               state.specification = ss,
               niter = 1000)
plot(model1, main = "Model 1", ylim = c(20,100))
plot(model1, "components", ylim = c(-20, 80))

# Local trend, weekly-seasonal, monthly-seasonal
ss2 <- AddLocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss2 <- AddSeasonal(ss2, ts_pm25_wk, nseasons = 52)
# Add monthly seasonal
ss2 <- AddSeasonal(ss2, ts_pm25_wk, nseasons = 13, season.duration = 4)
model2 <- bsts(ts_pm25_wk,
               state.specification = ss2,
               niter = 1000)
plot(model2, main = "Model 2", ylim = c(20,100))
plot(model2, "components", ylim = c(-20,80))

# Semi Local trend, weekly-seasonal
ss3 <- AddSemilocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss3 <- AddSeasonal(ss3, ts_pm25_wk, nseasons = 52)
model3 <- bsts(ts_pm25_wk,
               state.specification = ss3,
               niter = 1000)
plot(model3, main = "Model 3", ylim = c(20,100))
plot(model3, "components", ylim = c(-20,80))

# Semi Local trend, weekly-seasonal, monthly-seasonal
ss4 <- AddSemilocalLinearTrend(list(), ts_pm25_wk)
# Add weekly seasonal
ss4 <- AddSeasonal(ss4, ts_pm25_wk, nseasons = 52)
# Add monthly seasonal
ss4 <- AddSeasonal(ss4, ts_pm25_wk, nseasons = 13, season.duration = 4)
model4 <- bsts(ts_pm25_wk,
               state.specification = ss4,
               niter = 1000)
plot(model4, main = "Model 4", ylim = c(20,100))
plot(model4, "components", ylim = c(-20,80))


# Compare models
CompareBstsModels(list("Model 1" = model1,
                       "Model 2" = model2,
                       "Model 3" = model3,
                       "Model 4" = model4),
                  colors = c("black", "red","blue","green"))

##### 
# Causal impact of social distancing and Covid-19 
pre.period <- as.Date(c("2016-01-11", "2020-03-04"))
post.period <- as.Date(c("2020-03-04", "2020-04-16"))

# Obtain post period data
dat_pm25_wk_causal_post <- dat_pm25_wk %>% 
  filter(week >= as.Date("2020-03-04"))

# Use model 3 for causal impact
impact <- CausalImpact(bsts.model = model3,
                       post.period.response = dat_pm25_wk_causal_post$pm25, alpha = 0.05)
plot(impact)

summary(impact)

summary(impact, "report")
