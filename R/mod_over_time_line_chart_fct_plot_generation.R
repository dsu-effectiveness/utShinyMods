
#' Generate Line Chart
#'
#' The generate_line_chart function is used to create a line chart from a given data frame.
#'
#' @param df The data frame containing the data to be plotted.
#' @param x The column name of the data frame containing the x-axis values.
#' @param y The column name of the data frame containing the y-axis values.
#' @param x_label The label to be used for the x-axis.
#' @param y_label The label to be used for the y-axis.
#' @param x_is_continuous A Boolean indicating whether the x-axis values are continuous or not. Defaults to TRUE.
#' @param x_angle The angle, in degrees, at which to rotate the x-axis tick labels. Defaults to 45.
#' @param x_format A function used to format the x-axis values. Defaults to the identity function (i.e. no formatting).
#' @param y_format A function used to format the y-axis values. Defaults to the identity function (i.e. no formatting).
#' @param grouping The column name of the data frame to use for grouping the data. Defaults to 0 (no grouping).
#' @param group_labeling A string to be used as a label for the group. This is used in the tooltip for each data point. Defaults to the empty string.
#' @param legend_title The title for the legend. Defaults to the empty string.
#' @param legend_position The position of the legend on the plot. Defaults to "right".
#' @param lin_reg A boolean indicating whether to include a linear regression line on the plot. Defaults to FALSE.
#'
#' @return Returns a plotly object containing the line chart, this chart can be further customized using plotly functions.
#'
#' @export
generate_line_chart <- function(df,
                                x,
                                y,
                                x_label,
                                y_label,
                                x_is_continuous=TRUE,
                                x_angle=45,
                                x_format=function(x){x},
                                y_format=function(x){x},
                                grouping=0,
                                group_labeling="",
                                legend_title='',
                                legend_position="right",
                                lin_reg=FALSE) {

    if (x_is_continuous) {
        x_scale <- ggplot2::scale_x_continuous( x_label, labels=x_format )
    } else {
        x_scale <- ggplot2::scale_x_discrete( x_label, labels=x_format )
    }

    ggplot_object <- ggplot2::ggplot(df, ggplot2::aes(x={{x}},
                                                      y={{y}},
                                                      group=as.factor({{grouping}}),
                                                      color=as.factor({{grouping}}),
                                                      text=paste(paste(x_label, ": ", sep=''), x_format({{x}}), "<br />",
                                                                 paste(y_label, ": ", sep=''), y_format({{y}}), "<br />",
                                                                 {{group_labeling}},
                                                                 sep='') ) ) +
        ggplot2::geom_line( size=.5 ) +
        ggplot2::geom_point( alpha=.8, size=.5 ) +
        ggplot2::scale_color_manual( palette=ut_color_palette ) +
        ggplot2::scale_y_continuous( y_label, labels=y_format ) +
        x_scale +
        ggplot2::guides( color=ggplot2::guide_legend( title=legend_title ) ) +
        ggplot2::theme_minimal() +
        ggplot2::theme( panel.grid.minor.x = ggplot2::element_blank(),
                        panel.grid.minor.y = ggplot2::element_blank(),
                        legend.position=legend_position )

    if (lin_reg) {
        ggplot_object <-ggplot_object +
            ggplot2::geom_smooth(method="lm", fullrange=TRUE, linetype="dashed", size=.5, se=F)
    }

    plot <- plotly::ggplotly(ggplot_object, tooltip=c('text')) %>%
        plotly::config(displayModeBar=FALSE) %>%
        plotly::layout( xaxis=list(tickangle=x_angle) )

    return( plot )
}


#' Create conditional filter input
#'
#' Create conditional panel containing pickerInput
#' created by `conditional_filter_input()`.
#' This function is used in the UI (contains `shiny::uiOutput`)
#' @param col_name Which column to create filter for
#' @param panel_name A string as the name of the panel.
#' @param session Shiny session
#'
#' @export
conditional_filter_panel <- function(col_name, panel_name, session) {
    ns <- session$ns
    shiny::conditionalPanel(
        condition = glue::glue("input.{panel_name}.includes('{col_name}')"),
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
#'
#' @export
conditional_filter_input <- function(df, col_name, input_label, session) {
    ns <- session$ns
    shiny::renderUI({
        shinyWidgets::pickerInput(
            ns(glue::glue("{col_name}_filter")),
            label = glue::glue("{input_label} Filter"),
            choices = unique(df[[col_name]]),
            selected = unique(df[[col_name]]),
            multiple = TRUE,
            options = list(`actions-box` = TRUE)
        )
    })
}
