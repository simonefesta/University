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
# Reading libraries
library(base)
library(stats)
library(readxl)
library(rlist)
library(tibble)
library(dplyr)
library(tidyverse)
library("data.table")

library(reshape2)
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
#
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
# Note that in the above data frames, the temporal ordering of the rows against the row names is decreasing: following 
# the order of the row names the rows go from the most recent to the least recent.
# However, for our purposes, it is more convenient to dispose of data in increasing temporal order (from the least 
# recent to the most recent). Therefore, we invert the temporal order of the rows in the data frames.
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
# Note also that the "four months daily treasury rate" is reported in the column *X4.Mo* only from the year 2022.
# More precisely, the "four months daily treasury rate" is reported from the day
US_DTR_2022_df$Date[min(which(!is.na(US_DTR_2022_df$X4.Mo)))]
# as it clearly appears by observing the data frame *US_DTR_2022_df* in the vicinity of the above determined day.
show(US_DTR_2022_df[(min(which(!is.na(US_DTR_2022_df$X4.Mo)))-5):(min(which(!is.na(US_DTR_2022_df$X4.Mo)))+5),])
# Therefore, with the goal of merging the different data frames into a single one, we add a *X4.Mo* column with *NA* entries
# to the data frames *US_DTR_2020_df* and *US_DTR_2021_df*.
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
head(US_DTR_2020_2023_df)
tail(US_DTR_2020_2023_df)
######################################################################################################################
######################################################################################################################
# To draw a plot of the Treasury Yield Curve Rates, we need to manipulate the data frame *US_DTR_2020_2023_df*.
# First, we extract some rows (e.g., from March 27th to April 7th 2023) from the data frame, rename the rows, and delete 
# the Date column.
init_date  <- which(US_DTR_2020_2023_df$Date=="2023-03-27")
final_date <- which(US_DTR_2020_2023_df$Date=="2023-04-07")
sel_rows <- seq.int(from=init_date, to=final_date, by=1)
sel_US_DTR_2020_2023_df <- US_DTR_2020_2023_df[sel_rows,]
show(sel_US_DTR_2020_2023_df)
rownames(sel_US_DTR_2020_2023_df) <- seq(from=1, to=nrow(sel_US_DTR_2020_2023_df))
sel_US_DTR_2020_2023_df$Date <- NULL
show(sel_US_DTR_2020_2023_df)
#
# Second, we change the data frame in a data table
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
rsh_sel_US_DTR_2020_2023_tb <- add_column(rsh_sel_US_DTR_2020_2023_tb, 
                                        Index=rep(1:nrow(sel_US_DTR_2020_2023_df), times=ncol(sel_US_DTR_2020_2023_df)),
                                        Date=rep(US_DTR_2020_2023_df$Date[sel_rows], times=ncol(sel_US_DTR_2020_2023_df)),
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
leg_labs <- as.character(US_DTR_2020_2023_df$Date[sel_rows])
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
                                          Date=rep(US_DTR_2020_2023_df$Date[sel_rows], times=ncol(sel_US_DTR_2020_2023_df)),
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
leg_labs <- as.character(US_DTR_2020_2023_df$Date[sel_rows])
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
#
# Interpolating the NA value we the plot can be drawn as follows
show(rsh_sel_US_DTR_2020_2023_tb[20:52,])
as.vector(which(is.na(Data_df$value)))
NA_length <- length(as.vector(which(is.na(Data_df$value))))
#
(as.vector(which(is.na(Data_df$value)))-NA_length)[1]
(as.vector(which(is.na(Data_df$value)))+NA_length)[1]
#
(as.vector(which(is.na(Data_df$value)))-NA_length)[2]
(as.vector(which(is.na(Data_df$value)))+NA_length)[2]
#
# ...
#
Data_df$variable[(as.vector(which(is.na(Data_df$value)))- NA_length)[1]]
Data_df$value[(as.vector(which(is.na(Data_df$value)))-NA_length)[1]]
Data_df$variable[as.vector(which(is.na(Data_df$value))+NA_length)[1]]
Data_df$value[as.vector(which(is.na(Data_df$value))+NA_length)[1]]
# ...
Data_df$variable[(as.vector(which(is.na(Data_df$value)))- NA_length)[6]]
Data_df$value[(as.vector(which(is.na(Data_df$value)))-NA_length)[6]]
Data_df$variable[as.vector(which(is.na(Data_df$value))+NA_length)[6]]
Data_df$value[as.vector(which(is.na(Data_df$value))+NA_length)[6]]
# ...
#
Data_df <- rsh_sel_US_DTR_2020_2023_tb
length <- ncol(sel_US_DTR_2020_2023_df)
NA_length <- length(as.vector(which(is.na(Data_df$value))))
First_Day <- as.character(Data_df$Date[1])
Last_Day <- as.character(last(Data_df$Date))
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plots of U.S. Treasury Yield Curve Rates (business days from ", .(First_Day), " to ", .(Last_Day),")")))
link <- "https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics"
subtitle_content <- bquote(paste("path length ", .(length), " sample points. Data by courtesy of  U.S. Department of the Treasure  -  ", .(link)))
caption_content <- "Author: Roberto Monte"
x_name <- bquote("expiration dates")
leg_labs <- as.character(US_DTR_2020_2023_df$Date[sel_rows])
# leg_vals <- levels(factor(Data_df$Index))
leg_vals <- rainbow(length(levels(factor(Data_df$Index))))[as.numeric(levels(factor(Data_df$Index)))]
US_DTR_01_04_01_15_2021_Interp_Curve_Rate_lp <- ggplot(Data_df, aes(x=variable, y=value, group=factor(Index))) + 
  geom_line(aes(color=factor(Index)), linewidth=0.8, linetype="solid") +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[1]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[1]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[1]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[1]], 
                   color=factor(Index)[1]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[2]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[2]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[2]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[2]], 
                   color=factor(Index)[2]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[3]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[3]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[3]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[3]], 
                   color=factor(Index)[3]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[4]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[4]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[4]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[4]], 
                   color=factor(Index)[4]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[5]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[5]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[5]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[5]], 
                   color=factor(Index)[5]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[6]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[6]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[6]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[6]], 
                   color=factor(Index)[6]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[7]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[7]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[7]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[7]], 
                   color=factor(Index)[7]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[8]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[8]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[8]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[8]], 
                   color=factor(Index)[8]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[9]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[9]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[9]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[9]], 
                   color=factor(Index)[9]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  geom_segment(aes(x=variable[(as.vector(which(is.na(value)))-NA_length)[10]], 
                   y=value[(as.vector(which(is.na(value)))-NA_length)[10]], 
                   xend=variable[(as.vector(which(is.na(value)))+NA_length)[10]], 
                   yend=value[(as.vector(which(is.na(value)))+NA_length)[10]], 
                   color=factor(Index)[10]), linetype="dashed", alpha=1, linewidth=1, group=1) +
  ggtitle(title_content) +
  labs(subtitle=subtitle_content, caption=caption_content) +
  xlab("time to maturity") + ylab("yield rates") +
  scale_colour_manual(name="Legend", labels=leg_labs, values=leg_vals) +
  theme(plot.title=element_text(hjust=0.5), plot.subtitle=element_text(hjust=0),
        axis.text.x = element_text(angle=0, vjust=1),
        legend.key.width = unit(0.80,"cm"), legend.position="right")
