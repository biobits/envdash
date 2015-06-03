
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)


server <- function(input, output) {
  
  require(ggplot2)
  require(dplyr)
  require(scales)
  require("sqldf")
  library(ggthemes)
  library(RPostgreSQL)
  #datapath<-"c:/data/PiShared/data/"
  #   datapath<-"F:/PiShared/PiShared/data/"
 #datapath<-"/srv/data/PiShared/data/"
  #dbpath<-paste(datapath,"bighomedata.db",sep="")
 options(sqldf.RPostgreSQL.user ="user", 
         sqldf.RPostgreSQL.password ="pwd",
         sqldf.RPostgreSQL.dbname ="env_measures",
         sqldf.RPostgreSQL.host ="10.77.0.1", 
         sqldf.RPostgreSQL.port =5432)
  
  
  loc<-sqldf("select idlocation,location from locations")#,dbname = dbpath)
   locations<-setNames(loc$idlocation,loc$location)
  output$choose_loc <- renderUI({
  selectInput("locations",choices=locations,label="Location",selected=3)})
  
  histdat<- reactive({
  
    datborder<-Sys.Date()-input$time_adjust
    
    locid<-ifelse(is.null(input$locations),1,input$locations) 
    query<-paste("select * from messwerte where locationid= ",locid," and timestamp between '",as.character(datborder),"' and '",as.character(Sys.Date()+1),"'",sep="")
    data2<-sqldf(query)#,dbname = dbpath)
    data<-data2%>%mutate(date2=as.POSIXct(strptime(timestamp,"%Y-%m-%d %H:%M:%S")),col_temp=ifelse(temp<20,"palegreen3",ifelse(temp<=26,"goldenrod1","tomato1")))%>%arrange(desc(date2))
    
    
  })
  
  
  
  akt_dat<-reactive({
    
    data<-histdat()
    locsub<-loc%>%filter(idlocation==as.numeric(input$locations))
    data%>%top_n(1,date2)%>%mutate(location=paste(locsub$location),col_temp2=ifelse(temp<20,"green",ifelse(temp<=26,"yellow","red")))
    
  })
  
  output$dateBox <- renderValueBox({
    
    curr_dat<-akt_dat()
    t<-strftime(curr_dat$date2,"%H:%M:%S") 
    d<-strftime(curr_dat$date2,"%d-%m-%Y") 
    valueBox(t, d, icon = icon("clock-o"),color = "light-blue",width = 4)
  })
  
  output$temp1Box <- renderValueBox({
    
    curr_dat<-akt_dat()
    valueBox(
      paste0(curr_dat$temp, "°"), paste("Temp.",curr_dat$location), icon = icon("cloud"),color = curr_dat$col_temp2,width = 4)
  })
  output$hum1Box <- renderValueBox({
    curr_dat<-akt_dat()
    valueBox(
      paste0(curr_dat$hum, "%"), paste("Hum.",curr_dat$location), icon = icon("flask"),color = "olive",width = 4)
  })
  
  output$plot_temp1<-renderPlot({
    data<-histdat()
    dbreak<-if(input$time_adjust<=2){"4 hours"}else{"1 day"}
    ggplot(data,aes(date2,temp,color=col_temp))+geom_point()+scale_x_datetime(breaks = date_breaks(dbreak))+scale_colour_identity("temp", breaks=data$col_temp)
    
    
  })
  
  
}
