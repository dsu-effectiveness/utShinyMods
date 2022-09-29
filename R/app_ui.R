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
      tabPanel("Teams", mod_summarized_data_table_ui("teams_data_table")),
      tabPanel("Academic Portal Report", mod_downloadable_data_table_ui("academic_portal_upload_report_downloadable_data_table")),
      tabPanel("Fall to Spring Retention", mod_rate_metric_bar_chart_ui("fall_to_spring_retention_rate_metric_bar_chart")),
      tabPanel("Trending GPA", mod_over_time_line_chart_ui("gpa_over_time_line_chart"))
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
