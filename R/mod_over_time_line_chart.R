#' over_time_line_chart UI Function
#'
#' @description A shiny Module.
#'
#' @param id A unique identifier, linking the UI to the Server
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_over_time_line_chart_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinyjs::useShinyjs(), #TODO: is this required?
    fluidRow(
        column(3, wellPanel( uiOutput( ns('controls_ui') ) ) ),
        column(9, plotly::plotlyOutput( ns('over_time_line_chart'), width=NULL ) )
    )
  )
}

#' over_time_line_chart Server Functions
#'
#'
#' @param id A unique identifier, linking the UI to the Server
#' @param input,output,session Internal parameters for {shiny}.
#' @param df
#' @param time_col
#' @param metric_col
#' @param metric_summarization_function
#' @param grouping_cols
#'
#' Justification for using extra parameters in the Server function, can be found in the following documentation:
#' https://shiny.rstudio.com/articles/modules.html
#' Quote from documentation:
#' "You can define the function so that it takes any number of additional parameters, including ..., so that whoever uses the module can customize what the module does."
#'
#' @importFrom magrittr %>%
#'
#' @noRd
mod_over_time_line_chart_server <- function(id,
                                            df=entity_time_metric_categories_df,
                                            entity_id_col=c("Idenity"="entity_id"),
                                            time_col=c("Time"="time_column"),
                                            metric_col=c("Metric"="metric_column"),
                                            metric_summarization_function=sum,
                                            grouping_cols=c("Category 1"="entity_category_1",
                                                            "Category 2"="entity_category_2",
                                                            "Category 3"="entity_category_3")){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # UI Generation ####
    output$controls_ui <- renderUI({
        tagList(
          radioButtons(ns("grouping_selection"),
                       "Grouping Options",
                       c("None"="all",
                         grouping_cols),
                       selected="all"),
          # TODO: This potion needs to be generated based on input$grouping_selection,
          # to be a filter applied to the available groups.
          #pickerInput(ns("category_selector"), paste(agg_val_desc, "Filter"),
          #            categories,
          #            options=list(`actions-box`=TRUE, `live-search`=TRUE),
          #            multiple=TRUE,
          #            selected=sample(categories, selected_count)),
        )
    })

    # Reactive Dataframe ####
    reactive_over_time_plot_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        #req(input$category_selector)
        req(input$grouping_selection)

        plot_df <- df %>%
        #   filter(input$grouping_selection %in% input$category_selector) %>%
            dplyr::group_by( !!rlang::sym(time_col), !!rlang::sym(input$grouping_selection) ) %>%
            dplyr::summarize( y_plot=metric_summarization_function( !!rlang::sym(metric_col) ) ) %>%
            tidyr::drop_na() %>% # TODO: do we want to drop_na() here?
            dplyr::mutate(grouping=!!rlang::sym(input$grouping_selection),
                          x_plot=!!rlang::sym(time_col) ) %>%
            dplyr::ungroup()
        # Pause plot execution if df has no values. This eliminates an error message.
        req( nrow(plot_df) > 0 )
        return( plot_df )
    })

    # Plot Rendering ####
    output$over_time_line_chart <- plotly::renderPlotly({

        # custom function dependency
        generate_line_chart(reactive_over_time_plot_df(),
                            x=x_plot,
                            y=y_plot,
                            grouping=grouping,
                            x_label=names(time_col),
                            y_label=names(metric_col),
                            # TODO: input$grouping_selection does not contain any names
                            group_labeling=paste(names(input$grouping_selection),
                                                 ": ",
                                                 !!rlang::sym(input$grouping_selection),
                                                 "</br>",
                                                 sep=''),
                            title="Title of Plot",
                            sub_title="Sub Title for plot.",
                            # TODO: input$grouping_selection does not contain any names
                            legend_title=names(input$grouping_selection)
        )
    })

  })
}

## To be copied in the UI
# mod_over_time_line_chart_ui("over_time_line_chart_1")

## To be copied in the server
# mod_over_time_line_chart_server("over_time_line_chart_1")
