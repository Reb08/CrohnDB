# ------------------------------------------------------------------EXPLORE PAGE ---------------------------------------------------------

tabPanel(title=list(icon("binoculars"), "Explore"),
         
         titlePanel(h1("Explore Results",  style = "color:#2c3e50")),
         
         fluidRow(
           column(6,
                  
                  fluidRow(
                    column(6,
                           selectInput("study", h5("Select Study", style = "color:#2c3e50"),  # allow user to select study
                                       choices = list("GSE66207", "GSE99816", "GSE164871"),
                                       selected="GSE66207")),
                    column(6,
                           div(
                             style="margin-bottom: -2px",
                             helpText("Select conditions to analyse within the selected study")),
                           selectInput("comparison", h5("Select Comparison", style="color:#2c3e50; margin-top: -1px; margin-bottom:3px"),  # allow user to select the comparisons to look at within a study. The options will be updated from NULL to the right ones when the study is selected (see app.R)
                                       choices = NULL))
                  ),
                  
                  fluidRow(
                    column(3, align="center",
                           numericInput("FC",
                                        h5("Select logFC threshold", style= "color:#2c3e50"),  # allow user to log2FC threshold value
                                        value=1)),
                    
                    column(3, align="center",
                           numericInput("FDR",   
                                        h5("Select FDR threshold", style= "color:#2c3e50"),   # allow user to FDR threshold value
                                        value=0.05)),
                    
                  ),
                  
                  br(),
                  fluidRow(
                    column(4,
                           titlePanel(h3("Result Table", style = "color:#2c3e50")),
                           helpText("RNA-sequencing analysis results")),
                    column(4,
                           div(tags$label(), style = "margin-bottom: 5px"),
                           div(downloadButton('downloadResultTable', 'Download', class = "btn-primary")),
                           helpText("Download Result Table in .tsv format"),
                           
                           tags$script(
                             "var downloadTimeout;
           $(document).on('click', '#downloadResultTable', function(){
             $('#downloadResultTable').removeClass('btn-primary').addClass('btn-success');
             var timeoutSeconds = input$study == 'GSE154416' ? 38 : 10;
             downloadTimeout = setTimeout(function(){
               $('#downloadResultTable').removeClass('btn-success').addClass('btn-primary');
             }, timeoutSeconds * 1000); // Change the button back to blue after the specified seconds
           });
           $(document).ajaxComplete(function(event, xhr, settings) {
             clearTimeout(downloadTimeout); // Clear the timeout when the download is complete
             $('#downloadResultTable').removeClass('btn-success').addClass('btn-primary');
           });
           ")
                    )
                    
                  ),
                  # titlePanel(h3("Result Table",  style = "color:#2c3e50")),
                  # helpText("RNA-sequencing analysis results"),
                  fluidRow(
                    column(12,
                           DT::dataTableOutput("table") %>% withSpinner(color="#0dc5c1"))  # main table on the left hand side of Explore Tab
                  ),
                  
           ), # end column
           
           column(6,
                  tabsetPanel(
                    tabPanel("Volcano Plot", h3("Volcano Plot", style = "color:#2c3e50"),
                             helpText("Volcano plot showing differentially expressed genes from the selected study and comparison" 
                             ),
                             br(),
                             br(),
                             
                             fluidRow(
                               column(1,
                                      hidden(selectInput("gene", "Select a gene from the table:", choices = NULL))),  # this will allow user to select a specific row form the table (choices updated in app.R)
                               
                               column(5,
                                      plotlyOutput("boxplot", width=350, height=300) %>% withSpinner(color="#0dc5c1")),
                               
                               column(5, align = "left",
                                      tableOutput("summary_table"))  # count matrix on the right had side of volcanoPlot tab which shows number of up-and down-regulated genes in selected study and comparison
                             ),
                             
                             br(), 
                             br(),
                             
                             fluidRow(
                               column(11, offset=1,
                                      plotOutput("volcano", hover = T) %>% withSpinner(color="#0dc5c1"))
                             ),
                             
                             br(),
                             br(),
                             
                    ),
                    
                    # heatmap (can choose between displaying lncRNAs or protein-coding genes) 
                    
                    tabPanel("Heatmap", h3("Heatmap", style = "color:#2c3e50"),
                             helpText("Heatmap of differentially expressed genes from the selected study and comparison. CPM were used to generate the plot"),
                             br(),
                             br(),
                             fluidRow(
                               column(5,
                                      radioButtons("gene_type2", 
                                                   h5("Select gene type", style = "color:#2c3e50"),
                                                   choices = list("lncRNA genes", "Protein-coding genes"),
                                                   selected="lncRNA genes")),
                               column(5, 
                                      div(tags$label(), style = "margin-bottom: 5px"),
                                      div(actionButton("fullscreen", "Full Screen", class = "btn-primary")),
                                      helpText("Visualise heatmap in full screen mode"))
                               
                             ),
                             
                             br(),
                             fluidRow(
                               column(11, offset = 1, 
                                      # fullscreen_this(plotlyOutput("heatmap"), click_id = "fullscreen"))
                                      plotlyOutput("heatmap"))
                             ),
    
                    ),
                    
                    # Gene ontology plot (can choose between up-regulated or down-regulated genes)
                    
                    tabPanel("GO Analysis", h3("Gene Ontology Analysis", style = "color:#2c3e50"),
                             helpText("Perform Gene Ontology overepresentation test using gprofiler2 (a list of at least 10 genes is required). FDR was used for multiple tesing correction."),
                             
                             fluidRow(
                               column(6,
                                      radioButtons("expression", 
                                                   h5("Select expression pattern", style = "color:#2c3e50"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               
                             ),
                             
                             fluidRow(
                               column(10, offset = 1,
                                      plotlyOutput("GO", width=750, height=400)  %>% withSpinner(color="#0dc5c1")),
                             ),
                             
                             hidden(p("Sorry, no enough DEGs identified",
                                      id = "no_DEGs",
                                      style = "color:black; text-align: center; position: absolute; top: 50%; left: 75%; transform: translate(-50%, -25%);")
                             ),
                             
                             hidden(p("Sorry, no enriched terms found",
                                      id = "no_terms",
                                      style = "color:black; text-align: center; position: absolute; top: 50%; left: 75%; transform: translate(-50%, -25%);")
                             ),
                             
                             br(),
                             
                             fluidRow(
                               column(10, offset=2,
                                      DT::dataTableOutput("GO_table") %>% withSpinner(color="#0dc5c1"))
                             )
                    ),
                    
                    # Pathway analysis (can choose between up-regulated or down-regulated genes)
                    
                    tabPanel("Pathway Analysis", h3("KEGG Pathway Analysis", style = "color:#2c3e50"),
                             helpText("Perform Over-representation KEGG Pathway analysis using clusterProfiler (a list of at least 10 genes is required). Shows 20 top results"),
                             
                             fluidRow(
                               column(6,
                                      radioButtons("expression2", 
                                                   h5("Select expression pattern", style = "color:#2c3e50"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               
                             ),
                             
                             plotOutput("KEGG") %>% withSpinner(color="#0dc5c1")
                    ), 
                    
                    # UpSet plot
                    
                    tabPanel("Comparisons Intersection", h3("Shared DEGs among comparisons", style = "color:#2c3e50"),
                             helpText("Shows the DEGs shared among the different comparisons of one study"),
                             
                             fluidRow(
                               column(4,
                                      radioButtons("expression3", 
                                                   h6("Select expression pattern", style = "color:#2c3e50"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               column(3,
                                      selectInput("condition1",  h6("Select first condition", style = "color:#2c3e50"), choices = NULL)),

                               column(3,
                                      selectInput("condition2", h6("Select second condition", style = "color:#2c3e50"), choices = NULL)),
                               
                               column(2, 
                                      radioButtons("show_all", h6("Show all comparisons", style = "color:#2c3e50"), choices = c("Yes", "No"), selected = "No")
                                 
                               )
                               
                               
                             ),
                             
                             fluidRow(
                               column(10, offset = 1, 
                                        plotOutput("VENN") %>% withSpinner(color="#0dc5c1")
                               )
          
                             ),
                             
                             br(),
                             
                             fluidRow(
                               column(9, offset=2,
                                      conditionalPanel(
                                        condition = "!input$show_all",
                                        hidden(p("Shared genes", id="title")),   
                                        verbatimTextOutput("VENN_info", placeholder = F),
                                        tags$head(tags$style(HTML("#VENN_info{overflow-y:scroll; 
                                                                  height: 100px;
                                                                  width: 400px; 
                                                                  max-width: 100%;
                                                                  white-space: pre-wrap;
                                                                  padding: 10ps 12 px;}")))
                                      )
                               )
                             ),
                          
                             
                             br(),
                             hidden(p("Only one comparison in this study. No intersection available",
                                      id = "p_onecomparison",
                                      style = "color:black; text-align: center; position: absolute; top: 50%; left: 75%; transform: translate(-50%, -25%);")
                             )
                             
                    )
                  
                    
                  ) # end tabsetPanel
           ) # end column
           
         ) # end fluidRow     
         
)