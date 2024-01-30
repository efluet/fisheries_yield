# get template
r <- rast('../data/discharge/dis_dls/q_cls_1km.tif')

# /-----------------------------------------------------------------------------
#/   MAKE GRID OF COUNTRY ISO CODES 


library(rworldmap)
sPDF <- st_read('../data/nat_earth/ne_110m_admin_0_countries.shp')
sPDF <- vect(sPDF)
sPDF$adm0_a3 <- as.factor(sPDF$adm0_a3)

# this has 242 observations (hence 242 indiv countries)
isolookup <- as.data.frame(sPDF$adm0_a3)
isolookup$val <- as.numeric(sPDF$adm0_a3)

# then we lose some small countries in the gridding
ciso <- terra::rasterize(sPDF, r, "adm0_a3")

ciso_num <- as.numeric(ciso)


# Make lookup table
# NOTE probably could be simplified by using ciso_num
isolookup2 <- data.frame(cats(ciso) ) %>% 
              rename(ID=1,  adm0_a3=2) %>% 
              dplyr::select(adm0_a3) %>% 
              tibble::rownames_to_column(., "ID") %>% 
              mutate(ID=as.numeric(ID))





# # Make lookup table converting ISOA3 to numerical ID
# isolookup2 <- isolookup %>% filter(isolookup$val %in% c(levels(ciso)[[1]])$ID)
# names(isolookup2) <- c("ISO_A3", "ID")
# isolookup2 <- isolookup2[,c("ID", "ISO_A3")]
# isolookup2$ISO_A3 <- as.character(isolookup2$ISO_A3) 
# levels(ciso) <- isolookup2


# library(rworldmap)
# sPDF <- getMap()[getMap()$ADMIN!='Antarctica','ISO_A3']
# 
# # this has 242 observations (hence 242 indiv countries)
# isolookup <- as.data.frame(sPDF$ISO_A3)
# isolookup$val <- as.numeric(sPDF$ISO_A3)
# 
# # then we lose some small countries in the gridding
# ciso <- rasterize(sPDF, r, "ISO_A3")
# ciso <- ratify(ciso)