plot(US_DTR_01_04_01_15_2021_Interp_Curve_Rate_lp)
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
                                  Perc.Rate.of.Ret.at.Maturity=label_percent(accuracy = 0.001)((100-US_SP_2023_01_03_df$End.of.Day)/US_SP_2023_01_03_df$End.of.Day),
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
                                  Perc.Ann.Rate.of.Ret=label_percent(accuracy = 0.001)((1+US_SP_2023_01_03_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_01_03_df$Years.to.Maturity)-1),
                                  .after="Perc.Rate.of.Ret.at.Maturity")
show(US_SP_2023_01_03_df[1:15,])
#####################################################################################################################
# Still, we compute the Treasury Yield Rates from the prices of Market Based Bills
# https://www.treasurydirect.gov/GA-FI/FedInvest/selectSecurityPriceDate
# We build a data frame with data from the "securityprice-2023-04-11.csv" file.
US_SP_2023_04_11_df <- read.csv("securityprice-2023-04-11.csv", header=FALSE)
show(US_SP_2023_04_11_df[1:15,])
# We rename the columns according to the terminology in https://www.treasurydirect.gov/GA-FI/FedInvest/selectSecurityPriceDate.
US_SP_2023_04_11_df <- rename(US_SP_2023_04_11_df, CUSIP=V1, Security.Type=V2, Rate=V3, Maturity.Date=V4,
                              Call.Date=V5, Buy=V6, Sell=V7, End.of.Day=V8)
