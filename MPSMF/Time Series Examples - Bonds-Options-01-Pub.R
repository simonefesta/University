#### References ##############################################################################################################
##############################################################################################################################
#
# Rob J Hyndman and George Athanasopoulos - Forecasting: Principles and Practice
# Monash Univerisity, Australia
# https://otexts.com/fpp2/
#
# Robert H. Shumway, David S. Stoffer - Time Series Analysis and Its Applications (with R Examples) 4th Edition
# Springer Texts in Statistics - Springer Verlag
# https://www.stat.pitt.edu/stoffer/tsa4/tsa4.pdf
#
# R - Residual Diagnostic
# https://cran.r-project.org/web/packages/olsrr/vignettes/residual_diagnostics.html
##############################################################################################################################

# Sys.getenv('PATH')
##############################################################################################################################
# Reading libraries
# library(readxl)
library(dplyr)
library(tidyverse)
library("data.table")
library(reshape2)
library(tibble)
library(ggplot2)
library(scales)
library(lubridate)
library(xts)
library(zoo)
library(TTR)
library(quantmod)



library(moments)
library(lmtest) 

library(strucchange)
library(broom)
library(tibble)
library(rlang)
library(gridSVG)
library(grid)
#####################################################################################################################

# Remove all items in Global Environment
rm(list=ls())

# Clear all Plots
# try(dev.off(dev.list()["RStudioGD"]),silent=TRUE)
try(dev.off(),silent=TRUE)

# Clear the Console
cat(rep("\n",100))

# Set the working directory
WD <- dirname(rstudioapi::getSourceEditorContext()$path)
show(WD)
setwd(WD)
dir()
#####################################################################################################################
#### Functions
na.rm <- function(x){x <- as.vector(x[!is.na(as.vector(x))])}

########################### Create a data frame of data from US Department of Treasury ##############################
# From the website "https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics", 
# we download the "Daily Treasure Par Yield Curve Rates" selecting the years from 2020 to 2023 as the "time period". 
# We obtain the files "daily-treasury-rates-2020.csv", ..., "daily-treasury-rates-2023.csv".
# We build data frames with data from the files "daily-treasury-rates-2020.csv", ..., "daily-treasury-rates-2023.csv".
US_DTR_2020_df <- read.csv("daily-treasury-rates-2020.csv")
class(US_DTR_2020_df)
head(US_DTR_2020_df,15)
tail(US_DTR_2020_df,15)
US_DTR_2021_df <- read.csv("daily-treasury-rates-2021.csv")
class(US_DTR_2021_df)
head(US_DTR_2021_df,15)
tail(US_DTR_2021_df,15)
US_DTR_2022_df <- read.csv("daily-treasury-rates-2022.csv")
class(US_DTR_2022_df)
head(US_DTR_2022_df,15)
tail(US_DTR_2022_df,15)
US_DTR_2023_df <- read.csv("daily-treasury-rates-2023.csv")
class(US_DTR_2023_df)
head(US_DTR_2023_df,15)
tail(US_DTR_2023_df,15)
# Note that in the above data frames the temporal order of data decreases from the most recent to the least recent.
# However, for our purposes, it is more convenient to dispose of data in increasing temporal order (from the least 
# recent to the most recent). Therefore, we invert the temporal order order of data in the data frames.
US_DTR_2020_df <- US_DTR_2020_df[nrow(US_DTR_2020_df):1,]
head(US_DTR_2020_df,15)
tail(US_DTR_2020_df,15)
US_DTR_2021_df <- US_DTR_2021_df[nrow(US_DTR_2021_df):1,]
head(US_DTR_2021_df,15)
tail(US_DTR_2021_df,15)
US_DTR_2022_df <- US_DTR_2022_df[nrow(US_DTR_2022_df):1,]
head(US_DTR_2022_df,15)
tail(US_DTR_2022_df,15)
US_DTR_2023_df <- US_DTR_2023_df[nrow(US_DTR_2023_df):1,]
head(US_DTR_2023_df,15)
tail(US_DTR_2023_df,15)
# Note also that from the year 2022, the "four months daily treasury rate" is reported in the column *X4.Mo*.
# More precisely, the "four months daily treasury rate" is reported from the day
US_DTR_2022_df$Date[min(which(!is.na(US_DTR_2022_df$X4.Mo)))]
# as it appears by observing the data frame *US_DTR_2022_df* in the vicinity of the above determined day.
show(US_DTR_2022_df[(min(which(!is.na(US_DTR_2022_df$X4.Mo)))-5):(min(which(!is.na(US_DTR_2022_df$X4.Mo)))+5),])
# Therefore, with the goal of merging the different data frames in a single one, we add a *X4.Mo* column to the data 
# frames *US_DTR_2020_df* and *US_DTR_2021_df*.
# library(tibble)
US_DTR_2020_df <- add_column(US_DTR_2020_df, X4.Mo=rep(NA, nrow(US_DTR_2020_df)), .after="X3.Mo")
head(US_DTR_2020_df)
tail(US_DTR_2020_df)
US_DTR_2021_df <- add_column(US_DTR_2021_df, X4.Mo=rep(NA, nrow(US_DTR_2021_df)), .after="X3.Mo")
head(US_DTR_2021_df)
tail(US_DTR_2021_df)
# Hence, we merge the data frames *US_DTR_2020_df*, ..., *US_DTR_2023_df* in a single data frame.
# library(dplyr)
US_DTR_2020_2023_df <- bind_rows(US_DTR_2020_df,US_DTR_2021_df,US_DTR_2022_df,US_DTR_2023_df)
head(US_DTR_2020_2023_df)
tail(US_DTR_2020_2023_df)
# 
# We check whether the Date column is in "Date" format. In case it is not, we change the format to "Date".
class(US_DTR_2020_2023_df$Date)
US_DTR_2020_2023_df$Date <- as.Date(US_DTR_2020_2023_df$Date, format="%m/%d/%Y")
class(US_DTR_2020_2023_df$Date)
head(US_DTR_2020_2023_df,15)
tail(US_DTR_2020_2023_df,15)
# In the end, although unnecessary, we rename the columns in a more friendly way.
# library(tidyverse)
US_DTR_2020_2023_df <- rename(US_DTR_2020_2023_df, Mo01=X1.Mo, Mo02=X2.Mo, Mo03=X3.Mo, Mo04=X4.Mo,
                              Mo06=X6.Mo, Yr01=X1.Yr, Yr02=X2.Yr, Yr03=X3.Yr, Yr05=X5.Yr, Yr07=X7.Yr,
                              Yr10=X10.Yr, Yr20=X20.Yr, Yr30=X30.Yr)
head(US_DTR_2021_2022_df)
tail(US_DTR_2021_2022_df)
######################################################################################################################
######################################################################################################################
# To draw a plot of the Treasury Yield Curve Rates, we need to manipulate the data frame *US_DTR_2020_2023_df*.
# First, we extract some rows (e.g., from March 27th to April 7th 2023) from the data frame and delete the Date column.
init_date  <- which(US_DTR_2020_2023_df$Date=="2023-03-27")
final_date <- which(US_DTR_2020_2023_df$Date=="2023-04-07")
sel_rows <- seq.int(from=init_date, to=final_date, by=1)
sel_US_DTR_2020_2023_df <- US_DTR_2020_2023_df[sel_rows,]
show(sel_US_DTR_2020_2023_df)
rownames(sel_US_DTR_2020_2023_df) <- seq(from=1, to=nrow(sel_US_DTR_2020_2023_df))
sel_US_DTR_2020_2023_df$Date <- NULL
show(sel_US_DTR_2020_2023_df)
#
# Second, we change the data frame in a table
# library("data.table")
sel_US_DTR_2020_2023_tb <- setDT(sel_US_DTR_2020_2023_df)   
class(sel_US_DTR_2020_2023_tb)
show(sel_US_DTR_2020_2023_tb)
#
# Third, by the command *melt* we reshape the wide data frame to a long data frame
# library(reshape2)
rsh_sel_US_DTR_2020_2023_tb <- melt(sel_US_DTR_2020_2023_tb)
show(rsh_sel_US_DTR_2020_2023_tb[1:20,])
show(rsh_sel_US_DTR_2020_2023_tb[(nrow(rsh_sel_US_DTR_2020_2023_tb)-20):nrow(rsh_sel_US_DTR_2020_2023_tb),])
#
# In the end, we add an Index identifying variable and a Data column to the data frame rsh_sel_US_DTR_2020_2023_tb
# library(tibble)
rsh_sel_US_DTR_2020_2023_tb <- add_column(rsh_sel_US_DTR_2020_2023_tb, 
                                        Index=rep(1:nrow(sel_US_DTR_2020_2023_df), times=ncol(sel_US_DTR_2020_2023_df)),
                                        Date=rep(US_DTR_2021_2022_df$Date[sel_rows], times=ncol(sel_US_DTR_2020_2023_df)),
                                        .before="variable")
show(rsh_sel_US_DTR_2020_2023_tb[1:20,])
show(rsh_sel_US_DTR_2020_2023_tb[(ncol(sel_US_DTR_2020_2023_df)*nrow(sel_US_DTR_2020_2023_df)-20):
                                   (ncol(sel_US_DTR_2020_2023_df)*nrow(sel_US_DTR_2020_2023_df)),])
