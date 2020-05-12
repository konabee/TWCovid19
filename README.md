# TWCovid19
Covid 19 cases and deaths in Taiwan 

The Epidemic Intelligence Center at Taiwan's Centers for Disease Control collects and disseminates data on COVID 19 cases in Taiwan by area, age, and gender, by day (https://data.cdc.gov.tw/dataset/agsdctable-day-19cov) and by week (https://data.cdc.gov.tw/dataset/aagsdctable-weekly-19cov). The values and variable names in this dataset are in Chinese, and can benefit from translation and basic transformation to ease cross-national comparisons. I have completed this task for a larger project, 'COVerAGE-DB' which aims to harmonize global data from various sources by age for demographic or epidemiological research: https://github.com/timriffe/covid_age 

For Taiwan's data, the following has been done: 
1. All labels and variables have been translated from Chinese to English.
2. To ensure comparability, I expanded the data to include all possible combination of week(16), region(22), sex(2), age group(15), totaling 10560 rows for data on CASES of COVID 19 (not deaths). Those rows that did not experience a case are padded with zeroes. Therefore, although data by day is available, I used weekly data to avoid having to pad the data with too many rows of zeroes.  
3. Weeks have been matched to dates (with the first day of the week set as Monday) in accordance to WHO specification, with the source file for week/date provided by Taiwan's CDC. 
4. Taiwan so far has had 7 COVID deaths (as of May 12, 2020), but the demographic characteristics of the deceased have not been released by Taiwan's CDC. These six cases have been entered manually into the data base, using various news sources. For those whose age have only been roughly identified by the media, the upper bound of the 5-year age group is used (for example, 50+ is categorized as 55-59).   
* https://healthmedia.com.tw/main_detail.php?id=45372 
* https://www.cdc.gov.tw/Bulletin/Detail/C7SfkryzIXWf0eF_1O03hw?typeid=9
* https://www.storm.mg/article/2461485
* https://www.twreporter.org/i/covid-2019-keep-tracking-gcs 


## update 04.28.2020 ##
Taiwan CDC updated their source file on April 25th of 2020. https://data.cdc.gov.tw/dataset/agsdctable-day-19cov#
Code and source files are updated here accordingly.

## update 05.12.2020 ## 
Code and source files have been updated, and one death has been added 
