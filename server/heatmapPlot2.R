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
  "Crohn vs Control" = "GSE164871-Crohn-colon-Ratio-CPM.txt"
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


heatmap_data <- reactive({
  
  filtered_data <- filter(selected_df_mutated(), Significance!="Unchanged") 
  
  if(input$study == "GSE99816") {
  
    arr_data <- filtered_data[with(filtered_data, order(PValue, -abs(logFC))),] 
    
  } else {
    
    arr_data <- filtered_data[with(filtered_data, order(FDR, -abs(logFC))),] 
    
  }

  on.exit(rm(arr_data))
  
  return(arr_data)
})



heatmap_data_subset <- reactive({
  if(input$gene_type2 == "lncRNA genes"){
    data <- heatmap_data()[heatmap_data()$Biotype=="lncRNA",]
  } else {
    data <- heatmap_data()[heatmap_data()$Biotype=="protein_coding",]
  }

  on.exit(rm(data))

  return(data)
})


output$heatmap <- renderPlotly ({
  
  # "YlOrRd"
  
  my_palette <- colorRampPalette(brewer.pal(11, "RdYlBu"))(n = 100)
  
  if (input$study == "GSE66207" & input$comparison == "Crohn_B3 vs Crohn_B2") {
    
    shinyjs::show("no_heatmap")
    
  } else {
    
    shinyjs::hide("no_heatmap")
    
    if (nrow(heatmap_data_subset()) > 30) {
      dat <- heatmap_data_subset()[1:30, ]
      
    } else {
      dat <- heatmap_data_subset()
    }
    
    dat <- as.data.frame(dat[,c(2, 11:(ncol(dat)))]) %>%
      reshape2::melt()
    
    dat$log.CPM <- log(dat$value)
    
    dat$log.CPM[is.infinite(dat$log.CPM)] <- 0
    
    p <- ggplot(dat, aes(x=variable,
                         y= Gene.Symbol,
                         fill=log.CPM,
                         text=value))+
      geom_tile() +
      scale_fill_gradientn(colors = my_palette,
                           na.value = "white",
                           oob = scales::squish) +
      theme_classic() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
            axis.text.y = element_text(size = 9),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            legend.position = "right",
            legend.title = element_blank(),
            legend.text = element_text(size = 10))
    
    p <- p %>% ggplotly(tooltip = "text")
    
    p <- p %>% layout(
      xaxis = list(tickangle = -45,
                   tickfont = list(size = 10)),
      yaxis = list(tickfont = list(size = 10)),
      coloraxis = list(colorbar = list(len = 0.5,
                                       thickness = 20,
                                       tickfont = list(size = 10),
                                       title = list(text = "log value"))))
    
  }
  
   
  
  
})











