#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#'
#' @import shiny
#' @importFrom magrittr %>%
#'
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  waiter::waiter_show( # show the waiter
    html = tagList( waiter::spin_fading_circles(), # use a spinner
                    "Loading Insights..."
    ),
    color="#c2c5c8"
  )

  # Teams Module ####
  mod_summarized_data_table_server("teams_data_table")

  # Academic Portal Report Module ####
  mod_downloadable_data_table_server("academic_portal_upload_report_downloadable_data_table")

  # Fall to Spring Retention Module ####
  mod_rate_metric_bar_chart_server("fall_to_spring_retention_rate_metric_bar_chart")

  # Trending GPA Module ####
  mod_over_time_line_chart_server("gpa_over_time_line_chart")


  waiter::waiter_hide() # hide the waiter
}
