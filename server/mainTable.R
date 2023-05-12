# ------------------------------------------ Main table ------------------------------------------------- 

output$table <- DT::renderDataTable({
  
  my_table <- studyInput()[studyInput()$Comparison == input$comparison, ] # only displays genes that belong to the right comparisons
  
  if (input$study == "GSE99816") {
    
    my_table[,5:7] <- format(round(my_table[,5:7], digits = 5), nsmall=5)  # this makes sure that the FDR and logFC columns do not have very long float numbers
    
  } else {
    
    my_table[,5:6] <- format(round(my_table[,5:6], digits = 5), nsmall=5)
    
  }  
    
  DT::datatable(
    my_table, 
    selection = list(mode="single", selected=1),  # allows user to select only one row at a time
    options = list(lengthMenu = c(5, 10, 50), pageLength = 5, scrollX=TRUE),
    rownames=FALSE
  )
  
})


data <- reactive({
  studyInput()[studyInput()$Comparison == input$comparison, ]
})

output$downloadResultTable <- downloadHandler(
  
  # This function returns a string which tells the client browser what name to use when saving the file.
  filename = function() {
    paste(input$study, "-", input$comparison, "-Result_table.tsv", sep = "")
  },
  
  # This function should write data to a file given to it by the argument 'file'.
  content = function(file) {
    
    # Write to a file specified by the 'file' argument
    write.table(data(), file,
                row.names = FALSE, quote=F, sep="\t")
  }
)