# ----------------------------------------- Summary table ------------------------------------------------- 

output$summary_table <- renderTable({
  
  studyInput_mutated() %>% count(Significance)
  
}) 