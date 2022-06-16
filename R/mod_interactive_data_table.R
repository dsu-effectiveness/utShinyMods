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
    shinyjs::useShinyjs(), #TODO: is this required?
    uiOutput( ns("module_title_ui") ),
    fluidRow(
        column(2, tagList( h5("Table Controls"),
                           uiOutput( ns('grouping_selection_ui') ),
                           uiOutput( ns('category_filter_ui') ) ) ),
        column(10, tagList( h5(HTML(paste(em("Interactive"), "Data Table"))),
                            uiOutput( ns("table_title_ui") ),
                            DT::dataTableOutput( ns('summary_table'), width=NULL )))
    )
  )
}

#' interactive_data_table Server Functions
#'
#' @noRd
mod_interactive_data_table_server <- function(id,
                                              df=entity_time_metric_categories_df,
                                              entity_id_col=c("Idenity"="entity_id"),
                                              metric_columns = c("metric_column", "metric_column",
                                                                 "entity_category_1", "entity_category_3"),
                                              metric_columns_summarization_functions=c("SUM"=sum, "MEAN"=mean,
                                                                                       "Category 1"=ngram::concatenate, "Category 3"=ngram::concatenate),
                                              grouping_cols=c("Time"="time_column"),
                                              module_title="Title of Module",
                                              module_sub_title="Subtitle of module",
                                              table_title="Title of Table",
                                              table_sub_title="Subtitle for table."){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    # UI Generation ####
    output$module_title_ui <- renderUI({
      tagList(
        h2(module_title),
        h4(module_sub_title)
      )
    })
    output$table_title_ui <- renderUI({
      h3(table_title)
    })
    output$grouping_selection_ui <- renderUI({
        tagList(
          radioButtons(ns("grouping_selection"),
                       "Grouping Options",
                       c("Individual"="all",
                         grouping_cols),
                       selected="all")
        )
    })
    reactive_grouping_selection <- reactive({
        req(input$grouping_selection)
        grouping_selection <- input$grouping_selection
        if (grouping_selection == 'all') {
          grouping_selection <- entity_id_col
        }
        return(grouping_selection)
    })
    output$category_filter_ui <- renderUI({
          categories <- sort(unique(df[[reactive_grouping_selection()]]), decreasing=TRUE)
          shinyWidgets::pickerInput(ns("category_filter_selection"), "Grouping Filter",
                      categories,
                      options=list(`actions-box`=TRUE, `live-search`=TRUE),
                      multiple=TRUE,
                      selected=sample(categories, 7, replace=TRUE))
    })

    # Reactive Dataframe ####
    # You use a data frame to create multiple columns so you can wrap
    # this up into a function:
    apply_summarization_functions_to_metric_columns <- function(metric_columns_and_summarization_functions) {
      return_df <- dplyr::tibble()
      for ( column_function_pair in metric_columns_and_summarization_functions )  {
        print(column_function_pair)
        tibble::add_column(return_df, column_function_pair[[2]]( !!rlang::sym(column_function_pair[[1]]) ) )
      }
      return(return_df)
    }
    #mtcars %>%
    #  group_by(cyl) %>%
    #  summarise(my_quantile(disp, c(0.25, 0.75)))

    reactive_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        # req(input$required_input)
        req(input$category_filter_selection)
        req(input$grouping_selection)

        return_df <- df %>%
            dplyr::filter(  !!rlang::sym(reactive_grouping_selection()) %in% input$category_filter_selection ) %>%
            dplyr::group_by( !!rlang::sym(entity_id_col), !!rlang::sym(input$grouping_selection) )
            #dplyr::summarize( metric_summarization_function( !!rlang::sym(metric_col), na.rm=TRUE ) ) %>%
            #dplyr::summarize( apply_summarization_functions_to_metric_columns(metric_columns_and_summarization_functions) ) %>%
        return_summarized_df <- return_df %>%
            dplyr::summarize()
        temp_unsummarized_df <- return_df
        for( i in 1:length(metric_columns) )  {
          temp_summarized_df <- temp_unsummarized_df %>%
              dplyr::summarize_at( c(metric_columns[i]), metric_columns_summarization_functions[i] )
          return_summarized_df <- merge(return_summarized_df, temp_summarized_df, by=c(input$grouping_selection, entity_id_col))
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
                                                              lengthMenu=list( c(10, 25, 100, -1),
                                                                               c(10, 25, 100, "All") ) ),
                                                rownames=FALSE,
                                                colnames=colnames( reactive_df() ) )

    })
}

## To be copied in the UI
# mod_interactive_data_table_ui("interactive_data_table_1")

## To be copied in the server
# mod_interactive_data_table_server("interactive_data_table_1")
