#' rate_metric_bar_chart UI Function
#'
#' @description A shiny Module.
#'
#' To be copied in the UI
#' mod_rate_metric_bar_chart_ui("rate_metric_bar_chart_1")
#'
#' To be copied in the server
#' mod_rate_metric_bar_chart_server("rate_metric_bar_chart_1")
#'
#' @param id,input,output,session Internal parameters for {shiny}.
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
#
#' To be copied in the UI
#' mod_rate_metric_bar_chart_ui("rate_metric_bar_chart_1")
#'
#' To be copied in the server
#' mod_rate_metric_bar_chart_server("rate_metric_bar_chart_1")
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
