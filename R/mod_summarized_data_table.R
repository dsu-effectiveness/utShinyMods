#' summarized_data_table UI Function
#'
#' This function creates the UI portion for the `summarized_data_table` Shiny module. This function must be used in conjunction with the `mod_summarized_data_table_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @export
#'
#' @importFrom shiny NS tagList
mod_summarized_data_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    uiOutput( ns('category_filter_ui') ) ,
    DT::dataTableOutput( ns('summary_table'), width=NULL )
  )
}


#' summarized_data_table Server Function
#'
#' This function provides the server-side logic for the `summarized_data_table` Shiny module. This function must be used in conjunction with the `mod_summarized_data_table_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#' @param df The data frame that the module will use to create the summary table.
#' @param record_uniqueness_cols A vector of column names in `df` that will be used to uniquely identify each row in the summary table.
#' @param filter_col A named vector of labels and column names that will be used to filter the data in the data frame. Currently only supports one filter.
#' @param metric_columns A vector of column names in `df` that are summarized in the summary table. These columns should contain data that can be aggregated using the corresponding summarization function.
#' @param metric_columns_summarization_functions A named vector of functions that are used to summarize the columns specified in metric_columns. This named vector should be in the form c("Display Name 1"=function_1, "Display Name 2"=function_2, ...), where the display names are the names that will be shown to the user in the Shiny app and the function names are the actual functions. These functions should take a vector of values as input and return a single numeric value that represents the aggregation of the input values.
#' @param module_title A character string to be used as the title of the module.
#' @param module_sub_title A character string to be used as the sub-title of the module.
#'
#' @export
mod_summarized_data_table_server <- function(id,
                                              df=utShinyMods::entity_time_metric_categories_df,
                                              record_uniqueness_cols=c("entity_id", "time_column"),
                                              filter_col=c("Time"="time_column"),
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
          categories <- sort(unique(df[[filter_col]]), decreasing=TRUE)
          shinyWidgets::pickerInput(ns("category_filter_selection"), paste(names(filter_col), "Filter"),
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

        return_df <- as.data.frame(unclass(df), stringsAsFactors = TRUE)

        return_df <- return_df %>%
            dplyr::filter(  !!rlang::sym(filter_col) %in% input$category_filter_selection ) %>%
            dplyr::group_by_at( record_uniqueness_cols )
        return_summarized_df <- return_df %>%
            dplyr::summarize()
        temp_unsummarized_df <- return_df
        for( i in 1:length(metric_columns) )  {
          temp_summarized_df <- temp_unsummarized_df %>%
              dplyr::summarize_at( c(metric_columns[i]), metric_columns_summarization_functions[i] )
          return_summarized_df <- merge(return_summarized_df, temp_summarized_df, by=record_uniqueness_cols)
        }
        return_df <- return_summarized_df %>%
            dplyr::ungroup()
        column_drops <- c('all')
        return_df <- return_df[, !(names(return_df) %in% column_drops)]

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

    })
}

