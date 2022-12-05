#' over_time_line_chart UI Function
#'
#' This function creates the UI portion for the `over_time_line_chart` Shiny module. This function must be used in conjunction with the `mod_over_time_line_chart_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @importFrom shiny NS tagList
#'
#' @export
mod_over_time_line_chart_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    fluidRow(
        column(2, tagList( uiOutput( ns('grouping_selection_ui') ),
                           uiOutput( ns('filter_control_ui') ) ) ),
        column(10, tagList( plotly::plotlyOutput( ns('over_time_line_chart'), width=NULL ) ) )
    )
  )
}

#' over_time_line_chart Server Functions
#'
#' This function provides the server-side logic for the `over_time_line_chart` Shiny module. This function must be used in conjunction with the `mod_over_time_line_chart_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#' @param df A data frame containing the data to be plotted. The data frame should contain columns for time data, metric data, and any categorical variables to be used for grouping or filtering.
#' @param time_col The name of the column in `df` that contains time data.
#' @param metric_col The name of the column in `df` that contains metric data. This column should contain numerical data.
#' @param metric_summarization_function  A function for summarizing the metric data. This function should take a vector of numerical data as input and return a single numerical value. The default value is `sum`, which takes the sum of the metric data.
#' @param grouping_cols A list of columns to group the data by. This should be a named list, with each element containing the name of a column in `df` to group by. The names of the list elements will be used as labels in the Shiny app's input controls.
#' @param filter_cols A list of columns to use as filters for the data. This should be a named list, with each element containing the name of a column in `df` to filter by. The names of the list elements will be used as labels in the Shiny app's input controls.
#' @param module_title A character string to be used as the title of the module.
#' @param module_sub_title A character string to be used as the sub-title of the module.
#'
#' @importFrom magrittr %>%
#'
#' @export
mod_over_time_line_chart_server <- function(id,
                                            df=utShinyMods::entity_time_metric_categories_df,
                                            time_col=c("Time"="time_column"),
                                            metric_col=c("Metric"="metric_column"),
                                            metric_summarization_function=sum,
                                            grouping_cols=c("Category 1"="entity_category_1",
                                                            "Category 2"="entity_category_2",
                                                            "Category 3"="entity_category_3"),
                                            filter_cols=c("Category 1"="entity_category_1",
                                                          "Category 2"="entity_category_2",
                                                          "Category 3"="entity_category_3"),
                                            module_title="Title of Module",
                                            module_sub_title="Sub Title for module."){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # UI Generation ####
    output$module_title_ui <- renderUI({
      tagList(
        h2(module_title),
        p(module_sub_title)
      )
    })
    output$grouping_selection_ui <- renderUI({
        tagList(
          shinyWidgets::pickerInput(ns("grouping_selection"),
                                    tags$b("Group By"),
                                    choices=grouping_cols,
                                    multiple=TRUE,
                                    selected=grouping_cols[1],
                                    options = list(`actions-box` = TRUE) )
        )
    })
    # Filter controls
    output$filter_control_ui <- renderUI({
      filter_panel_name <- "filter_control"
      filter_control <- shinyWidgets::pickerInput( ns(filter_panel_name),
                                                   tags$b("Add/Remove Filter"),
                                                   choices = filter_cols,
                                                   multiple = TRUE,
                                                   options = list(`actions-box` = TRUE) )
      filter_displays <- lapply(names(filter_cols), function(filter_label) {
        conditional_filter_panel(filter_cols[[filter_label]], filter_panel_name, session)
      })
      do.call(tagList, list(filter_control, filter_displays) )
    })
    for ( filter_label in names(filter_cols) ) {
      local({
        local_filter_cols <- filter_cols
        local_filter_label <- filter_label
        col_name <- local_filter_cols[[local_filter_label]]
        output_name <- glue::glue("{col_name}_panel")
        output[[output_name]] <- conditional_filter_input(df, col_name, local_filter_label, session)
      })
    }

    # Reactive Dataframe ####
    reactive_over_time_plot_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        req(input$grouping_selection)

        # Bind variables to function
        x_plot <- NULL
        y_plot <- NULL

        plot_df <- df %>%
            tidyr::unite( grouping, input$grouping_selection, remove=FALSE, sep=' | ' ) %>%
            dplyr::filter( dplyr::across(input$filter_control, ~ .x %in% input[[glue::glue("{dplyr::cur_column()}_filter")]] ) ) %>%
            dplyr::group_by( grouping, !!rlang::sym(time_col) ) %>%
            dplyr::summarize( y_plot=metric_summarization_function( !!rlang::sym(metric_col) ) ) %>%
            dplyr::mutate( x_plot=!!rlang::sym(time_col) ) %>%
            dplyr::ungroup()
        # Pause plot execution if df has no values. This eliminates an error message.
        req( nrow(plot_df) > 0 )
        return( plot_df )
    })

    # Plot Rendering ####
    output$over_time_line_chart <- plotly::renderPlotly({

        reactive_plot_df <- reactive_over_time_plot_df()

        x_is_continuous <- !is.character( reactive_plot_df[['x_plot']] )
        if (!x_is_continuous) {
          reactive_plot_df[['x_plot']] <- as.factor(reactive_plot_df[['x_plot']])
        }

        group_label <- ngram::concatenate( names(grouping_cols)[grouping_cols %in% input$grouping_selection],
                                           collapse=' | ' )

        generate_line_chart(reactive_plot_df,
                            x=x_plot,
                            y=y_plot,
                            x_is_continuous=x_is_continuous,
                            grouping=grouping,
                            x_label=names(time_col),
                            y_label=names(metric_col),
                            group_labeling=paste("Grouping Label: ", group_label,
                                                 "</br>",
                                                 "Grouping Value: ", grouping,
                                                 "</br>",
                                                 sep=''),
                            legend_title=group_label
        )
    })

  })
}

