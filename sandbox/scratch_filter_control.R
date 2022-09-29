library(shiny)

#' Create conditional filter input
#'
#' Create conditional panel containing pickerInput
#' created by `conditional_filter_input()`.
#' This function is used in the UI (contains `shiny::uiOutput`)
#' @param col_name Which column to create filter for
#' @param session Shiny session
conditional_filter_panel <- function(col_name, session) {
    ns <- session$ns
    shiny::conditionalPanel(
        condition = glue::glue("input.add_filter.includes('{col_name}')"),
        shiny::uiOutput(ns(glue::glue("{col_name}_panel"))),
        ns = ns
    )
}

#' Create conditional filter input
#'
#' Create pickerInput to be used in
#' conditional panel created by `conditional_filter_panel()`
#' This function is used in the server (contains `shiny::renderUI`)
#' @param df A dataframe like object.
#' @param col_name Which column, contained in df, to create filter for.
#' @param input_label Label for pickerInput
#' @param session Shiny session
conditional_filter_input <- function(df, col_name, input_label, session) {
    ns <- session$ns
    shiny::renderUI({
        shinyWidgets::pickerInput(
            ns(glue::glue("{col_name}")),
            label = input_label,
            choices = unique(df[[col_name]]),
            selected = unique(df[[col_name]]),
            multiple = TRUE,
            options = list(`actions-box` = TRUE)
        )
    })
}



# UI ####
ui <- fluidPage(
    uiOutput( 'filter_control_ui' )
)

# Server ####

server <- function(input, output, session) {
    ns <- session$ns

    df <- utShinyMods::entity_time_metric_categories_df

    filter_options <- c("Time"="time_column",
                        "Category 1"="entity_category_1",
                        "Category 2"="entity_category_2")

    # UI Generation ####
    # https://gist.github.com/wch/5436415/
    output$filter_control_ui <- renderUI({
        filter_control <- shinyWidgets::pickerInput( ns("add_filter"),
                                                     "Add Filter",
                                                     choices = filter_options,
                                                     multiple = TRUE,
                                                     options = list(`actions-box` = TRUE) )

        filter_displays <- lapply(names(filter_options), function(filter_label) {
            conditional_filter_panel(filter_options[[filter_label]], session)
        })

        do.call(tagList, list(filter_control, filter_displays) )
    })

    for ( filter_label in names(filter_options) ) {
        local({
            local_filter_options <- filter_options
            local_filter_label <- filter_label

            col_name <- local_filter_options[[local_filter_label]]
            output_name <- glue::glue("{col_name}_panel")
            output[[output_name]] <- conditional_filter_input(df, col_name, local_filter_label, session)
        })
    }

}
shinyApp(ui, server)
