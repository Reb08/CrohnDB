# ----------------------------------------------------------------------DOWNLOAD PAGE ----------------------------------

tabPanel(title=list(icon("download"),"Download"),
         
         titlePanel(div(HTML("Download <em>CrohnDB</em> Data"), style="color:#2c3e50")),
         
         p("All data in CrohnDB were processed from a snakemake pipeline available in the Analysis_of_CD_Studies ", tags$a(href="https://github.com/heartlncrna/Analysis_of_CD_Studies", "GitHub Repository")),
         
         fluidRow(
           column(3,
                  selectInput("dataset", h5("Select a dataset", style = "color:#2c3e50"),
                              choices = c("GSE66207", "GSE99816", "GSE164871")),  # allow user to select dataset to download
                  radioButtons("filetype", "File type:",
                               choices = c("csv", "tsv")),  # allow user to select type of file
                  
                  downloadButton('downloadData', 'Download', class = "btn-primary"), 
                  br(),
                  helpText("It takes between 10-30 seconds for the download window to appear"),
                  
           ), # end column
           
           column(9,
                  div(DT::dataTableOutput("table2"), style = "font-size: 85%; width: 90%"))
         ) # end fluidRow
         
         
)