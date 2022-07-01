
#' Make Percent
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
make_percent <- function(x) {
    return( scales::percent(round(x, 3), drop0trailing=TRUE) )
}

#' Generate Grouped Bar Plot
#'
#' @param df
#' @param x
#' @param y
#' @param x_label
#' @param y_label
#' @param y_format
#' @param grouping
#' @param group_labeling
#' @param legend_title
#' @param legend_position
#' @param plot_height
#'
#' @return
#' @export
#'
#' @examples
generate_grouped_bar_plot <- function(df, x, y, x_label, y_label, y_format=make_percent,
                                      grouping="None", group_labeling="",
                                      legend_title='', legend_position="right",
                                      plot_height=NULL) {

     brookes_blues <- c(
        "#003058",
        "#004782",
        "#005eac",
        "#0075d7",
        "#028cff",
        "#2c9fff"
    )

    rock_reds <- c(
        "#BA1C21",
        "#95161A",
        "#771215",
        "#5F0E11",
        "#4C0B0E",
        "#3D090B"
    )

    desert_sands <- c(
        "#E6CCB3",
        "#B8A38F",
        "#938272",
        "#76685B",
        "#5E5349",
        "#4B423A"
    )

    color_palette <- c( brookes_blues, rock_reds, desert_sands )
    color_palette <- c(color_palette, color_palette)
    color_palette <- c(color_palette, color_palette)
    color_palette <- c(color_palette, color_palette)


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
        ggplot2::scale_fill_manual( values=color_palette ) +
        ggplot2::scale_y_continuous( labels=y_format, limits=c(0, 1) ) +
        ggplot2::scale_x_discrete( expand=ggplot2::expansion(0, 0) ) +
        ggplot2::guides( color=ggplot2::guide_legend( title=legend_title ) ) +
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
