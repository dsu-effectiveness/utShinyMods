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
    html = shiny::HTML(paste(waiter::spin_fading_circles(),
                             shiny::br(),
                             shiny::p("Waiting for brilliance...")))
  )

  # Over Time Line Chart Term Module ####
  mod_over_time_line_chart_server( "over_time_line_chart_term_example" )

  # Over Time Line Chart Days Module ####
  mod_over_time_line_chart_server("over_time_line_chart_days_example",
                                  time_col=c("Time"="time_column_2") )

  # Rate Metric Bar Chart Module ####
  mod_rate_metric_bar_chart_server("rate_metric_bar_chart_example")

  # Sunburst Module ####
  mod_sunburst_diagram_server("sunburst_diagram_example")

  # Summarized Data Table Module ####
  mod_summarized_data_table_server("summarized_data_table_example")

  # Downloadable Data Table Module ####
  mod_downloadable_data_table_server("downloadable_data_table_example")



  waiter::waiter_hide() # hide the waiter
}
