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


# selected_df_mutated <- reactive({
#   
#   if (input$study == "GSE99816") {
#     
#     Sign <- case_when(
#       selected_df()$logFC > input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Up-reg_Prot",
#       selected_df()$logFC > input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Up-reg_lncRNA",
#       selected_df()$logFC < -input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Down-reg_Prot",
#       selected_df()$logFC < -input$FC & selected_df()$PValue < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Down-reg_lncRNA",
#       TRUE ~ "Unchanged")
#     
#     sigcond <- case_when(
#       selected_df()$logFC > input$FC & selected_df()$PValue < input$FDR ~ "Up-regulated", 
#       selected_df()$logFC <- input$FC & selected_df()$PValue < input$FDR ~ "Down-regulated",
#       TRUE ~ "Unchanged"
#     )
#     
#   } else {  
#     
#     Sign <- case_when(
#       selected_df()$logFC > input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Up-reg_Prot",
#       selected_df()$logFC > input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Up-reg_lncRNA",
#       selected_df()$logFC < -input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "protein_coding" ~ "Down-reg_Prot",
#       selected_df()$logFC < -input$FC & selected_df()$FDR < input$FDR & selected_df()$Biotype == "lncRNA" ~ "Down-reg_lncRNA",
#       TRUE ~ "Unchanged")
#     
#     sigcond <- case_when(
#       selected_df()$logFC > input$FC & selected_df()$FDR < input$FDR ~ "Up-regulated", 
#       selected_df()$logFC < -input$FC & selected_df()$FDR < input$FDR ~ "Down-regulated",
#       TRUE ~ "Unchanged"
#     )
#     
#   }  
#   
#   cbind(Significance = Sign, selected_df())
#   cbind(Sigcond = sigcond, selected_df())
#   
# })
# 
# heatmap_data <- reactive({
#   
#   if (input$study == "GSE99816") {
#     
#     filtered_data <- filter(selected_df_mutated(), Sigcond!="Unchanged") %>% 
#       group_by(Sigcond) %>%
#       slice_min(
#         order_by = PValue, n=15
#       )
#     
#   } else {
#     
#     filtered_data <- filter(selected_df_mutated(), Sigcond!="Unchanged") %>% 
#       group_by(Sigcond) %>%
#       slice_min(
#         order_by = FDR, n=15
#       )
#     
#   }
#   
#   on.exit(rm(filtered_data))
#   return(filtered_data)
# })  
# 
# 
# 
# heatmap_data_subset <- reactive({
#   
#   if(input$gene_type2 == "lncRNA genes"){
#     data <- heatmap_data()[heatmap_data()$Biotype=="lncRNA",]
#   } else {
#     data <- heatmap_data()[heatmap_data()$Biotype=="protein_coding",]
#   }
#   
#   on.exit(rm(data))
#   
#   return(data)
# })


# output$heatmap <- renderPlotly ({
# 
#   print(heatmap_data())
# 
#   dat <- as.data.frame(heatmap_data()[,10:(ncol(heatmap_data()))]) %>%
#     reshape2::melt()
# 
#   dat$log_value <- log(dat$value)
# 
#   p <- ggplot(dat, aes(x=variable,
#                        y= Ensembl_ID.1,
#                        fill=log_value,
#                        text=value))+
#     geom_tile() +
#     scale_fill_gradientn(colours = rev(morecols(100))) +
#     theme_classic() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
#           axis.text.y = element_text(size = 10),
#           axis.title.x = element_blank(),
#           axis.title.y = element_blank(),
#           legend.position = "right",
#           legend.title = element_blank(),
#           legend.text = element_text(size = 10))
# 
#   p <- p %>% ggplotly(tooltip="text")
# 
#   p
# 
# })






######################### new part ###############################

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
# heatmap_data_subset <- reactive({
#   if(input$gene_type2 == "lncRNA genes"){
#     data <- heatmap_data()[heatmap_data()$Biotype=="lncRNA",]
#   } else {
#     data <- heatmap_data()[heatmap_data()$Biotype=="protein_coding",]
#   }
# 
#   on.exit(rm(data))
# 
#   return(data)
# })

heatmap_data_subset <- reactive({
  top30 <- head(arrange(selected_df_mutated(), desc(abs(logFC))), 30)
  if(input$gene_type2 == "lncRNA genes"){
    data <- top30[top30$Biotype=="lncRNA",]
  } else {
    data <- top30[top30$Biotype=="protein_coding",]
  }
  on.exit(rm(data))
  return(data)
})


