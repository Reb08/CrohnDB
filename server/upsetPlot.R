#-------------------------------------------------Upset plot------------------------------------------------------

# creates list of up- or down-regulated genes from all the comparisons of the selected study based on the selected expression pattern 
gene_sets <- reactive ({ 
  lapply(comparisons(), function(c) {
    
    if (input$expression3 == "up-regulated genes") {
      studyInput() %>% 
        filter(Comparison == c & logFC >= input$FC & FDR <= input$FDR) %>%
        pull(Ensembl.Gene.ID)
    } else {
      studyInput() %>% 
        filter(Comparison == c & logFC <= - input$FC & FDR <= input$FDR) %>%
        pull(Ensembl.Gene.ID)
    } 
    
  })
})

# creates vector with names for the gene set
names_reactive <- reactive({
  lapply(1:length(comparisons()), function(c) {
    comparisons()[c]
  })
})

# assigns names to gene set
gene_sets_named <- reactive({
  my_names <- names_reactive()
  setNames(gene_sets(), my_names)
})

# create data in the correct format for the upset plot
upset_data <- reactive({
  fromList(gene_sets_named())
})


output$UPSET <- renderPlot({
  
  if (input$study == "GSE164871") {
    
    shinyjs::show("p_onecomparison")
    
  } else {
    
    shinyjs::hide("p_onecomparison")
    
    upset(upset_data(),
          main.bar.color = "#4e79a7",
          sets.bar.color = "#f28e2b",
          matrix.color = "#e15759",
          text.scale = 1.8,
          nsets = length(comparisons()),
          nintersects = NA
    )}
})