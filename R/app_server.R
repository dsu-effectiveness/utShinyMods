#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  ## To be copied in the server
  mod_over_time_line_chart_server("over_time_line_chart_1")
  mod_over_time_line_chart_server("over_time_line_chart_2")
  mod_over_time_line_chart_server("over_time_line_chart_3")
}
