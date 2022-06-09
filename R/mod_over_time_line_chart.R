#' over_time_line_chart UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_over_time_line_chart_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' over_time_line_chart Server Functions
#'
#' @noRd 
mod_over_time_line_chart_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_over_time_line_chart_ui("over_time_line_chart_1")
    
## To be copied in the server
# mod_over_time_line_chart_server("over_time_line_chart_1")
