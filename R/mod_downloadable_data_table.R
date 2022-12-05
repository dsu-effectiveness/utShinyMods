#' downloadable_data_table UI Function
#'
#' This function creates the UI portion for the `downloadable_data_table` Shiny module. This function must be used in conjunction with the `mod_downloadable_data_table_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @importFrom shiny NS tagList
#'
#' @export
mod_downloadable_data_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    tags$div( downloadButton( ns("report_download_csv"), "CSV" ),
              downloadButton( ns("report_download_excel"), "Excel" ),
              style="padding-bottom: 1em;"),
    DT::dataTableOutput( ns('downloadable_table'), width=NULL )
  )
}

#' downloadable_data_table Server Function
#'
#' This function provides the server-side logic for the `mod_downloadable_data_table` Shiny module. This function must be used in conjunction with the `mod_downloadable_data_table_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#' @param df The data frame containing the data to be displayed and available for download.
#' @param module_title The character string to be used as the title of the Shiny module.
#' @param module_sub_title The character string to be used as the subtitle of the Shiny module.
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
    output$downloadable_table <- DT::renderDataTable(reactive_df(),
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

