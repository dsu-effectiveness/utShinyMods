library(tidyverse)
library(ggplot2)
library(plotly)
library(scales)

# variable formatting functions ###
make_percent <- function(x) {
    return( percent(round(x, 3), drop0trailing=TRUE) )
}
make_percent_negative_to_zero <- function(x) {
    x <- if_else(x < 0, 0, x)
    x <- round(x, 3)
    return( percent(x, drop0trailing=TRUE) )
}
add_comma <- function(x) {
    return( format(x, big.mark=',', scientific=FALSE) )
}
no_format <- function(x) {
    return( x )
}
relative_to_actual_semester <- function(x) {
    x <- map(x, function(v) {
        v = as.numeric(v)
        if (v %% 2 == 0) {
            paste0('S', (v+1)%/%2)
        }
        else {
            paste0('F', (v+1)%/%2)
        }
    })
    return( x )
}


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

default_colors <- c( desert_sand, dixie_based_reds,
                     desert_sand, dixie_based_reds,
                     desert_sand, dixie_based_reds )

#default_colors <- c("#9bc1bc", '#7cbdc9', '#40817a', '#668CB0',
#                    '#cb9998', '#868662', '#947fa0', "#537014",
#                    "#D4DBD9", "#E7CA8C", "#F6BC8C", "#C87D55",
#                    "#0F1644", "#dd4b39", "#871518", '#FF851B')

generate_standard_plot <- function(df, x, y, x_label, y_label, x_angle=0, y_format=no_format, x_format=no_format,
                                   grouping=0, group_labeling="",
                                   title='', sub_title='',
                                   legend_title='', legend_position="right",
                                   color_palette=default_colors, lin_reg=FALSE) {

    ggplot_object <- ggplot(df, aes(x=as.factor({{x}}),
                                    y={{y}},
                                    group=as.factor({{grouping}}),
                                    color=as.factor({{grouping}}),
                                    text=paste(paste(x_label, ": ", sep=''), x_format({{x}}), "<br />",
                                               paste(y_label, ": ", sep=''), y_format({{y}}), "<br />",
                                               {{group_labeling}},
                                               sep='') ) ) +
        geom_line() +
        geom_point(alpha=.8) +
        scale_color_manual( values=color_palette ) +
        scale_y_continuous(y_label, labels=y_format ) +
        scale_x_discrete(x_label, labels=x_format ) +
        guides( color=guide_legend( title=legend_title ) ) +
        theme_minimal() +
        theme(panel.grid.minor.x = element_blank(),
              panel.grid.minor.y = element_blank(),
              legend.position=legend_position)

    if (lin_reg) {
        ggplot_object <-ggplot_object +
            geom_smooth(method="lm", fullrange=TRUE, linetype="dashed", size=.5, se=F)
    }

    plot <- ggplotly(ggplot_object, tooltip=c('text')) %>%
        config(displayModeBar=FALSE) %>%
        layout( title=list(text = paste0(title,
                                         '<br>',
                                         '<sup style="color:#a6a6a6;">',
                                         sub_title,
                                         '</sup>',
                                         '<br>')),
                xaxis=list(tickangle=x_angle),
                margin=list(t=100))

    return( plot )
}

generate_lollipop_plot <- function(df, x, y, x_label="", y_label="", y_format=no_format,
                                   title="", sub_title="",
                                   color_pallete=default_colors) {
    ggplot_object <- df %>%
        arrange( {{x}} ) %>%    # First sort by x
        mutate( name=factor({{x}}, levels={{x}}) ) %>%   # This trick update the factor levels
        ggplot( aes( x=name,
                     y={{y}},
                     text=paste(paste(x_label, ": ", sep=''), name, "<br />",
                                paste(y_label, ": ", sep=''), y_format({{y}}), "<br />", sep='') ) ) +
        geom_segment( aes(xend=name, yend=0)) +
        geom_point( size=3, color="orange", alpha=.8) +
        labs(y=y_label, x=x_label) +
        scale_y_continuous( labels=y_format ) +
        scale_color_manual(values=color_pallete) +
        coord_flip() +
        theme_minimal()
    plot <- ggplotly(ggplot_object, tooltip=c('text')) %>%
        config(displayModeBar=FALSE) %>%
        layout(title = list(text = paste0(title,
                                          '<br>',
                                          '<sup style="color:#a6a6a6;">',
                                          sub_title,
                                          '</sup>')),
               margin=list(t=100) )
    return( plot )
}

generate_grouped_bar_plot <- function(df, x, y, x_label, y_label, y_format=no_format,
                                      grouping="None", group_labeling="",
                                      title='', sub_title='',
                                      legend_title='', legend_position="right",
                                      color_palette=default_colors,
                                      plot_height=NULL) {
    df <- df %>%
        mutate( x_is_numeric=is.numeric({{x}}) ) %>%
        mutate( ordering=ifelse(x_is_numeric, {{x}}, -{{y}}) ) %>%
        arrange( ordering ) %>%
        mutate( x=factor( {{x}}, levels=unique({{x}}) ) ) # update the factor levels
    ggplot_object <- df %>%
        ggplot(aes(x=x,
                   y={{y}},
                   fill={{grouping}},
                   text=paste(paste(x_label, ": ", sep=''), {{x}}, "<br />",
                              paste(y_label, ": ", sep=''), y_format({{y}}), "<br />",
                              {{group_labeling}},
                              sep='') ) )
    ggplot_object <- ggplot_object +
        geom_bar(stat='identity', width=.8, position=position_dodge2()) +
        coord_flip() +
        scale_fill_manual( values=color_palette ) +
        scale_y_continuous( labels=y_format ) +
        guides( color=guide_legend( title=legend_title ) ) +
        labs(x=x_label,
             y=y_label,
             fill=legend_title) +
        theme_minimal() +
        theme(panel.grid.minor.x = element_blank(),
              panel.grid.minor.y = element_blank(),
              legend.position=legend_position )
    plot <- ggplotly(ggplot_object, tooltip=c('text'), height=plot_height) %>%
        config(displayModeBar=FALSE) %>%
        layout( title=list(text = paste0(title,
                                         '<br>',
                                         '<sup style="color:#a6a6a6;">',
                                         sub_title,
                                         '</sup>',
                                         '<br>')),
                margin=list(t=100))
    return( plot )
}
