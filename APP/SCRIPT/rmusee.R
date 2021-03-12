library(tidyverse)
library(leaflet)



#Tri des données 
net <- function(data){
  museefreq = read_csv(paste('DATA/',data, sep=''), locale=locale())
  date = museefreq$year[1]
  museefreq <- museefreq %>%
    filter(country == 'France', status == 'open') %>%
    select(!c(website, phone, fax, description, tags, year))
  if (date != 2018){
    museefreq <- museefreq %>% select(id,stats) 
  }
  pdate <- paste('payant', date, sep = '.')
  gdate <- paste('gratuit',date, sep ='.')
  tdate <-paste('total',date, sep ='.')
  museefreq <-  museefreq %>%
    separate(stats, c(pdate, gdate, 'label-date'), sep = ';') %>%
    select(!`label-date`)
  museefreq[,pdate]<-  as.numeric(apply(as.matrix(museefreq[,pdate]),1, substring,first=8))
  museefreq[,gdate] <-  as.numeric(apply(as.matrix(museefreq[,gdate]),1, substring,first=9))
    museefreq[,tdate] <- museefreq[,pdate] + museefreq[,gdate]
  return(museefreq)
}

recupdata <- function(){
  lmusee = paste('frequentation-musees-de-france-',2018:2013,'.csv',sep = '')
  list.musee = lapply(lmusee, net)
  museefreq <- list.musee[[1]]
  for (i in 2:(length(list.musee))){
    museefreq <- inner_join(museefreq, list.musee[[i]])
  }
  
  museefreq <-  museefreq %>% filter(lon > (-20) & lon < 25)
  loc_musee <- read_delim(paste('DATA/','liste-et-localisation-des-musees-de-france.csv', sep=''),delim = ';')
  loc_musee <- loc_musee %>% select(c(2,6,8,14,15))
  musee <- inner_join(loc_musee, museefreq, by = c('ref_musee'='id'))
  return(musee)
}

#Carte

testurl <- function(texte){
  for (chaine in strsplit(texte, " ")[[1]]){
    if(grepl("^http" ,chaine)){return(chaine)}
    if(grepl("^www.",chaine)){return(paste("http://", chaine, sep=""))}
  }
  return(F)
}

fpopup <- function(rdt){
  rdt = data.frame(t(rdt))
  popup = "
  <head>
 <style>
 .leaflet-container a{
  text-decoration:none;
  color:#0078A8}
a:hover{color:Black}

h4{color:none;}
#txt{margin-left:5px;}
#ad, #txt{
    display: inline-block;
    vertical-align: top;}
.leaflet-container p{color:#293133;}
 </style>
 <meta charset='UTF-8'>
</head><body>"
  title = paste('<h4>', as.character(rdt$name), "</h4>")
  if (testurl(rdt$sitweb) != F){
    popup = popup %>% paste("<a href='", testurl(rdt$sitweb), "' target=_blank>", title, "</a>", sep ="")
  }else{
    popup = popup %>% paste(title)
  } 
  popup = popup %>% paste('<p id="ad"><strong>Adresse:</strong></p>')
  rdt = unite(rdt, "ad", number, street, sep=' ',na.rm = T)
  if(is.na(rdt$postal_code)){
    popup = popup %>% paste('<p id="txt">', rdt$ad , "<br>", rdt$city,"</p>", sep="")
  }else{
    popup = popup %>% paste('<p id="txt">', rdt$ad , "<br>", rdt$postal_code, " ", rdt$city,"</p>", sep="")
  }
  popup = popup %>% paste('<p><strong>Téléphone: </strong>', rdt$telephone1, "</p>", sep="")
  popup = popup %>% paste('<p><strong>Total visiteur en 2018: </strong>', rdt$total.2018, "</p></body>", sep="")
  return(popup)
}

## Geocode 

if (!(require(jsonlite))) install.packages("jsonlite")
mygeocode <- function(adresses){
  # adresses est un vecteur contenant toutes les adresses sous forme de chaine de caracteres
  nominatim_osm <- function(address = NULL){
    ## details: http://wiki.openstreetmap.org/wiki/Nominatim
    ## fonction nominatim_osm proposée par D.Kisler
    if(suppressWarnings(is.null(address)))  return(data.frame())
    tryCatch(
      d <- jsonlite::fromJSON(
        gsub('\\@addr\\@', gsub('\\s+', '\\%20', address),
             'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0&limit=1')
      ), error = function(c) return(data.frame())
    )
    if(length(d) == 0) return(data.frame())
    return(c(as.numeric(d$lon), as.numeric(d$lat)))
  }
  tableau <- t(sapply(adresses,nominatim_osm))
  colnames(tableau) <- c("lon","lat")
  return(tableau)
}
        
