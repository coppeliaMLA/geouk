## ONS Quick Statistics

## Source 

This data was was downloaded from [here](http://www.nomisweb.co.uk/census/2011/quick_statistics)


## Extraction code

I extracted the data using the following python code:

```
import os, time, re, urllib
from selenium import webdriver
from selenium.webdriver.support.ui import Select
from bs4 import BeautifulSoup

#First use beautifulsoup to pick out the tables

#Open up web page and put contents (html) into query_response
query_url = "http://www.nomisweb.co.uk/census/2011/quick_statistics"
query_response = urllib.urlopen(query_url)
soup = BeautifulSoup(query_response)


data_links = []
for a in soup.find_all('a',{'class': 'dsLink'}):
    data_links.append(a['href'])

dataset_titles = []
for row in soup.find_all('tr')[1:]:
    col = row.find_all("td")
    dataset_titles.append(col[1].get_text())

#Now go to the pages and use selenium to download the data

driver = webdriver.Chrome()

regex = re.compile('[^a-zA-Z0-9]')
regex_comma = re.compile('[^a-zA-Z0-9,_]')

#Set up a file to list the tables and cols

with open('/Users/simon/Downloads/tables_and_cols.csv', 'w') as ref:
    ref.write("table, col\n")

    for n in xrange(len(data_links)):
        try:
            correct_file_name = regex.sub("", dataset_titles[n].title())
            href = "http://www.nomisweb.co.uk" + data_links[n]
            print dataset_titles[n], href
            driver.get(href)
            select = Select(driver.find_element_by_id('geography'))
            select.select_by_visible_text('wards 2011')
            download=driver.find_element_by_id("dwnBtn")
            download.click()
            time.sleep(20) #Give it time to download properly

            #Strip out measures: Value and do some other formatting on the col titles

            with open('bulk.csv', 'r') as bulk:
                lines = bulk.readlines()
            new_cols = regex_comma.sub("", lines[0].replace('; measures: Value', '').lower().replace(', ', ',').replace(' ', '_'))+'\n'
            lines[0] = new_cols
            split_cols = new_cols.split(",")

            for s in split_cols[3:]:
                ref.write(correct_file_name + ", " + s + "\n")

            with open(correct_file_name + '.csv', 'w') as perm:
                for line in lines:
                    perm.write(line)

            os.remove('bulk.csv')
        except:
            pass
```

## Transformation code 

I transformed the data using the following R code:

```
economic_activity<-read_in_geouk(paste0(dir, "EconomicActivity.csv"), sep=",")
keep<-c("economic_activity_economically_active_employee_parttime", "economic_activity_economically_inactive_total", "economic_activity_economically_inactive_looking_after_home_or_family", "economic_activity_economically_inactive_longterm_sick_or_disabled"  )
economic_activity<-economic_activity[,c( "geography_code" , keep)]
names(economic_activity)[1]<-"ward_code"
names(economic_activity)[2:5]<-sapply(names(economic_activity)[2:5], function(x) substr(x, 10, nchar(x)))

health<-read_in_geouk(paste0(dir, "GeneralHealth.csv"), sep=",")
keep<-c("general_health_bad_health", "general_health_very_bad_health")
health<-health[,c( "geography_code" , keep)]
names(health)[1]<-"ward_code"
names(health)[2:3]<-c("bad_health", "very_bad_health")

deprivation<-read_in_geouk(paste0(dir, "HouseholdsByDeprivationDimensions.csv"), sep=",")
keep<-c(3, 5, 7:10)
deprivation<-deprivation[,keep]
names(deprivation)[1]<-"ward_code"
names(deprivation)[2:6]<-c("num_households", "deprived_in_1d", "deprived_in_2d", "deprived_in_3d", "deprived_in_4d")

deprivation<-read_in_geouk(paste0(dir, "HouseholdsByDeprivationDimensions.csv"), sep=",")
keep<-c(3, 5, 7:10)
deprivation<-deprivation[,keep]
names(deprivation)[1]<-"ward_code"
names(deprivation)[2:6]<-c("num_households", "deprived_in_1d", "deprived_in_2d", "deprived_in_3d", "deprived_in_4d")

dep_children<-read_in_geouk(paste0(dir, "FamiliesWithDependentChildren.csv"), sep=",")
keep<-c(3, 6:16)
dep_children<-dep_children[,keep]
names(dep_children)[1]<-"ward_code"
names(dep_children)[2:12]<-sapply(names(dep_children)[2:12], function(x) substr(x, 13, nchar(x)))

len_residence<-read_in_geouk(paste0(dir, "LengthOfResidenceInTheUk.csv"), sep=",")
keep<-c(3, 7:10)
len_residence<-len_residence[,keep]
names(len_residence)[1]<-"ward_code"
names(len_residence)[2:5]<-sapply(names(len_residence)[2:5], function(x) substr(x, 42, nchar(x)))

social_grade<-read_in_geouk(paste0(dir, "ApproximatedSocialGrade.csv"), sep=",")
keep<-c(3, 5:8)
social_grade<-social_grade[,keep]
names(social_grade)[1]<-"ward_code"
names(social_grade)[2:5]<-sapply(names(social_grade)[2:5], function(x) substr(x, 14, nchar(x)))
```
