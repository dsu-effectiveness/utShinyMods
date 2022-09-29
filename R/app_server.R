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

  # Sunburst Module ####
  mod_sunburst_diagram_server("sunburst_diagram_example")

  # Summarized Data Table Module ####
  mod_summarized_data_table_server("summarized_data_table_example")

  # Downloadable Data Table Module ####
  mod_downloadable_data_table_server("downloadable_data_table_example")

  # Rate Metric Bar Char Module ####
  mod_rate_metric_bar_chart_server("rate_metric_bar_chart_example")

  # Over Time Line Char Module ####
  mod_over_time_line_chart_server("over_time_line_chart_example")


  waiter::waiter_hide() # hide the waiter
}
