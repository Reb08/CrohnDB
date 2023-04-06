#----------------------------------- heatmap ------------------------------------------------------

file_lookup <- list(
  "Crohn_B1 vs Control" = "GSE66207-Crohn-Crohn_B1_vs_Control-Ratio-CPM.txt",
  "Crohn_B2 vs Control" = "GSE66207-Crohn-Crohn_B2_vs_Control-Ratio-CPM.txt",
  "Crohn_B2 vs Crohn_B1" = "GSE66207-Crohn-Crohn_B2_vs_Crohn_B1-Ratio-CPM.txt",
  "Crohn_B3 vs Control" = "GSE66207-Crohn-Crohn_B3_vs_Control-Ratio-CPM.txt",
  "Crohn_B3 vs Crohn_B1" = "GSE66207-Crohn-Crohn_B3_vs_Crohn_B1-Ratio-CPM.txt",
  "Crohn_B3 vs Crohn_B2" = "GSE66207-Crohn-Crohn_B3_vs_Crohn_B2-Ratio-CPM.txt",
  "CD vs Control" = "GSE99816-Crohn-fibroblasts-CD_vs_Control-Ratio-CPM.txt", 
  "INF vs Control" = "GSE99816-Crohn-fibroblasts-IFN_vs_Non_CD-Ratio-CPM.txt",
  "NINF vs Control" = "GSE99816-Crohn-fibroblasts-NINF_vs_Non_CD-Ratio-CPM.txt",
  "INF vs NINF" = "GSE99816-Crohn-fibroblasts-IFN_vs_NINF-Ratio-CPM.txt",
  "STEN vs Control" = "GSE99816-Crohn-fibroblasts-STEN_vs_Non_CD-Ratio-CPM.txt",
  "STEN vs INF" = "GSE99816-Crohn-fibroblasts-STEN_vs_INF-Ratio-CPM.txt",
  "STEN vs NINF" = "GSE99816-Crohn-fibroblasts-STEN_vs_NINF-Ratio-CPM.txt",
  "CD vs Healthy control" = "GSE164871-Crohn-colon-Ratio-CPM.txt"
)


# Get the file name based on the comparison choice
file_name <- reactive({
  file_lookup[[input$comparison]]
})  

selected_df <- reactive({
  # Get the file path based on the user input
  file_path <- file.path("data", file_name())
  
  # Load the data and cache it
  data <- data.frame(fread(file_path), row.names = 1)
  
  on.exit(rm(data))
  
  return(data)
})


# add column indicating whether the gene is an up- or down-regulated protein-coding gene or lncRNA
selected_df_mutated <- reactive({
  
  if (input$study == "GSE99816") {
    
    Sign <- case_when(
      selected_df()$logFC > input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Up-reg_Prot",
      selected_df()$logFC > input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Up-reg_lncRNA",
      selected_df()$logFC < -input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Down-reg_Prot",
      selected_df()$logFC < -input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Down-reg_lncRNA",
      TRUE ~ "Unchanged")
    
  } else {  
    
    Sign <- case_when(
      selected_df()$logFC > input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Up-reg_Prot",
      selected_df()$logFC > input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Up-reg_lncRNA",
      selected_df()$logFC < -input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Down-reg_Prot",
      selected_df()$logFC < -input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Down-reg_lncRNA",
      TRUE ~ "Unchanged")
  
  }  
  
  cbind(Significance = Sign, selected_df())
  
})


# filter data to have only DEGs
heatmap_data <- reactive({
  filtered_data <- filter(selected_df_mutated(), Significance!="Unchanged")
  on.exit(rm(filtered_data))
  return(filtered_data)
})  


# further subset data based on whether user chooses to display protein-coding genes or lncRNAs genes
heatmap_data_subset <- reactive({
  if(input$gene_type2 == "lncRNA genes"){
    data <- heatmap_data()[heatmap_data()$Biotype=="lncRNA",]
  } else {
    data <- heatmap_data()[heatmap_data()$Biotype=="protein_coding",]
  }
  
  on.exit(rm(data))
  
  return(data)
})


# plot heatmap while catching errors that appear when there are no enough DEGs 
output$heatmap <- renderPlot({
  tryCatch(
    {
      pheatmap(heatmap_data_subset()[,11:(ncol(heatmap_data_subset()))],
               cluster_rows = T,
               cluster_cols = F,
               show_rownames = F,
               angle_col = "45",
               scale = "row",
               color = rev(morecols(100)),
               cex=1, 
               legend=T,
               main = input$comparison)
    }, 
    error = function(e) {
      if (grepl("must have n >= 2 objects to cluster", e$message)) {
        message <- "Sorry, no enough DEGs identified"
      } else if (grepl("'from' must be a finite number", e$message)) {
        message <- "Sorry, no enough DEGs identified"
      } 
      
      plot.new()
      text(0.5, 0.5, message, cex = 1.2)
      
    })
})