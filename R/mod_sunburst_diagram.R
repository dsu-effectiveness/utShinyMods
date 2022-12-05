#' sunburst_diagram UI Function
#'
#' This function creates the UI portion for the `sunburst_diagram` Shiny module. This function must be used in conjunction with the `mod_sunburst_diagram_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @importFrom shiny NS tagList
#'
#' @export
mod_sunburst_diagram_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput( ns("module_title_ui") ),
    shiny::fluidRow(
      shiny::column(width = 6,
                    utVizSunburst::sunburstOutput(ns("sunburst"))),
      shiny::column(width = 6,
                    reactable::reactableOutput(ns("table")))
    )
  )
}



#' sunburst_diagram Server Function
#'
#' This function provides the server-side logic for the `sunburst_diagram` Shiny module. This function must be used in conjunction with the `mod_sunburst_diagram_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#' @param df The data frame that the module uses to create the sunburst diagram.
#' @param step_cols A vector of column names in `df` that are used to define the levels of the sunburst diagram. Each column should contain categorical data, and the columns should be ordered such that the first column defines the innermost level of the diagram, the second column defines the next level, and so on.
#' @param module_title A character string to be used as the title of the module.
#' @param module_sub_title A character string to be used as the sub-title of the module.
#'
#' @export
mod_sunburst_diagram_server <- function(id,
                                        df=utShinyMods::entity_time_metric_categories_df,
                                        step_cols=c( "entity_category_1", "entity_category_2", "entity_category_3", "entity_outcome" ),
                                        module_title="Title of Module",
                                        module_sub_title="Sub Title for module." ){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$module_title_ui <- renderUI({
      tagList(
        h2(module_title),
        p(module_sub_title)
      )
    })

    # Sunburst diagram requires all step columns to be of type character
    df[step_cols] <- lapply(df[step_cols], as.character)

    mouseover_handler <- utVizSunburst::get_shiny_input_handler(inputId=ns("sunburst_sector_data"),
                                                                type="path_data")
    output$sunburst <- utVizSunburst::renderSunburst({
      utVizSunburst::sunburst(df,
                              palette=colors_8(),
                              steps=step_cols,
                              mouseover_handler=mouseover_handler)
    })

    reactive_sector_data <- shiny::eventReactive(input$sunburst_sector_data, {
      input$sunburst_sector_data
    })

    output$table = reactable::renderReactable({
      reactable::reactable(reactive_sector_data(),
                           columns=list( color=reactable::colDef( style = function(value) { list(background=value, color="transparent") } ) ) )
    })
  })
}

