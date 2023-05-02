#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    navbarPage(
      theme = get_theme(),
      title = get_title_logo(),
      tabPanel("Over Time Line Chart - Term", mod_over_time_line_chart_ui("over_time_line_chart_term_example")),
      tabPanel("Over Time Line Chart - Days", mod_over_time_line_chart_ui("over_time_line_chart_days_example")),
      tabPanel("Rate Metric Bar Chart", mod_rate_metric_bar_chart_ui("rate_metric_bar_chart_example")),
      tabPanel("Sunburst", mod_sunburst_diagram_ui("sunburst_diagram_example")),
      tabPanel("Summarized Data Table", mod_summarized_data_table_ui("summarized_data_table_example")),
      tabPanel("Downloadable Data Table", mod_downloadable_data_table_ui("downloadable_data_table_example")),
      tabPanel("Sankey", mod_sankey_diagram_ui("sankey_diagram_example")),
      tabPanel("Help", mod_help_ui("help_example"))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "utShinyMods"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
    waiter::useWaiter() # include dependencies
  )

}
