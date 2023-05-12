
# labels for the two drop down menus

label <- reactive({
  if(input$study == "GSE66207"){
    c("Crohn_B1 vs Control",
      "Crohn_B2 vs Control",
      "Crohn_B2 vs Crohn_B1",
      "Crohn_B3 vs Control",
      "Crohn_B3 vs Crohn_B1",
      "Crohn_B3 vs Crohn_B2")
  } else if (input$study == "GSE99816"){
    c("CD vs Control", 
      "INF vs Control",
      "NINF vs Control",
      "INF vs NINF",
      "STEN vs Control",
      "STEN vs INF",
      "STEN vs NINF")
  } else {
    c("Crohn vs Control")
    
  }
})


# update drop down menu one based on study selected
observeEvent(input$study, {
  updateSelectInput(
    session,
    inputId = "condition1",
    choices = label(),
    selected = label()[1]
  )
})

# update drop down menu two based on study selected
observeEvent(input$study, {
  updateSelectInput(
    session,
    inputId = "condition2",
    choices = label(),
    selected = label()[2]
  )
})

# create list of gene sets that will be used to draw the venn diagrams
gene_set <- reactive({

  if (input$study == "GSE99816") {

    if (input$expression3 == "up-regulated genes") {
      set1 = studyInput() %>%
        filter(Comparison == input$condition1 & logFC > input$FC & PValue < input$FDR) %>%
        pull(Ensembl.Gene.ID)
      set2 = studyInput() %>%
        filter(Comparison == input$condition2 & logFC > input$FC & PValue < input$FDR) %>%
        pull(Ensembl.Gene.ID)
    } else {
      set1 = studyInput() %>%
        filter(Comparison == input$condition1 & logFC < - input$FC & PValue < input$FDR) %>%
        pull(Ensembl.Gene.ID)
      set2 = studyInput() %>%
        filter(Comparison == input$condition2 & logFC < - input$FC & PValue < input$FDR) %>%
        pull(Ensembl.Gene.ID)
    }

  } else {

    if (input$expression3 == "up-regulated genes") {
      set1 = studyInput() %>%
        filter(Comparison == input$condition1 & logFC > input$FC & FDR < input$FDR) %>%
        pull(Ensembl.Gene.ID)
      set2 = studyInput() %>%
        filter(Comparison == input$condition2 & logFC > input$FC & FDR < input$FDR) %>%
        pull(Ensembl.Gene.ID)
    } else {
      set1 = studyInput() %>%
        filter(Comparison == input$condition1 & logFC < - input$FC & FDR < input$FDR) %>%
        pull(Ensembl.Gene.ID)
      set2 = studyInput() %>%
        filter(Comparison == input$condition2 & logFC < - input$FC & FDR < input$FDR) %>%
        pull(Ensembl.Gene.ID)
    }

  }
  
  l <- list(set1, set2) %>% setNames(c(input$condition1, input$condition2))
  
  on.exit(rm(l))
  return(l)

})


# create list of gene sets that will be used to draw the Upset plot
gene_sets <- reactive ({
  lapply(comparisons(), function(c) {
    
    if (input$study == "GSE99816") {
      
      if (input$expression3 == "up-regulated genes") {
        studyInput() %>%
          filter(Comparison == c & logFC > input$FC & PValue < input$FDR) %>%
          pull(Ensembl.Gene.ID)
      } else {
        studyInput() %>%
          filter(Comparison == c & logFC < - input$FC & PValue < input$FDR) %>%
          pull(Ensembl.Gene.ID)
      }
      
    } else {
      
      if (input$expression3 == "up-regulated genes") {
        studyInput() %>%
          filter(Comparison == c & logFC > input$FC & FDR < input$FDR) %>%
          pull(Ensembl.Gene.ID)
      } else {
        studyInput() %>%
          filter(Comparison == c & logFC < - input$FC & FDR < input$FDR) %>%
          pull(Ensembl.Gene.ID)
      }
      
    }
    
  })
})

#creates vector with names for the gene sets
names_reactive <- reactive({
  lapply(1:length(comparisons()), function(c) {
    comparisons()[c]
  })
})

# assigns names to gene sets
gene_sets_named <- reactive({
  my_names <- names_reactive()
  setNames(gene_sets(), my_names)
})

# create data in the correct format for the upset plot
upset_data <- reactive({
  fromList(gene_sets_named())
})


Intersect <- function (x) {
  # Multiple set version of intersect
  # x is a list
  if (length(x) == 1) {
    unlist(x)
  } else if (length(x) == 2) {
    intersect(x[[1]], x[[2]])
  } else if (length(x) > 2){
    intersect(x[[1]], Intersect(x[-1]))
  }
}

# find list of overlaps between the two conditions being compared
overlaps <- reactive({
  Intersect(gene_set())
})

# plots venn diagram if the show all comparison input is set to No. Otherwise it will draw the Upset plot and disable the two dropdown menus. 
observe({
  if (input$show_all == "Yes") {
    
    # disable condition1 and condition2 inputs
    disable("condition1")
    disable("condition2")
    
    shinyjs::hide("VENN_info")
    shinyjs::hide("title")
    
    # generate plot based on all comparisons
    output$VENN <- renderPlot({
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
  } else {
    
    # enable condition1 and condition2 inputs
    enable("condition1")
    enable("condition2")
    
    if (input$condition1 != input$condition2 & length(overlaps() != 0)) {
      
      shinyjs::show("VENN_info")
      shinyjs::show("title")
      
    } else {
      
      shinyjs::hide("VENN_info")
      shinyjs::hide("title")
    }
    
    
    # generate plot based on selected comparisons
    output$VENN <- renderPlot({
      
      tryCatch(
        
        {
          if (input$study == "GSE164871") {
            
            shinyjs::show("p_onecomparison")
            
          } else {
            
            shinyjs::hide("p_onecomparison")
            
            plot(eulerr::venn(gene_set()),  fill = myCol2,#c("#ABDEE6", "#CBAACB"),
                 labels = NULL, quantities = TRUE, legend=list(names(gene_set())))
          }
        
        },
        
        error = function(e) {
          if (grepl("error", e$message)) {
            message <- "The same condition has been selected from the the two dropdown menus. \n Please, select a different option from either 'Select first comparison' or 'Select second comparison'"
          }
          
          plot.new()
          text(0.5, 0.5, message, cex = 1.1)
          
        }) # end tryCatch
      
    }) # end renderPlot
    
  } # end if statement
})

# prints list of shared genes
output$VENN_info <- renderPrint({
  
    cat(overlaps())
    
})


