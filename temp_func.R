require(ggplot2)
require(dplyr)
require(scales)
require("sqldf")
library(ggthemes)
library(ggvis)
library(RPostgreSQL)
library(zoo)

options(sqldf.RPostgreSQL.user ="usr", 
        sqldf.RPostgreSQL.password ="pass",
        sqldf.RPostgreSQL.dbname ="env_measures",
        sqldf.RPostgreSQL.host ="10.77.0.1", 
        sqldf.RPostgreSQL.port =5432)


loc<-sqldf("select idlocation,location from locations")#,dbname = dbpath)

GetTempValues<-function(locids,startdate=NULL,enddate=NULL){
  require(sqldf)
  if(is.null(locids))
    return(NULL)
  
  query<-paste("select * from messwerte where locationid in (",paste(locids,collapse=","),")")
  if (!is.null(startdate)){
    ed<-ifelse( is.null(enddate),as.character(Sys.Date()+1),as.character(enddate))
    query<-paste(query," and timestamp between '",as.character(startdate),"' and '",ed,"'",sep="")
  }
  
  return (sqldf(query))
  
}


tdata<-GetTempValues(c(1,2,3),startdate = '06.06.2015',enddate = NULL)

testdat<-tdata%>%mutate(tag=as.Date(timestamp, format = '%d.%m.%Y',tz=""),ishot=ifelse(temp>26.0,TRUE,FALSE),
               zeit=strftime(timestamp, format = '%H:%M:%S'))%>%
  group_by(tag,locationid,ishot)%>%summarise(mintime=min(timestamp)
                                             ,maxtime=max(timestamp)
                                             ,diff=difftime(max(timestamp),min(timestamp), 
                                                       units = "min")
                                             ,ant=round((100/1440)*difftime(max(timestamp),min(timestamp), 
                                                                units = "min"),2)
                                             )%>%mutate(Anteil=ifelse(ishot==TRUE,ant,0))%>%
          select(tag,locationid,Anteil)




## Verlauf
data<-tdata%>%filter(locationid==1)%>%mutate(
  col_temp=ifelse(temp<20,"palegreen3",ifelse(temp<=26,"goldenrod1","tomato1")))
ggplot(data,aes(timestamp,temp))+,#color=col_temp))+
  geom_polygon()+
  scale_x_datetime(breaks = date_breaks("day"))+
  scale_colour_identity("temp", breaks=data$col_temp)

## ANteil
dat<-testdat%>%filter(locationid==1,Anteil>0)


ggplot(dat,aes(x=as.POSIXct(tag),y=Anteil,fill=ifelse(dat$Anteil>10,"darkred","darkgreen"),alpha=0.9))+
  geom_bar(stat = "identity")+scale_x_datetime(breaks = date_breaks("day"))+
  scale_fill_identity("Anteil", breaks=ifelse(dat$Anteil>10,"darkred","darkgreen"))


# 
# testdat%>%filter(locationid==1)%>%ggvis(~as.character(tag),~Anteil, fill = ~locationid,opacity :=0.5)%>%
#   layer_bars()%>%add_axis("y", 'temp' , orient = "right", title= "Temperatur" , grid=F )
# sqldf("select * from tdata where sensorid=1 and strftime('%Y-%m-%d', timestamp)='2015-06-03'",drv="SQLite")
# 
# sqldf("select distinct strftime('%Y-%m-%d', t.timestamp) as tag,
#       (select min(timestamp) from tdata as t2 where 
#             strftime('%Y-%m-%d', t2.timestamp)=strftime('%Y-%m-%d', t.timestamp) and t2.temp>26.0) as mintime ,
# (select max(timestamp) from tdata as t2 where 
#             strftime('%Y-%m-%d', t2.timestamp)=strftime('%Y-%m-%d', t.timestamp) and t2.temp>26.0) as maxtime 
#       from tdata as t",drv="SQLite")
# 
# tdata%>%ggvis(~timestamp,~temp, fill = ~locationid,opacity :=0.5) %>% layer_points()



