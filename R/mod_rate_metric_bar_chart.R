#' rate_metric_bar_chart UI Function
#'
#' This function creates the UI portion for the `rate_metric_bar_chart` Shiny module. This function must be used in conjunction with the `mod_rate_metric_bar_chart_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @export
#'
#' @importFrom shiny NS tagList
mod_rate_metric_bar_chart_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    fluidRow(
        column(2, tagList( uiOutput( ns('grouping_selection_ui') ),
                           uiOutput( ns('category_filter_ui') ) ) ),
        column(10, tagList( plotly::plotlyOutput( ns('rate_metric_bar_chart'), width=NULL ) ) )
    )
  )
}

#' rate_metric_bar_chart Server Functions
#'
#' This function provides the server-side logic for the `rate_metric_bar_chart` Shiny module. This function must be used in conjunction with the `mod_rate_metric_bar_chart_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#' @param df A data frame containing the data to be plotted.
#' @param time_col The name of the column in `df` that contains time data.
#' @param rate_metric_uniqueness_col The name of the column in `df` that specifies the units for which the rate metric is calculated. For example, if the rate metric is the percentage of customers who purchased a product, this column could contain the customer ID, and each customer would be counted only once.
#' @param rate_metric_criteria_col The name of the column in `df` that specifies the criteria for the rate metric. For example, if the rate metric is the percentage of customers who purchased a product, this column could contain a binary value indicating whether each customer purchased the product or not.
#' @param rate_metric_desc A description of the rate metric. This will be used as the label for the y-axis of the bar chart.
#' @param grouping_cols A named vector of columns in `df` as options to group the data by. This vector should be in the form c("Display Name 1"="column_name_1", "Display Name 2"="column_name_2", ...), where the display names are the names that will be shown to the user in the Shiny app and the column names are the actual names of the columns in the data frame.
#' @param module_title A character string to be used as the title of the module.
#' @param module_sub_title A character string to be used as the sub-title of the module.
#'
#' @export
mod_rate_metric_bar_chart_server <- function(id,
                                            df=utShinyMods::entity_time_metric_categories_df,
                                            time_col=c("Time"="time_column"),
                                            rate_metric_uniqueness_col=c("Entity"="entity_id"),
                                            rate_metric_criteria_col=c("Outcome"="entity_outcome"),
                                            rate_metric_desc="Outcome",
                                            grouping_cols=c("Category 1"="entity_category_1",
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
          radioButtons(ns("grouping_selection"),
                       tags$b("Group By"),
                       c("None"="population",
                         grouping_cols),
                       selected="population")
        )
    })
    output$category_filter_ui <- renderUI({
          req(input$grouping_selection)
          categories <- sort(unique(df[[input$grouping_selection]]))
          shinyWidgets::pickerInput(ns("category_filter_selection"),
                                    tags$b(paste(stringr::str_to_title(stringr::str_replace_all(input$grouping_selection, '_', ' ')), "Filter")),
                      categories,
                      options=list(`actions-box`=TRUE, `live-search`=TRUE),
                      multiple=TRUE,
                      selected=sample(categories, 7, replace=TRUE))
    })

    # Reactive Dataframe ####
    reactive_rate_metric_plot_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        req(input$category_filter_selection)
        req(input$grouping_selection)

        # Bind variables to function
        rate_metric_numerator <- NULL
        rate_metric_denominator <- NULL
        rate_metric <- NULL

        plot_df <- df %>%
            dplyr::filter(  !!rlang::sym(input$grouping_selection) %in% input$category_filter_selection ) %>%
            dplyr::group_by( !!rlang::sym(time_col), !!rlang::sym(input$grouping_selection) ) %>%
            dplyr::summarize( rate_metric_numerator = dplyr::n_distinct( dplyr::case_when(!!rlang::sym(rate_metric_criteria_col) == TRUE
                                                                                              ~ !!rlang::sym(rate_metric_uniqueness_col) ) ),
                              rate_metric_denominator = dplyr::n_distinct( !!rlang::sym(rate_metric_uniqueness_col) ) ) %>%
            dplyr::mutate(grouping=!!rlang::sym(input$grouping_selection),
                          rate_metric=rate_metric_numerator/rate_metric_denominator) %>%
            dplyr::ungroup()
        # Pause plot execution if df has no values. This eliminates an error message.
        req( nrow(plot_df) > 0 )
        return( plot_df )
    })

    # Plot Rendering ####
    output$rate_metric_bar_chart <- plotly::renderPlotly({

      plot_df <- reactive_rate_metric_plot_df()
      generate_grouped_bar_plot(plot_df,
                                x=!!rlang::sym(time_col),
                                y=rate_metric,
                                grouping=grouping,
                                x_label=names(time_col),
                                y_label=rate_metric_desc,
                                group_labeling=paste(stringr::str_to_title(stringr::str_replace_all(input$grouping_selection, '_', ' ')), ": ", !!rlang::sym(input$grouping_selection),
                                                     "</br>",
                                                     names(rate_metric_criteria_col), " Count: ", rate_metric_numerator,
                                                     "<br>",
                                                     "Total Population: ", rate_metric_denominator,
                                                     "<br>",
                                                     sep=''),
                                legend_title=stringr::str_to_title(stringr::str_replace_all(input$grouping_selection, '_', ' ')),
                                plot_height=80*dplyr::n_distinct(plot_df[, time_col])*max(1, .3*dplyr::n_distinct(input$category_filter_selection)) )
    })

  })
}
