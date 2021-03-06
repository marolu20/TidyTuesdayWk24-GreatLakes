library(tidyverse)
library(purrr)
library(tidyr)
library(ggplot2)
library(dplyr)
library(scales)
library(Hmisc)
library(shinythemes)
library(RColorBrewer)
library(ggthemes)
library(ggtext)

#https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-06-08/readme.md
#http://www.glfc.org/fishstocking/dbstruct.htm

#load data
tuesdata <- tidytuesdayR::tt_load(2021, week = 24)
stocked <- tuesdata$stocked
df<-stocked

#remove unnecessary columns
df = df %>%
  select(c('YEAR','MONTH','DAY', 'LAKE','STATE_PROV','SPECIES','NO_STOCKED','AGEMONTH', 'WEIGHT', 'CONDITION'))

#remove decimals from condition variables
df$CONDITION = trunc(df$CONDITION)

#impute missing values
df$MONTH = with(df, impute(MONTH, median))
df$DAY = with(df, impute(DAY, median))
df$CONDITION = with(df, impute(CONDITION, median))

#view obs where day = 0 and change it to 1
subset(df, DAY==0)
df[df$DAY==0,'DAY'] = 1
subset(df, DAY==0)  

view(df)

#convert the condition numeric variable to dummy
df$CONDITION = as.factor(df$CONDITION)

#create csv of cleaned data
write.csv(df,"stocked_clean.csv", row.names = FALSE)

#df<-read.csv("stocked_clean.csv")

# List of 6 lakes
lake_list<-list("Michigan" = "MI",
                "Superior"="SU",
                "Ontario" = "ON",
                "Erie"="ER", 
                "Huron"="HU", 
                "Saint Clair"="SC") 

# List of species

species_list<-list( "ATS"="Atlantic Salmon","BKT"="Brook Trout","BNT"="Brown Trout",
                    "COS"="Coho Salmon","CHS"="Chinook Salmon", "LAH"="Lake Herring","LAS"="Lake Sturgeon","LAT"="Lake Trout","MUE"="Muskllunge",
                    "NOP"="Northern Pike", "RBT"="Rainbow Trout","SMB"="Smallmoouth Bass","SPE"="Splake", "STN"="Sturgeon",
                    "TIM"="Tiger Muskellunge","TRT"="Tiger Trout", "WAE"="Walleye", "YEP"="Yellow Perch")

df_species<-as.data.frame(do.call(rbind, species_list)) 
names(df_species)[1]<-"Species_name"
df_species <- cbind(Abbreviation = rownames(df_species), df_species)
rownames(df_species) <- 1:nrow(df_species)

#List of Conditions
levels(df$CONDITION) = list("Unknown"=0, "Excellent"=1, "Good"=2, "Fair"=3, "Bad"=4, "Very Bad"=5, "Mortality is Reported"=6, "Distressed or Sick"=7)


ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("Great Lakes Fish Stock From 1950 To 2018"), # Application title
  
  sidebarLayout(
    sidebarPanel(
      h3("Choose a lake to visualize fish stock"),
      selectInput(inputId = "lake", "Lake:",
                  choices = lake_list),
      h3("Choose a year to visualize fish stock"),
      sliderInput(inputId = "YEAR", "Year:", sep = "", min = 1950,  max = 2018, value = 2018, step = 1), 
      actionButton(inputId = "action", "Run"),
      tableOutput(outputId ="Species_table")
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Number of Fish Stocked", value = "fish_stock_number", plotOutput(outputId = "fish_number", height = "600px", width = "800px")),
                  tabPanel("Weight of Fish Stocked", value = "fish_stock_weight", plotOutput(outputId = "fish_weight", height = "600px", width = "800px")),
                  tabPanel("Condition of Fish Stocked", value = "fish_stock_condition", plotOutput(outputId = "fish_condition", height = "600px", width = "800px")),
                  tabPanel("Age of Fish Stocked", value = "fish_stock_Age", plotOutput(outputId = "fish_age", height = "600px", width = "800px"))
      )
    )
  )
)

