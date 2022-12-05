#' help UI Function
#'
#' This function creates the UI portion for the `help` Shiny module. This function must be used in conjunction with the `mod_help_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
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
#' This function provides the server-side logic for the `help` Shiny module. This function must be used in conjunction with the `mod_help_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @export
mod_help_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}
