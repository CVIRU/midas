# |----------------------------------------------------------------------------------|
# | Project: ICD-9 Shiny App                                                         |
# | Script: ICD-9 Shiny App                                                          |
# | Authors: Davit Sargsyan                                                          |   
# | Created: 03/31/2018                                                              |
# | Modified: 04/03/2018, DS: replaced text boxes wit DT table. Download only        |
# |                           SELECTED rows (all selected by default)                |
# |                           Output a map file, i.e. R list with mapped diagnoses   |
# | ToDo: Keep selected diagnoses after switching to the next category               |
# |----------------------------------------------------------------------------------|
options(stringsAsFactors = FALSE)
require(icd)
require(DT)
dt1 <- icd9cm_hierarchy

# # TEST: bypass user interface!
input <- list()
input$chapter = unique(as.character(dt1$chapter))[1]
input$subchapter = unique(as.character(dt1$sub_chapter[dt1$chapter == input$chapter]))[1]
input$major = unique(as.character(dt1$major[dt1$sub_chapter == input$subchapter]))[1]
input$dx = unique(as.character(dt1$long_desc[dt1$major == input$major]))[1]

ui <- fluidPage(
  titlePanel("ICD-9 Clinical Modification Codes & Diagnoses"),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "chapter",
                  label = "Chapter",
                  choices = unique(as.character(dt1$chapter))),
      uiOutput(outputId = "subchapterIn"),
      uiOutput(outputId = "majorIn"),
      uiOutput(outputId = "dxIn")
    ),
    mainPanel(
      DT:: dataTableOutput("tbl"),
      downloadLink(outputId = "downloadData", 
                   label = "Download Selected Rows"),
      downloadLink(outputId = "downloadMap", 
                   label = "Download Map of Selected Rows")
    )
  )
)

server <- function(input, output) {
  output$subchapterIn <- renderUI({
    selectInput(inputId = "subchapter", 
                label = "Sub-chapter", 
                choices = unique(as.character(dt1$sub_chapter[dt1$chapter == input$chapter])))
  })
  
  output$majorIn <- renderUI({
    selectInput(inputId = "major", 
                       label = "Major", 
                       choices = unique(as.character(dt1$major[dt1$sub_chapter == input$subchapter])))
  })
  
  output$dxIn <- renderUI({
    selectInput(inputId = "dx", 
                label = "Diagnosis", 
                choices = unique(as.character(dt1$long_desc[dt1$major == input$major])),
                multiple = TRUE)
  })
  
  # Source: https://yihui.shinyapps.io/DT-rows/
  output$tbl <- DT::renderDT({
    DT::datatable(unique(dt1[dt1$long_desc %in% input$dx, ]),
                  options = list(pageLength = 10),
                  selection = list(mode = "multiple",
                                   selected = 1:nrow(unique(dt1[dt1$long_desc %in% input$dx, ])),
                                   target = "row"))
  }) 
  
  # Source: https://shiny.rstudio.com/articles/download.html
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("icd9_codes_", 
            Sys.Date(),
            ".csv",
            sep = "")
    },
    content = function(file) {
      tmp <- unique(dt1[dt1$long_desc %in% input$dx, ])[input$tbl_rows_selected, ]
      write.csv(tmp, 
                file,
                row.names = FALSE)
    }
  )
  
  # New comorbidity map
  output$downloadMap <- downloadHandler(
    filename = function() {
      paste("icd9_map_", 
            Sys.Date(),
            ".RData",
            sep = "")
    },
    content = function(file) {
      tmp <- unique(dt1[dt1$long_desc %in% input$dx, ])[input$tbl_rows_selected, ]
      l1 <- list(unique(c(tmp$code)))
      names(l1) <- tmp$major[1]
      l1 <- as.icd_comorbidity_map(l1)
      save(l1,
           file = file)
    }
  )
}

shinyApp(ui, server)