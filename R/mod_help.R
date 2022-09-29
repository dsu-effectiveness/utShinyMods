#' help UI Function
#'
#' To be copied in the UI
#' mod_help_ui("help_1")
#'
#' To be copied in the server
#' mod_help_server("help_1")
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @export
#'
#' @importFrom shiny NS tagList
mod_help_ui <- function(id){
  ns <- NS(id)
  tagList(

  )
}

#' help Server Functions
#'
# To be copied in the UI
#' mod_help_ui("help_1")
#'
#' To be copied in the server
#' mod_help_server("help_1")'
#' @export
mod_help_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}
