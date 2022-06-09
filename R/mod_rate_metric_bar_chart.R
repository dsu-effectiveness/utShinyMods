#' rate_metric_bar_chart UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_rate_metric_bar_chart_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' rate_metric_bar_chart Server Functions
#'
#' @noRd 
mod_rate_metric_bar_chart_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_rate_metric_bar_chart_ui("rate_metric_bar_chart_1")
    
## To be copied in the server
# mod_rate_metric_bar_chart_server("rate_metric_bar_chart_1")