server <- function(input, output) {
  
  fish <- eventReactive( 
    input$action,{ 
      withProgress({
        setProgress(message = "Getting Fish...")
        df%>%filter(df$YEAR==input$YEAR&df$LAKE==input$lake)
      })
    }
  )
  output$Species_table<-renderTable({df_species})
  output$fish_number<-renderPlot({
    v <- fish()
    pal <- brewer.pal(8,"Dark2")
    
    v %>% 
      ggplot(aes(x=SPECIES, y=NO_STOCKED, fill = STATE_PROV))+
      geom_bar(stat="identity")+
      labs(title = "Number of Fish Stocked",
           x = "State Province", y = "Total Number of Fish Stocked",
           fill = "State")+
      theme_wsj() +
      theme(
        axis.title = element_blank()
      ) +
      facet_wrap(~STATE_PROV, scales = "free_y")+
      scale_y_continuous(labels = comma)+
      theme(legend.position = "none",
            strip.text = element_text(size = 20))+
      theme(plot.title = element_markdown(size = 26, hjust = 0.5),
            axis.title.x.bottom=element_text(size =16, face="bold", vjust=-5.0),
            axis.title.y.left=element_text(size =16, face="bold", vjust=5.0),
            plot.margin=unit(c(1,1,1,1), "cm"))
  })
  output$fish_weight<-renderPlot({
    v <- fish()
    pal <- brewer.pal(8,"Dark2")
    
    v %>% 
      ggplot(aes(x=SPECIES, y=WEIGHT, fill = STATE_PROV))+
      geom_bar(stat="identity")+
      labs(title = "Weight of Fish Stocked",
           x = "State Province", y = "Weight (in Thousand Pounds)",
           fill = "State")+
      theme_wsj() +
      theme(
        axis.title = element_blank(),
      )+
      facet_wrap(~STATE_PROV, scales = "free_y")+
      scale_y_continuous(labels = comma)+
      theme(legend.position = "none",
            strip.text = element_text(size = 20))+
      theme(plot.title = element_markdown(size = 30, hjust = 0.5),
            axis.title.x.bottom=element_text(size =16, face="bold", vjust=-5.0),
            axis.title.y.left=element_text(size =16, face="bold", vjust=5.0),
            plot.margin=unit(c(1,1,1,1), "cm"))
  })
  output$fish_condition<-renderPlot({
    v <- fish()
    pal <- brewer.pal(8,"Dark2")
    
    v %>% 
      ggplot(aes(x=SPECIES, y=NO_STOCKED, fill = CONDITION))+
      geom_bar(position= "dodge", stat="identity") +
      labs(title = "Condition of Fish Stocked",
           x = "Condition", y = "Total Number of Fish Stocked")+
      theme_wsj() +
      theme(
        axis.title = element_blank(),
        legend.margin = margin(20,0,0,0),
        strip.text = element_text(size = 20)
      )+
      facet_wrap(~STATE_PROV, scales = "free_y") +
      scale_y_continuous(labels = comma)+
      theme(plot.title = element_markdown(size = 30, hjust = 0.5),
            axis.title.x.bottom=element_text(size =16, face="bold", vjust=-5.0),
            axis.title.y.left=element_text(size =16, face="bold", vjust=5.0),
            plot.margin=unit(c(1,1,1,1), "cm"))
  })
  output$fish_age<-renderPlot({
    v <- fish()
    pal <- brewer.pal(8,"Dark2")
    
    v %>% 
      ggplot(aes(x=SPECIES, y=NO_STOCKED, fill = AGEMONTH))+
      geom_bar(position= "dodge", stat="identity")+
      labs(title = "Age of Fish Stocked",
           x = "Age (in Month)", y = "Total Number of Fish Stocked",
           fill = "Age")+
      theme_wsj() +
      theme(
        axis.title = element_blank(),
        legend.margin = margin(20,0,0,0),
        strip.text = element_text(size = 20)
      )+
      facet_wrap(~STATE_PROV, scales = "free_y") +
      scale_y_continuous(labels = comma)+
      theme(plot.title = element_markdown(size = 30, hjust = 0.5),
            axis.title.x.bottom=element_text(size =16, face="bold", vjust=-5.0),
            axis.title.y.left=element_text(size =16, face="bold", vjust=5.0),
            plot.margin=unit(c(1,1,1,1), "cm"))
  })
  
}

shinyApp(ui = ui, server = server)