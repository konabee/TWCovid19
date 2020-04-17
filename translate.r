## This file was written by Chia Liu, for a collaborative project documenting COVID 19 cases and deaths globally by age (April 15, 2020) ## 

library(tidyverse)
library(readxl)

## weekly data source: (https://data.cdc.gov.tw/en/dataset/aagstable-weekly-19cov) ##
## monthly data source: (https://data.cdc.gov.tw/en/dataset/aagstable-19cov) ##

twcovidw<-read_excel('sourcefiles/Age_County_Gender_19Cov.xlsx', sheet='ByWeek')

## translate variables ##
colnames(twcovidw)<-c('Diagnosis','Year','week','Region','Sex','RecentTravelAbroad','Age','Cases')

## drop RecentTravelAbroad ##
twcovidw<-select(twcovidw,-c('RecentTravelAbroad'))

## translate values ##
twcovidw$Diagnosis[twcovidw$Diagnosis=='嚴重特殊傳染性肺炎']<-'COVID19'

twcovidw$Region[twcovidw$Region=='南投縣']<-'Nantou County'
twcovidw$Region[twcovidw$Region=='台中市']<-'Taichung City'
twcovidw$Region[twcovidw$Region=='台北市']<-'Taipei City'
twcovidw$Region[twcovidw$Region=='台南市']<-'Tainan City'
twcovidw$Region[twcovidw$Region=='嘉義市']<-'Chiayi City'
twcovidw$Region[twcovidw$Region=='嘉義縣']<-'Chiayi County'
twcovidw$Region[twcovidw$Region=='基隆市']<-'Keelung City'
twcovidw$Region[twcovidw$Region=='宜蘭縣']<-'Yilan County'
twcovidw$Region[twcovidw$Region=='屏東縣']<-'Pingtung County'
twcovidw$Region[twcovidw$Region=='彰化縣']<-'Changhua County'
twcovidw$Region[twcovidw$Region=='新北市']<-'New Taipei City'
twcovidw$Region[twcovidw$Region=='新竹市']<-'Hsinchu City'
twcovidw$Region[twcovidw$Region=='新竹縣']<-'Hsinchu County'
twcovidw$Region[twcovidw$Region=='桃園市']<-'Taoyuan City'
twcovidw$Region[twcovidw$Region=='苗栗縣']<-'Miaoli County'
twcovidw$Region[twcovidw$Region=='雲林縣']<-'Yunlin County'
twcovidw$Region[twcovidw$Region=='高雄市']<-'Kaohsiung City'

# twcovidw$RecentTravelAbroad[twcovidw$RecentTravelAbroad=='是']<-'yes'
# twcovidw$RecentTravelAbroad[twcovidw$RecentTravelAbroad=='否']<-'no'

twcovidw$Age[twcovidw$Age=='4']<-0
twcovidw$Age[twcovidw$Age=='5-9']<-5
twcovidw$Age[twcovidw$Age=='10-14']<-10
twcovidw$Age[twcovidw$Age=='15-19']<-15
twcovidw$Age[twcovidw$Age=='20-24']<-20
twcovidw$Age[twcovidw$Age=='25-29']<-25
twcovidw$Age[twcovidw$Age=='30-34']<-30
twcovidw$Age[twcovidw$Age=='35-39']<-35
twcovidw$Age[twcovidw$Age=='40-44']<-40
twcovidw$Age[twcovidw$Age=='45-49']<-45
twcovidw$Age[twcovidw$Age=='50-54']<-50
twcovidw$Age[twcovidw$Age=='55-59']<-55
twcovidw$Age[twcovidw$Age=='60-64']<-60
twcovidw$Age[twcovidw$Age=='65-69']<-65
twcovidw$Age[twcovidw$Age=='70+']<-70

## Create AgeInt, age interval, with highest age set as 105 ##
twcovidw$AgeInt<-ifelse(twcovidw$Age==70, 35, 5)

## change week to date by Taiwan CDC's specification, using file provided by Taiwan's CDC ## 
## beginning of week set to Monday rather than Sunday ##
wdates<-read_excel('sourcefiles/weekdate.xls') %>% slice(8399:n()) %>% select(-c('year'))
wdatesshort<-wdates[seq(1,nrow(wdates),7),]
wdatesshort$date<-format(as.Date(wdatesshort$date), '%d.%m.%Y')
wdatesshort$week<-as.numeric(as.character(wdatesshort$week))

twcovidw<-left_join(twcovidw,wdatesshort, by='week')
colnames(twcovidw)[9]<-'Date'

## make/keep only useful columns ## 
twcovidw$Country<-'Taiwan'
twcovidw$Code<-paste0('TW',twcovidw$Date)
twcovidw$Metric<-'Count'
twcovidw2<-select(twcovidw,-c('Diagnosis','week'))

## reshape ## 
l <- gather(twcovidw2, Measure, Value, Cases, factor_key=T)

## manually add deaths (6) from news source: https://healthmedia.com.tw/main_detail.php?id=45372 ## 
## https://www.cdc.gov.tw/Bulletin/Detail/C7SfkryzIXWf0eF_1O03hw?typeid=9 ##
## https://www.storm.mg/article/2461485 ##
## https://www.twreporter.org/i/covid-2019-keep-tracking-gcs ##

## Case number 19 (62 male, died 25.02.20), 27 (80+ male, died 20.03.20), 34 (50+ female, 30.03.20), ##
## Case numer 108 (40+ male), died 29.03.20), 170 (60+ male, died 29.03.20), ##
## Case number 101 (70+ male, 09.04.20)  ## 
## upper bound of age group used when unspecified, such as 55 for 50+ and 65 for 60+ ## 

Year<-rep(c(2020),times=6)
Region<-rep(c('All'),times=6)
Sex<-c('M','M','F','M','M','M')
Age<-c('60','70+','55','45','65','70+')
Deaths<-rep(c(1), times=6)
AgeInt<-c(5,35,5,5,5,35)
Date<-c('02.03.2020','16.03.2020','30.03.2020','23.03.2020','23.03.2020','06.04.2020')
Country<-rep(c('Taiwan'),times=6)
Code<-paste0('TW',Date)
Metric<-rep(c('Count'), times=6)

mort<-data.frame(Year,Region,Sex,Age,Deaths,AgeInt,Date,Country,Code,Metric)

l2<-gather(mort,Measure,Value,Deaths,factor_key =T)

## glue l and l2 together ## 
lall<-rbind(l,l2)

## change M/F to m/f for sex ##
lall$Sex[lall$Sex=='M']<-'m'
lall$Sex[lall$Sex=='F']<-'f'

## re-order columns ##
lall<-lall[,c(7,2,8,6,3,4,5,9,10,11)]

## output ## 
write.csv(lall, 'tw0415.csv')
