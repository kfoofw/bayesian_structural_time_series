library(bsts)
library(CausalImpact)
library(tidyverse)
library(zoo)


dat <- read_csv("data/airquality_northvan.csv")

ts <- zoo(dat$pm25, dat$date)

dat$date <- as.Date(dat$date)

plot(dat$date, dat$pm25)

ggplot(dat, aes(x = date, y = pm25))+
  geom_point()

# trend, seasonal, regression
ss <- AddLocalLinearTrend(list(), initial.claims$iclaimsNSA)
ss <- AddSeasonal(ss, initial.claims$iclaimsNSA, nseasons = 52)
model1 <- bsts(initial.claims$iclaimsNSA,
               state.specification = ss,
               niter = 1000)
model1
