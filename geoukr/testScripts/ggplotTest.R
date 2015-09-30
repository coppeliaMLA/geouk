data(ward_shapes)
ward_shapes_f <- fortify(ward_shapes)

ward_shapes_f <- merge(ward_shapes_f, ward_2014, by.x = "id", by.y = "ons_label")

Map <- ggplot(ward_shapes.f, aes(long, lat, group = group, fill = 1)) + geom_polygon() +
  +     coord_equal()


data(la_shapes)
la_shapes_f <- fortify(la_shapes)

ward_shapes_f <- merge(ward_shapes_f, ward_2014, by.x = "id", by.y = "ons_label")

Map <- ggplot(la_shapes_f, aes(long, lat, group = group, fill = 1)) + geom_polygon() +     coord_equal()
