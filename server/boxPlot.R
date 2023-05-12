
file_list <- list(
  "Crohn_B1 vs Control" = "GSE66207-Crohn-Crohn_B2_vs_Control-Ratio-CPM.txt", ################ change to correct file
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
name <- reactive({
  file_list[[input$comparison]]
})  



sel_df <- reactive({
  # Get the file path based on the user input
  file_path <- paste0("data/", name())
  
  # Load the data and cache it
  data <- read.delim(file_path, sep=" ")
  
  on.exit(rm(data))
  
  return(data)
})

observe({
  print(sel_df())
})


# data_subset <- reactive({
# 
#   str <- input$comparison
# 
#   cols_name <- unlist(strsplit(str, " vs "))
# 
#   my_cols_matched <- lapply(cols_name, function(x) {
#     grep(paste0("^", x), names(df()), value = TRUE)
#   })
# 
# 
#   subs <- df() %>% filter(`Gene Symbol` == selected_row()$Gene.Symbol) 
#   # %>%
#   #   pivot_longer(cols = unlist(my_cols_matched), names_to = "Condition", values_to = "CPM")
#   # 
#   # subs$Condition <- c(rep("control", length(my_cols_matched[[1]])), rep(selected_row()$Gene.Symbol, length(my_cols_matched[[2]])))
#   # 
#   # return(subs)
# 
# })

# observe({
#   print(data_subset())
# })
# 
# 
# output$boxplot <- renderPlot({
# 
#   ggplot(data_subset(), aes(x=Condition, y=CPM, fill=Condition)) +
#     geom_boxplot()+
#     geom_jitter() +
#     xlab("Sample condition") +
#     ylab(paste0("Expression (CPM)")) +
#     theme_bw() +
#     theme(legend.position = "none")
# 
# })


# CPM_101 <- read_delim("GSE66207-Crohn-Crohn_B2_vs_Control-Ratio-CPM.txt")
# 
# CPM_101$Biotype <- as.factor(CPM_101$Biotype)
# 
# subs <- subset(CPM_101, `Ensembl Gene ID` == "ENSG00000176928")
# 
# df_long_1 <- subs %>%
#   pivot_longer(cols = colnames(subs)[11:22], names_to = "Condition", values_to = "CPM") 
# 
# df_long_1$Condition <- c(rep("control", 6), rep("ENSG00000176928", 6))
# 
# 
# ggplot(df_long_1, aes(x=Condition, y=CPM, fill=Condition)) + 
#   geom_boxplot()+
#   geom_jitter() +
#   xlab("Sample condition") +
#   ylab(paste0("Expression (CPM)")) +
#   theme_bw() +
#   theme(legend.position = "none")