#
# Finally, We are in a position to draw a draft plot of the Daily Treasury Yield Curve Rates
# library(ggplot2)
Data_df <- rsh_sel_US_DTR_2020_2023_tb
length <- ncol(sel_US_DTR_2020_2023_df)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plots of U.S. Treasury Yield Curve Rates (business days from ", .(First_Day), " to ", .(Last_Day),")")))
link <- "https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics"
subtitle_content <- bquote(paste("path length ", .(length), " sample points. Data by courtesy of  U.S. Department of the Treasure  -  ", .(link)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("expiration dates")
leg_labs <- as.character(US_DTR_2021_2022_df$Date[sel_rows])
# leg_vals <- levels(factor(Data_df$Index))
leg_vals <- rainbow(length(levels(factor(Data_df$Index))))[as.numeric(levels(factor(Data_df$Index)))]
US_DTR_03_27_04_07_2023_Curve_Rate_lp <- ggplot(Data_df, aes(x=variable, y=value, group=factor(Index))) + 
  geom_line(aes(color=factor(Index)), linewidth=0.8, linetype="solid") +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time to maturity") + ylab("yield rates") +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="right")
plot(US_DTR_03_27_04_07_2023_Curve_Rate_lp)
#####################################################################################################################
# We compare the Treasury Yield Curve Rates that we have obtained with the one at the beginning of 2021. 
# As before, we need to manipulate the data from January 3rd to January 20th 2021) from the data frame and delete the Date column.
init_date  <- which(US_DTR_2020_2023_df$Date=="2021-01-04")
final_date <- which(US_DTR_2020_2023_df$Date=="2021-01-15")
sel_rows <- seq.int(from=init_date, to=final_date, by=1)
sel_US_DTR_2020_2023_df <- US_DTR_2020_2023_df[sel_rows,]
show(sel_US_DTR_2020_2023_df)
rownames(sel_US_DTR_2020_2023_df) <- seq(from=1, to=nrow(sel_US_DTR_2020_2023_df))
sel_US_DTR_2020_2023_df$Date <- NULL
show(sel_US_DTR_2020_2023_df)
#
# Second, we change the data frame in a table
# library("data.table")
sel_US_DTR_2020_2023_tb <- setDT(sel_US_DTR_2020_2023_df)   
class(sel_US_DTR_2020_2023_tb)
show(sel_US_DTR_2020_2023_tb)
#
# Third, by the command *melt* we reshape the wide data frame to a long data frame
# library(reshape2)
rsh_sel_US_DTR_2020_2023_tb <- melt(sel_US_DTR_2020_2023_tb)
show(rsh_sel_US_DTR_2020_2023_tb[1:20,])
show(rsh_sel_US_DTR_2020_2023_tb[(nrow(rsh_sel_US_DTR_2020_2023_tb)-20):nrow(rsh_sel_US_DTR_2020_2023_tb),])
#
# In the end, we add an Index identifying variable and a Data column to the data frame rsh_sel_US_DTR_2020_2023_tb
# library(tibble)
rsh_sel_US_DTR_2020_2023_tb <- add_column(rsh_sel_US_DTR_2020_2023_tb, 
                                          Index=rep(1:nrow(sel_US_DTR_2020_2023_df), times=ncol(sel_US_DTR_2020_2023_df)),
                                          Date=rep(US_DTR_2021_2022_df$Date[sel_rows], times=ncol(sel_US_DTR_2020_2023_df)),
                                          .before="variable")
show(rsh_sel_US_DTR_2020_2023_tb[1:20,])
show(rsh_sel_US_DTR_2020_2023_tb[(ncol(sel_US_DTR_2020_2023_df)*nrow(sel_US_DTR_2020_2023_df)-20):
                                   (ncol(sel_US_DTR_2020_2023_df)*nrow(sel_US_DTR_2020_2023_df)),])
#
# Finally, We are in a position to draw a draft plot of the Daily Treasury Yield Curve Rates
# library(ggplot2)
Data_df <- rsh_sel_US_DTR_2020_2023_tb
length <- ncol(sel_US_DTR_2020_2023_df)
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plots of U.S. Treasury Yield Curve Rates (business days from ", .(First_Day), " to ", .(Last_Day),")")))
link <- "https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics"
subtitle_content <- bquote(paste("path length ", .(length), " sample points. Data by courtesy of  U.S. Department of the Treasure  -  ", .(link)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("expiration dates")
leg_labs <- as.character(US_DTR_2021_2022_df$Date[sel_rows])
# leg_vals <- levels(factor(Data_df$Index))
leg_vals <- rainbow(length(levels(factor(Data_df$Index))))[as.numeric(levels(factor(Data_df$Index)))]
US_DTR_01_04_01_15_2021_Curve_Rate_lp <- ggplot(Data_df, aes(x=variable, y=value, group=factor(Index))) + 
  geom_line(aes(color=factor(Index)), linewidth=0.8, linetype="solid") +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time to maturity") + ylab("yield rates") +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="right")
plot(US_DTR_01_04_01_15_2021_Curve_Rate_lp)
#####################################################################################################################
# Now, we try to compute the Treasury Yield Rates from the prices of Market Based Bills
# https://www.treasurydirect.gov/GA-FI/FedInvest/selectSecurityPriceDate
# We build a data frame with data from the "securityprice-2023-01-03.csv" file.
US_SP_2023_01_03_df <- read.csv("securityprice-2023-01-03.csv", header=FALSE)
show(US_SP_2023_01_03_df[1:15,])
# We rename the columns according to the terminology in https://www.treasurydirect.gov/GA-FI/FedInvest/selectSecurityPriceDate.
US_SP_2023_01_03_df <- rename(US_SP_2023_01_03_df, CUSIP=V1, Security.Type=V2, Rate=V3, Maturity.Date=V4,
                              Call.Date=V5, Buy=V6, Sell=V7, End.of.Day=V8)
head(US_SP_2023_01_03_df)
# We check whether the Maturity.Date column is in "Date" format. In case it is not, we change the format to "Date".
class(US_SP_2023_01_03_df$Maturity.Date)
US_SP_2023_01_03_df$Maturity.Date <- as.Date(US_SP_2023_01_03_df$Maturity.Date,  format="%m/%d/%Y")
show(US_SP_2023_01_03_df[1:15,])
# We add a column *Days.to.Maturity*, which accounts for the number of days from January 1st, 2023, to the Maturity Date
US_SP_2023_01_03_df <- add_column(US_SP_2023_01_03_df, 
                                  Days.to.Maturity=as.vector(difftime(US_SP_2023_01_03_df$Maturity.Date, as.Date(as.character("2023-01-03")), units="days")), 
                                  .after="Maturity.Date")
show(US_SP_2023_01_03_df[1:15,])
# We also add the column *Months.to.Maturity* [resp. *Years.to.Maturity*], which accounts for the number of months 
# [resp. years] from January 1st, 2023, to the Maturity Date.
US_SP_2023_01_03_df <- add_column(US_SP_2023_01_03_df, 
                                  Months.to.Maturity=as.vector(US_SP_2023_01_03_df$Days.to.Maturity/30.4369),
                                  Years.to.Maturity=as.vector(US_SP_2023_01_03_df$Days.to.Maturity/365.2425),
                                  .after="Days.to.Maturity")
show(US_SP_2023_01_03_df[1:15,])
# We add a column *Rate.of.Return.at.Maturity* and *Perc.Rate.of.Return.at.Maturity*
US_SP_2023_01_03_df <- add_column(US_SP_2023_01_03_df, 
                                  Rate.of.Ret.at.Maturity=(100-US_SP_2023_01_03_df$End.of.Day)/US_SP_2023_01_03_df$End.of.Day,
                                  Perc.Rate.of.Ret.at.Maturity=100*(100-US_SP_2023_01_03_df$End.of.Day)/US_SP_2023_01_03_df$End.of.Day,
                                  .after="End.of.Day")
show(US_SP_2023_01_03_df[1:15,])
#
# We compute the annual rate of return according to the formulas
# (1+r_a)^t=1+r_t; r_a=(1+r_t)^(1/t)-1
# where r_a=annual rate of return, t=time to maturity (in years), r_t=rate of return in the period t.
# or 
# (1+r_a)^(t/365.2425)=1+r_t; r_a=(1+r_t)^(365.2425/t)-1
# where r_a=annual rate of return, t=time to maturity (in days), r_t=rate of return in the period t.
#
Annual.Rate.of.Ret_01 <- (1+US_SP_2023_01_03_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_01_03_df$Years.to.Maturity)-1
show(Annual.Rate.of.Ret_01)
Annual.Rate.of.Ret_02 <- (1+US_SP_2023_01_03_df$Rate.of.Ret.at.Maturity)^(365.2425/US_SP_2023_01_03_df$Days.to.Maturity)-1
show(Annual.Rate.of.Ret_02)
Annual.Rate.of.Ret_01==Annual.Rate.of.Ret_02
# We add a column *Ann.Rate.of.Return* and *Perc.Ann.Rate.of.Return*
US_SP_2023_01_03_df <- add_column(US_SP_2023_01_03_df, 
                                  Ann.Rate.of.Ret=(1+US_SP_2023_01_03_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_01_03_df$Years.to.Maturity)-1,
                                  Perc.Ann.Rate.of.Ret=label_percent(accuracy = 0.01)((1+US_SP_2023_01_03_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_01_03_df$Years.to.Maturity)-1),
                                  .after="End.of.Day")
show(US_SP_2023_01_03_df[1:15,])
#####################################################################################################################
# European Options on Standard & Poor 500 (Yahoo Finance - ^SPX)
# library(quantmod)
SPX_Opt_2023_06_16 <- getOptionChain("^SPX", Exp="2023-06-16", src='yahoo')
class(SPX_Opt_2023_06_16)
length(SPX_Opt_2023_06_16)
show(SPX_Opt_2023_06_16[[1]])
class(SPX_Opt_2023_06_16[[1]])
nrow(SPX_Opt_2023_06_16[[1]])
show(SPX_Opt_2023_06_16[[2]])
class(SPX_Opt_2023_06_16[[2]])
nrow(SPX_Opt_2023_06_16[[2]])
show(SPX_Opt_2023_06_16[[1]]$Strike)
show(SPX_Opt_2023_06_16[[2]]$Strike)
Strike <- sort(union(SPX_Opt_2023_06_16[[1]]$Strike, SPX_Opt_2023_06_16[[2]]$Strike))
show(Strike)
length(Strike)
Call_Indx <- sapply(Strike, function(x) which(SPX_Opt_2023_06_16[[1]]$Strike==x)[1])
Put_Indx <- sapply(Strike, function(x) which(SPX_Opt_2023_06_16[[2]]$Strike==x)[1])

SPX_Opt_2023_06_16_df <- data.frame(Indx=1:length(Strike),
                                    Call_ContractID=SPX_Opt_2023_06_16[[1]]$ContractID[Call_Indx], 
                                    Call_Bid=SPX_Opt_2023_06_16[[1]]$Bid[Call_Indx],
                                    Call_Ask=SPX_Opt_2023_06_16[[1]]$Ask[Call_Indx],
                                    Call_Vol=SPX_Opt_2023_06_16[[1]]$Vol[Call_Indx],
                                    Call_OI=SPX_Opt_2023_06_16[[1]]$OI[Call_Indx],
                                    Call_PrChg=SPX_Opt_2023_06_16[[1]]$Chg[Call_Indx],
                                    Call_PrChgPct=SPX_Opt_2023_06_16[[1]]$ChgPct[Call_Indx],
                                    Call_LastTrTime=SPX_Opt_2023_06_16[[1]]$LastTradeTime[Call_Indx],
                                    Call_LastPr=SPX_Opt_2023_06_16[[1]]$Last[Call_Indx],
                                    Call_ImplVol=SPX_Opt_2023_06_16[[1]]$IV[Call_Indx],
                                    Call_ITM=SPX_Opt_2023_06_16[[1]]$ITM[Call_Indx],
                                    Strike=Strike,
                                    Put_ITM=SPX_Opt_2023_06_16[[2]]$ITM[Put_Indx],
                                    Put_ImplVol=SPX_Opt_2023_06_16[[2]]$IV[Put_Indx],
                                    Put_LastPr=SPX_Opt_2023_06_16[[2]]$Last[Put_Indx],
                                    Put_LastTrTime=SPX_Opt_2023_06_16[[2]]$LastTradeTime[Put_Indx],
                                    Put_PrChgPct=SPX_Opt_2023_06_16[[2]]$ChgPct[Put_Indx],
                                    Put_PrChg=SPX_Opt_2023_06_16[[2]]$Chg[Put_Indx],
                                    Put_OI=SPX_Opt_2023_06_16[[2]]$OI[Put_Indx],
                                    Put_Vol=SPX_Opt_2023_06_16[[2]]$Vol[Put_Indx],
                                    Put_Ask=SPX_Opt_2023_06_16[[2]]$Ask[Put_Indx],
                                    Put_Bid=SPX_Opt_2023_06_16[[2]]$Bid[Put_Indx],
                                    Put_ContractID=SPX_Opt_2023_06_16[[2]]$ContractID[Put_Indx])
head(SPX_Opt_2023_06_16_df,10)                                   
tail(SPX_Opt_2023_06_16_df,10)
write.csv(SPX_Opt_2023_06_16_df,"C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Data/SPX_Option_Chain_2023_06_16.csv")
dir("C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Data")
write.csv(SPX_Opt_2023_06_16_df,"C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Scripts/SPX_Option_Chain_2023_06_16.csv")
dir("C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Scripts")
#
Call_LastTrTime_df <- data.frame(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrTime))
class(Call_LastTrTime_df)
head(Call_LastTrTime_df,20)
nrow(Call_LastTrTime_df)
Call_LastTrTime_tb <- table(Call_LastTrTime_df)   
class(Call_LastTrTime_tb)
show(Call_LastTrTime_tb)
#
Put_LastTrTime_df <- data.frame(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrTime))
class(Put_LastTrTime_df)
head(Put_LastTrTime_df,20)
nrow(Put_LastTrTime_df)
Put_LastTrTime_tb <- table(Put_LastTrTime_df)   
class(Put_LastTrTime_tb)
show(Put_LastTrTime_tb)
#
Call_LastTrTime_2023_04_10_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrTime)=="2023-04-10")]
show(Call_LastTrTime_2023_04_10_Indx)
Put_LastTrTime_2023_04_10_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrTime)=="2023-04-10")]
show(Put_LastTrTime_2023_04_10_Indx)
Call_Put_2023_04_10_Indx <- intersect(Call_LastTrTime_2023_04_10_Indx, Put_LastTrTime_2023_04_10_Indx)
show(Call_Put_2023_04_10_Indx)
length(Call_Put_2023_04_10_Indx)
#
Call_LastTrTime_2023_04_06_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrTime)=="2023-04-06")]
show(Call_LastTrTime_2023_04_06_Indx)
Put_LastTrTime_2023_04_06_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrTime)=="2023-04-06")]
show(Put_LastTrTime_2023_04_06_Indx)
Call_Put_2023_04_06_Indx <- intersect(Call_LastTrTime_2023_04_06_Indx, Put_LastTrTime_2023_04_06_Indx)
show(Call_Put_2023_04_06_Indx)
length(Call_Put_2023_04_06_Indx)
#
Call_LastTrTime_2023_04_05_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrTime)=="2023-04-05")]
show(Call_LastTrTime_2023_04_05_Indx)
Put_LastTrTime_2023_04_05_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrTime)=="2023-04-05")]
show(Put_LastTrTime_2023_04_05_Indx)
Call_Put_2023_04_05_Indx <- intersect(Call_LastTrTime_2023_04_05_Indx, Put_LastTrTime_2023_04_05_Indx)
show(Call_Put_2023_04_05_Indx)
length(Call_Put_2023_04_05_Indx)
#
Call_LastTrTime_2023_04_04_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrTime)=="2023-04-04")]
show(Call_LastTrTime_2023_04_04_Indx)
Put_LastTrTime_2023_04_04_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrTime)=="2023-04-04")]
show(Put_LastTrTime_2023_04_04_Indx)
Call_Put_2023_04_04_Indx <- intersect(Call_LastTrTime_2023_04_04_Indx, Put_LastTrTime_2023_04_04_Indx)
show(Call_Put_2023_04_04_Indx)
length(Call_Put_2023_04_04_Indx)
#
# Put-Call parity
# P_0 = C_0 - S_0 + K/(1+r_f)
# C_0-P_0 = S_0 - K/(1+r_f)
#
x <- SPX_Opt_2023_06_16_df$Strike[Call_Put_2023_04_10_Indx]
show(x)
length(x)
y <- SPX_Opt_2023_06_16_df$Call_LastPr[Call_Put_2023_04_10_Indx]-SPX_Opt_2023_06_16_df$Put_LastPr[Call_Put_2023_04_10_Indx]
show(y)
length(y)
#
Data_df <- data.frame(x,y)
n <- nrow(Data_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plot of the Call-Put Difference Against the Strike Price")))
subtitle_content <- bquote(paste("Data set size",~~.(n),~~"sample points;    Evaluation Date 2023-04-10;   Maturity Date 2023-06-16"))
caption_content <- "Author: Roberto Monte" 
# To obtain the submultiples of the length of the data set as a hint on the number of breaks to use
# library(numbers)
# primeFactors(n)
x_breaks_num <- 13
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[n]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- format(x_breaks, scientific=FALSE)
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth,x_breaks_up+J*x_binwidth)
x_name <- bquote("strike")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- y_min
y_breaks_up <- y_max
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth)
if((y_breaks_up-max(y_breaks))>y_binwidth/2){y_breaks <- c(y_breaks,y_breaks_up)}
y_labs <- format(y_breaks, scientific=FALSE)
y_name <- bquote("call-put difference")
K <- 1
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("data set sample points")
col_2 <- bquote("regression line")
col_3 <- bquote("LOESS curve")
leg_labs <- c(col_1, col_2, col_3)
leg_cols <- c("col_1"="blue", "col_2"="green", "col_3"="red")
leg_ord <- c("col_1", "col_2", "col_3")
Call_Put_Strike_Pr_sp <- ggplot(Data_df, aes(x=x, y=y)) +
  geom_smooth(alpha=1, linewidth=0.8, linetype="dashed", aes(color="col_3"),
              method="loess", formula=y ~ x, se=FALSE) +
  geom_smooth(alpha=1, linewidth=0.8, linetype="solid", aes(color="col_2"),
              method="lm" , formula=y ~ x, se=FALSE, fullrange=TRUE) +
  geom_point(alpha=1, size=1.0, shape=19, aes(color="col_1")) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_ord,
                      guide=guide_legend(override.aes=list(shape=c(19,NA,NA), 
                                                           linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(1.0,"cm"), legend.position="bottom")
plot(Call_Put_Strike_Pr_sp)
#
PutCall_par_lm <- lm(y~x)
summary(PutCall_par_lm)
#
S_0 <- PutCall_par_lm$coefficients[1]
show(S_0)
# 4080.022
# SPX Market Price 4,109.11 +4.09 (+0.10%) At close: April 10 04:57PM EDT
#
r_f <- -(1/PutCall_par_lm$coefficients[2]+1)
show(r_f)
# 0.01008137
r_f_a=(1+r_f)^(365.2425/32)-1
show(r_f_a)
# 0.1213024
#
# Put-Call parity
# P_0 = C_0 - S_0 + K/(1+r_f)
# C_0-P_0-S_0 = - K/(1+r_f)
#
x <- SPX_Opt_2023_06_16_df$Strike[Call_Put_2023_04_10_Indx]
show(x)
length(x)
y <- SPX_Opt_2023_06_16_df$Call_LastPr[Call_Put_2023_04_10_Indx]-SPX_Opt_2023_06_16_df$Put_LastPr[Call_Put_2023_04_10_Indx]-4109.11
show(y)
length(y)
#
Data_df <- data.frame(x,y)
n <- nrow(Data_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plot of the Call-Put Difference Adjusted by the Stock Price Against the Strike Price")))
subtitle_content <- bquote(paste("Data set size",~~.(n),~~"sample points;    Evaluation Date 2023-04-10;   Maturity Date 2023-06-16"))
caption_content <- "Author: Roberto Monte" 
# To obtain the sub-multiples of the length of the data set as a hint on the number of breaks to use
# library(numbers)
# primeFactors(n)
x_breaks_num <- 13
x_breaks_low <- Data_df$x[1]
x_breaks_up <- Data_df$x[n]
x_binwidth <- floor((x_breaks_up-x_breaks_low)/x_breaks_num)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=x_binwidth)
if((x_breaks_up-max(x_breaks))>x_binwidth/2){x_breaks <- c(x_breaks,x_breaks_up)}
x_labs <- format(x_breaks, scientific=FALSE)
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth,x_breaks_up+J*x_binwidth)
x_name <- bquote("strike")
y_breaks_num <- 10
y_max <- max(na.rm(Data_df$y))
y_min <- min(na.rm(Data_df$y))
y_binwidth <- round((y_max-y_min)/y_breaks_num, digits=3)
y_breaks_low <- y_min
y_breaks_up <- y_max
y_breaks <- seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth)
if((y_breaks_up-max(y_breaks))>y_binwidth/2){y_breaks <- c(y_breaks,y_breaks_up)}
y_labs <- format(y_breaks, scientific=FALSE)
y_name <- bquote("call-put difference")
K <- 1
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("data set sample points")
col_2 <- bquote("regression line")
col_3 <- bquote("LOESS curve")
leg_labs <- c(col_1, col_2, col_3)
leg_cols <- c("col_1"="blue", "col_2"="green", "col_3"="red")
leg_ord <- c("col_1", "col_2", "col_3")
Call_Put_Stock_Pr_Strike_Pr_sp <- ggplot(Data_df, aes(x=x, y=y)) +
  geom_smooth(alpha=1, linewidth=0.8, linetype="dashed", aes(color="col_3"),
              method="loess", formula=y ~ x, se=FALSE) +
  geom_smooth(alpha=1, linewidth=0.8, linetype="solid", aes(color="col_2"),
              method="lm" , formula=y ~ x, se=FALSE, fullrange=TRUE) +
  geom_point(alpha=1, size=1.0, shape=19, aes(color="col_1")) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis=sec_axis(~., breaks=y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_ord,
                      guide=guide_legend(override.aes=list(shape=c(19,NA,NA), 
                                                           linetype=c("blank", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x=element_text(angle=0, vjust=1),
        legend.key.width=unit(1.0,"cm"), legend.position="bottom")
plot(Call_Put_Stock_Pr_Strike_Pr_sp)
#
PutCall_par_lm <- lm(y~0+x)
summary(PutCall_par_lm)
r_f <- -(1/PutCall_par_lm$coefficients[1]+1)
show(r_f)
r_f_a=(1+r_f)^(365.2425/32)-1
show(r_f_a)
# 0.03252117

#####################################################################################################################
# European Options on Standard & Poor 500 (Yahoo Finance - ^SPX)
# library(quantmod)
SPX_Opt_2023_05_12 <- getOptionChain("^SPX", Exp="2023-05-12", src='yahoo')
class(SPX_Opt_2023_05_12)
length(SPX_Opt_2023_05_12)
show(SPX_Opt_2023_05_12[[1]])
class(SPX_Opt_2023_05_12[[1]])
nrow(SPX_Opt_2023_05_12[[1]])
show(SPX_Opt_2023_05_12[[2]])
class(SPX_Opt_2023_05_12[[2]])
nrow(SPX_Opt_2023_05_12[[2]])
show(SPX_Opt_2023_05_12[[1]]$Strike)
show(SPX_Opt_2023_05_12[[2]]$Strike)
Strike <- sort(union(SPX_Opt_2023_05_12[[1]]$Strike, SPX_Opt_2023_05_12[[2]]$Strike))
show(Strike)
length(Strike)
Call_Indx <- sapply(Strike, function(x) which(SPX_Opt_2023_05_12[[1]]$Strike==x)[1])
Put_Indx <- sapply(Strike, function(x) which(SPX_Opt_2023_05_12[[2]]$Strike==x)[1])

SPX_Opt_2023_05_12_df <- data.frame(Indx=1:length(Strike),
                                    Call_ContractID=SPX_Opt_2023_05_12[[1]]$ContractID[Call_Indx], 
                                    Call_Bid=SPX_Opt_2023_05_12[[1]]$Bid[Call_Indx],
                                    Call_Ask=SPX_Opt_2023_05_12[[1]]$Ask[Call_Indx],
                                    Call_Vol=SPX_Opt_2023_05_12[[1]]$Vol[Call_Indx],
                                    Call_OI=SPX_Opt_2023_05_12[[1]]$OI[Call_Indx],
                                    Call_PrChg=SPX_Opt_2023_05_12[[1]]$Chg[Call_Indx],
                                    Call_PrChgPct=SPX_Opt_2023_05_12[[1]]$ChgPct[Call_Indx],
                                    Call_LastTrTime=SPX_Opt_2023_05_12[[1]]$LastTradeTime[Call_Indx],
                                    Call_LastPr=SPX_Opt_2023_05_12[[1]]$Last[Call_Indx],
                                    Call_ImplVol=SPX_Opt_2023_05_12[[1]]$IV[Call_Indx],
                                    Call_ITM=SPX_Opt_2023_05_12[[1]]$ITM[Call_Indx],
                                    Strike=Strike,
                                    Put_ITM=SPX_Opt_2023_05_12[[2]]$ITM[Put_Indx],
                                    Put_ImplVol=SPX_Opt_2023_05_12[[2]]$IV[Put_Indx],
                                    Put_LastPr=SPX_Opt_2023_05_12[[2]]$Last[Put_Indx],
                                    Put_LastTrTime=SPX_Opt_2023_05_12[[2]]$LastTradeTime[Put_Indx],
                                    Put_PrChgPct=SPX_Opt_2023_05_12[[2]]$ChgPct[Put_Indx],
                                    Put_PrChg=SPX_Opt_2023_05_12[[2]]$Chg[Put_Indx],
                                    Put_OI=SPX_Opt_2023_05_12[[2]]$OI[Put_Indx],
                                    Put_Vol=SPX_Opt_2023_05_12[[2]]$Vol[Put_Indx],
                                    Put_Ask=SPX_Opt_2023_05_12[[2]]$Ask[Put_Indx],
                                    Put_Bid=SPX_Opt_2023_05_12[[2]]$Bid[Put_Indx],
                                    Put_ContractID=SPX_Opt_2023_05_12[[2]]$ContractID[Put_Indx])
head(SPX_Opt_2023_05_12_df,10)                                   
tail(SPX_Opt_2023_05_12_df,10)
write.csv(SPX_Opt_2023_05_12_df,"C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Data/SPX_Option_Chain_2023_05_12.csv")
dir("C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Data")
write.csv(SPX_Opt_2023_05_12_df,"C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Scripts/SPX_Option_Chain_2023_05_12.csv")
dir("C:/Users/rober/Documents/My Documents/My Teaching Documents/MPSFM/R-Scripts & Data/Scripts")
#
Call_LastTrTime_df <- data.frame(as.Date(SPX_Opt_2023_05_12_df$Call_LastTrTime))
class(Call_LastTrTime_df)
head(Call_LastTrTime_df,20)
nrow(Call_LastTrTime_df)
Call_LastTrTime_tb <- table(Call_LastTrTime_df)   
class(Call_LastTrTime_tb)
show(Call_LastTrTime_tb)
#
Put_LastTrTime_df <- data.frame(as.Date(SPX_Opt_2023_05_12_df$Put_LastTrTime))
class(Put_LastTrTime_df)
head(Put_LastTrTime_df,20)
nrow(Put_LastTrTime_df)
Put_LastTrTime_tb <- table(Put_LastTrTime_df)   
class(Put_LastTrTime_tb)
show(Put_LastTrTime_tb)
#
Call_LastTrTime_2023_04_10_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Call_LastTrTime)=="2023-04-10")]
show(Call_LastTrTime_2023_04_10_Indx)
Put_LastTrTime_2023_04_10_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Put_LastTrTime)=="2023-04-10")]
show(Put_LastTrTime_2023_04_10_Indx)
Call_Put_2023_04_10_Indx <- intersect(Call_LastTrTime_2023_04_10_Indx, Put_LastTrTime_2023_04_10_Indx)
show(Call_Put_2023_04_10_Indx)
length(Call_Put_2023_04_10_Indx)
#
Call_LastTrTime_2023_04_06_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Call_LastTrTime)=="2023-04-06")]
show(Call_LastTrTime_2023_04_06_Indx)
Put_LastTrTime_2023_04_06_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Put_LastTrTime)=="2023-04-06")]
show(Put_LastTrTime_2023_04_06_Indx)
Call_Put_2023_04_06_Indx <- intersect(Call_LastTrTime_2023_04_06_Indx, Put_LastTrTime_2023_04_06_Indx)
show(Call_Put_2023_04_06_Indx)
length(Call_Put_2023_04_06_Indx)
#
Call_LastTrTime_2023_03_31_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Call_LastTrTime)=="2023-03-31")]
show(Call_LastTrTime_2023_03_31_Indx)
Put_LastTrTime_2023_03_31_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Put_LastTrTime)=="2023-03-31")]
show(Put_LastTrTime_2023_03_31_Indx)
Call_Put_2023_03_31_Indx <- intersect(Call_LastTrTime_2023_03_31_Indx, Put_LastTrTime_2023_03_31_Indx)
show(Call_Put_2023_03_31_Indx)
length(Call_Put_2023_03_31_Indx)
#
Call_LastTrTime_2023_03_23_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Call_LastTrTime)=="2023-03-23")]
show(Call_LastTrTime_2023_03_23_Indx)
Put_LastTrTime_2023_03_23_Indx <- SPX_Opt_2023_05_12_df$Indx[which(as.Date(SPX_Opt_2023_05_12_df$Put_LastTrTime)=="2023-03-23")]
show(Put_LastTrTime_2023_03_23_Indx)
Call_Put_2023_03_23_Indx <- intersect(Call_LastTrTime_2023_03_23_Indx, Put_LastTrTime_2023_03_23_Indx)
show(Call_Put_2023_03_23_Indx)
length(Call_Put_2023_03_23_Indx)
#
#
# Put-Call parity
# P_0 = C_0 - S_0 + K/(1+r_f)
# C_0-P_0 = S_0 - K/(1+r_f)
#
x <- SPX_Opt_2023_05_12_df$Strike[Call_Put_2023_04_10_Indx]
show(x)
length(x)
y <- SPX_Opt_2023_05_12_df$Call_LastPr[Call_Put_2023_04_10_Indx]-SPX_Opt_2023_05_12_df$Put_LastPr[Call_Put_2023_04_10_Indx]
show(y)
length(y)
#
#
PutCall_par_lm <- lm(y~x)
summary(PutCall_par_lm)
#
S_0 <- PutCall_par_lm$coefficients[1]
show(S_0)
# SPX Market Price 4,109.11 +4.09 (+0.10%) At close: April 10 04:57PM EDT
#
r_f <- -(1/PutCall_par_lm$coefficients[2]+1)
show(r_f)
r_f_a=(1+r_f)^(365.2425/32)-1
show(r_f_a)
#
# Put-Call parity
# P_0 = C_0 - S_0 + K/(1+r_f)
# C_0-P_0-S_0 = - K/(1+r_f)
#
x <- SPX_Opt_2023_05_12_df$Strike[Call_Put_2023_04_10_Indx]
show(x)
length(x)
y <- SPX_Opt_2023_05_12_df$Call_LastPr[Call_Put_2023_04_10_Indx]-SPX_Opt_2023_05_12_df$Put_LastPr[Call_Put_2023_04_10_Indx]-4109.11
show(y)
length(y)
#
PutCall_par_lm <- lm(y~0+x)
summary(PutCall_par_lm)
r_f <- -(1/PutCall_par_lm$coefficients[1]+1)
show(r_f)
r_f_a=(1+r_f)^(365.2425/32)-1
show(r_f_a)
r_f_a_c <- log(1+r_f_a)
show(r_f_a_c)
##############################################################################################################################

