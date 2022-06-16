# UI FUNCTION ####
# TODO: move all data specific UI generation functions to server
tagList(
    shinyjs::useShinyjs(), #TODO: is this required?
    fluidRow(
        column(3, wellPanel( uiOutput( ns('grouping_selection_ui') ),
                             uiOutput( ns('category_filter_ui') ) ) ),
        column(9, DT::dataTableOutput( ns('summary_table'), width=NULL ) )
    )
)

# SERVER FUNCTION ####

# UI Generation ####
output$grouping_selection_ui <- renderUI({
    tagList(
      radioButtons(ns("grouping_selection"),
                   "Grouping Options",
                   c("None"="all",
                     grouping_cols),
                   selected="all")
    )
})
output$category_filter_ui <- renderUI({
      req(input$grouping_selection)
      categories <- sort(unique(df[[input$grouping_selection]]))
      shinyWidgets::pickerInput(ns("category_filter_selection"), "Grouping Filter",
                  categories,
                  options=list(`actions-box`=TRUE, `live-search`=TRUE),
                  multiple=TRUE,
                  selected=sample(categories, 7, replace=TRUE))
})

# Reactive Dataframe ####
reactive_df <- reactive({
    # Pause plot execution while input values evaluate. This eliminates an error message.
    # req(input$required_input)
    req(input$category_filter_selection)
    req(input$grouping_selection)

    return_df <- df %>%
        dplyr::filter(  !!rlang::sym(input$grouping_selection) %in% input$category_filter_selection ) %>%
        dplyr::group_by( !!rlang::sym(time_col), !!rlang::sym(input$grouping_selection) ) %>%
        dplyr::summarize( y_plot=metric_summarization_function( !!rlang::sym(metric_col),
                          na.rm=TRUE ) ) %>%
        dplyr::mutate(grouping=!!rlang::sym(input$grouping_selection),
                      x_plot=!!rlang::sym(time_col) ) %>%
        dplyr::ungroup()
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
                                            colnames=colnames( clean_names(reactive_df(), case="title") ) )

