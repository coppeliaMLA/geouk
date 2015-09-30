# geouk

We created this repository while working on project analysing food bank data provided by the Trussell Trust. We (The University of Hull, Coppelia and AAM associates) found we needed some common standards in order to collaborate when working with the hundreds of open geospatial data sets that are available online.

Once we had an agreement on what the data should look like it was much easier to put together some tools that provide standard views on it (maps, time series plots etc). These tools include

1. geoukr, an r package for produce maps and time series plots of the data
2. Javascript code to create a browser based tool that allows the user to explore maps of the data
3. the SQL to create a mySQL database from the csv files
4. python code for downloading various open source data sets

Unless they are hard to find we haven't provided the open data sets themselves (that would just duplicate what already exists) but rather 

1. Code that downloads the datasets
2. Useful transformations of the datasets (or the code to make those transformations if the data sets are too large to add to the repository.
3. The tables that we used to link them together. 


## Conventions for our data

1. All tables and column names use `lower_case_with_underscores`
2. All file names use `mixedCase`
3. When stored in flat files
  1. Full dates are formatted as `yyyy-mm-dd`
  2. Monthly data is labelled using the first day of the month. e.g. January 2007 would be stored as `2007-01-01`
  3. Likewise weekly data is labelled using the first day of the week (the first day being Monday)

## Not essential but preferred

1. Count measures start with `num_`
2. Percentage measures start with `pct_`


## Process for adding new data (should aim to make this like `brew` i.e. using formulas) 

1. Create a new markdown file from the openDataSources.md markdown template
2. Where appropriate complete sections for
  1. Source
  2. Extraction code
2. Data needs to join other data sets by date or by geographical location. Any new data set therefore must have a column that contains values that are to be found in one of the columns of the `date_hierarchy` table or one of the columns of any of the `geo_hierarchy` tables or both. Create your code (in python or R) for transforming the data into the required format and paste it into the transformation code section of the markdown file. When constructing the code please work to the following principles
  1. Only import columns that have an obvious use (to avoid being swamped by data) and avoid duplicating information
  2. Ensure that column names and file meet our conventions for data
3. Do not save the data itself within the repository. By running your code any user should be able to pull down the data for themselves.
4. Save your markdown file within openDataSources

That's it. You should now be able to use your data in our package along with any of the other data sets.


![](images/AddingNewTables.png)

## Types of table

1. Hierarchy tables (includes the `date_hierarchy` table which maps date to useful longer time periods and the `geo_hierarchy` tables which include 
  1. `postal_geo_hierarchy`
  2. `electoral_geo_hierarchy`
  3. `admin_geo_hierarchy`
2. Bridge tables
3. Metadata tables

## Installing the geoukr r package

The package is not yet on cran but can be installed via devtools

Install devtools if you do not have it already

```
install.packages("devtools")
```

And the download and install from github

```
install_github("coppeliaMLA/geouk", subdir = "geoukr")
```

Note that rgeos requires geos and rgdal requires gdal so you'll need to install these too. If you are using a mac then can easily be done via brew

```
brew install geos
brew install gdal
```









