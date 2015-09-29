add_data_to_shapes<-function(shapes, data, by){
  shapes@data = merge(shapes@data, data, by=by, all.x = TRUE)
  return(shapes)
}

uk_ward_map<-function(ward_data, shapes_dir, points = NULL) {

  #Load in the ward shapes
  ward_shapes <- readOGR(paste0(shapes_dir, "/wardShapes"), "CMWD_2011_EW_BGC")

  #Load in the LA shapes
  la_shapes <- readOGR(paste0(shapes_dir, "/laShapes"), "LAD_DEC_2012_GB_BFE")

  #Join regions to the shapes
  data(admin_geo_hierarchy)
  regions_to_lads<-unique(admin_geo_hierarchy[,c("local_authority_code","region_name")])
  la_shapes@data = data.frame(la_shapes@data, regions_to_lads[match(la_shapes@data[, "LAD12CD"], regions_to_lads[, "local_authority_code"]), ])
  regions_to_cm_wards<-unique(admin_geo_hierarchy[,c("cm_ward_code","region_name")])
  ward_shapes@data = data.frame(ward_shapes@data, regions_to_cm_wards[match(ward_shapes@data[, "CMWD11CD"], regions_to_cm_wards[, "cm_ward_code"]), ])

  add_data<-add_data_to_shapes(ward_shapes, ward_data, "CMWD11CD")



  #Return the shapes as an object
  uk_ward_map<-list(ward_shapes = add_data, la_shapes=la_shapes, points = points)

}

ward_map_by_region<-function(region, uk_ward_map){

  #Set map colours
  my_colours <- brewer.pal(7, "Blues")

  #Filter the data to a region
  ward_to_map <- uk_ward_map$ward_shapes[is.na(uk_ward_map$ward_shapes@data$region_name) == FALSE & uk_ward_map$ward_shapes@data$region_name == region, ]
  la_to_map <- uk_ward_map$la_shapes[is.na(uk_ward_map$la_shapes@data$region_name) == FALSE & uk_ward_map$la_shapes@data$region_name == region, ]

  #Calculate breaks
  breaks <- classIntervals(ward_to_map@data$value, n = 7, style = "fisher", unique = TRUE)
  breaks <- breaks$brks

  #Plot the map
  plot(ward_to_map, col = my_colours[findInterval(ward_to_map@data$value,
                                                  breaks, all.inside = TRUE)], axes = FALSE, border = NA)
  plot(la_to_map, border = "#4292C6", lwd=0.5, add = TRUE)
  #Add text
  pointLabel(coordinates(la_to_map)[, 1], coordinates(la_to_map)[, 2], labels = la_to_map@data$LAD12NM, cex = 0.5)

  #Add a legend
  legend("topleft", legend = leglabs(round(breaks, digits = 2), between = " to "), fill = my_colours, bty = "n", cex = 0.7)

  #Add title
  title(region)
}

#Examples


#uk_ward_map<-function(ward_data, "~/Users/simon/Documents/CodeRepos/trussell/opendata/mapShapes/", points = NULL)

#geo_hierarchy <- read.csv("~/Documents/CodeRepos/trussell/opendata/2011Census/2011CensusDownloads/geoLookups/CTRY14_RGN14_CTY14_LAD14_WD14_UK_LU.csv", stringsAsFactors=FALSE)
#names(geo_hierarchy)<-c("ward_code", "ward_name", "local_authority_code", "local_authority_name", "county_code", "county_name", "region_code", "region_name", "country_code", "country_name")
#save(geo_hierarchy, file="~/Documents/CodeRepos/geouk/geoukr/data/geo_hierarchy.RData")
