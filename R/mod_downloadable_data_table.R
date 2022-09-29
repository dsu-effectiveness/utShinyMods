#' downloadable_data_table UI Function
#'
#' To be copied in the UI
#' mod_downloadable_data_table_ui("downloadable_data_table_1")
#'
#' To be copied in the server
#' mod_downloadable_data_table_server("downloadable_data_table_1")'
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @export
#'
#' @importFrom shiny NS tagList
mod_downloadable_data_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    tags$div( downloadButton( ns("report_download_csv"), "CSV" ),
              downloadButton( ns("report_download_excel"), "Excel" ),
              style="padding-bottom: 1em;"),
    DT::dataTableOutput( ns('summary_table'), width=NULL )
  )
}

#' downloadable_data_table Server Functions
#'
#' To be copied in the UI
#' mod_downloadable_data_table_ui("downloadable_data_table_1")
#'
#' To be copied in the server
#' mod_downloadable_data_table_server("downloadable_data_table_1")
#'
#' @export
mod_downloadable_data_table_server <- function(id,
                                               df=utShinyMods::entity_time_metric_categories_df,
                                               module_title="Title of Module",
                                               module_sub_title="Subtitle of module"){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    # UI Generation ####
    output$module_title_ui <- renderUI({
      tagList(
        h2(module_title),
        p(module_sub_title)
      )
    })

    # Reactive Dataframe ####
    reactive_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        # req(input$required_input)
        return_df <- as.data.frame(unclass(df), stringsAsFactors = TRUE)
        # Pause plot execution if df has no values. This eliminates an error message.
        req( nrow(return_df) > 0 )
        return( return_df )
    })

    # Datatable Rendering ####
    output$summary_table <- DT::renderDataTable(reactive_df(),
                                                filter="top",
                                                options=list( scrollX = TRUE,
                                                              lengthMenu=list( c(5, 10, 25, -1),
                                                                               c(5, 10, 25, "All") ) ),
                                                rownames=FALSE,
                                                colnames=colnames( janitor::clean_names( reactive_df(), case="title") ) )
   # Download Handlers ####
   output$report_download_csv <- downloadHandler(filename=function(){ "report.csv" },
                                                 content=function(file){
                                                      readr::write_csv(df, file)
                                                  })

   output$report_download_excel <- downloadHandler(filename=function(){ "report.xlsx" },
                                                   content=function(file){
                                                      writexl::write_xlsx(df, file)
                                                  })

    })

}