############################## Create data frames of data from Yahoo Finance ########################################
# We consider data on US Treasury Bonds available on Yahoo Finance
# library(xts)
# library(zoo)
# library(TTR)
# library(quantmod)
# Retrieve financial data from https://finance.yahoo.com/
# Treasury bonds - https://finance.yahoo.com/bonds?.tsrc=fin-srch
# ^IRX = 13 Week Treasury Bill
# ^FVX = Treasury Yield 5 Years
# ^TNX = Treasury Yields 10 Years
# ^TYX = Treasury Yield 30 Years

# Set start date
start_date <- Sys.Date()-years(x=1)
# Set end date
end_date <- Sys.Date()
# To evaluate the difference between the dates in terms of days.
difftime(end_date, start_date, units="days")
# To evaluate the difference between the dates in terms of business days.
# library(timeDate)
# help(holidayNYSE)
# library(bizdays)
NYSE_cal  <- create.calendar("UnitedStates/NYSE", holidayNYSE(2020:2022), weekdays=c("saturday", "sunday"))
bizdays(from=start_date, to=end_date, cal=NYSE_cal)

bond_symbols <- c("^IRX", "^FVX", "^TNX", "^TYX")
getSymbols.yahoo(Symbols=bond_symbols, from=start_date, to=end_date, periodicity="daily", 
                 base.currency="USD", env = .GlobalEnv, verbose = TRUE, warning = TRUE, auto.assign = TRUE)

