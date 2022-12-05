
#' Make Percent
#'
#' @param x Any real number.
#'
#' @return Input formatted as if assumed to be a percentage, with a "%" sign appended.
#' @export
#'
#' @examples
#' make_percent(.5)
#' make_percent(1)
#' make_percent(90)
make_percent <- function(x) {
    return( scales::percent(round(x, 3), drop0trailing=TRUE) )
}

#' Generate Grouped Bar Plot
#'
#' @param df A data frame containing the data to be plotted.
#' @param x A column name in `df` representing the x-axis variable in the plot.
#' @param y A column name in `df` representing the y-axis variable in the plot.
#' @param x_label A string representing the label for the x-axis.
#' @param y_label A string representing the label for the y-axis.
#' @param y_format A function that takes a numeric value and returns a string. This function is used to format the y-axis labels. Default value is make_percent, which converts numeric values to percentages.
#' @param grouping A column name in df representing the variable to group by in the plot. Default value is "None", which means no grouping will be performed.
#' @param group_labeling A string representing the label for the grouping variable. Default value is an empty string.
#' @param legend_title A string representing the title of the legend. Default value is an empty string.
#' @param legend_position A string representing the position of the legend in the plot. Default value is "right".
#' @param plot_height A numeric value representing the height of the plot in pixels. Default value is `NULL`.
#'
#' @return Returns a plotly object containing the bar plot, this chart can be further customized using plotly functions.
#' @export
#'
#' @examples
generate_grouped_bar_plot <- function(df, x, y, x_label, y_label, y_format=make_percent,
                                      grouping="None", group_labeling="",
                                      legend_title='', legend_position="right",
                                      plot_height=NULL) {

    df <- df %>%
        dplyr::arrange( {{x}} ) %>%
        dplyr::mutate( x=factor( {{x}}, levels=unique({{x}}) ) ) # update the factor levels
    ggplot_object <- df %>%
        ggplot2::ggplot(ggplot2::aes(x=x,
                                     y={{y}},
                                     fill=as.character( {{grouping}} ),
                                     text=paste(paste(x_label, ": ", sep=''), {{x}}, "<br />",
                                                paste(y_label, ": ", sep=''), y_format({{y}}), "<br />",
                                                {{group_labeling}},
                                                sep='') ) )
    ggplot_object <- ggplot_object +
        ggplot2::geom_bar(stat='identity', width=.8, position=ggplot2::position_dodge2()) +
        ggplot2::coord_flip() +
        ggplot2::geom_text(ggplot2::aes(label = paste( {{grouping}}, '|', y_format( {{y}} ) ), y={{y}}-({{y}}*.5) ),
                           position = ggplot2::position_dodge2(.8),
                           colour="white",
                           check_overlap=TRUE) +
        ggplot2::scale_fill_manual( palette=ut_color_palette ) +
        ggplot2::scale_y_continuous( labels=y_format, limits=c(0, 1) ) +
        ggplot2::scale_x_discrete( expand=ggplot2::expansion(0, 0) ) +
        ggplot2::guides( fill=ggplot2::guide_legend( title=legend_title ) ) +
        ggplot2::labs(x=x_label,
                      y=y_label,
                      fill=legend_title) +
        ggplot2::theme_minimal() +
        ggplot2::theme(panel.grid.minor.x = ggplot2::element_blank(),
                       panel.grid.minor.y = ggplot2::element_blank(),
                       legend.position=legend_position )
    plot <- plotly::ggplotly(ggplot_object, tooltip=c('text'), height=plot_height ) %>%
        plotly::config(displayModeBar=FALSE)

    return( plot )
}