output$heatmap <- renderPlot ({
  
  print(heatmap_data_subset())

  dat <- as.data.frame(heatmap_data_subset()[,10:(ncol(heatmap_data_subset()))]) %>%
    reshape2::melt()

  dat$log_value <- log(dat$value)
  dat <- dat[complete.cases(dat),]
  
  my_palette <- colorRampPalette(brewer.pal(9, "YlOrRd"))(n = 100)

  p <- ggplot(dat, aes(x=variable,
                  y= Ensembl_ID.1,
                  fill=log_value,
                  text=value))+
    geom_tile() +
    scale_fill_gradientn(colors = my_palette,
                         na.value = "white",
                         oob = scales::squish) +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
          axis.text.y = element_text(size = 10),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          legend.position = "right",
          legend.title = element_blank(),
          legend.text = element_text(size = 10))

  # p <- p %>% ggplotly(tooltip="text")
  # 
  # p <- p %>% layout(
  #   margin = list(l = 100, b = 100, t = 50, r = 100),
  #   xaxis = list(tickangle = -45,
  #                tickfont = list(size = 10)),
  #   yaxis = list(tickfont = list(size = 10)),
  #   coloraxis = list(colorbar = list(len = 0.5,
  #                                    thickness = 20,
  #                                    tickfont = list(size = 10),
  #                                    title = list(text = "log value"))))

  p

})

observeEvent(input$fullscreen, {
  session$sendCustomMessage(type = "toggleFullScreen", message = "heatmap")
})

########################################################################################## code that uses heatmaply
# output$heatmap <- renderPlotly({
# 
#   dat <- as.data.frame(heatmap_data_subset()[,10:(ncol(heatmap_data_subset()))])%>%
#      reshape2::melt()
#   
#   dat$log_value <- log(dat$value)
# 
#   
#   dat <- reshape2::acast(dat, Ensembl_ID.1 ~ variable, value.var = "log_value")
#   
#   dat <- dat[complete.cases(dat), ]
# 
#   heatmaply(dat,
#     #y = rownames(dat),
#     colors = rev(morecols(10)),
#     dendrogram = "row",
#     scale_fill_gradient_fun = ggplot2::scale_fill_gradient2(
#       low = "dodgerblue3",
#       high = "firebrick1",
#       midpoint = mean(dat),
#       limits = c(min(dat), max(dat))
#     ),
#     scale_fill_continuous = FALSE,
#     # width = 900,
#     # height = 600,
#     layout = list(title = input$comparison, titlefont = list(size = 20))
#   )
# 
# })

# output$heatmap <- renderPlotly ({
#   
#   dat <- as.data.frame(heatmap_data_subset()[,10:(ncol(heatmap_data_subset()))]) %>%
#     reshape2::melt()
#   
#   dat$log_value <- log(dat$value)
#   
#   # Transpose the data for clustering
#   dat <- reshape2::acast(dat, Ensembl_ID.1 ~ variable, value.var = "log_value")
#   
#   dat <- dat[!apply(is.na(dat), 1, any), !apply(is.na(dat), 2, any)]
#   
#   dat[is.infinite(dat)] <- NA
#   
#   # Create the heatmap with clustering
#   p <- heatmaply(dat)#, scale_fill_gradientn(colors = brewer.pal(9, "YlOrRd"), na.value = "white"))
#   # 
#   # Adjust the aspect ratio
#   # p <- p %>% layout(yaxis = list(scaleanchor = "x", scaleratio = 1),
#   #                   xaxis = list(scaleanchor = "y", scaleratio = 1))
#   
#   p
# })

################################################################################### code that binds pheatmap with ggplotly)
# output$heatmap <- renderPlotly({
# 
#   dat <- as.data.frame(heatmap_data_subset()[,11:(ncol(heatmap_data_subset()))])
# 
#   p <- as.ggplot(pheatmap(dat,
#            cluster_rows = T,
#            cluster_cols = F,
#            show_rownames = F,
#            angle_col = "45",
#            scale = "row",
#            color = rev(morecols(100)),
#            cex=1,
#            legend=T,
#            main = input$comparison))
# 
#   p <- p %>% ggplotly()
#   p
# 
# })


######################################################################################### original code
#plot heatmap while catching errors that appear when there are no enough DEGs
# output$heatmap <- renderPlot({
#   tryCatch(
#     {
#       pheatmap(heatmap_data_subset()[,11:(ncol(heatmap_data_subset()))],
#                cluster_rows = T,
#                cluster_cols = F,
#                show_rownames = F,
#                angle_col = "45",
#                scale = "row",
#                color = rev(morecols(100)),
#                cex=1,
#                legend=T,
#                main = input$comparison)
#     },
#     error = function(e) {
#       if (grepl("must have n >= 2 objects to cluster", e$message)) {
#         message <- "Sorry, no enough DEGs identified"
#       } else if (grepl("'from' must be a finite number", e$message)) {
#         message <- "Sorry, no enough DEGs identified"
#       }
# 
#       plot.new()
#       text(0.5, 0.5, message, cex = 1.2)
# 
#     })
# })