class(IRX)
nrow(IRX)
head(IRX)
tail(IRX)

class(FVX)
nrow(FVX)
head(FVX)
tail(FVX)

class(TNX)
nrow(TNX)
head(TNX)
tail(TNX)

class(TYX)
nrow(TYX)
head(TYX)
tail(TYX)

IRX_df <- as.data.frame(IRX)
class(IRX_df)
IRX_df <- add_column(IRX_df, Bond="IRX", .before=1)
head(IRX_df)

FVX_df <- as.data.frame(FVX)
class(FVX_df)
FVX_df <- add_column(FVX_df, Bond="FVX", .before=1)
head(FVX_df)

TNX_df <- as.data.frame(TNX)
class(TNX_df)
TNX_df <- add_column(TNX_df, Bond="TNX", .before=1)
head(TNX_df)

TYX_df <- as.data.frame(TYX)
class(TYX_df)
TYX_df <- add_column(TYX_df, Bond="TYX", .before=1)
head(TYX_df)

US_Bonds_Hor_df <- cbind(IRX_df, FVX_df, TNX_df, TYX_df)
head(US_Bonds_Hor_df)
US_Bonds_Hor_df <- add_column(US_Bonds_Hor_df, Date=rownames(US_Bonds_Hor_df), .before=1)
row.names(US_Bonds_Hor_df) <- NULL
head(US_Bonds_Hor_df)

IRX_mod_df <- add_column(IRX_df, Date=rownames(IRX_df), .before=1)
colnames(IRX_mod_df) <- c("Date", "Bond", "Open", "High", "Low", "Close", "Volume", "Adjusted")
row.names(IRX_mod_df) <- NULL
head(IRX_mod_df)

FVX_mod_df <- add_column(FVX_df, Date=rownames(FVX_df), .before=1)
colnames(FVX_mod_df) <- c("Date", "Bond", "Open", "High", "Low", "Close", "Volume", "Adjusted")
row.names(FVX_mod_df) <- NULL
head(FVX_mod_df)

TNX_mod_df <- add_column(TNX_df, Date=rownames(TNX_df), .before=1)
colnames(TNX_mod_df) <- c("Date", "Bond", "Open", "High", "Low", "Close", "Volume", "Adjusted")
row.names(TNX_mod_df) <- NULL
head(TNX_mod_df)

TYX_mod_df <- add_column(TYX_df, Date=rownames(TYX_df), .before=1)
colnames(TYX_mod_df) <- c("Date", "Bond", "Open", "High", "Low", "Close", "Volume", "Adjusted")
row.names(TYX_mod_df) <- NULL
head(TYX_mod_df)

US_Bonds_Ver_df <- rbind(IRX_mod_df, FVX_mod_df, TNX_mod_df, TYX_mod_df)
head(US_Bonds_Ver_df)
tail(US_Bonds_Ver_df)

start_date <- Sys.Date()-years(x=1)
# Set end date
end_date <- Sys.Date()
bond_symbols <- c("^IRX", "^FVX", "^TNX", "^TYX")
bond_ids <- c("IRX", "FVX", "TNX", "TYX")
US_Bonds_H_df <- data.frame(matrix(nrow=nrow(IRX), ncol=0))
US_Bonds_V_df <- data.frame(matrix(nrow=0, ncol=(ncol(IRX)+1)))
for(cnt in seq(1,length(bond_symbols))){
   temp_df <- as.data.frame(getSymbols.yahoo(Symbols=bond_symbols[cnt], from=start_date, to=end_date, periodicity="daily", 
                            base.currency="USD", env = .GlobalEnv, verbose = TRUE, warning = TRUE, auto.assign = FALSE))
   temp_df <- add_column(temp_df, Bond=bond_ids[cnt], .before=1)
   US_Bonds_H_df <- cbind(US_Bonds_H_df, temp_df)
   temp_df <- add_column(temp_df, Date=rownames(temp_df), .before=1)
   colnames(temp_df) <- c("Date", "Bond", "Open", "High", "Low", "Close", 
                         "Volume", "Adjusted")
   US_Bonds_V_df <- rbind(US_Bonds_V_df, temp_df)
}
US_Bonds_H_df <- add_column(US_Bonds_H_df, Date=rownames(US_Bonds_H_df), .before=1)
row.names(US_Bonds_H_df) <- NULL
head(US_Bonds_H_df)
row.names(US_Bonds_V_df) <- NULL
head(US_Bonds_V_df,25)
tail(US_Bonds_V_df,25)

#####################################################################################################################

# We build a data frame with the adjusted bond prices and add an Index column

US_Bond_Yield_Rates_df <- data.frame(Date=index(IRX), TB13W=as.vector(IRX$IRX.Adjusted),
                             TN5Yr=as.vector(FVX$FVX.Adjusted), TN10Yr=as.vector(TNX$TNX.Adjusted),
                             TN30Yr=as.vector(TYX$TYX.Adjusted))
US_Bond_Yield_Rates_df <- add_column(US_Bond_Yield_Rates_df, Index=1:nrow(US_Bond_Yield_Rates_df), .before="Date")
show(US_Bond_Yield_Rates_df[1:15,])