head(US_SP_2023_04_11_df)
# We check whether the Maturity.Date column is in "Date" format. In case it is not, we change the format to "Date".
class(US_SP_2023_04_11_df$Maturity.Date)
US_SP_2023_04_11_df$Maturity.Date <- as.Date(US_SP_2023_04_11_df$Maturity.Date,  format="%m/%d/%Y")
show(US_SP_2023_04_11_df[1:15,])
# We add a column *Days.to.Maturity*, which accounts for the number of days from January 1st, 2023, to the Maturity Date
US_SP_2023_04_11_df <- add_column(US_SP_2023_04_11_df, 
                                  Days.to.Maturity=as.vector(difftime(US_SP_2023_04_11_df$Maturity.Date, as.Date(as.character("2023-04-11")), units="days")), 
                                  .after="Maturity.Date")
show(US_SP_2023_04_11_df[1:15,])
# We also add the column *Months.to.Maturity* [resp. *Years.to.Maturity*], which accounts for the number of months 
# [resp. years] from January 1st, 2023, to the Maturity Date.
US_SP_2023_04_11_df <- add_column(US_SP_2023_04_11_df, 
                                  Months.to.Maturity=as.vector(US_SP_2023_04_11_df$Days.to.Maturity/30.4369),
                                  Years.to.Maturity=as.vector(US_SP_2023_04_11_df$Days.to.Maturity/365.2425),
                                  .after="Days.to.Maturity")
show(US_SP_2023_04_11_df[1:15,])
# We add a column *Rate.of.Return.at.Maturity* and *Perc.Rate.of.Return.at.Maturity*
US_SP_2023_04_11_df <- add_column(US_SP_2023_04_11_df, 
                                  Rate.of.Ret.at.Maturity=(100-US_SP_2023_04_11_df$End.of.Day)/US_SP_2023_04_11_df$End.of.Day,
                                  Perc.Rate.of.Ret.at.Maturity=label_percent(accuracy = 0.001)((100-US_SP_2023_04_11_df$End.of.Day)/US_SP_2023_04_11_df$End.of.Day),
                                  .after="End.of.Day")
show(US_SP_2023_04_11_df[1:15,])
#
# We compute the annual rate of return according to the formulas
# (1+r_a)^t=1+r_t; r_a=(1+r_t)^(1/t)-1
# where r_a=annual rate of return, t=time to maturity (in years), r_t=rate of return in the period t.
# or 
# (1+r_a)^(t/365.2425)=1+r_t; r_a=(1+r_t)^(365.2425/t)-1
# where r_a=annual rate of return, t=time to maturity (in days), r_t=rate of return in the period t.
#
Annual.Rate.of.Ret_01 <- (1+US_SP_2023_04_11_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_04_11_df$Years.to.Maturity)-1
show(Annual.Rate.of.Ret_01)
Annual.Rate.of.Ret_02 <- (1+US_SP_2023_04_11_df$Rate.of.Ret.at.Maturity)^(365.2425/US_SP_2023_04_11_df$Days.to.Maturity)-1
show(Annual.Rate.of.Ret_02)
Annual.Rate.of.Ret_01==Annual.Rate.of.Ret_02
# We add a column *Ann.Rate.of.Return* and *Perc.Ann.Rate.of.Return*
US_SP_2023_04_11_df <- add_column(US_SP_2023_04_11_df, 
                                  Ann.Rate.of.Ret=(1+US_SP_2023_04_11_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_04_11_df$Years.to.Maturity)-1,
                                  Perc.Ann.Rate.of.Ret=label_percent(accuracy = 0.001)((1+US_SP_2023_04_11_df$Rate.of.Ret.at.Maturity)^(1/US_SP_2023_04_11_df$Years.to.Maturity)-1),
                                  .after="Perc.Rate.of.Ret.at.Maturity")
