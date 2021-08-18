#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(zoo)
library(shinydashboard)
library(DT)
library(ggplot2)
library(plotly)
library(highcharter)
library(data.table)

load("mydata.RData", envir = .GlobalEnv)

# Define UI for application that draws a histogram
ui <- dashboardPage(

    # Define UI for dataset viewer app ----
    header <- dashboardHeader(
        title = "Dataset Similarity"
    ),
    
    
    
    sidebar <- dashboardSidebar(  
        # Sidebar panel for inputs ----
        sidebarMenu(
            
            
        )
    ),
    
    
    body <- dashboardBody(
        tabsetPanel(type = "tabs",
                    
                    tabPanel("Gower Distribution Plot",
                             plotOutput("dist_plot")
                             ,icon = icon("bar-chart-o")),
                    
                    tabPanel("Similarity Score Plot",
                             plotlyOutput("bar_plot")
                             ,icon = icon("bar-chart-o")),
                    # 
                    # tabPanel("Gower Distance Combined",
                    #          icon = icon("table")
                    #          ,dataTableOutput("dataset1")
                    #          ,br() ,dataTableOutput("dataset2")
                    #         ),
                    tabPanel("Gower Distances Merged",
                             icon = icon("table")
                             ,dataTableOutput("merge_data")
                    ),
                    tabPanel("Combined data",
                             icon = icon("table")
                             # Input: Selector for choosing dataset ----
                            ,textInput("id","Enter Agreement Number", value ="", width = NULL, placeholder = NULL)
                             ,dataTableOutput("combined_data")
                             
                    )
                    
                    
        )
    )  
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$dist_plot <- renderPlot({
        
        ggplot(combined_data1, aes(x= `Gower Distance`, color=Months)) +
            geom_density() +
            labs(title="Gower Distribution across months")+
            ylab("Density") +
            theme(plot.title=element_text(size=15, face="bold"),
                  axis.text.x=element_text(size=10),
                  axis.text.y=element_text(size=10),
                  axis.title.x=element_text(size=15),
                  axis.title.y=element_text(size=15))
        
        #ggplotly(p)
        
        
    })
    
    output$bar_plot <- renderPlotly({
        
        p <- ggplot(data=combined_data_simmilarity, aes(x=Months, y=similarity_score, fill=Months,width=0.2)) +
            geom_bar(stat="identity")+
            xlab("Months") +
            ylab("Similarity Score")  
        # scale_x_discrete(breaks=c("Mar-Apr","Apr-May"),
        #                  labels=c("Control", "Treatment 1")) +
        # scale_fill_discrete(name="Experimental\nCondition",
        #                     breaks=c("Mar-Apr","Apr-May"),
        #                     labels=c("Control", "Treatment 1"))
        #guides(fill = guide_legend(reverse=TRUE))
        #scale_color_hue(labels = c("T999", "T888"))+
        #scale_color_manual(labels = c("T999", "T888"), values = c("blue", "red"))+
        #theme_bw()
        
        
        ggplotly(p)
        
        
    })
    
    
    
    output$merge_data <- renderDataTable({
        datatable(merge_data) %>% formatRound(c("Gower Distance Dataset1",
                                                "Gower Distance Dataset2"
                                                ,"Diff_in_gower_dist"), 3)
        
    })
    
    data <- reactive({
        
        dr <- combined_data2 %>%                    # take the data.frame "data"
            filter(`Agreement Number`== input$id) 
        
        col_list <- c("Agreement Number")
        for(i in names(dr)){
            #print(names(dr)[i])
            if(length(unique(dr[,i]))!=1){
                col_list <- c(col_list,i)
            }
        }
        
        
        return(dr[,col_list])
        
        
        
    })
    
    output$combined_data <- renderDataTable({
        
        dr <- data()
        
        datatable(dr,options = list(scrollX = TRUE)) 
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
