library(shiny)
library(BiocManager)
options(repos = BiocManager::repositories())
library(shinyWidgets)
library(shinyjs)
library(shinycssloaders)
library(ggplot2)
library(dplyr)
library(DT)
library(tibble)
library(bslib)
library(shinydashboard)
library(data.table)
library(pheatmap, include.only = "pheatmap")
library(RColorBrewer, include.only = "brewer.pal")
library(tableHTML)
library(gprofiler2, include.only = c("gost", "gostplot"))
library(enrichplot)
library(clusterProfiler)
library(org.Hs.eg.db)
library(AnnotationDbi)
library(VennDiagram)
library(eulerr)
library(plotly)
library(heatmaply)
library(tidyverse)
library(htmlwidgets)
library(ggplotify)
library(shinyfullscreen)
library(UpSetR, include.only = c("upset", "fromList"))



################### Helper function #############################################

footerHTML <- function() {  # defines style of the footer
  "
    <footer class='footer' style='background-color: #2c3e50; color: white; height: 1cm; display: flex; justify-content: center; align-items: center;'>
      <div>
        <span style='margin: 0;'>CrohnDB © 2023 Copyright:</span>
        <a href='http://heartlncrna.github.io' target='_blank' style='color:white;'>heartlncrna</a>
        <span>&nbsp</span>
        <a href='https://github.com/Reb08/CrohnDB/' target='_blank'> 
          <img src='GitHub-Mark-Light-64px.png' height='20'>
      </div>
    </footer>
  "
}


titleHTML <- function() {  # defines style of the footer
  "
      <div>
        <h5 style='color:white;'>Select first comparison</h5>
        <span>&nbsp</span>
      </div>
  "
}


# colors used in heatmap
mypalette <- brewer.pal(11,"RdYlBu")
morecols <- colorRampPalette(mypalette)
myCol2 <- brewer.pal(3, "Pastel2")

########################################### shiny app ########################################

