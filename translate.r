## File updated on May 12, 2020 by CL ## 

## This file was written by Chia Liu, for a collaborative project documenting COVID 19 cases and deaths globally by age ## 

library(tidyverse)
library(readxl)

## data source: https://data.cdc.gov.tw/download?resourceid=3c1e263d-16ec-4d70-b56c-21c9e2171fc7&dataurl=https://od.cdc.gov.tw/eic/Day_Confirmation_Age_County_Gender_19CoV.csv ##

twcovidw<-read_csv('Weekly_Confirmation_Age_County_Gender_19CoV.csv') %>% select(-c(1,2,6))

## translate variables ##
colnames(twcovidw)<-c('week','Region','Sex','Age','Cases')

## translate values ##

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


## lower case m/f
## change M/F to m/f for sex ##
twcovidw$Sex<-tolower(twcovidw$Sex)

## pad with rows of zeroes for weeks/regions/sex/age with no cases ## 
Sex<-c('m','f')
Age<-unique(twcovidw$Age) %>% as.numeric()
Week<-c(4:19)
Region<-unique(iso$Region) 
fake<-expand.grid(Sex,Age,Week,Region)
names(fake)<-c('Sex','Age','Week','Region')
fake$uniqueid<-paste0(fake$Sex,fake$Age,fake$Week,fake$Region)

twcovidw$uniqueid<-paste0(twcovidw$Sex, twcovidw$Age, twcovidw$week, twcovidw$Region)
twcovidwnew<-right_join(twcovidw, fake, by='uniqueid') 
## rows exceed expand grid dataframe because of duplicate rows due to tw cdc separating rows for external and internal transmission ##
twcovidwnew<-select(twcovidwnew,-c('uniqueid','Sex.x','Region.x','Age.x','week')) %>% rename(Sex=Sex.y, Region=Region.y, Age=Age.y)

## Create AgeInt ##
twcovidwnew$AgeInt<-ifelse(twcovidwnew$Age==70, 35, 5)

## change week to date by Taiwan CDC's specification, using file provided by Taiwan's CDC ## 
## Monday as the beginning of the week (rather than Sunday) ##
wdates<-read_excel('weekdate.xls') %>% slice(8399:n()) %>% select(-c('Year'))
wdatesshort<-wdates[seq(1,nrow(wdates),7),]
wdatesshort$Date<-format(as.Date(wdatesshort$Date), '%d.%m.%Y')
wdatesshort$Week<-as.numeric(as.character(wdatesshort$Week))
twcovidwnew<-left_join(twcovidwnew,wdatesshort, by='Week')
colnames(twcovidw)[6]<-'Date'

## add ISO-3 code ##
iso<-read_csv('ISO3.csv')
twcovidwnew<-left_join(twcovidwnew,iso, by='Region')

## Create columns ## 
twcovidwnew$Country<-'Taiwan'
twcovidwnew$Year<-c(2020)
twcovidwnew$Code<-paste0('TW','_',twcovidwnew$iso3,'_',twcovidwnew$Date)
twcovidwnew$Metric<-'Count'

## change NA to 0 ## 
twcovidwnew$Cases[is.na(twcovidwnew$Cases)]<-0

## reshape ## 
l <- gather(twcovidwnew, Measure, Value, Cases, factor_key=T)

## here we get rid of the duplicate rows ## 
l <- l %>% group_by(Country, Year, Code, Region, Date, Sex, Age, AgeInt, Metric, Measure)%>% summarise(Value=sum(Value)) 

## manually add deaths (6) from news source: https://healthmedia.com.tw/main_detail.php?id=45372 ## 
## https://www.cdc.gov.tw/Bulletin/Detail/C7SfkryzIXWf0eF_1O03hw?typeid=9 ##
## https://www.storm.mg/article/2461485 ##
## https://www.twreporter.org/i/covid-2019-keep-tracking-gcs ##

## Case number 19 (62 male, died 25.02.20), 27 (80+ male, died 20.03.20), 34 (50+ female, 30.03.20), ##
## Case numer 108 (40+ male), died 29.03.20), 170 (60+ male, died 29.03.20)in Taiwan, ##
## Case number 101 (70+ male, 09.04.20, 197 (40+ male)  ## 

## upper bound of age group used when unspecified, such as 55 for 50+ and 65 for 60+ ## 

Year<-rep(c(2020),times=7)
Region<-rep(c('All'),times=7)
Sex<-c('m','m','f','m','m','m','m')
Age<-c(60,70,55,45,65,70,45)
Deaths<-rep(c(1), times=7)
AgeInt<-c(5,35,5,5,5,35,5)
Date<-c('02.03.2020','16.03.2020','30.03.2020','23.03.2020','23.03.2020','06.04.2020','04.05.2020')
Country<-rep(c('Taiwan'),times=7)
Code<-paste0('TW',Date)
Metric<-rep(c('Count'), times=7)

mort<-data.frame(Year,Region,Sex,Age,Deaths,AgeInt,Date,Country,Code,Metric)

l2<-gather(mort,Measure,Value,Deaths,factor_key =T)

## glue l and l2 together ## 
lall<-rbind(l,l2)

## re-order columns ##
colorder<-c('Country','Region','Code','Date','Sex','Age','AgeInt','Metric','Measure','Value')
lall<-lall[,colorder]

## output ## 
googlesheets4::sheet_write(lall,ss="https://docs.google.com/spreadsheets/d/1NVmyknEZnEwiZvxwfFCHhkvuW9VH5NBqBf1cXX82I_M/edit#gid=1079196673",sheet = "database")

