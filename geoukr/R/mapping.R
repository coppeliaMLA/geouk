#' Add data to shapes
#'
#' @param shapes A SpatialPolygonsDataFrame as generated using the SP package
#' @param data The geospatial data that should be added to the shapes
#' @param by The column on the existing dataframe that new data should be joined to
#' @return Returns the modified shape SpatialPolygonsDataFrame
#' @author Simon Raper
#' @export

add_data_to_shapes<-function(shapes, data, by.x, by.y){
  shapes@data = merge(shapes@data, data, by.x=by.x, by.y = by.y, all.x = TRUE)
  return(shapes)
}

#' Creates the data for a UK ward map by appending a ward level dataset to the ward shapes
#'
#' @param ward_data A ward level data set. This must contain a column called cm_ward_code that contains the ONS census merged ward codes and a column called value which contains the statistic to be mapped.
#' @param points An optional data frame containing the co-ordinates and labels of points that you may want to plot on the map
#' @return Returns an object of class uk_ward_map containing the ward_shapes with the data appended and the la_shapes
#' @author Simon Raper
#' @examples
#'
#' data(household_deprivation_3d)
#' dep_map<-uk_ward_map(household_deprivation_3d)
#'
#' @export


uk_ward_map<-function(ward_data, points = NULL) {

  #Load in the ward shapes
  data("ward_shapes")

  #Load in the LA shapes
  data("la_shapes")

  #Join regions to the shapes
  data(admin_geo_hierarchy)
  regions_to_lads<-unique(admin_geo_hierarchy[,c("local_authority_code","region_name")])
  la_shapes@data = data.frame(la_shapes@data, regions_to_lads[match(la_shapes@data[, "LAD12CD"], regions_to_lads[, "local_authority_code"]), ])
  regions_to_cm_wards<-unique(admin_geo_hierarchy[,c("cm_ward_code","region_name")])
  ward_shapes@data = data.frame(ward_shapes@data, regions_to_cm_wards[match(ward_shapes@data[, "CMWD11CD"], regions_to_cm_wards[, "cm_ward_code"]), ])

  add_data<-add_data_to_shapes(ward_shapes, ward_data, by.x = "CMWD11CD", by.y = "cm_ward_code" )

  #Return the shapes as an object
  uk_ward_map<-list(ward_shapes = add_data, la_shapes=la_shapes, points = points)

  class(uk_ward_map)<-"uk_ward_map"

  return(uk_ward_map)

}

#' Plots a map for just one region of a uk ward map object
#'
#' @param region The name of the region. Possible values are: London, North West, Yorkshire and The Humber, North East, West Midlands, East Midlands, South West, East of England, South East
#' @param uk_ward_map A UK ward map created with the uk_ward_map function
#' @param map_title Optional title for the map
#' @author Simon Raper
#' @examples
#'
#' data(household_deprivation_3d)
#' dep_map<-uk_ward_map(household_deprivation_3d)
#' ward_map_by_region("London", dep_map)
#' @export

ward_map_by_region<-function(region, uk_ward_map, breaks, map_title=NULL){

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

  #Add the points
  if (is.null(uk_ward_map$points) == FALSE) {

    points<-uk_ward_map$points
    outer_shape<- unionSpatialPolygons(la_to_map, rep(1,length(la_to_map)))

    #Get the bounding box
    bb<-bbox(ward_to_map)

    #Exclude points outside it
    points_bb<-points[points$e<bb[4] & points$e>bb[2] & points$n<bb[3]  & points$n>bb[1],]

    #Further exclude points outside the polygons. Should speed up by merging the polygons http://gis.stackexchange.com/questions/63577/joining-polygons-in-r
    inside_poly<-sapply(1:nrow(points_bb), function(i) gContains(outer_shape,SpatialPoints(points_bb[i, 2:3],proj4string=CRS(proj4string(outer_shape)))))

    points_ex<-points_bb[inside_poly,]

    points(points_ex$n,points_ex$e, pch=17,col="#FB6A4A")

  }

  #Add title
  if (is.null(map_title) == TRUE) {
  title(region)
  }
  else
  {
    title(paste0(map_title, ": ", region))
  }

  mtext("Contains National Statistics data © Crown copyright and database right 2013; Contains Ordnance Survey data © Crown copyright and database right 2013",
        side = 1, line = 2, cex = 0.7)
  mtext("Map created by Coppelia using the geoukr package",
        side = 1, line = 1, cex = 0.7)
}

