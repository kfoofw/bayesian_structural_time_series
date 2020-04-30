# bayesian_structural_time_series

This repo is my personal repo for learning how to use bayesian structural time series (`bsts`) for time series analysis. Using `bsts` as a foundation, one can perform causal inference of an intervention on time series data by modelling the past and using it as a counterfactual baseline.

Links to readings will be kept on this README document for reference.

# Side Project!

1. [Causal Analysis of PM 2.5 Air Quality in Los Angeles During Quarantine using CausalImpact and BSTS](https://github.com/kfoofw/bayesian_structured_time_series/blob/master/analysis/analysis_pm25.md)

<div align="center">
    <img src= ./img/causal_impact.png width=400>
</div>

# Readings

Introductory:
- [Sorry ARIMA but I'm going Bayesian](https://multithreaded.stitchfix.com/blog/2016/04/21/forget-arima/)
- [Fitting Bayesian structural time series with the bsts R package](http://www.unofficialgoogledatascience.com/2017/07/fitting-bayesian-structural-time-series.html?m=1)
- [Structural Time-Series Models](http://oliviayu.github.io/post/2019-03-21-bsts/)
- [Spike and slab: Bayesian linear regression with variable selection](http://www.batisengul.co.uk/post/spike-and-slab-bayesian-linear-regression-with-variable-selection/)
- [Making Causal Impact Analysis Easy](https://multithreaded.stitchfix.com/blog/2016/01/13/market-watch/)

Package papers and tutorials:
- [Predicting the Present with Bayesian Structural Time Series](http://people.ischool.berkeley.edu/~hal/Papers/2013/pred-present-with-bsts.pdf)
- [INFERRING CAUSAL IMPACT USING BAYESIAN STRUCTURAL TIME-SERIES MODELS](https://storage.googleapis.com/pub-tools-public-publication-data/pdf/41854.pdf)
- [R package bsts tutorial](http://hedibert.org/wp-content/uploads/2016/05/bsts-tutorial.pdf)
- [Causal Impact using Bayesian Structural Time-Series Models](https://rstudio-pubs-static.s3.amazonaws.com/348164_d03363ac0c864fe7885343d3c58eda2a.html)
- [Software for Bayesian Structural Time Series](https://drive.google.com/file/d/14US56VzanuLt03XBkoAGzLy0gDEreZUc/view)
- [MineThatData Forecasting Challenge: proposed solution with Bayesian Structural Time Series models](http://sisifospage.tech/2017-10-30-forecasting-bsts.html)


# R packages

The following packages may be used in this learning repo:
- [bsts](https://cran.r-project.org/web/packages/bsts/index.html)
- [CausalImpact](https://github.com/google/CausalImpact)
- [MarketMatching](https://cran.r-project.org/web/packages/MarketMatching/index.html)
- [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html)
- [tidyquant](https://cran.r-project.org/web/packages/tidyquant/index.html)

# Datasets

For my analysis, I used the following data sources:
- [Los Angeles Air Quality Data](https://aqicn.org/city/losangeles/los-angeles-north-main-street/)