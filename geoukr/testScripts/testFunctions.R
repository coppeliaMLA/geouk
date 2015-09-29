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

write.csv(admin_geo_hierarchy, file="~/Documents/CodeRepos/geouk/openDataSources/hierarchyTables/admin_geo_hierarchy.csv")

save(admin_geo_hierarchy, file="~/Documents/CodeRepos/geouk/geoukr/data/admin_geo_hierarchy.RData")

save(household_deprivation_3d, file="~/Documents/CodeRepos/geouk/geoukr/data/household_deprivation_3d.RData")

save(ward_shapes, file="~/Documents/CodeRepos/geouk/geoukr/data/ward_shapes.RData")

save(la_shapes, file="~/Documents/CodeRepos/geouk/geoukr/data/la_shapes.RData")

ward_shapes

length(unique(geo_hierarchy$ward_code))
