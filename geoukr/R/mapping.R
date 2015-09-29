#' Add data to shapes
#'
#' @param shapes A SpatialPolygonsDataFrame as generated using the SP package
#' @param data The geospatial data that should be added to the shapes
#' @param by The column on the existing dataframe that new data should be joined to
#' @return Returns the modified shape SpatialPolygonsDataFrame
#' @author Simon Raper
#' @export

add_data_to_shapes<-function(shapes, data, by){
  shapes@data = merge(shapes@data, data, by=by, all.x = TRUE)
  return(shapes)
}

#' Creates the data for a UK ward map by appending a ward level dataset to the ward shapes
#'
#' @param ward_data A ward level data set. This must contain a column called CMWD11CD that contains the ONS census merged ward codes and a column called value which contains the statistic to be mapped.
#' @param shapes_dir The local directory containing the shape files for census merged wards and local authorities. Please see instructions on the geouk github repo for instruction on how to obtain these file. The ward shapes must be placed in a subdirectory called wardShapes and the local authority shapes in a subdirectory called laShapes.
#' @param points TBC
#' @return Returns an object of class uk_ward_map containing the ward_shapes with the data appended and the la_shapes
#' @author Simon Raper
#' @examples
#'
#' data(household_deprivation_3d)
#' dep_map<-uk_ward_map(household_deprivation_3d, "/Users/simon/Documents/CodeRepos/trussell/opendata/mapShapes")
#'
#' @export


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

  class(uk_ward_map)<-"uk_ward_map"

  return(uk_ward_map)

}

#' Plots a map for just one region of a uk ward map object
#'
#' @param region The name of the region. Possible values are: London, North West, Yorkshire and The Humber, North East, West Midlands, East Midlands, South West, East of England, South East
#' @param uk_ward_map A UK ward map created with the uk_ward_map function
#' @author Simon Raper
#' @examples
#'
#' data(household_deprivation_3d)
#' dep_map<-uk_ward_map(household_deprivation_3d, "/Users/simon/Documents/CodeRepos/trussell/opendata/mapShapes")
#' ward_map_by_region("London", dep_map)
#' @export

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
