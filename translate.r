## File updated on April 28, 2020 by CL ## 

## This file was written by Chia Liu, for a collaborative project documenting COVID 19 cases and deaths globally by age (April 15, 2020) ## 

library(tidyverse)
library(readxl)

## data source: https://data.cdc.gov.tw/download?resourceid=3c1e263d-16ec-4d70-b56c-21c9e2171fc7&dataurl=https://od.cdc.gov.tw/eic/Day_Confirmation_Age_County_Gender_19CoV.csv ##

twcovidw<-read_excel('Day_Confirmation_Age_County_Gender_19CoV.xlsx')

## translate variables ##
colnames(twcovidw)<-c('Diagnosis','date','Region','Sex','RecentTravelAbroad','Age','Cases')

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

#twcovidw$RecentTravelAbroad[twcovidw$RecentTravelAbroad=='是']<-'yes'
#twcovidw$RecentTravelAbroad[twcovidw$RecentTravelAbroad=='否']<-'no'

twcovidw$Sex[twcovidw$Sex=='男']<-'m'
twcovidw$Sex[twcovidw$Sex=='女']<-'f'

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

## Create AgeInt ##
twcovidw$AgeInt<-ifelse(twcovidw$Age==70, 35, 5)

## change date format ## 
twcovidw$Date<-format(as.Date(twcovidw$date),'%d.%m.%Y') 

## add ISO-3 code ##

iso<-read_csv('ISO3.csv')

twcovidw<-left_join(twcovidw,iso,by='Region')

## make/keep only useful columns ## 
twcovidw$Country<-'Taiwan'
twcovidw$Code<-paste0('TW','_',twcovidw$iso3,'_',twcovidw$date)
twcovidw$Metric<-'Count'
twcovidw<-select(twcovidw,-c('Diagnosis','date','iso3'))

## reshape ## 
l <- gather(twcovidw, Measure, Value, Cases, factor_key=T)

## order columns ## 
colorder<-c('Country','Region','Code','Date','Sex','Age','AgeInt','Metric','Measure','Value')
l<-l[,colorder]

## manually add deaths (6) from news source: https://healthmedia.com.tw/main_detail.php?id=45372 ## 
## https://www.cdc.gov.tw/Bulletin/Detail/C7SfkryzIXWf0eF_1O03hw?typeid=9 ##
## https://www.storm.mg/article/2461485 ##
## https://www.twreporter.org/i/covid-2019-keep-tracking-gcs ##

## Case number 19 (62 male, died 25.02.20), 27 (80+ male, died 20.03.20), 34 (50+ female, 30.03.20), ##
## Case numer 108 (40+ male), died 29.03.20), 170 (60+ male, died 29.03.20)in Taiwan, ##
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
l2<-l2[,colorder]

## glue l and l2 together ## 
lall<-rbind(l,l2)

## output ## 
readr::write_csv(lall, 'tw0428.csv')