ui <- fluidPage(
  
  useShinyjs(),
  
  tags$head(
    tags$link(rel = "stylesheet", href = "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"),
    tags$style(  # details position of footer
      HTML("
           html {
           position: relative;
           min-height: 100%;
           }
           
           body {
           margin-bottom: 1cm;
           padding-bottom: 20px; /* add margin to the top */
           }
           
           .footer {
           position: absolute;
           bottom: 0;
           width: 100%;
           background-color: #2c3e50;
           color: white;
           height: 1cm;
           display: flex;
           justify-content: center;;
           align-items: center;
           }
        ")
    ),
    tags$script(
      "var downloadTimeout;
           $(document).on('click', '#downloadData', function(){
             $('#downloadData').removeClass('btn-primary').addClass('btn-success');
             var timeoutSeconds = input$dataset == 'GSE154416' ? 38 : 10;
             downloadTimeout = setTimeout(function(){
               $('#downloadData').removeClass('btn-success').addClass('btn-primary');
             }, timeoutSeconds * 1000); // Change the button back to blue after the specified seconds
           });
           $(document).ajaxComplete(function(event, xhr, settings) {
             clearTimeout(downloadTimeout); // Clear the timeout when the download is complete
             $('#downloadData').removeClass('btn-success').addClass('btn-primary');
           });
           ")
    ),
  
  
  # theme
  theme = bslib::bs_theme(bootswatch = "cerulean",
                          primary = "#2c3e50"),
  
  navbarPage(
    "CrohnDB",
    
    source(file.path("ui", "HomePage.R"), local=TRUE)$value,
    source(file.path("ui", "ExplorePage.R"), local=TRUE)$value,
    source(file.path("ui", "DownloadPage.R"), local=TRUE)$value,
    source(file.path("ui", "DocumentationPage.R"), local=TRUE)$value
    
  ),# end navbarPage
    
  tags$footer(HTML(footerHTML()))
)




server <- function(input, output, session){
  
  studyInput <- reactive({
    if(input$study == "GSE66207"){
      data <- data.frame(data.table::fread("data/GSE66207-All.txt"))
    } else if (input$study == "GSE99816"){
      data <- data.frame(data.table::fread("data/GSE99816-All.txt"))
    } else {
      data <- data.frame(data.table::fread("data/GSE164871-All.txt"))
    }
    
    on.exit(rm(data))
    
    return(data)
  })
  
  
  # change the options for the "comparison" drop down menu (in ExplorePanel.R) based on the study selected in the "study" drop down menu (in ExplorePanel.R)
  comparisons <- reactive({
    if(input$study == "GSE66207"){
      c("Crohn_B1 vs Control",
        "Crohn_B2 vs Control",
        "Crohn_B2 vs Crohn_B1",
        "Crohn_B3 vs Control",
        "Crohn_B3 vs Crohn_B1",
        "Crohn_B3 vs Crohn_B2")
    } else if (input$study == "GSE99816"){
      c("CD vs Control", 
        "INF vs Control",
        "NINF vs Control",
        "INF vs NINF",
        "STEN vs Control",
        "STEN vs INF",
        "STEN vs NINF")
    } else {
      c("Crohn vs Control")
      
    }
  })
  
  
  observeEvent(input$study, {
    updateSelectInput(
      session,
      inputId = "comparison",
      #label = "Select Comparison",
      choices = comparisons(),
      selected = comparisons()[1]
    )
  })
  
  studyInput_mutated <- reactive({
    
    if (input$study == "GSE99816") {
      
      df <- studyInput()[studyInput()$Comparison == input$comparison, ] %>%
        mutate(
          Significance = case_when(
            logFC > input$FC & PValue < input$FDR & Biotype == "protein_coding" ~ "Up-reg protein-coding gene",
            logFC > input$FC & PValue < input$FDR & Biotype == "lncRNA" ~ "Up-reg lncRNA",
            logFC < -input$FC & PValue < input$FDR & Biotype == "protein_coding" ~ "Down-reg protein-coding gene",
            logFC < -input$FC & PValue < input$FDR & Biotype == "lncRNA" ~ "Down-reg lncRNA",
            TRUE ~ "Unchanged"))
      
    } else {
      
      df <- studyInput()[studyInput()$Comparison == input$comparison, ] %>%
        mutate(
          Significance = case_when(
            logFC > input$FC & FDR < input$FDR & Biotype == "protein_coding" ~ "Up-reg protein-coding gene",
            logFC > input$FC & FDR < input$FDR & Biotype == "lncRNA" ~ "Up-reg lncRNA",
            logFC < -input$FC & FDR < input$FDR & Biotype == "protein_coding" ~ "Down-reg protein-coding gene",
            logFC < -input$FC & FDR < input$FDR & Biotype == "lncRNA" ~ "Down-reg lncRNA",
            TRUE ~ "Unchanged"))
    }
    
    on.exit(rm(df))
    
    return(df)
  })
  
  
  
  # allow user to select a row in table
  selected_row <- reactive({
    data.frame(Ensembl.Gene.ID = character(),
               Gene.Symbol = character(),
               logFC = numeric(),
               FDR = numeric(),
               Biotype = character(),
               Significance = character())
  })
  
  observeEvent(input$table_rows_selected, {
    row_index <- input$table_rows_selected
    row_name <- studyInput_mutated()[row_index, "Gene.Symbol"]
    updateSelectInput(session, "gene", choices = row_name, selected=row_name[1])  
  })
  
  selected_row <- reactive({
    row_name <- input$gene
    if (!is.null(row_name)) {
      studyInput_mutated()[studyInput_mutated()$Gene.Symbol == row_name, ]
    } else {
      data.frame(Ensembl.Gene.ID = character(),
                 Gene.Symbol = character(),
                 logFC = numeric(),
                 FDR = numeric(),
                 Biotype = character(),
                 Significance = character())
    }
  })
  
  source(file.path("server", "mainTable.R"), local=TRUE)$value
  source(file.path("server", "boxPlot2.R"), local=TRUE)$value
  source(file.path("server", "summaryTable.R"), local=TRUE)$value
  source(file.path("server", "volcanoPlot.R"), local=TRUE)$value
  source(file.path("server", "heatmapPlot.R"), local=TRUE)$value
  source(file.path("server", "GOPlot.R"), local=TRUE)$value
  source(file.path("server", "KEGGPlot.R"), local=TRUE)$value
  source(file.path("server", "upsetPlot.R"), local=TRUE)$value
  source(file.path("server", "downloadTable.R"), local=TRUE)$value
  
  # source(file.path("mainTable.R"), local=TRUE)$value
  # source(file.path("boxPlot2.R"), local=TRUE)$value
  # source(file.path("summaryTable.R"), local=TRUE)$value
  # source(file.path("volcanoPlot.R"), local=TRUE)$value
  # source(file.path("heatmapPlot.R"), local=TRUE)$value
  # source(file.path("GOPlot.R"), local=TRUE)$value
  # source(file.path("KEGGPlot.R"), local=TRUE)$value
  # source(file.path("upsetPlot.R"), local=TRUE)$value
  # source(file.path("downloadTable.R"), local=TRUE)$value
  
}


shinyApp(ui, server)



