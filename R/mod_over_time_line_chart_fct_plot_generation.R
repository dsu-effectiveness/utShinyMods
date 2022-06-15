#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
no_format <- function(x) {
    return( x )
}

#' Title
#'
#' @param df
#' @param x
#' @param y
#' @param x_label
#' @param y_label
#' @param x_angle
#' @param y_format
#' @param x_format
#' @param grouping
#' @param group_labeling
#' @param title
#' @param sub_title
#' @param legend_title
#' @param legend_position
#' @param lin_reg
#'
#' @return
#' @export
#'
#' @examples
generate_line_chart <- function(df, x, y, x_label, y_label, x_angle=45, y_format=no_format, x_format=no_format,
                                grouping=0, group_labeling="",
                                title='', sub_title='',
                                legend_title='', legend_position="right",
                                lin_reg=FALSE) {
    desert_sand <- c(
        "#E6CCB3",
        "#B8A38F",
        "#938272",
        "#76685B",
        "#5E5349",
        "#4B423A")

    dixie_based_reds <-c(
        "#BA1C21",
        "#95161A",
        "#771215",
        "#5F0E11",
        "#4C0B0E",
        "#3D090B")

    color_palette <- c( desert_sand, dixie_based_reds,
                         desert_sand, dixie_based_reds,
                         desert_sand, dixie_based_reds,
                        desert_sand, dixie_based_reds,
                         desert_sand, dixie_based_reds,
                         desert_sand, dixie_based_reds )
    color_palette <- c(color_palette, color_palette)
    color_palette <- c(color_palette, color_palette)
    color_palette <- c(color_palette, color_palette)
    color_palette <- c(color_palette, color_palette)
    color_palette <- c(color_palette, color_palette)


    ggplot_object <- ggplot2::ggplot(df, ggplot2::aes(x=as.factor({{x}}),
                                                        y={{y}},
                                                        group=as.factor({{grouping}}),
                                                        color=as.factor({{grouping}}),
                                                        text=paste(paste(x_label, ": ", sep=''), x_format({{x}}), "<br />",
                                                                   paste(y_label, ": ", sep=''), y_format({{y}}), "<br />",
                                                                   {{group_labeling}},
                                                                   sep='') ) ) +
        ggplot2::geom_line() +
        ggplot2::geom_point(alpha=.8) +
        ggplot2::scale_color_manual( values=color_palette ) +
        ggplot2::scale_y_continuous(y_label, labels=y_format ) +
        ggplot2::scale_x_discrete(x_label, labels=x_format ) +
        ggplot2::guides( color=ggplot2::guide_legend( title=legend_title ) ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(panel.grid.minor.x = ggplot2::element_blank(),
                       panel.grid.minor.y = ggplot2::element_blank(),
                       legend.position=legend_position)

    if (lin_reg) {
        ggplot_object <-ggplot_object +
            ggplot2::geom_smooth(method="lm", fullrange=TRUE, linetype="dashed", size=.5, se=F)
    }

    plot <- plotly::ggplotly(ggplot_object, tooltip=c('text')) %>%
        plotly::config(displayModeBar=FALSE) %>%
        plotly::layout( title=list(text = paste0(title,
                                         '<br>',
                                         '<sup style="color:#a6a6a6;">',
                                         sub_title,
                                         '</sup>',
                                         '<br>')),
                xaxis=list(tickangle=x_angle),
                margin=list(t=100))

    return( plot )
}
