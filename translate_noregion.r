## Cumulative COVID 19 Cases and Deaths, for all Regions in Taiwan, by Age group, Sex and Week ##

library(tidyverse)
library(readxl)
setwd('C:/Users/Chia/Desktop/TW')

## COVID 19 cases ## 

twcovidw<-read_csv('C:/Users/Chia/Desktop/TW/Weekly_Confirmation_Age_County_Gender_19CoV.csv') %>% select(-c(1,2,6))

## translate variables ##
colnames(twcovidw)<-c('Week','Region','Sex','Age','Cases')

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

## change M/F to m/f for sex ##
twcovidw$Sex<-tolower(twcovidw$Sex)

## collapse regions into just Taiwan ## 
twshort<-twcovidw %>% group_by(Week, Sex, Age) %>% summarise(Cases=sum(Cases)) 

## create fake data to expand ##
Sex<-c('m','f')
Age<-unique(twshort$Age) %>% as.numeric()
Week<-c(4:19)

fake<-expand.grid(Sex,Age,Week) 
names(fake)<-c('Sex','Age','Week')
fake$uniqueid<-paste0(fake$Sex,fake$Age,fake$Week)

twshort$uniqueid<-paste0(twshort$Sex,twshort$Age,twshort$Week)
twnew<-right_join(twshort[,4:5],fake,by='uniqueid') %>% select(-c('uniqueid'))

## change NA to 0 ## 
twnew$Cases[is.na(twnew$Cases)]<-0

## create AgeInt ##
twnew$AgeInt<-ifelse(twnew$Age==70,35,5)

## change week to date of the Monday of the week by Taiwan CDC's specification, using file provided by Taiwan's CDC ## 
## same date for beginning of week as Scotland (Monday rather than Sunday) ##
wdates<-read_excel('C:/Users/Chia/Desktop/TW/weekdate.xls') %>% slice(8399:n()) %>% select(-c('Year'))
wdatesshort<-wdates[seq(1,nrow(wdates),7),]
wdatesshort$Date<-format(as.POSIXct(wdatesshort$Date), '%d.%m.%Y') %>% lubridate::dmy()
wdatesshort$Week<-as.numeric(as.character(wdatesshort$Week))
twnew<-left_join(twnew,wdatesshort, by='Week') %>% select(-c('Week'))

## add columns for cross national comparisons ## 
twnew$Country<-'Taiwan'
twnew$Year<-c(2020)
twnew$Code<-paste0('TW',twnew$Date)
twnew$Metric<-c('Count')
twnew$Region<-c('All')
l <- gather(twnew, Measure, Value, Cases, factor_key=T)
l <-l %>% group_by(Sex, Age) %>% mutate(Value=cumsum(Value))


## COVID 19 deaths ## 
## manually add deaths (6) from news source: https://healthmedia.com.tw/main_detail.php?id=45372 ## 
## https://www.cdc.gov.tw/Bulletin/Detail/C7SfkryzIXWf0eF_1O03hw?typeid=9 ##
## https://www.storm.mg/article/2461485 ##
## https://www.twreporter.org/i/covid-2019-keep-tracking-gcs ##

## Case number 19 (62 male, died 25.02.20), 27 (80+ male, died 20.03.20), 34 (50+ female, 30.03.20), ##
## Case numer 108 (40+ male), died 29.03.20), 170 (60+ male, died 29.03.20)in Taiwan, ##
## Case number 101 (70+ male, 09.04.20, 197 (40+ male)  ## 
## upper bound of age group used when unspecified, such as 55 for 50+ and 65 for 60+ ## 

Year<-rep(c(2020), 7)
Sex<-c('m','m','f','m','m','m','m')
Age<-c(60,70,55,45,65,70,45)
Deaths<-rep(c(1), 7)
AgeInt<-c(5,35,5,5,5,35,5)
Country<-rep(c('Taiwan'),7)
Metric<-rep(c('Count'),7)
Week<-c(10,12,14,13,13,15,19) ## matched with week chart 
mort<-data.frame(Year,Sex,Age,Deaths,AgeInt,Week,Country,Metric) ## this is the basic unpadded dataframe ## 

## create empty rows for sex,age,days where deaths did not take place ## 
mort$uniqueid<-paste0(mort$Sex,mort$Age,mort$Week)
mortnew<-right_join(mort, fake, by='uniqueid') %>% select(-c('Sex.x','Age.x','Week.x','uniqueid')) %>% rename(Sex=Sex.y,Age=Age.y, Week=Week.y)
mortnew<-left_join(mortnew,wdatesshort, by='Week') %>% select(-c('Week'))

mortnew$Deaths[is.na(mortnew$Deaths)]<-0
mortnew$Year<-2020
mortnew$Country<-c('Taiwan')
mortnew$Metric<-c('Count')
mortnew$AgeInt<-ifelse(mortnew$Age==70,35,5)
mortnew$Code<-paste0('TW',mortnew$Date)
mortnew$Region<-c('All')

l2 <- gather(mortnew, Measure, Value, Deaths, factor_key=T)
l2 <-l2 %>% group_by(Sex, Age) %>% mutate(Value=cumsum(Value))

## glue cases and deaths together ## 
lall<-rbind(l,l2)

## re-order columns, then bind cases with deaths (480 rows + 480 rows) ##
colorder<-c('Country','Region', 'Code','Date','Sex','Age','AgeInt','Metric','Measure','Value')
lall<-lall[,colorder]

## output ## 
googlesheets4::sheet_write(lall,ss="https://docs.google.com/spreadsheets/d/1NVmyknEZnEwiZvxwfFCHhkvuW9VH5NBqBf1cXX82I_M/edit#gid=1079196673",sheet = "database")