# We draw a plot of the adjusted bond prices.
# The scatter plot
Data_df <- US_Bond_Yield_Rates_df
length <- length(na.omit(Data_df$TB13W))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plots of US Treasury Yield Rates from ", .(First_Day), " to ", .(Last_Day))))
link <- "https://finance.yahoo.com/bonds?.tsrc=fin-srch"
subtitle_content <- bquote(paste("path length ", .(length), " sample points. Dati Yahoo Finance  -  ", .(link)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("treasury yield rates")
y_breaks_num <- 10
y_bound_low <- min(Data_df$TB13W, Data_df$TN5Yr, Data_df$TN10Yr, Data_df$TN30Yr, na.rm=TRUE)
y_bound_up <- max(Data_df$TB13W, Data_df$TN5Yr, Data_df$TN10Yr, Data_df$TN30Yr, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- label_percent(accuracy = 0.01)(y_breaks)
# y_labs <- paste(format(y_breaks, scientific=FALSE),"%")
K <- 1
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("13 Week Yield Adj. Close")
col_2 <- bquote("05 Years Yield Adj. Close")
col_3 <- bquote("10 Years Yield Adj. Close")
col_4 <- bquote("30 Years Yield Adj. Close")
leg_labs <- c(col_1, col_2, col_3, col_4)
leg_cols <- c("col_1"="red", "col_2"="green", "col_3"="blue", "col_4"="black")
leg_sort <- c("col_1", "col_2", "col_3", "col_4")
US_Bond_Yield_Rates_sp <- ggplot(Data_df) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=TB13W, color="col_1"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=TN5Yr, color="col_2"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=TN10Yr, color="col_3"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=TN30Yr, color="col_4"), na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(US_Bond_Yield_Rates_sp)

# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plots of US Treasury Yield Rates from ", .(First_Day), " to ", .(Last_Day))))
US_Bond_Yield_Rates_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.6, linetype="solid", aes(x=Index, y=TB13W, color="col_1", group=1)) +
  geom_line(alpha=1, size=0.6, linetype="solid", aes(x=Index, y=TN5Yr, color="col_2", group=1)) +
  geom_line(alpha=1, size=0.6, linetype="solid", aes(x=Index, y=TN10Yr, color="col_3", group=1)) +
  geom_line(alpha=1, size=0.6, linetype="solid", aes(x=Index, y=TN30Yr, color="col_4", group=1)) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(US_Bond_Yield_Rates_lp)

#####################################################################################################################
# With the goal of investigating the validity of the spot-futures Parity Theorem, we consider some 
# public data sets containing both the spot and the future price of some assets of the financial market.
# Unfortunately, there are limitations to the free availability of this type of data sets. 
# Therefore, our investigation will suffer somehow.

# The website https://www.lbma.org.uk/ operated by the London Bullion Market Association (LBMA) 
# (see https://en.wikipedia.org/wiki/London_Bullion_Market_Association) provides free access 
# to morning and afternoon auction prices of gold, silver, platinum, and palladium 
# both in chart and table form (see https://www.lbma.org.uk/prices-and-data/precious-metal-prices#/).
# In free access data are available only in xml format.

# The website https://www.gold.org/ operated by the WorldGold Council provides free access, 
# upon registration, to many data sets related to gold and silver market 
# (see https://www.gold.org/goldhub/data/gold-prices), 
# among which the LBMA afternoon prices in chart form and also table form (upon registration).

# By using the tables from https://www.gold.org/goldhub/data/gold-prices 
# and https://www.lbma.org.uk/prices-and-data/precious-metal-prices#/ we create the file
# US-Daily-Gold-Spot-Prices-From-2020-04-02-2021-04-01.csv
# Thereafter we load it as data frame
Gold_df <- read.csv("US-Daily-Gold-Spot-Prices-From-2020-04-02-2021-04-01.csv", header=TRUE)
class(Gold_df)
head(Gold_df)
tail(Gold_df)

# We check whether the Date column is in "Date" format. In case it is not, we change the format to "Date".
class(Gold_df$Date)
# library(lubridate)
Gold_df$Date <- as.Date(Gold_df$Date, format="%d/%m/%Y")
class(Gold_df$Date)
head(Gold_df)

# As additional information, we report that t he website Goldprice (see https://goldprice.org) provides charts 
# of the spot(?) prices of gold and silver, and charts of some CFD's, but likely not easily downloadable data.

# The website Oanda (see https://www.oanda.com) provides free access, by means of the dedicated quantmod API 
# to 180 days of CFD's prices of some commodities, for instance gold (XAU), silver (XAG), palladium (XPD), 
# platinum (XPT) (see https://www.rdocumentation.org/packages/quantmod/versions/0.4.18/topics/getMetals).

# library(quantmod)
# Gold_CFD <- getMetals("XAU", from = Sys.Date()-days(x=180), to = Sys.Date(), base.currency="USD",
#                         env = .GlobalEnv, verbose = FALSE, warning = TRUE, auto.assign = FALSE)
# Silver_CFD <- getMetals("XAG", from = Sys.Date()-days(180), to = Sys.Date(), base.currency="USD",
#                         env = .GlobalEnv, verbose = FALSE, warning = TRUE, auto.assign = FALSE)

# The website Yahoo Finance (see https://finance.yahoo.com) provides free access, by means of the dedicated 
# quantmod API, to a large amount of financial data. In particular, we can access to historical 
# data on the future contracts on gold and silver spot price, but, unfortunately, not to historical data
# on the spot prices themselves.

# Also the website MarketWatch (see https://www.marketwatch.com) provides free access to to a large amount 
# of financial data, downloadable as csv files (e.g. see https://www.marketwatch.com/investing/stock/gold).

# Futures on Gold Prices
# Dates
# library(lubridate)
To <- Sys.Date()-days(17)
# The above variable needs to be adjusted in terms of days to download data up to the 1st of April 2021.
From <- To-years(x=1)

# Future on Gold price, maturity April 2021
# library(quantmod)
GCJ21_df <- getSymbols.yahoo("GCJ21.CMX", from=From, to=To, periodicity="daily",
                          base.currency="USD",  return.class="data.frame", env = .GlobalEnv, 
                          verbose = FALSE, warning = TRUE, auto.assign = FALSE)
class(GCJ21_df)
head(GCJ21_df)
tail(GCJ21_df)
# library(tidyverse)
GCJ21_df <- add_column(GCJ21_df, Index=1:nrow(GCJ21_df), Date=as.Date(row.names(GCJ21_df), format="%Y-%m-%d"), 
                    .before="GCJ21.CMX.Open")
rownames(GCJ21_df) <- NULL
head(GCJ21_df)
class(GCJ21_df$Date)

# Future on Gold price, maturity May 2021
GCK21_df <- getSymbols.yahoo("GCK21.CMX", from=From, to=To, periodicity="daily",
                          base.currency="USD",  return.class="data.frame", env = .GlobalEnv, 
                          verbose = FALSE, warning = TRUE, auto.assign = FALSE)
class(GCK21_df)
head(GCK21_df)
tail(GCK21_df)
GCK21_df <- add_column(GCK21_df, Index=1:nrow(GCK21_df), Date=as.Date(row.names(GCK21_df), format="%Y-%m-%d"), 
                    .before="GCK21.CMX.Open")
rownames(GCK21_df) <- NULL
head(GCK21_df)
class(GCK21_df$Date)

# Future on Gold price, maturity June 2021
GCM21_df <- getSymbols.yahoo("GCM21.CMX", from=From, to=To, periodicity="daily",
                          base.currency="USD",  return.class="data.frame", env = .GlobalEnv, 
                          verbose = FALSE, warning = TRUE, auto.assign = FALSE)
head(GCM21_df)
tail(GCM21_df)
GCM21_df <- add_column(GCM21_df, Index=1:nrow(GCM21_df), Date=as.Date(row.names(GCM21_df), format="%Y-%m-%d"), 
                    .before="GCM21.CMX.Open")
rownames(GCM21_df) <- NULL
head(GCM21_df)
class(GCM21_df$Date)

# Future on Gold price, maturity Aug 2021
GCQ21_df <- getSymbols.yahoo("GCQ21.CMX", from=From, to=To, periodicity="daily",
                          base.currency="USD",  return.class="data.frame", env = .GlobalEnv, 
                          verbose = FALSE, warning = TRUE, auto.assign = FALSE)
head(GCQ21_df)
tail(GCQ21_df)
GCQ21_df <- add_column(GCQ21_df, Index=1:nrow(GCQ21_df), Date=as.Date(row.names(GCQ21_df), format="%Y-%m-%d"), 
                    .before="GCQ21.CMX.Open")
rownames(GCQ21_df) <- NULL
head(GCQ21_df)
class(GCQ21_df$Date)

# Future on Gold price, maturity Oct 2021
GCV21_df <- getSymbols.yahoo("GCV21.CMX", from=From, to=To, periodicity="daily",
                          base.currency="USD",  return.class="data.frame", env = .GlobalEnv, 
                          verbose = FALSE, warning = TRUE, auto.assign = FALSE)
head(GCV21_df)
tail(GCV21_df)
GCV21_df <- add_column(GCV21_df, Index=1:nrow(GCV21_df), Date=as.Date(row.names(GCV21_df), format="%Y-%m-%d"), 
                    .before="GCV21.CMX.Open")
rownames(GCV21_df) <- NULL
head(GCV21_df)
class(GCV21_df$Date)

# Future on Gold price, maturity Dec 2021
GCZ21_df <- getSymbols.yahoo("GCZ21.CMX", from=From, to=To, periodicity="daily",
                          base.currency="USD",  return.class="data.frame", env = .GlobalEnv, 
                          verbose = FALSE, warning = TRUE, auto.assign = FALSE)
head(GCZ21_df)
tail(GCZ21_df)
GCZ21_df <- add_column(GCZ21_df, Index=1:nrow(GCZ21_df), Date=as.Date(row.names(GCZ21_df), format="%Y-%m-%d"), 
                    .before="GCZ21.CMX.Open")
rownames(GCZ21_df) <- NULL
head(GCZ21_df)
class(GCZ21_df$Date)

# XAU <- getSymbols.yahoo("XAUUSD=X", from=Sys.Date()-years(x=1), to=Sys.Date(), periodicity="daily",
#                        base.currency="USD", return.class="data.frame", env = .GlobalEnv, 
#                        verbose = FALSE, warning = TRUE, warning = TRUE, auto.assign = FALSE)
# head(XAU)
# tail(XAU)


# Note that except for the future GCK21.CMX all future data frames in the time interval 2020-04-02 - 2021-04-01
# contain 252 observations. However, in the same time interval the Gold_df data frame contains 261 observations.
# Eventually, some holidays, like "2020-12-25", are present in the spot data set, but missed in the future data set.
# Futures are traded by means of the Chicago Mercantile Exchange clearing house (see https://www.cmegroup.com) 
# The CMEGroup holiday calendar is available at https://www.cmegroup.com/tools-information/holiday-calendar.html).
# We want to create a common data frame for future and spot prices. Therefore we need to selct the spot prices
# corresponding to the dates of the futures.
# First, we check whether the indices of all future data frames correspond to the same dates
all(GCJ21_df$Date==GCM21_df$Date)
all(GCJ21_df$Date==GCQ21_df$Date)
all(GCJ21_df$Date==GCV21_df$Date)
all(GCJ21_df$Date==GCZ21_df$Date)
# Second, we select the rows of the vector Gold_df$Date corresponding to same entries as the vector GCJ21_df$Date.
which(Gold_df$Date %in% GCJ21_df$Date)
# We check that whether the selection is correct 
all(Gold_df$Date[which(Gold_df$Date %in% GCJ21_df$Date)]==GCJ21_df$Date)
# Third, we create the desired data frame
Spot_Fut_df <- data.frame(Index=1:nrow(GCJ21_df), Date=GCJ21_df$Date,
                          Spot=Gold_df$USD_Spot[which(Gold_df$Date %in% GCJ21_df$Date)],
                          Apr21_Fut=GCJ21_df$GCJ21.CMX.Adjusted, Jun21_Fut=GCM21_df$GCM21.CMX.Adjusted, 
                          Aug21_Fut=GCQ21_df$GCQ21.CMX.Adjusted, Oct21_Fut=GCV21_df$GCV21.CMX.Adjusted, 
                          Dec21_Fut=GCZ21_df$GCZ21.CMX.Adjusted)
head(Spot_Fut_df)
tail(Spot_Fut_df)

# We add to the Spot_Fut_df the bases of the futures, that is the differences between futures and spot prices.
Spot_Fut_df <- add_column(Spot_Fut_df, Apr21_Bs=Spot_Fut_df$Apr21_Fut-Spot_Fut_df$Spot, .after="Apr21_Fut")
Spot_Fut_df <- add_column(Spot_Fut_df, Jun21_Bs=Spot_Fut_df$Jun21_Fut-Spot_Fut_df$Spot, .after="Jun21_Fut")
Spot_Fut_df <- add_column(Spot_Fut_df, Aug21_Bs=Spot_Fut_df$Aug21_Fut-Spot_Fut_df$Spot, .after="Aug21_Fut")
Spot_Fut_df <- add_column(Spot_Fut_df, Oct21_Bs=Spot_Fut_df$Oct21_Fut-Spot_Fut_df$Spot, .after="Oct21_Fut")
Spot_Fut_df <- add_column(Spot_Fut_df, Dec21_Bs=Spot_Fut_df$Dec21_Fut-Spot_Fut_df$Spot, .after="Dec21_Fut")
head(Spot_Fut_df)
tail(Spot_Fut_df)

# Now, we add to the Spot_Fut_df the time to maturity columns for each of the future price column.
# We consider the Gold Futures Calendar to check the settlment dates of the futures
# (see https://www.cmegroup.com/trading/metals/precious/gold_product_calendar_futures.html),
# so that we can add a *Days.to.Maturity", Months.to.Maturity, and *Years.to.Maturity* columns 
Apr21_Fut_DtM <- as.Date("2021-04-28", format="%Y-%m-%d")-Spot_Fut_df$Date
show(Apr21_Fut_DtM)
Apr21_Fut_MtM <- as.numeric(Apr21_Fut_DtM)/30.417
show(Apr21_Fut_MtM)
Apr21_Fut_YtM <- as.numeric(Apr21_Fut_DtM)/365
show(Apr21_Fut_YtM)
Spot_Fut_df <- add_column(Spot_Fut_df, Apr21_Fut_DtM=Apr21_Fut_DtM, Apr21_Fut_MtM=Apr21_Fut_MtM,
                          Apr21_Fut_YtM=Apr21_Fut_YtM, .after="Apr21_Bs")
head(Spot_Fut_df)

Jun21_Fut_DtM <- as.Date("2021-06-28", format="%Y-%m-%d")-Spot_Fut_df$Date
show(Jun21_Fut_DtM)
Jun21_Fut_MtM <- as.numeric(Jun21_Fut_DtM)/30.417
show(Jun21_Fut_MtM)
Jun21_Fut_YtM <- as.numeric(Jun21_Fut_DtM)/365
show(Jun21_Fut_YtM)
Spot_Fut_df <- add_column(Spot_Fut_df, Jun21_Fut_DtM=Jun21_Fut_DtM, Jun21_Fut_MtM=Jun21_Fut_MtM,
                          Jun21_Fut_YtM=Jun21_Fut_YtM, .after="Jun21_Bs")
head(Spot_Fut_df)

Aug21_Fut_DtM <- as.Date("2021-08-27", format="%Y-%m-%d")-Spot_Fut_df$Date
show(Aug21_Fut_DtM)
Aug21_Fut_MtM <- as.numeric(Aug21_Fut_DtM)/30.417
show(Aug21_Fut_MtM)
Aug21_Fut_YtM <- as.numeric(Aug21_Fut_DtM)/365
show(Aug21_Fut_YtM)
Spot_Fut_df <- add_column(Spot_Fut_df, Aug21_Fut_DtM=Aug21_Fut_DtM, Aug21_Fut_MtM=Aug21_Fut_MtM,
                          Aug21_Fut_YtM=Aug21_Fut_YtM, .after="Aug21_Bs")
head(Spot_Fut_df)

Oct21_Fut_DtM <- as.Date("2021-10-27", format="%Y-%m-%d")-Spot_Fut_df$Date
show(Oct21_Fut_DtM)
Oct21_Fut_MtM <- as.numeric(Oct21_Fut_DtM)/30.417
show(Oct21_Fut_MtM)
Oct21_Fut_YtM <- as.numeric(Oct21_Fut_DtM)/365
show(Oct21_Fut_YtM)
Spot_Fut_df <- add_column(Spot_Fut_df, Oct21_Fut_DtM=Oct21_Fut_DtM, Oct21_Fut_MtM=Oct21_Fut_MtM,
                          Oct21_Fut_YtM=Oct21_Fut_YtM, .after="Oct21_Bs")
head(Spot_Fut_df)

Dec21_Fut_DtM <- as.Date("2021-12-29", format="%Y-%m-%d")-Spot_Fut_df$Date
show(Dec21_Fut_DtM)
Dec21_Fut_MtM <- as.numeric(Dec21_Fut_DtM)/30.417
show(Dec21_Fut_MtM)
Dec21_Fut_YtM <- as.numeric(Dec21_Fut_DtM)/365
show(Dec21_Fut_YtM)
Spot_Fut_df <- add_column(Spot_Fut_df, Dec21_Fut_DtM=Dec21_Fut_DtM, Dec21_Fut_MtM=Dec21_Fut_MtM,
                          Dec21_Fut_YtM=Dec21_Fut_YtM, .after="Dec21_Bs")
head(Spot_Fut_df)

# In addition, we compute the risk free return associated to the time to maturity according to the formula
# $F_{t,T} = \left(1+r_{t,T}\right)S_{t}$,
# where $S_{t}$ is the gold spot price at time $t$,
# $F_{t,T}$ is the future price of gold at time $t$ for delivery at date $T$, 
# $r_{t,T}$ is the risk free rate of return from $t$ to the delivery date $T$,
# The above formula yields
# $r_{t,T} = \frac{F_{t,T}},{S_{t}}-1$

Apr21_RR <- Spot_Fut_df$Apr21_Fut/Spot_Fut_df$Spot -1
Jun21_RR <- Spot_Fut_df$Jun21_Fut/Spot_Fut_df$Spot -1
Aug21_RR <- Spot_Fut_df$Aug21_Fut/Spot_Fut_df$Spot -1
Oct21_RR <- Spot_Fut_df$Oct21_Fut/Spot_Fut_df$Spot -1
Dec21_RR <- Spot_Fut_df$Dec21_Fut/Spot_Fut_df$Spot -1

Spot_Fut_df <- add_column(Spot_Fut_df, Apr21_RR=Apr21_RR, .after="Apr21_Fut_YtM")
Spot_Fut_df <- add_column(Spot_Fut_df, Jun21_RR=Jun21_RR, .after="Jun21_Fut_YtM")
Spot_Fut_df <- add_column(Spot_Fut_df, Aug21_RR=Aug21_RR, .after="Aug21_Fut_YtM")
Spot_Fut_df <- add_column(Spot_Fut_df, Oct21_RR=Oct21_RR, .after="Oct21_Fut_YtM")
Spot_Fut_df <- add_column(Spot_Fut_df, Dec21_RR=Dec21_RR, .after="Dec21_Fut_YtM")

head(Spot_Fut_df)

# We compute the annual rate of return according to the formula
# (1+r_A)^t=1+r_M; r_A=(1+r_M)^(1/t)-1
# where r_A=annual rate of return, t=time to maturity (in years), r_M=rate of return in the period t.
Apr21_ARR <-((1+Apr21_RR)^(1/Apr21_Fut_YtM)-1)
Jun21_ARR <-((1+Jun21_RR)^(1/Jun21_Fut_YtM)-1)
Aug21_ARR <-((1+Aug21_RR)^(1/Aug21_Fut_YtM)-1)
Oct21_ARR <-((1+Oct21_RR)^(1/Oct21_Fut_YtM)-1)
Dec21_ARR <-((1+Dec21_RR)^(1/Dec21_Fut_YtM)-1)

# We represent the annual rate of return in percentage form
# library(scales)
Apr21_Perc_ARR <- label_percent(accuracy = 0.01)(Apr21_ARR)
Jun21_Perc_ARR <- label_percent(accuracy = 0.01)(Jun21_ARR)
Aug21_Perc_ARR <- label_percent(accuracy = 0.01)(Aug21_ARR)
Oct21_Perc_ARR <- label_percent(accuracy = 0.01)(Oct21_ARR)
Dec21_Perc_ARR <- label_percent(accuracy = 0.01)(Dec21_ARR)

Spot_Fut_df <- add_column(Spot_Fut_df, Apr21_ARR=Apr21_ARR, Apr21_Perc_ARR=Apr21_Perc_ARR, .after="Apr21_RR")
Spot_Fut_df <- add_column(Spot_Fut_df, Jun21_ARR=Jun21_ARR, Jun21_Perc_ARR=Jun21_Perc_ARR, .after="Jun21_RR")
Spot_Fut_df <- add_column(Spot_Fut_df, Aug21_ARR=Aug21_ARR, Aug21_Perc_ARR=Aug21_Perc_ARR, .after="Aug21_RR")
Spot_Fut_df <- add_column(Spot_Fut_df, Oct21_ARR=Oct21_ARR, Oct21_Perc_ARR=Oct21_Perc_ARR, .after="Oct21_RR")
Spot_Fut_df <- add_column(Spot_Fut_df, Dec21_ARR=Dec21_ARR, Dec21_Perc_ARR=Dec21_Perc_ARR, .after="Dec21_RR")

head(Spot_Fut_df)
tail(Spot_Fut_df)

# We draw a plot of spot and future prices

# The scatter plot
Data_df <- Spot_Fut_df
length <- length(na.omit(Data_df$Spot))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plots of Gold and Futures Spot Prices from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA - ", .(link_1), " and Yahoo Finance  -  ", .(link_2)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("spot and future prices")
y_breaks_num <- 10
y_bound_low <- min(Data_df$Spot, Data_df$Apr21_Fut, Data_df$Jun21_Fut, Data_df$Aug21_Fut, Data_df$Oct21_Fut, Data_df$Dec21_Fut, na.rm=TRUE)
y_bound_up <- max(Data_df$Spot, Data_df$Apr21_Fut, Data_df$Jun21_Fut, Data_df$Aug21_Fut, Data_df$Oct21_Fut, Data_df$Dec21_Fut, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Gold Spot Price")
col_2 <- bquote("Gold Apr. 21 Fut. Price")
col_3 <- bquote("Gold Jun. 21 Fut. Price")
col_4 <- bquote("Gold Aug. 21 Fut. Price")
y5_col <- bquote("Gold Oct. 21 Fut. Price")
y6_col <- bquote("Gold Dec. 21 Fut. Price")
leg_labs <- c(col_1, col_2, col_3, col_4, y5_col, y6_col)
leg_cols <- c("col_1"="red", "col_2"="green", "col_3"="blue", "col_4"="black", y5_col="magenta", y6_col="brown")
leg_sort <- c("col_1", "col_2", "col_3", "col_4", "y5_col", "y6_col")
Gold_Spot_Fut_Prices_sp <- ggplot(Data_df) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Spot, color="col_1"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Apr21_Fut, color="col_2"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Jun21_Fut, color="col_3"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Aug21_Fut, color="col_4"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Oct21_Fut, color="y5_col"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Dec21_Fut, color="y6_col"), na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Fut_Prices_sp)

# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plots of Gold and Futures Spot Prices from ", .(First_Day), " to ", .(Last_Day))))
Gold_Spot_Fut_Prices_lp <- ggplot(Data_df) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Spot, color="col_1", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Apr21_Fut, color="col_2", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Jun21_Fut, color="col_3", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Aug21_Fut, color="col_4", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Oct21_Fut, color="y5_col", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Dec21_Fut, color="y6_col", group=1)) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Fut_Prices_lp)

# We draw a plot of the bases of spot and future prices

Data_df <- Spot_Fut_df
length <- length(na.omit(Data_df$Spot))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plots of Gold Future Bases from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA - ", .(link_1), " and Yahoo Finance  -  ", .(link_2)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("spot and future prices")
y_breaks_num <- 10
y_bound_low <- min(0, Data_df$Apr21_Bs, Data_df$Jun21_Bs, Data_df$Aug21_Bs, Data_df$Oct21_Bs, 
                   Data_df$Dec21_Bs, na.rm=TRUE)
y_bound_up <- max(0, Data_df$Apr21_Bs, Data_df$Jun21_Bs, Data_df$Aug21_Bs, Data_df$Oct21_Bs, 
                  Data_df$Dec21_Bs, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Reference Line")
col_2 <- bquote("Fut. Apr. 21 Basis")
col_3 <- bquote("Fut. Jun. 21 Basis")
col_4 <- bquote("Fut. Aug. 21 Basis")
y5_col <- bquote("Fut. Oct. 21 Basis")
y6_col <- bquote("Fut. Dec. 21 Basis")
leg_0_lab <- col_1
leg_0_col <- c("col_1"="red")
leg_0_line_type <- c("y_1_col"="solid")
leg_labs <- c(col_2, col_3, col_4, y5_col, y6_col)
leg_cols <- c("col_2"="green", "col_3"="blue", "col_4"="black", y5_col="magenta", y6_col="brown")
leg_sort <- c("col_2", "col_3", "col_4", "y5_col", "y6_col")
Gold_Spot_Fut_Bases_sp <- ggplot(Data_df) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Apr21_Bs, color="col_2"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Jun21_Bs, color="col_3"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Aug21_Bs, color="col_4"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Oct21_Bs, color="y5_col"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Dec21_Bs, color="y6_col"), na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, 
                                         override.aes=list(linetype=c("blank", "blank", "blank", "blank", "blank"),
                                                           shape = c(16, 16, 16, 16, 16)))) +
  guides(linetype=guide_legend(order=1), colour=guide_legend(order=2)) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Fut_Bases_sp)

# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plots of Gold Future Bases from ", .(First_Day), " to ", .(Last_Day))))
Gold_Spot_Fut_Bases_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_2", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Jun21_Bs, color="col_3", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Aug21_Bs, color="col_4", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Oct21_Bs, color="y5_col", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="y6_col", group=1)) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  guides(linetype=guide_legend(order=1), colour=guide_legend(order=2)) +
    theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Fut_Bases_lp)

# We reconsider the plot of the basis of future with maturity on April and December the 29th. 

# April the 29th

Data_df <- Spot_Fut_df
length <- length(na.omit(Data_df$Spot))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plot of April 2021 Gold Future Basis from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA - ", .(link_1), " and Yahoo Finance  -  ", .(link_2)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("spot and future prices")
y_breaks_num <- 10
y_bound_low <- min(0, Data_df$Apr21_Bs, na.rm=TRUE)
y_bound_up <- max(0, Data_df$Apr21_Bs, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Reference Line")
col_2 <- bquote("Fut. Apr. 21 Basis")
col_3 <- bquote("Regression Line")
col_4 <- bquote("LOESS Curve")
leg_0_lab <- col_1
leg_0_col <- c("col_1"="red")
leg_0_line_type <- c("y_1_col"="solid")
leg_labs <- c(col_2, col_3, col_4)
leg_cols <- c("col_2"="green", "col_3"="blue", "col_4"="black")
leg_sort <- c("col_2", "col_3", "col_4")
Gold_Spot_Apr_21_Fut_Basis_sp <- ggplot(Data_df) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Apr21_Bs, color="col_2"), na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_3"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Apr21_Bs, color="col_4"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("blank", "solid", "dashed"),
                                                           shape = c(16, NA, NA)))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Apr_21_Fut_Basis_sp)

# The line plot

title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plot of April 2021 Gold Future Basis from ", .(First_Day), " to ", .(Last_Day))))
Gold_Spot_Apr_21_Fut_Basis_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_2", group=1)) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_3"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Apr21_Bs, color="col_4"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Apr_21_Fut_Basis_lp)


# December the 29th

Data_df <- Spot_Fut_df
length <- length(na.omit(Data_df$Spot))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plot of December 2021 Gold Future Basis from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA - ", .(link_1), " and Yahoo Finance  -  ", .(link_2)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("spot and future prices")
y_breaks_num <- 10
y_bound_low <- min(0, Data_df$Dec21_Bs, na.rm=TRUE)
y_bound_up <- max(0, Data_df$Dec21_Bs, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Reference Line")
y5_col <- bquote("Gold Dec. 21 Basis")
col_3 <- bquote("Regression Line")
col_4 <- bquote("LOESS Curve")
leg_0_lab <- col_1
leg_0_col <- c("col_1"="red")
leg_0_line_type <- c("y_1_col"="solid")
leg_labs <- c(y5_col, col_3, col_4)
leg_cols <- c(y5_col="magenta", "col_3"="blue", "col_4"="black")
leg_sort <- c("y5_col", "col_3", "col_4")
Gold_Spot_Dec_21_Fut_Basis_sp <- ggplot(Data_df) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Apr21_Bs, color="y5_col"), na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="col_3"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Dec21_Bs, color="col_4"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1))  +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("blank", "solid", "dashed"),
                                                           shape = c(16, NA, NA)))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Dec_21_Fut_Basis_sp)

# The line plot

title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plot of December 2021 Gold Future Basis from ", .(First_Day), " to ", .(Last_Day))))
Gold_Spot_Dec_21_Fut_Basis_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="y5_col", group=1)) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="col_3"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Dec21_Bs, color="col_4"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Dec_21_Fut_Basis_lp)


# We compare the two plots

Data_df <- Spot_Fut_df
length <- length(na.omit(Data_df$Spot))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plot of April and December 2021 Gold Future Basis from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA - ", .(link_1), " and Yahoo Finance  -  ", .(link_2)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("spot and future prices")
y_breaks_num <- 10
y_bound_low <- min(0, Data_df$Dec21_Bs, na.rm=TRUE)
y_bound_up <- max(0, Data_df$Dec21_Bs, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Reference Line")
col_2 <- bquote("Fut. Apr. 21 Basis")
col_3 <- bquote("Fut. Dec. 21 Basis")
col_4 <- bquote("Fut. Apr. 21 Regression Line")
y5_col <- bquote("Fut. Dec. 21 Regression Line")
y6_col <- bquote("Fut. Apr. 21 LOESS Curve")
y7_col <- bquote("Fut. Dec. 21 LOESS Curve")
leg_0_lab <- col_1
leg_0_col <- c("col_1"="red")
leg_0_line_type <- c("y_1_col"="solid")
leg_labs <- c(col_2, col_3, col_4, y5_col, y6_col, y7_col)
leg_cols <- c("col_2"="green", "col_3"="blue", "col_4"="black", 
              "y5_col"="brown", "y6_col"="magenta", "y7_col"="grey50")
leg_sort <- c("col_2", "y5_col", "col_3", "y6_col", "col_4", "y7_col")
Gold_Spot_Apr_Dec_21_Fut_Basis_sp <- ggplot(Data_df) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Apr21_Bs, color="col_2"), na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_3"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Apr21_Bs, color="col_4"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Dec21_Bs, color="y5_col"), na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="y6_col"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Dec21_Bs, color="y7_col"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("blank", "blank", "solid", "solid", "dashed", "dashed"),
                                                           shape = c(16, 16, NA, NA, NA, NA)))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Apr_Dec_21_Fut_Basis_sp)

# The line plot

title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plot of April and December 2021 Gold Future Basis from ", .(First_Day), " to ", .(Last_Day))))
Gold_Spot_Apr_Dec_21_Fut_Basis_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, color="red", aes(x=Index, y=0, linetype="y_1_col", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_2", group=1)) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Apr21_Bs, color="col_3"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Apr21_Bs, color="col_4"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="y5_col", group=1)) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=Dec21_Bs, color="y6_col"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=Dec21_Bs, color="y7_col"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("solid", "solid", "solid", "solid", "dashed", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Gold_Spot_Apr_Dec_21_Fut_Basis_lp)

# At the beginning of the time series of gold spot prices and futures, we can observe the so called "contango" 
# pricing structure: the bases are clearly positive, that is future prices are constantly higer than spot prices.
# According to the formula $F_{t,T} = \left(1+r_{t,T}\right)S_{t}$, future prices should actually be higher than 
# spot prices. However, considering the very low risk free return rate in the period that we are considering,
# the difference is much higher than expected. 
# The terms which might be responsible for the high difference are carrying costs. 
# Carrying costs are the storage costs, the insurance costs and other types of costs
# that the seller of the future contract incurrs from the sale date to the delivery date of the commodity.
# Nevertheless, carrying cost cannot explain the variability of the difference.
# Such a variability suggests the presence of noise in the future market. 
# Furthermore, the rather good synchronization between futures with different delivery dates suggests that 
# this noise should be due mainly to uncertainty about future expectations.
# Note that at the end of the time series the relevance of the carrying cost clearly decreases and the erraticity of
# future expectations can lead the bases below the zero level.

# We draw also a plot of the supposed risk free rates

# The scatter plot
Data_df <- Spot_Fut_df
length <- length(na.omit(Data_df$Spot))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plots of Annual Risk Free Rates of Return by Gold and Futures Spot Prices Naive Formula from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA - ", .(link_1), " and Yahoo Finance  -  ", .(link_2)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=50)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("risk free return rate")
y_breaks_num <- 10
y_bound_low <- min(Data_df$Apr21_ARR, Data_df$Jun21_ARR, Data_df$Aug21_ARR, Data_df$Oct21_ARR, Data_df$Dec21_ARR, na.rm=TRUE)
y_bound_up <- max(Data_df$Apr21_ARR, Data_df$Jun21_ARR, Data_df$Aug21_ARR, Data_df$Oct21_ARR, Data_df$Dec21_ARR, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
# y_breaks <- seq(from=y_bound_low, to=y_bound_up, length.out=y_breaks_num)
y_labs <- label_percent(accuracy = 0.01)(y_breaks)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Apr21 Perc ARR")
col_2 <- bquote("Jun21 Perc ARR")
col_3 <- bquote("Aug21 Perc ARR")
col_4 <- bquote("Oct21 Perc ARR")
y5_col <- bquote("Dec21 Perc ARR")
leg_labs <- c(col_1, col_2, col_3, col_4, y5_col)
leg_cols <- c("col_1"="red", "col_2"="green", "col_3"="blue", "col_4"="black", y5_col="magenta")
leg_sort <- c("col_1", "col_2", "col_3", "col_4", "y5_col")
Annual_Risk_Free_Rates_sp <- ggplot(Data_df) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Apr21_ARR, color="col_1"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Jun21_ARR, color="col_2"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Aug21_ARR, color="col_3"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Oct21_ARR, color="col_4"), na.rm=TRUE) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=Dec21_ARR, color="y5_col"), na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Annual_Risk_Free_Rates_sp)

# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plots of Annual Risk Free Rates of Return by Gold and Futures Spot Prices Naive Formula from ", .(First_Day), " to ", .(Last_Day))))
Annual_Risk_Free_Rates_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Apr21_ARR, color="col_1", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Jun21_ARR, color="col_2", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Aug21_ARR, color="col_3", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Oct21_ARR, color="col_4", group=1)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=Dec21_ARR, color="y5_col", group=1)) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_cols, breaks=leg_sort) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Annual_Risk_Free_Rates_lp)

# A more accurate formula for the relationship between future and spot prices prescribes that
# $F_{t,T} = \left(1+r_{t,T}\right)S_{t}-\left(\gamma_{t,T}-\kappa_{t,T}\right)$,
# where $\gamma_{t,T}$ is the capitalized flow of the marginal convenience yield for holding the commodity over 
# the period from $t$ to $T$, and $\kappa_{t,T}$ is the per-unit cost of physical storage from $t$ to $T$.

# Assume we have two futures at $t$ with delivery dates $T_{1}$ and $T_{2}$, where $T_{2}>T_{1}$. 
# We can write
# \[
# F_{t,T_{j}}=\left(1+r_{t,T_{j}}\right)S_{t}-\left(\gamma_{t,T_{j}}-\kappa_{t,T_{j}}\right),\quad j=1,2.
# \]
# Assume that
# \[
# \kappa_{t,T_{j}}\equiv\kappa\left(T_{j}-t\right),\quad j=1,2,
#  \]
# for some constant $\kappa>0$. Assume also that
# \[
#  r_{t,T_{j}}\equiv e^{\rho\left(T_{j}-t\right)}-1,\quad j=1,2,
#  \]
# where
# \[
# \rho\equiv\log\left(1+r_{a}\right),
# \]
# is the continuous time annual risk free rate equivalent to a constant annual risk free rate $r_{a}$, that is
# \[
#  \left(1+r_{a}\right)^{t}=e^{\rho\left(t\right)},
# \]
# where $t$ is expressed in years. In the end, assume that
# \[
#  \gamma_{t,T_{j}}\equiv\gamma\left(T_{j}-t\right),\quad j=1,2,
#  \]
# for some constant $\gamma>0$. We can write
# \[
#  F_{t,T_{j}}=e^{\rho\left(T_{j}-t\right)}S_{t}
# -\left(\gamma-\kappa\right)\left(T_{j}-t\right),\quad j=1,2.
#  \]
# Therefore,
# \begin{align*}
# F_{t,T_{2}}-F_{t,T_{1}} & =\left(e^{\rho\left(T_{2}-t\right)}
# -e^{\rho\left(T_{1}-t\right)}\right)S_{t}-\left(\gamma-\kappa\right)\left(T_{2}-T_{1}\right)\\
# & =\left(1-e^{-\rho\left(T_{2}-T_{1}\right)}\right)e^{\rho\left(T_{2}-t\right)}S_{t}
# -\left(\gamma-\kappa\right)\left(T_{2}-T_{1}\right)
# \end{align*}
# Setting
# \[
#  F_{t,T_{2}}-F_{t,T_{1}}\equiv F_{t}
# \]
# we have
# \[
# F_{t}=\left(1-e^{-\rho\left(T_{2}-T_{1}\right)}\right)e^{\rho\left(T_{2}-t\right)}S_{t}
# -\left(\gamma-\kappa\right)\left(T_{2}-T_{1}\right).
# \]
# Hence,
# \begin{align*}
# F_{t+1}-F_{t}  
# &=e^{\rho\left(T_{2}-\left(t+1\right)\right)}\left(1-e^{-\rho\left(T_{2}-T_{1}\right)}\right)S_{t+1}
# -e^{\rho\left(T_{2}-t\right)}\left(1-e^{-\rho\left(T_{2}-T_{1}\right)}\right)S_{t}\\
# & =\left(1-e^{-\rho\left(T_{2}-T_{1}\right)}\right)
# \left(e^{\rho\left(T_{2}-\left(t+1\right)\right)}S_{t+1}-e^{\rho\left(T_{2}-t\right)}S_{t}\right)\\
# & =\left(1-e^{-\rho\left(T_{2}-T_{1}\right)}\right)e^{\rho\left(T_{2}-t\right)}
# \left(  e^{-\rho}S_{t+1}-S_{t}\right).
# \end{align*}

