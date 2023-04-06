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
                           helpText("Select conditions to analyse within the selected study"),
                           selectInput("comparison", h4("Select Comparison", "color:#2c3e50"),  # allow user to select the comparisons to look at within a study. The options will be updated from NULL to the right ones when the study is selected (see app.R)
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
                  titlePanel(h3("Result Table",  style = "color:#2c3e50")),
                  helpText("RNA-sequencing analysis results"),
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
                               
                               column(10, align = "right",
                                      tableOutput("summary_table"))  # count matrix on the right had side of volcanoPlot tab which shows number of up-and down-regulated genes in selected study and comparison
                             ),
                             
                             br(),
                             br(),
                             fluidRow(
                               column(11, offset=1,
                                      plotOutput("volcano") %>% withSpinner(color="#0dc5c1"))
                             ),
                             
                             br(),
                             br(),
                             
                    ),
                    
                    # heatmap (can choose between displaying lncRNAs or protein-coding genes) 
                    
                    tabPanel("Heatmap", h3("Heatmap", style = "color:#2c3e50"),
                             helpText("Heatmap of differentially expressed genes from the selected study and comparison. CPM were used to generate the plot"),
                             br(),
                             br(),
                             radioButtons("gene_type2", 
                                          h5("Select gene type", style = "color:#2c3e50"),
                                          choices = list("lncRNA genes", "Protein-coding genes"),
                                          selected="lncRNA genes"),
                             br(),
                             fluidRow(
                               column(11, offset = 1, 
                                      plotOutput("heatmap"))
                             )
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
                               column(12,
                                      plotOutput("GO")  %>% withSpinner(color="#0dc5c1")),
                             ),
                             
                             br(),
                             br(),
                             
                             fluidRow(
                               column(10, offset=1,
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
                               column(6,
                                      radioButtons("expression3", 
                                                   h5("Select expression pattern", style = "color:#2c3e50"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               
                             ),
                             
                             plotOutput("UPSET") %>% withSpinner(color="#0dc5c1"),
                             
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