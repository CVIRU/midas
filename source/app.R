# |----------------------------------------------------------------------------------|
# | Project: ICD-9 Shiny App                                                         |
# | Script: ICD-9 Shiny App                                                          |
# | Authors: Davit Sargsyan                                                          |   
# | Created: 03/31/2018                                                              |
# |----------------------------------------------------------------------------------|
options(stringsAsFactors = FALSE)
require(icd)
dt1 <- icd9cm_hierarchy

# # TEST: bypass user interface!
# input <- list()
# input$chapter = unique(as.character(dt1$chapter))[1]
# input$subchapter = unique(as.character(dt1$sub_chapter[dt1$chapter == input$chapter]))[1]
# input$major = unique(as.character(dt1$major[dt1$sub_chapter == input$subchapter]))[1]
# input$dx = unique(as.character(dt1$long_desc[dt1$major == input$major]))[1]

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
      textOutput(outputId = "majorICD9"),
      textOutput(outputId = "dxICD9"),
      downloadLink(outputId = "downloadData", 
                   label = "Download")
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
  output$majorICD9 <- renderText({
    paste("Major ICD-9 Code:",
          unique(dt1$three_digit[dt1$major == input$major]))
  })
  
  output$dxIn <- renderUI({
    selectInput(inputId = "dx", 
                label = "Diagnosis", 
                choices = unique(as.character(dt1$long_desc[dt1$major == input$major])),
                multiple = TRUE)
  })
  output$dxICD9 <- renderText({
    paste("Diagnosis ICD-9 Code(s):",
          paste(unique(dt1$code[dt1$long_desc %in% input$dx]),
                collapse = ", "))
  })
  
  # Source: https://shiny.rstudio.com/articles/download.html
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("icd9_codes_", 
            Sys.Date(),
            ".csv",
            sep="")
    },
    content = function(file) {
      write.csv(dt1[dt1$long_desc %in% input$dx, ], 
                file,
                row.names = FALSE)
    }
  )
}

shinyApp(ui, server)