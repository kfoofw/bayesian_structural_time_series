
# Analysis of PM 2.5 Air Quality in Los Angeles During Quarantine using CausalImpact and BSTS

With the recent COVID-19 pandemic, the implementation of quarantine and social distancing by various governments created a ripple of effects that affect cities all around the world. The key driver behind this was the halting of economic activity which brought about a big crunch in the global economy. In the early phase of the COVID-19 crisis, the media reported that [the carbon emissions in China was reduced drastically](https://www.nytimes.com/2020/02/26/climate/nyt-climate-newsletter-coronavirus.html) in mid Feb 2020.  This gave me an idea as I wanted to try out some time series analysis on air quality in certain cities with the implementation of a quarantine. 

I was always interested in learning the Bayesian Structured Time Series (BSTS) methodology for time series analysis, and had been doing some research on the `bsts` package. Going down the rabbit hole, I found another package called `CausalImpact` that was developed on top of the `bsts` package which allows for causal analysis of time series experiments. Although relatively unknown, both packages were developed by the smart guys working at Google. If you haven't heard about them, I highly encourage you to check them out.

In this article, I will be assessing the air quality of Los Angeles city and the impact of the quarantine. The following points frame my analysis:
- The type of air quality used for this analysis is the PM2.5, which stands for atmospheric particulate matter with a diameter of less than 2.5 micrometers. 
- The implementation of the quarantine will be perceived as an "intervention". The date of this intervention will be explained in more detail.
- Los Angeles was chosen because it is such an iconic city that is bustling with activity. Not only that, it is also know for its traffic congestion which contributes to the PM 2.5 levels.
- The air quality data will be aggregated by calendar week

## Data Source 

The data for this was taken from [The World Air Quality Project](https://aqicn.org/city/losangeles/los-angeles-north-main-street/). The particular data measurement point is at North Main Street, which is pretty central in terms of Los Angeles.

<p align="center">
    <img src=../img/aqicn_la.png>
</p>

The World Air Quality Project works with the following sources:
- [South Coast Air Quality Management district (AQMD)](http://www.aqmd.gov/)
- [Air Now (US EPA)](https://www.airnow.gov/)
- [California Air Resources Board (CARB)](https://ww2.arb.ca.gov/)

As shown in the following screenshot, you get to pick the different air quality types. I chose PM2.5 primarily because the values were nominally higher compared to the others, which allows for us to capture a reduction in air quality. The heatmap below shows the daily observations of the data with "cool" colours (like blue or green) representing lower values while hot colours (like yellow or red) representing high values. In addition, we also observe greyed out boxes which represent missing data. 
<p align="center">
    <img src=../img/aqicn_heatmap.png>
</p>

## EDA and Data Analysis

At the point of this analysis, the data I downloaded was from Jan 2014 to 19th April 2020. A simple plot reveals a glaring outlier in Jan 2016 is extremely high of 800 in value which is unlikely. In addition to that, there is also a missing chunk of data leading up to the outlier.

<p align="center">
    <img src=../img/eda1.png>
</p>

Corroborating that with the heatmap chart, we observe that:
- There is missing data from the second half of November 2015 to mid Jan 2016 (shown by the red rectangle)
- The outlier data has a value of 822, and occurred in the midst of the missing data period.

Based on that, it seems that perhaps the measurement instrument might have had a prolonged failure/outage which resulted in 2 months worth of missing data. Any attempts for data imputation is highly questionable as the extended period of missing data makes it hard to determine the basis for imputation. 

<p align="center">
    <img src=../img/eda2.png>
</p>

For the purpose of the analysis, I decided to trim down the data to mid Jan 2016. At the same time, I will be aggregating the data on a weekly basis which is an intentional choice that allows me not to perform any unnecessary imputation of the missing data. 

## Intervention Timing

Based on my research of Los Angeles news search, [a public health emergency was declared in LA County over the coronavirus](https://www.dailynews.com/2020/03/04/public-health-emergency-declared-in-la-county-over-coronavirus/) on the Wednesday March 4th 2020. 

Taking that into account, the aggregation by calendar week basis produced a plot which shows a stable time series withe occasional fluctations.

<p align="center">
    <img src=../img/eda3.png>
</p>

In this analysis, the impact of the public health emergency that was declared is perceived as an intervention. With the intention to slow the spread of the virus, the government mandated several measures such as social distancing, travel bans, closure of non-essential services. This drastically reduced economic activity, which can be seen as a form. Not only are the measures a sudden change, they are implemented for a prolonged period, which makes the quarantine initiative an interesting candidate for a causal analysis.

Based on the data, we do see a sharp reduction in terms of the weekly PM2.5 data. However, we can't conclude that the reduction is statistically significant. This brings us to the next step of time series analysis using structured time series analysis.

## Structured Time Series Modelling

Using both the `CausalImpact` and `bsts` package, we can utilise the models of structured time series to create a counterfactual baseline as a projection of what would have happened if the intervention event did not occur.

We can first model the time series of the PM2.5 data using the structure time series. The model assumes the following state components: 
- Observed states Y
- Hidden state or level component μ
- Trend component δ
- Seasonal component τ

<p align="center">
    <img src="https://latex.codecogs.com/svg.latex?\large&space;y_t&space;=&space;{\mu}_{t}&space;&plus;\epsilon_t\\&space;{\mu}_{t&plus;1}&space;=&space;{\mu}_{t}&space;&plus;&space;\delta_t&space;&plus;&space;\eta_{0t}\\" title="\large y_t = {\mu}_{t} + \tau_{t}+ \epsilon_t\\ {\mu}_{t+1} = {\mu}_{t} + \delta_t + \eta_{0t}\\" />
</p>

<p align="center">
    <img src="https://latex.codecogs.com/svg.latex?\large&space;\delta_{t&plus;1}&space;=&space;\delta_t&space;&plus;&space;\eta_{1t}&space;\\&space;\tau_{t&plus;1}&space;=&space;-&space;\sum_{s=1}^{S-1}\tau_t&space;&plus;&space;\eta_{2t}" title="\large \delta_{t+1} = \delta_t + \eta_{1t} \\ \tau_{t+1} = - \sum_{s=1}^{S-1}\tau_t + \eta_{2t}" />
</p>

