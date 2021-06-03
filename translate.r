## Written then updated by Chia Liu, on 03.06.2021 ## 

library(tidyverse)
library(readxl)

## COVID 19 cases ##
## read data from Taiwan CDC website ## 

twcovidw<-read_csv('https://data.cdc.gov.tw/download?resourceid=a49ab31a-4711-4064-b2f0-216228a7cefc&dataurl=https://od.cdc.gov.tw/eic/Weekly_Age_County_Gender_19CoV.csv') %>% 
  select(-c(1,5,7))

## translate variables ##
colnames(twcovidw)<-c('Year','Week','Place','Sex','Age','Cases')
head(twcovidw)

## recode age ##
## change M/F to m/f for sex ##
twcovidw<-twcovidw %>% mutate (
  Sex=tolower(Sex),
    Age = case_when(
               Age %in% c('0','1','2','3','4') ~ 0,
               Age=='5-9' ~ 5,
               Age=='10-14' ~ 10,
               Age=='15-19' ~ 15,
               Age=='20-24' ~ 20,
               Age=='25-29' ~ 25,
               Age=='30-34' ~ 30,
               Age=='35-39' ~ 35,
               Age=='40-44' ~ 40,
               Age=='45-49' ~ 45,
               Age=='50-54' ~ 50,
               Age=='55-59' ~ 55,
               Age=='60-64' ~ 60,
               Age=='65-69' ~ 65,
               Age=='70+' ~ 70))

## collapse geography into national total ## 
twshort<-twcovidw %>% group_by(Year,Week, Sex, Age) %>% summarise(Cases=sum(Cases)) 
twshort$Week<-paste0(twshort$Year,twshort$Week)

## create fake data to expand ##
Sex<-c('m','f')
Age<-unique(twshort$Age) %>% as.numeric()
Year<-c(2020,2021)
Week<-c(1:53) %>% as.numeric()

fake<-expand.grid(Sex,Age,Week,Year)
names(fake)<-c('Sex','Age','Week','Year')
fake$Week<-paste0(fake$Year,fake$Week)
fake$uniqueid<-paste0(fake$Sex,fake$Age,fake$Week)
fake<-fake %>% select(Year,Week,Sex,Age,uniqueid)

twshort$uniqueid<-paste0(twshort$Sex,twshort$Age,twshort$Week)
twnew<-right_join(twshort[,5:6],fake,by='uniqueid') %>% select(-c('uniqueid')) %>% arrange(Week)

## change NA to 0 ## 
twnew$Cases[is.na(twnew$Cases)]<-0

## create AgeInt ##
twnew$AgeInt<-ifelse(twnew$Age==70,35,5)

## change week to date of the Monday of the week by Taiwan CDC's specification, using file provided by Taiwan's CDC ## 
wdates<-read_excel('/weekdate.xls') %>% slice(8399:n()) %>% select(-c('Year'))
wdatesshort<-wdates[seq(1,nrow(wdates),7),]
wdatesshort$Date<-format(as.POSIXct(wdatesshort$Date), '%d.%m.%Y') %>% lubridate::dmy()
wdatesshort$Date<-format(as.POSIXct(wdatesshort$Date), '%d.%m.%Y')

wdatesshort$Week<-paste0(substr(wdatesshort$Date,7,10),wdatesshort$Week)


twnew<-left_join(twnew,wdatesshort, by='Week') %>% select(-c('Week')) %>% filter(!is.na(Date))

## add columns for cross national comparisons ## 
twnew$Country<-'Taiwan'
twnew$Code<-paste0('TW',twnew$Date)
twnew$Metric<-c('Count')
twnew$Region<-c('All')
l <- gather(twnew, Measure, Value, Cases, factor_key=T)
l <-l %>% group_by(Sex, Age) %>% mutate(Value=cumsum(Value))

## COVID 19 Deaths ## 
 
## To be updated pending information from Taiwan CDC ## 
