#' interactive_data_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_interactive_data_table_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' interactive_data_table Server Functions
#'
#' @noRd 
mod_interactive_data_table_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_interactive_data_table_ui("interactive_data_table_1")
    
## To be copied in the server
# mod_interactive_data_table_server("interactive_data_table_1")
