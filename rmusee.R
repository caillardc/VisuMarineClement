library(tidyverse)

net <- function(data){
  museefreq = read_csv(data, locale=locale())
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

lmusee = paste('frequentation-musees-de-france-',2018:2013,'.csv',sep = '')
list.musee = lapply(lmusee, net)
museefreq <- list.musee[[1]]
for (i in 2:(length(list.musee))){
  museefreq <- inner_join(museefreq, list.musee[[i]])
}

museefreq <-  museefreq %>% filter(lon > (-20) & lon < 25)
loc_musee <- read_delim('liste-et-localisation-des-musees-de-france.csv',delim = ';')
loc_musee <- loc_musee %>% select(c(2,6,8,14,15))
musee <- inner_join(loc_musee, museefreq, by = c('ref_musee'='id'))µ
#TEST BG
#non pas bg