# In the end, we can hope to estimate $\rho$ by a non linear regression. 

#####################################################################################################################
# We create a suitable data frame to study the first regression.

F <- Spot_Fut_df$Dec21_Fut-Spot_Fut_df$Apr21_Fut
Diff_T <- Spot_Fut_df$Dec21_Fut_YtM-Spot_Fut_df$Apr21_Fut_YtM
S <- Spot_Fut_df$S
NL_Regr_df <- data.frame(Index=Spot_Fut_df$Index, Date=Spot_Fut_df$Date, t=Spot_Fut_df$Dec21_Fut_YtM, 
                         S=Spot_Fut_df$Spot, F=F)
head(NL_Regr_df)

Est_df <- na.exclude(NL_Regr_df)
Est_Par <- vector(mode="list", length=0)
SUCCESS_def_df <- data.frame(matrix(nrow=0, ncol=8))
SUCCESS_def_df <-  rename(SUCCESS_def_df, try_num=X1, init_r=X2, init_K=X3, RSE=X4, AIC=X5, BIC=X6, fin_r=X7, fin_K=X8)
# Res_SUCCESS_def_df <- data.frame(matrix(nrow=nrow(Est_df), ncol=0))
Res_SUCCESS_def_df <- data.frame(Index=1:nrow(Est_df),Date=Est_df$Date)
con <- file("estimate.log")
sink(con, append=TRUE, type=c("output","message"), split=TRUE)
# library(nlstools)
for(n in 1:100){
  tryCatch(
    expr={
      init_r=runif(1, min=0,max=0.1)
      init_K=runif(1, min=-100,max=1000)
      print(n)
      show(c(round(init_r,4), round(init_K,4)))
      NLS_Est <- nls(F ~ exp(r*t)*(1-exp(-r*Diff_T[1]))*S-K*Diff_T[1], data=Est_df, 
                    start=list(r=init_r, K=init_K), trace=TRUE, algorithm="default", 
                    control=list(maxiter = 1000, tol = 1e-06))
      message("SUCCESS!")
      Est_Par[[length(Est_Par)+1]] <- NLS_Est
      SUCCESS_def_df[nrow(SUCCESS_def_df)+1,] <- c(n, init_r, init_K, 
                                         summary(NLS_Est)$sigma, AIC(NLS_Est), BIC(NLS_Est),
                                         summary(NLS_Est)$coefficients[1, 1], summary(NLS_Est)$coefficients[2, 1])
      Res_SUCCESS_def_df[,ncol(Res_SUCCESS_def_df)+1] <- nlsResiduals(NLS_Est)$resi1[,2]
    }, error=function(e){cat("ERROR: ", conditionMessage(e), "\n")})
}
sink()
print(SUCCESS_def_df)
print(Res_SUCCESS_def_df)
write.csv(SUCCESS_def_df, "Success.csv", row.names=FALSE)
write.csv(Res_SUCCESS_def_df, "Res_Succes.csv", row.names=FALSE)

#####################################################################################################################
# We plot the residuals of the regression
# The scatter plot
Data_df <- Res_SUCCESS_def_df
length <- length(na.omit(Data_df$V3))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plot of the Residuals from the Non Linear Estimate of the Risk Free Rate from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA (", .(link_1), ") and Yahoo Finance (", .(link_2),")"))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=35)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Residuals")
y_breaks_num <- 10
y_bound_low <- min(0, Data_df$V3, na.rm=TRUE)
y_bound_up <- max(0, Data_df$V3, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Residuals")
col_2 <- bquote("Regression Line")
col_3 <- bquote("LOESS Curve")
leg_labs <- c(col_1, col_2, col_3)
leg_cols <- c(col_1="blue", "col_2"="green", "col_3"="red")
leg_sort <- c("col_1", "col_2", "col_3")
Est_Par_Res_sp <- ggplot(Data_df) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=V3, color="col_1"), na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=V3, color="col_2"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=V3, color="col_3"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1))  +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("blank", "solid", "dashed"),
                                                                    shape = c(16, NA, NA)))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Est_Par_Res_sp)

# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plot of the Residuals from the Non Linear Estimate of the Risk Free Rate from ", .(First_Day), " to ", .(Last_Day))))
Est_Par_Res_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=V3, color="col_1", group=1)) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=V3, color="col_2"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=V3, color="col_3"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Est_Par_Res_lp)

# Can we assess that the above residuals constitute the realisation of some (Gaussian) white noise?

#####################################################################################################################
# We create a suitable data frame to study the second regression.

F <- Spot_Fut_df$Dec21_Fut-Spot_Fut_df$Apr21_Fut
Diff_F <- c(diff(F, lag= 1, differences=1))
# length(Diff_F)
S=Spot_Fut_df$Spot
S_2 <- c(S[-1])
# length(S_2)
S_1 <- c(S[-length(S)])
# length(S_1)
t <- Spot_Fut_df$Dec21_Fut_YtM[-length(Spot_Fut_df$Dec21_Fut_YtM)]
# length(t)
Diff_T <- Spot_Fut_df$Dec21_Fut_YtM-Spot_Fut_df$Apr21_Fut_YtM
NL_Regr_II_df <- data.frame(Index=1:length(Diff_F), Date=Spot_Fut_df$Date[-1], t=t, S_1=S_1, S_2=S_2, Diff_F=Diff_F)
head(NL_Regr_II_df)

Est_df <- na.exclude(NL_Regr_II_df)
Est_Par <- vector(mode="list", length=0)
SUCCESS_II_def_df <- data.frame(matrix(nrow=0, ncol=6))
SUCCESS_II_def_df <-  rename(SUCCESS_II_def_df, try_num=X1, init_r=X2, RSE=X3, AIC=X4, BIC=X5, fin_r=X6)
Res_SUCCESS_II_def_df <- data.frame(Index=1:nrow(Est_df),Date=Est_df$Date)
con <- file("estimate.log")
sink(con, append=TRUE, type=c("output","message"), split=TRUE)
# library(nlstools)
for(n in 1:100){
  tryCatch(
    expr={
      init_r=runif(1, min=0,max=0.1)
      print(n)
      show(c(round(init_r,4)))
      NLS_Est <- nls(Diff_F ~ (1-exp(-r*Diff_T[1]))*exp(r*t)*(exp(-r)*S_2-S_1), data=Est_df, 
                     start=list(r=init_r), trace=TRUE, algorithm="default", 
                     control=list(maxiter = 1000, tol = 1e-09))
      message("SUCCESS!")
      Est_Par[[length(Est_Par)+1]] <- NLS_Est
      SUCCESS_II_def_df[nrow(SUCCESS_II_def_df)+1,] <- c(n, init_r, 
                                                         summary(NLS_Est)$sigma, AIC(NLS_Est), BIC(NLS_Est),
                                                         summary(NLS_Est)$coefficients[1, 1])
      Res_SUCCESS_II_def_df[,ncol(Res_SUCCESS_II_def_df)+1] <- nlsResiduals(NLS_Est)$resi1[,2]
    }, error=function(e){cat("ERROR: ", conditionMessage(e), "\n")})
}
sink()
print(SUCCESS_II_def_df)
print(Res_SUCCESS_II_def_df)
write.csv(SUCCESS_II_def_df, "Success.csv", row.names=FALSE)
write.csv(Res_SUCCESS_II_def_df, "Res_Succes.csv", row.names=FALSE)

#####################################################################################################################v
# We plot the residuals of the regression
# The scatter plot
Data_df <- Res_SUCCESS_II_def_df
length <- length(na.omit(Data_df$V3))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Scatter Plot of the Residuals from the II Non Linear Estimate of the Risk Free Rate from ", .(First_Day), " to ", .(Last_Day))))
link_1 <- "https://www.lbma.org.uk"
link_2 <- "https://finance.yahoo.com"
subtitle_content <- bquote(paste("Path length ", .(length), " sample points. Data from LBMA (", .(link_1), ") and Yahoo Finance (", .(link_2),")"))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("dates")
x_breaks_low <- min(Data_df$Index)
x_breaks_up <- max(Data_df$Index)
x_breaks <- seq(from=x_breaks_low, to=x_breaks_up, by=35)
x_binwidth <- x_breaks[2]-x_breaks[1]
x_labs <- as.character(Data_df$Date[x_breaks])
J <- 0
x_lims <- c(x_breaks_low-J*x_binwidth, x_breaks_up+J*x_binwidth)
y_name <- bquote("Residuals")
y_breaks_num <- 10
y_bound_low <- min(0, Data_df$V3, na.rm=TRUE)
y_bound_up <- max(0, Data_df$V3, na.rm=TRUE)
y_binwidth <- round((y_bound_up-y_bound_low)/y_breaks_num, digits=3)
y_breaks_low <- floor(y_bound_low/y_binwidth)*y_binwidth
y_breaks_up <- ceiling(y_bound_up/y_binwidth)*y_binwidth
y_breaks <- round(seq(from=y_breaks_low, to=y_breaks_up, by=y_binwidth),3)
y_labs <- format(y_breaks, scientific=FALSE)
K <- 0
y_lims <- c((y_breaks_low-K*y_binwidth), (y_breaks_up+K*y_binwidth))
col_1 <- bquote("Residuals")
col_2 <- bquote("Regression Line")
col_3 <- bquote("LOESS Curve")
leg_labs <- c(col_1, col_2, col_3)
leg_cols <- c(col_1="blue", "col_2"="green", "col_3"="red")
leg_sort <- c("col_1", "col_2", "col_3")
Est_Par_II_Res_sp <- ggplot(Data_df) +
  geom_point(alpha=1, size=0.9, shape=19, aes(x=Index, y=V3, color="col_1"), na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=V3, color="col_2"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=V3, color="col_3"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, labels=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1))  +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("blank", "solid", "dashed"),
                                                                    shape = c(16, NA, NA)))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Est_Par_II_Res_sp)

# The line plot
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - Corso di Metodi Probabilistici e Statistici per i Mercati Finanziari", 
                             paste("Line Plot of the Residuals from the II Non Linear Estimate of the Risk Free Rate from ", .(First_Day), " to ", .(Last_Day))))
Est_Par_II_Res_lp <- ggplot(na.omit(Data_df)) +
  geom_line(alpha=1, size=0.5, linetype="solid", aes(x=Index, y=V3, color="col_1", group=1)) +
  geom_smooth(alpha=1, size = 0.5, linetype="solid", aes(x=Index, y=V3, color="col_2"),
              method = "lm" , formula = y ~ x, se=FALSE, fullrange=TRUE, na.rm=TRUE) +
  geom_smooth(alpha=1, size = 0.8, linetype="dashed", aes(x=Index, y=V3, color="col_3"),
              method = "loess", formula = y ~ x, se=FALSE, na.rm=TRUE) +
  scale_x_continuous(name=x_name, breaks=x_breaks, label=x_labs, limits=x_lims) +
  scale_y_continuous(name=y_name, breaks=y_breaks, labels=NULL, limits=y_lims,
                     sec.axis = sec_axis(~., breaks = y_breaks, labels=y_labs)) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  scale_linetype_manual(name="", labels=leg_0_lab, values=leg_0_line_type, guide=guide_legend(order=1)) +
  scale_colour_manual(name="", labels=leg_labs, values=leg_cols, breaks=leg_sort,
                      guide=guide_legend(order=2, override.aes=list(linetype=c("solid", "solid", "dashed")))) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0.5),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="bottom")
plot(Est_Par_II_Res_lp)

# Can we assess that the above residuals constitute the realization of some (Gaussian) white noise?

#####################################################################################################################
#####################################################################################################################