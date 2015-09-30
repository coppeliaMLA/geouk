wards_to_cmw <- read.csv("~/Documents/CodeRepos/trussell/opendata/2011Census/2011CensusDownloads/geoLookups/WD11_CMWD11_LAD11_EW_LU.csv", stringsAsFactors=FALSE)
deprivation <- read.csv("~/Documents/CodeRepos/trussell/opendata/2011Census/2011CensusDownloads/WebScraped/HouseholdsByDeprivationDimensions.csv", stringsAsFactors=FALSE)
deprivation_cm<-merge(wards_to_cmw, deprivation, by.x = "WD11CD", by.y="geography_code")
household_deprivation_3d<-dcast(data=deprivation_cm, CMWD11CD~"value", sum, value.var = "household_deprivation_household_is_deprived_in_3_dimensions")
dep_map<-uk_ward_map(ward_data, "/Users/simon/Documents/CodeRepos/trussell/opendata/mapShapes")
shapes_dir<-"/Users/simon/Documents/CodeRepos/trussell/opendata/mapShapes"

ward_map_by_region("London", dep_map)


geo_hierarchy <- read.csv("~/Documents/CodeRepos/trussell/opendata/2011Census/2011CensusDownloads/geoLookups/CTRY14_RGN14_CTY14_LAD14_WD14_UK_LU.csv", stringsAsFactors=FALSE)
names(geo_hierarchy)<-c("ward_code", "ward_name", "local_authority_code", "local_authority_name", "county_code", "county_name", "region_code", "region_name", "country_code", "country_name")
administrative_geo_hierarchy<-merge(geo_hierarchy, wards_to_cmw[,c(1,4,5)], by.x="ward_code", by.y = "WD11CD", all.x=TRUE)
names(administrative_geo_hierarchy)[11:12]<-c("cm_ward_code", "cm_ward_name")
admin_geo_hierarchy<-administrative_geo_hierarchy[,c("ward_code", "ward_name", "cm_ward_code", "cm_ward_name", "local_authority_code", "local_authority_name", "county_code", "county_name", "region_code", "region_name", "country_code", "country_name")]

write.csv(admin_geo_hierarchy, file="~/Documents/CodeRepos/geouk/openDataSources/hierarchyTables/admin_geo_hierarchy.csv", row.names=FALSE)

save(admin_geo_hierarchy, file="~/Documents/CodeRepos/geouk/geoukr/data/admin_geo_hierarchy.RData")

save(household_deprivation_3d, file="~/Documents/CodeRepos/geouk/geoukr/data/household_deprivation_3d.RData")

save(ward_shapes, file="~/Documents/CodeRepos/geouk/geoukr/data/ward_shapes.RData")

save(la_shapes, file="~/Documents/CodeRepos/geouk/geoukr/data/la_shapes.RData")

ward_shapes

length(unique(geo_hierarchy$ward_code))


date<-seq(as.Date("1900-01-01"), as.Date("2050-01-01"), "days")
weekday_num<-as.numeric(date+3) %% 7
date_hierarchy<-data.frame(date, week_day=weekdays(date), week_num=3652 + (as.numeric(date+3) - as.numeric(date+3) %% 7)/7,month_num=month(date), month_name = month.abb[month(date)],  year=year(date_id))
mondays<-date_hierarchy[date_hierarchy$week_day=="Monday",c(1,3)]
names(mondays)[1]<-"start_of_week"
date_hierarchy<-merge(date_hierarchy, mondays, by="week_num")

date_hierarchy<-date_hierarchy[order(date_hierarchy$date), c( "date","week_day","week_num","start_of_week" ,"month_num"  ,   "month_name"   , "year" )   ]
head(weekdays(date))

head(as.numeric(date+3) %% 7)

date_lookup<-data.frame(date_id, week=week(date_id), month=month(date_id), year=year(date_id))
first_day<-dcast(data=date_lookup, year+week~"start_of_week", value.var = "date_id", fun.aggregate=min)
first_day$start_of_week<-as.Date(first_day$start_of_week)
date_lookup<-merge(date_lookup, first_day, by=c("week", "year"))
date_lookup<-date_lookup[order(date_lookup$date_id),]
ward_level<-merge(ward_level, date_lookup, by ="date_id")

head(date_lookup, 5)

save(date_hierarchy, file="~/Documents/CodeRepos/geouk/geoukr/data/date_hierarchy.RData")
