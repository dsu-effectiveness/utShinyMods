#' interactive_data_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_interactive_data_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    uiOutput( ns('category_filter_ui') ) ,
    DT::dataTableOutput( ns('summary_table'), width=NULL )
  )
}

#' interactive_data_table Server Functions
#'
#' @noRd
mod_interactive_data_table_server <- function(id,
                                              df=entity_time_metric_categories_df,
                                              record_uniqueness_col=c("Time"="time_column"),
                                              grouping_col=c("Idenity"="entity_id"),
                                              metric_columns = c("metric_column", "metric_column",
                                                                 "entity_category_1", "entity_category_3"),
                                              metric_columns_summarization_functions=c("SUM"=sum, "MEAN"=mean,
                                                                                       "Category 1"=ngram::concatenate, "Category 3"=ngram::concatenate),
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
    output$category_filter_ui <- renderUI({
          categories <- sort(unique(df[[grouping_col]]), decreasing=TRUE)
          shinyWidgets::pickerInput(ns("category_filter_selection"), paste(names(grouping_col), "Filter"),
                      categories,
                      options=list(`actions-box`=TRUE, `live-search`=TRUE),
                      multiple=TRUE,
                      selected=dplyr::first(categories))
    })

    # Reactive Dataframe ####
    reactive_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        # req(input$required_input)
        req(input$category_filter_selection)

        return_df <- df %>%
            dplyr::filter(  !!rlang::sym(grouping_col) %in% input$category_filter_selection ) %>%
            dplyr::group_by( !!rlang::sym(record_uniqueness_col) )
        return_summarized_df <- return_df %>%
            dplyr::summarize()
        temp_unsummarized_df <- return_df
        for( i in 1:length(metric_columns) )  {
          temp_summarized_df <- temp_unsummarized_df %>%
              dplyr::summarize_at( c(metric_columns[i]), metric_columns_summarization_functions[i] )
          return_summarized_df <- merge(return_summarized_df, temp_summarized_df, by=c(record_uniqueness_col))
        }
        return_df <- return_summarized_df %>%
            dplyr::ungroup()
        column_drops <- c('all')
        return_df <- return_df[, !(names(return_df) %in% column_drops)] %>%
          dplyr::rename(record_uniqueness_col)

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
                                                colnames=colnames( reactive_df() ) )

    })
}

## To be copied in the UI
# mod_interactive_data_table_ui("interactive_data_table_1")

## To be copied in the server
# mod_interactive_data_table_server("interactive_data_table_1")
