# CrohnDB

Shiny app for exploring RNA-seq data from Crogn disease (CD) patients analysed by *Distefano et al., Systematic Analysis of Long Non-Coding RNA Genes in Crohn Disease ,2023*.

To generate the data for this app, please see the steps in https://github.com/heartlncrna/Analysis_of_CD_Studies.

## Run the app locally

 1. Start R
 
 2. Load the "Shiny" library package (install if not already available)
 ```
 library(shiny)
 
 install.packages("shiny") # ----- if not already installed
 ```
 
 3. Run App
 
 ```
 runGitHub(repo = "CrohnDB", username = "Reb08", ref = "main")
 ```
 
 ## Visit the app online
 
 You can find the app online at:  https://rebeccadistefano.shinyapps.io/CrohnDB/
