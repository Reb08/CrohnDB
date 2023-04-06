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