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

            with open('/Users/simon/Downloads/bulk.csv', 'r') as bulk:
                lines = bulk.readlines()
            new_cols = regex_comma.sub("", lines[0].replace('; measures: Value', '').lower().replace(', ', ',').replace(' ', '_'))+'\n'
            lines[0] = new_cols
            split_cols = new_cols.split(",")

            for s in split_cols[3:]:
                ref.write(correct_file_name + ", " + s + "\n")

            with open('/Users/simon/Downloads/' + correct_file_name + '.csv', 'w') as perm:
                for line in lines:
                    perm.write(line)

            os.remove('/Users/simon/Downloads/bulk.csv')
            #os.rename('/Users/simon/Downloads/bulk.csv', '/Users/simon/Downloads/' + regex.sub("", dataset_titles[n]) + '.csv')
        except:
            pass


