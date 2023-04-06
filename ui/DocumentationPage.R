# --------------------------------------------------------------DOCUMENTATION PAGE ------------------------------------------

tabPanel(title=list(icon("circle-info"),"Documentation"),
         
         fluidRow(
           
           column(7, offset=2, 
                  navlistPanel(
                    tabPanel("Home",
                             h3(em("CrohnDB"), "Documentation", style = "color:#2c3e50"),
                             h6("v1.0.0", style = "color:#2c3e50"),
                             p("2023-04-  INSERT EXACT DATE"),
                             p(strong("CrohnDB"), "is a web database for", strong("accessing and exploring expression data of protein-coding and lncRNA genes in Crohn disease patients."),
                               "The data for this database was derived from three studies profiled by", em("Distefano et al., 2023."),
                               strong("CrohnDB"), "is the work of the ", tags$a(href="https://heartlncrna.github.io/", "Uchida laboratory,"), "Center for RNA Medicine, Aalborg University, and the ", tags$a(href="https://www.bioresnet.org/", "Bioinformatic Reaserch Network.")),
                             br(),
                             p("Key features:"),
                             tags$ul(
                               tags$li("View transcriptomic data across three different studies and across different conditions"),
                               tags$li("Explore differential gene expression results"),
                               tags$li("Download processed datasets")
                             )
                    ), # end tabPanel("Home")
                    
                    tabPanel("Datasets",
                             h4("Datasets", style = "color:#2c3e50"),
                             p("The current version of", strong("CrohnDB"), "contains the following datasets:"),
                             tags$ul(
                               tags$li(tags$a(href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE66207", "GSE66207:"), "RNA-seq data of colon tissue from 19 CD and 13 non-IBD control subjects. CD patients were further stratified according to disease behaviour: 5 samples from nonstricturing and nonpenetrating (B1) CD patients, 6 samples from stricturing (B2) CD patients, and 8 samples from penetrating/fistulizing (B3) CD patients"),
                               tags$li(tags$a(href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE99816", "GSE99816:"), "RNA-seq data of 21 ileal fibroblast samples from 6 control subjects and 15 CD patients. These were further divided into 4 inflamed samples (INF), 6 non-inflamed samples (NINF) and 5 stenotic samples (STEN)"),
                               tags$li(tags$a(href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE164871", "GSE164871:"), "RNA-seq data of colon tissue from 4 CD patients and 4 control subjects")
                             )
                    ),# end tabPanel("Datasets")
                    
                    tabPanel("T2DB Interfaces",
                             h4("T2DB Interfaces", style = "color:#2c3e50"),
                             tags$figure(
                               align="center",
                               tags$img(
                                 src="volcanoPage.png",
                                 width="950",
                                 alt="Picture for the result page"
                               )
                             ),
                             p(strong("'Explore Results' page"), strong("(A)"), "Controls the study which is displayed.",
                               strong("(B)"), "Controls the type of condition to focus on within the selected study.",
                               strong("(C)"), "Controls threshold for log2 Fold Change and FDR.",
                               strong("(D)"), "Result table which displays the results of the differential expression analysis for each gene in the selected comparison and study.",
                               strong("(E)"), "Summary table which displays the number of differentially expressed genes (differentiating between protein-coding and lncRNA genes) in the selected comparison and study.",
                               strong("(F)"), "Volcano plot which displays the results of the DGE analysis. Selecting a row in the 'Results table' (D) will cause the corresponding gene to be highlighted in the volcano plot."),
                             
                             
                             tags$figure(
                               align="center",
                               tags$img(
                                 src="heatmapPage.png",
                                 width="950",
                                 alt="Picture for the heatmap page"
                               )
                             ),
                             
                             p(strong("DGE Heatmap."), strong("(A)"), "Controls the expression pattern of the displayed DEGs on (B).",
                               strong("(B)"), "Heatmap of the differentially expressed genes in the selected comparison and study."),
                             
                             
                             tags$figure(
                               align="center",
                               tags$img(
                                 src="GOPage.png",
                                 width="950",
                                 alt="Picture for the GO page"
                               )
                             ),
                             
                             p(strong("Gene Ontology analysis."), strong("(A)"), "Controls the expression pattern of the DEGs used for the analysis on (B)",
                               strong("(B)"), "Gene Ontology analysis results displayed as Manhattan plot, showing the significantly enriched GO terms associated with the list of up- or down-regulated genes in the selected comparison and study",
                               strong("(C)"), "Table displaying the results of the Gene Ontology analysis shown on (B)"),
                             
                             tags$figure(
                               align="center",
                               tags$img(
                                 src="KEGGPage.png",
                                 width="950",
                                 alt="Picture for the Kegg analysis page"
                               )
                             ),
                             
                             p(strong("Pathway Analysis"), strong("(A)"), "Controls the expression pattern of the displayed DEGs on (B).",
                               strong("(B)"), "KEGG Pathway over-representation analysis results displayed as dotplot, showing the significantly enriched KEGG pathways associated with the list of up- or down-regulated genes in the selected comparison and study."),
                             
                             
                             tags$figure(
                               align="center",
                               tags$img(
                                 src="upsetPage.png",
                                 width="950",
                                 alt="Picture for the comparison page"
                               )
                             ),
                             
                             p(strong("Comparsisons Intersection."), strong("(A)"), "Controls the expression pattern of the DEGs used on (B).",
                               strong("(B)"), "This interface displays the DEGs shared among the different comparisons of the selected study as an UpSet plot. For more information, see the", tags$a(href="https://upset.app", "Upset plot documentation.")),
                             
                             tags$figure(
                               align="center",
                               tags$img(
                                 src="downloadPage.png",
                                 width="970",
                                 alt="Picture for the comparison page"
                               )
                             ),
                             
                             p(strong("Download Page."), strong("(A)"), "Controls the study which will be displayed and subsequently downloaded.",
                               strong("(B)"), "Controls the type of file used to download the desired data set (either comma-separated-values (CSV) file or tab-separated-values (TSV) file)",
                               strong("(C)"), "Preview of the data of the selected study which will be downloaded.")
                             
                    ),# end tabPanel
                    
                    tabPanel("Terminology",
                             
                             h4("Terminology", style = "color:#2c3e50"),
                             tags$ul(
                               tags$li(em("DEG:"), "Differentally Expressed Gene"),
                               tags$ul(
                                 tags$li("Differentially expressed genes refer to genes that are expressed at significantly different levels between two or more conditions. In this study, we calculated DEGs using the", tags$a(href="https://bioconductor.org/packages/release/bioc/html/edgeR.html", "edgeR"), "R/Bioconductor package.")
                               ),
                               tags$li(em("DGE:"), "Differential Gene Expression"),
                               tags$ul(
                                 tags$li("Differential gene expression refers to a significant difference in the expression of a gene between two conditions of interest.")
                               ),
                               tags$li(em("FDR:"), "False Discovery Rate"),
                               tags$ul(
                                 tags$li("The false discovery rate is a metric used to correct for multiple testing, restricting the total number of false positives (type I errors).")
                               ),
                               tags$li(em("FC:"), "Fold Change"),
                               tags$ul(
                                 tags$li("The fold chage measures how much the expression of a gene has changed between one condition relative to the other. It is calculated by taking the ratio of the normalised gene count values (counts per million (CPM) in this case)")
                               ),
                               tags$li(em("CPM:"), "Counts per Million"),
                               tags$ul(
                                 tags$li("Counts per million is a gene count normalzation metric where the count of reads mapped to a gene is divided by the total number of reads mapped and multiplied by a million")
                               ),
                               tags$li(em("CD:"), "Crohn Disease"),
                               tags$li(em("Crohn_B1:"), "Nonstricturing and nonpenetrating Crohn disease patients"),
                               tags$li(em("Crohn_B2:"), "Stricturing Crohn disease patients"),
                               tags$li(em("Crohn_B3:"), "Penetrating/fistulizing Crohn disease patients"),
                               tags$li(em("INF:"), "Crohn disease patient samples of inflamed ileal tissue"), 
                               tags$li(em("NINF:"), "Crohn disease patient samples of non-inflamed ilead tissue"), 
                               tags$li(em("STEN:"), "Crohn disease patient samples of stenotic ilead tissue"), 
                               tags$li(em("KEGG:"), "Kyoto Encyclopedia of Genes and Genomes"),
                               tags$li(em("GO:BP:"), "Gene Ontology: Biological Processes"),
                               tags$li(em("GO:MF:"), "Gene Ontology: Molecular Functions"),
                               tags$li(em("GO:CC:"), "Gene Ontology: Cellular Components"),
                               tags$li(em("csv:"), "comma-separated-values file"),
                               tags$li(em("tsv:"), "tab-separated-values file"),
                             ),
                    ), # end tabPanel("Terminology")
                    
                    tabPanel("Bugs",
                             h4("Bugs", style = "color:#2c3e50"),
                             p(strong("CrohnDB"), "is a new database, and as such, bugs may occasionally occur. If you encounter any bugs or unexpected behavious please open an issue on the", tags$a(href="https://github.com/Reb08/CrohnDB/issues", "RLBase GitHub repo"), "and describe, in as much as possible, the following:"),
                             tags$ul(
                               tags$li("What you expected", strong("CrohnDB"), "to do."),
                               tags$li("What", strong("CrohnDB"), "did and why it was unexpected."),
                               tags$li("Any error messages you received (along with screenshots).")
                             )
                    ),
                    
                    tabPanel("License and attribution",
                             h4("License and Attribution", style = "color:#2c3e50"),
                             p(strong("CrohnDB"), "is licensed under an MIT license and we ask that you please cite", strong("CrohnDB"), "in any published work like so:"),
                             h5(em("'Distefano"), "et. al", em("Systematic Analysis of Long Non-Coding RNA Genes in Crohn Disease, 2023'"), style = "color:#2c3e50")
                    ) # end tabPanel
                    
                  )), # end navlistPanel and column, repsectively
           
         ) # end fluidRow
         
) # end Documentation