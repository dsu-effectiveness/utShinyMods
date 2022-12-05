#' sankey_diagram UI Function
#'
#' This function creates the UI portion for the `sankey_diagram` Shiny module. This function must be used in conjunction with the `mod_sankey_diagram_server` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#'
#' @importFrom shiny NS tagList
#'
#' @export
#'
mod_sankey_diagram_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::uiOutput(ns("cohort")),
        shiny::selectInput(
          ns("metric"),
          "Select Metric:",
          choices = c(
            c("Fall to Spring" = "spring_returned"),
            c("Fall to Fall" = "second_fall_returned"),
            c("Third Year" = "third_fall_returned"),
            c("Fourth Year" = "fourth_fall_returned"),
            c("Fifth Year" = "fifth_fall_returned"),
            c("Sixth Year" = "sixth_fall_returned")
          ),
          selected = "spring_returned"
        ),
        shiny::selectInput(
          ns("first_level"),
          "Select First-Level Group",
          choices = group_choices(),
          selected = "college"
        ),
        shiny::selectInput(
          ns("second_level"),
          "Select Second-Level Group",
          choices = group_choices(),
          selected = "gender"
        ),
        shiny::selectInput(
          ns("third_level"),
          "Select Third-Level Group",
          choices = group_choices(),
          selected = "race_ethnicity"
        ),
      ),
      shiny::mainPanel(
        utVizSankey::sankeyOutput(ns("retention_sankey"))
      )
    )
  )
}

#' sankey_diagram Server Functions
#'
#' This function provides the server-side logic for the `sankey_diagram` Shiny module. This function must be used in conjunction with the `mod_sankey_diagram_ui` function in order to create a complete Shiny module.
#'
#' @param id A character string giving the id of the module. This id should be unique and is used to identify the module when it is used in a Shiny app.
#' @param df A data frame containing the data that will be used to create the Sankey diagram.
#'
#' @export
mod_sankey_diagram_server <- function(id,
                                      df=utShinyMods::entity_time_metric_categories_df){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$cohort = shiny::renderUI({
      shiny::selectInput(
        ns("cohort"),
        "Add Cohort",
        choices = sort(unique(df$cohort), decreasing=TRUE),
        selected = as.numeric(format(Sys.time(), "%Y"))
      )
    })

    rvs = shiny::reactiveValues(
      select = c(
        first_level = "college",
        second_level = "gender",
        third_level = "race_ethnicity"
      )
    )

    shiny::observeEvent(input$first_level, {
      purrr::map(
        c("second_level", "third_level"),
        ~ check_update_select(input, "first_level", .x, rvs)
      )
      rvs$first_level = input$first_level
      rvs$second_level = input$second_level
      rvs$third_level = input$third_level
    })

    shiny::observeEvent(input$second_level, {
      purrr::map(
        c("first_level", "third_level"),
        ~ check_update_select(input, "second_level", .x, rvs)
      )
      rvs$first_level = input$first_level
      rvs$second_level = input$second_level
      rvs$third_level = input$third_level
    })

    shiny::observeEvent(input$third_level, {
      purrr::map(
        c("first_level", "second_level"),
        ~ check_update_select(input, "third_level", .x, rvs)
      )
      rvs$first_level = input$first_level
      rvs$second_level = input$second_level
      rvs$third_level = input$third_level
    })

    sankey_steps = shiny::reactive({
      basic_options = sankey_options()
      if (input$metric %in% basic_options) {
        idx = which(basic_options == input$metric)
        steps = basic_options[1:idx]
      } else {
        basic_options[4] = input$metric
        steps = basic_options
      }
      steps[[1]] = c(steps[[1]], input$first_level, input$second_level, input$third_level)
      return(steps)
    })

    retention_data = shiny::reactive({
      df %>%
        dplyr::filter(.data$cohort == input$cohort)
    })

    alt_click_handler = htmlwidgets::JS(glue::glue("function(event, data) {{
                                          Shiny.setInputValue('{ns('sankey_node_data')}:utVizSankey.nodeConverter', data.entries);}}")) # nolint

    output$retention_sankey = utVizSankey::renderSankey({
      # prevent sankey from rendering before all inputs
      # have been created/updated
      shiny::req(input$cohort)
      shiny::req(all(
        input$first_level != input$second_level,
        input$second_level != input$third_level,
        input$third_level != input$first_level))

      utVizSankey::sankey(retention_data(),
                          steps = sankey_steps(),
                          alt_click_handler = alt_click_handler)
    })

    # Can you download the data in the modal?
    modal_footer = get_modal_footer(get_app_version_visibility())

    shiny::observeEvent(input$sankey_node_data, {
      shiny::showModal(
        shiny::modalDialog(
          title = "Retention data",
          reactable::reactable(input$sankey_node_data,
                               elementId = "sankey-data",
                               defaultColDef = reactable::colDef(
                                 minWidth = 100
                               ),
                               columns = list(
                                 race_ethnicity = reactable::colDef(minWidth = 210),
                                 metric = reactable::colDef(minWidth = 140)
                               )),
          size = "xl",
          easyClose = TRUE,
          footer = modal_footer
        )
      )
    })


  })
}

#' Update drilldown inputs
#'
#' If two drilldown input choices are the same as each other,
#' replace one with the other
#' @param input List of all app inputs
#' @param input_a Current drilldown input
#' @param input_b One of remaining drilldown inputs
#' @param rvs Reactive values
check_update_select <- function(input, input_a, input_b, rvs) {
  if (input[[input_a]] == input[[input_b]]) {
    shiny::updateSelectInput(inputId = input_b, selected = rvs[[input_a]])
  }
}

#' Return all group choices
#'
#' Returns a vector of group of named column choices
#' Used for the Sankey drilldown options
group_choices <- function() {
  choices = c(
    c("College" = "college"),
    c("Department" = "department"),
    c("Program" = "program"),
    c("Gender" = "gender"),
    c("Race/Ethnicity" = "race_ethnicity")
  )
  return(choices)
}

#' Helper function for Sankey steps
#'
#' Returns a list of Sankey steps that can be
#' modified based on inputs
sankey_options <- function() {
  basic_options = list("population",
                       "spring_returned",
                       "second_fall_returned",
                       "third_fall_returned")
  return(basic_options)
}

#' Can you download the data in the modal?
#'
#' Determines the modal footer for the sankey pop-up table.
#' @param retention_version is the app 'public' or 'private'?
get_modal_footer <- function(retention_version) {
  if (retention_version == "private") {
    modal_footer = shiny::tagList(
      shiny::modalButton("Close"),
      shiny::actionButton("download-csv",
                          "Download as CSV",
                          onclick = "Reactable.downloadDataCSV('sankey-data')")
    )
  } else {
    modal_footer = shiny::tagList(
      shiny::modalButton("Close")
    )
  }
  return(modal_footer)
}


#' Get version
#'
#' Read environment variable which decides
#' whether to use the public or private version
get_app_version_visibility <- function() {
  # version_visibility <- Sys.getenv("VERSION_VISIBILITY")
  # Just hardcoding this for now.
  version_visibility <- "private"
  valid_versions <- c("public", "private")
  if (!(version_visibility %in% valid_versions)) {
    cli::cli_alert_warning("Ensure you have an environment variable called VERSION_VISIBILITY")
    cli::cli_alert_warning("VERSION_VISIBILITY should be either 'private' or 'public'")
    stop("Fix env variable VERSION_VISIBILITY and try again")
  }
  return(version_visibility)
}
