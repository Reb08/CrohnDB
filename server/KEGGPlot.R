# ----------------------------------------------KEGG plot-------------------------------------------------------------------

# obtain full list of genes in Ensembl-ID and create new list in ENTREZ-ID
dedup_ids <- reactive({
  data <- studyInput_mutated() %>% dplyr::pull(Ensembl.Gene.ID)
  ids <-
    clusterProfiler::bitr(data,
                          fromType = "ENSEMBL",
                          toType = "ENTREZID",
                          OrgDb = "org.Hs.eg.db")
  dedup_ids = ids[!duplicated(ids[c("ENSEMBL")]), ]
})


data_kegg <- reactive({
  studyInput_mutated()[studyInput_mutated()$Ensembl.Gene.ID %in% dedup_ids()$ENSEMBL,]
})


# add new column to data with entrez-ID
data_kegg_mutated <- reactive({
  data_kegg() %>% mutate(EntrezID = dedup_ids()$ENTREZID)
})


data_kegg_mutated_ordered <- reactive({
  data_kegg_mutated()[order(data_kegg_mutated()$logFC, decreasing=TRUE),]
})


# subset data based on user's choice of up or down regulated genes
KEGG_analysis_data <- reactive({
  if (input$expression2 == "up-regulated genes") {
    data_kegg_mutated_ordered()[data_kegg_mutated_ordered()$Significance == "Up-reg protein-coding gene" |
                                  data_kegg_mutated_ordered()$Significance == "Up-reg lncRNA", ]
  } else {
    data_kegg_mutated_ordered()[data_kegg_mutated_ordered()$Significance == "Down-reg protein-coding gene" |
                                  data_kegg_mutated_ordered()$Significance == "Down-reg lncRNA", ]
  }
})

# perform pathway analysis using clusterProfiler
KEGG_results <- reactive({
  
  gene_list <- KEGG_analysis_data()$EntrezID
  
  if (length(gene_list) < 10) {
    
    return(NULL)
    
  } else {
    
    clusterProfiler::enrichKEGG(
      gene = gene_list,
      universe = data_kegg_mutated_ordered()$EntrezID,
      minGSSize = 10,
      organism = "hsa",
      keyType = "ncbi-geneid"
    )}
})


output$KEGG <- renderPlot({
  tryCatch({
    
    if (is.null(KEGG_results)) {
      message <- "Sorry, no enough DEGs identified"
      plot.new()
      text(0.5, 0.5, message, cex = 1.2)
    } else if (nrow(KEGG_results())== 0) {
      message <- "Sorry, no enriched terms found"
      plot.new()
      text(0.5, 0.5, message, cex = 1.2)
    } else {
      dotplot(
        KEGG_results(),
        showCategory = 20,
        title = "Enriched Pathways",
        font.size = 10
      )
    }
  },
  error = function(e) {
    message <- "Sorry, no enough DEGs identified"
    plot.new()
    text(0.5, 0.5, message, cex = 1.2)
  })
})

