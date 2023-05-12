data_boxplot <- reactive({
  
  if (input$study== "GSE66207") {
    data <- data.frame(fread("data/GSE66207-All_Samples.txt"))
  } else if (input$study == "GSE99816") {
    data <- data.frame(fread("data/GSE99816-All_Samples.txt"))
  } else {
    data <- data.frame(fread("data/GSE164871-All_Samples.txt"))
  }
  
  on.exit(rm(data))
  
  return(data)
  
})

str <- reactive({
  s <- input$comparison
  cols_name <- unlist(strsplit(s, " vs "))
  
  on.exit(rm(cols_name))
  return(cols_name)
})

my_cols_matched <- reactive({
  lapply(str(), function(x) {
    grep(paste0("^", x), names(data_boxplot()), value=T)
  })
})

box_data_subset <- reactive({
  d <- data_boxplot()[data_boxplot()$Gene.Symbol == input$gene, ]
  
  on.exit(rm(d))
  return(d)
})

p <- reactive({
  
  if (length(my_cols_matched()) != 0) {
    
    if (input$study == "GSE99816" & input$comparison == "CD vs Control") {
      n_row <- 21
      new_df <- data.frame(
        condition = c(rep("CD", 15), rep("Control", 6)),
        CPM = 0
      )
    } else {
      
      n_row <- length(my_cols_matched()[[1]]) + length(my_cols_matched()[[2]])
      #subs <- box_data_subset()[, c(unlist(my_cols_matched()))]
      new_df <- data.frame(
        condition = c(rep(str()[1], length(my_cols_matched()[[1]])), rep(str()[2], length(my_cols_matched()[[2]]))),
        CPM = 0) }
    
    on.exit(rm(new_df))
    return(new_df)
  }
  
})


plot_data <- reactive({
  
  x <- NULL
  p <- p()
  
  if(!is.null(p())) {
    
    if (input$study == "GSE99816" & input$comparison == "CD vs Control") {
      x <- as.vector(t(box_data_subset()[, -c(1:4)]))
      
      if(length(x) != 0) {
        p$CPM <- x
      }
      
    } else {
      
      x <- as.vector(t(box_data_subset()[, c(unlist(my_cols_matched()))]))
      
      if(length(x) != 0) {
        p$CPM <- x
      }
    }
  }  
  
  on.exit(rm(p))
  return(p)
  
})


output$boxplot <- plotly::renderPlotly({
  
  p <- ggplot(plot_data(), aes(x=condition, y=CPM, fill=condition, text=paste("CPM; ", CPM))) +
    stat_boxplot(geom = "errorbar") +
    geom_boxplot()+
    geom_jitter() +
    xlab("Sample condition") +
    ylab(paste0("Expression (CPM)")) +
    theme_bw() +
    theme(legend.position = "none") +
    #theme(axis.text = element_text(size=12), axis.title = element_text(size=14)) +
    labs(subtitle=input$gene) 
  p <- p %>%
    ggplotly(tooltip = "text") %>%
    layout(
      title=list(text=input$gene, font=list(size=10))
    )
  
  p
  
})