show(US_SP_2023_04_11_df[1:30,])
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
#
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
write.csv(SPX_Opt_2023_06_16_df,"/Users/festinho/Desktop/University/University/MPSMF/Time Series in R/SPX_Option_Chain_2023_06_16.csv")
dir("/Users/festinho/Desktop/University/University/MPSMF/Time Series in R")
write.csv(SPX_Opt_2023_06_16_df,"/Users/festinho/Desktop/University/University/MPSMF/Time Series in R/SPX_Option_Chain_2023_06_16.csv")
dir("/Users/festinho/Desktop/University/University/MPSMF/Time Series in R")
#
Call_LastTrDate_df <- data.frame(Call_LastTrDate=as.Date(SPX_Opt_2023_06_16_df$Call_LastTrTime))
class(Call_LastTrDate_df)
head(Call_LastTrDate_df,20)
nrow(Call_LastTrDate_df)
Call_LastTrDate_tb <- table(Call_LastTrDate_df)   
class(Call_LastTrDate_tb)
show(Call_LastTrDate_tb)
#
Put_LastTrDate_df <- data.frame(Put_LastTrDate=as.Date(SPX_Opt_2023_06_16_df$Put_LastTrTime))
class(Put_LastTrDate_df)
head(Put_LastTrDate_df,20)
nrow(Put_LastTrDate_df)
Put_LastTrDate_tb <- table(Put_LastTrDate_df)   
class(Put_LastTrDate_tb)
show(Put_LastTrDate_tb)
#
Call_LastTrDate_2023_04_11_Indx <- SPX_Opt_2023_06_16_df$Indx[which(Call_LastTrDate_df$Call_LastTrDate=="2023-04-11")]
show(Call_LastTrDate_2023_04_11_Indx)
length(Call_LastTrDate_2023_04_11_Indx)
Put_LastTrDate_2023_04_11_Indx <- SPX_Opt_2023_06_16_df$Indx[which(Put_LastTrDate_df$Put_LastTrDate=="2023-04-11")]
show(Put_LastTrDate_2023_04_11_Indx)
length(Put_LastTrDate_2023_04_11_Indx)
Call_Put_2023_04_11_Indx <- intersect(Call_LastTrDate_2023_04_11_Indx, Put_LastTrDate_2023_04_11_Indx)
show(Call_Put_2023_04_11_Indx)
length(Call_Put_2023_04_11_Indx)
# 34
#
Call_LastTrDate_2023_04_10_Indx <- SPX_Opt_2023_06_16_df$Indx[which(Call_LastTrDate_df$Call_LastTrDate=="2023-04-10")]
show(Call_LastTrDate_2023_04_10_Indx)
length(Call_LastTrDate_2023_04_10_Indx)
Put_LastTrDate_2023_04_10_Indx <- SPX_Opt_2023_06_16_df$Indx[which(Put_LastTrDate_df$Put_LastTrDate=="2023-04-10")]
show(Put_LastTrDate_2023_04_10_Indx)
length(Put_LastTrDate_2023_04_10_Indx)
Call_Put_2023_04_10_Indx <- intersect(Call_LastTrDate_2023_04_10_Indx, Put_LastTrDate_2023_04_10_Indx)
show(Call_Put_2023_04_10_Indx)
length(Call_Put_2023_04_10_Indx)
# 5
#
Call_LastTrDate_2023_04_06_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrDate)=="2023-04-06")]
show(Call_LastTrDate_2023_04_06_Indx)
Put_LastTrDate_2023_04_06_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrDate)=="2023-04-06")]
show(Put_LastTrDate_2023_04_06_Indx)
Call_Put_2023_04_06_Indx <- intersect(Call_LastTrDate_2023_04_06_Indx, Put_LastTrDate_2023_04_06_Indx)
show(Call_Put_2023_04_06_Indx)
length(Call_Put_2023_04_06_Indx)
# 0
#
Call_LastTrDate_2023_04_06_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrDate)=="2023-04-06")]
show(Call_LastTrDate_2023_04_06_Indx)
Put_LastTrDate_2023_04_06_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrDate)=="2023-04-06")]
show(Put_LastTrDate_2023_04_06_Indx)
Call_Put_2023_04_06_Indx <- intersect(Call_LastTrDate_2023_04_06_Indx, Put_LastTrDate_2023_04_06_Indx)
show(Call_Put_2023_04_06_Indx)
length(Call_Put_2023_04_06_Indx)
# 0
#
Call_LastTrDate_2023_04_05_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrDate)=="2023-04-05")]
show(Call_LastTrDate_2023_04_05_Indx)
Put_LastTrDate_2023_04_05_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrDate)=="2023-04-05")]
show(Put_LastTrDate_2023_04_05_Indx)
Call_Put_2023_04_05_Indx <- intersect(Call_LastTrDate_2023_04_05_Indx, Put_LastTrDate_2023_04_05_Indx)
show(Call_Put_2023_04_05_Indx)
length(Call_Put_2023_04_05_Indx)
# 0
#
Call_LastTrDate_2023_04_04_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Call_LastTrDate)=="2023-04-04")]
show(Call_LastTrDate_2023_04_04_Indx)
Put_LastTrDate_2023_04_04_Indx <- SPX_Opt_2023_06_16_df$Indx[which(as.Date(SPX_Opt_2023_06_16_df$Put_LastTrDate)=="2023-04-04")]
show(Put_LastTrDate_2023_04_04_Indx)
Call_Put_2023_04_04_Indx <- intersect(Call_LastTrDate_2023_04_04_Indx, Put_LastTrDate_2023_04_04_Indx)
show(Call_Put_2023_04_04_Indx)
length(Call_Put_2023_04_04_Indx)
#
# Put-Call parity
# P_0 = C_0 - S_0 + K/(1+r_f)
# C_0-P_0 = S_0 - K/(1+r_f)
#
x <- SPX_Opt_2023_06_16_df$Strike[Call_Put_2023_04_11_Indx]
show(x)
length(x)
y <- SPX_Opt_2023_06_16_df$Call_LastPr[Call_Put_2023_04_11_Indx]-SPX_Opt_2023_06_16_df$Put_LastPr[Call_Put_2023_04_11_Indx]
show(y)
length(y)
#
Data_df <- data.frame(x,y)
n <- nrow(Data_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plot of the Call-Put Difference Against the Strike Price")))
subtitle_content <- bquote(paste("Data set size",~~.(n),~~"sample points;    Evaluation Date 2023-04-11;   Maturity Date 2023-06-16"))
caption_content <- "Author: Roberto Monte" 
# To obtain the submultiples of the length of the data set as a hint on the number of breaks to use
# library(numbers)
# primeFactors(n)
x_breaks_num <- 17
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
# 4094.027
# SPX Market Price 4,108.94 -0.17 (-0.00%) At close: April 11 04:55PM EDT
#
r_f <- -(1/PutCall_par_lm$coefficients[2]+1)
show(r_f)
# 0.01144599
Days_to_Mat <- as.vector(difftime("2023-06-16", "2023-04-11"))
show(Days_to_Mat)
# 66
r_f_a=(1+r_f)^(365.2425/Days_to_Mat)-1
show(r_f_a)
# 0.06500779
label_percent(accuracy = 0.001)(r_f_a)
# 6.501%
#
# Put-Call parity
# P_0 = C_0 - S_0 + K/(1+r_f)
# C_0-P_0-S_0 = - K/(1+r_f)
#
x <- SPX_Opt_2023_06_16_df$Strike[Call_Put_2023_04_11_Indx]
show(x)
length(x)
y <- SPX_Opt_2023_06_16_df$Call_LastPr[Call_Put_2023_04_11_Indx]-SPX_Opt_2023_06_16_df$Put_LastPr[Call_Put_2023_04_11_Indx]-4108.94
show(y)
length(y)
#
Data_df <- data.frame(x,y)
n <- nrow(Data_df)
title_content <- bquote(atop("University of Roma \"Tor Vergata\" - \u0040 MPSMF 2022-2023", 
                             paste("Scatter Plot of the Call-Put Difference Adjusted by the Stock Price Against the Strike Price")))
subtitle_content <- bquote(paste("Data set size",~~.(n),~~"sample points;    Evaluation Date 2023-04-11;   Maturity Date 2023-06-16"))
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
Days_to_Mat <- as.vector(difftime("2023-06-16", "2023-04-11"))
show(Days_to_Mat)
# 66
r_f_a=(1+r_f)^(365.2425/Days_to_Mat)-1
show(r_f_a)
# 0.04317122
label_percent(accuracy = 0.001)(r_f_a)
# 4.317%
#
# This should be compared with the rate
# 4.828% 
# computed corresponding to a maturity of 65 days in the data frame *US_SP_2023_04_11_df*
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################