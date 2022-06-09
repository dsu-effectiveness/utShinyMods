
# implementation 1 ####
over_relative_terms_plot_UI <- function(id, info_desc) {
    ns <- NS(id)

    tagList(
        useShinyjs(),
        fluidRow(
            column(3, wellPanel( uiOutput(ns('category_selection_ui')) ) ),
            column(9, plotlyOutput(ns('over_time_plot'), width=NULL) )
        ),
    )

}

over_relative_terms_plot_server <- function(input, output, session, agg_val, agg_val_desc, input_plot_df, info_desc) {
    ns <- session$ns

    output$category_selection_ui <- renderUI({
        categories <- input_plot_df[[agg_val]] %>%
            unique() %>%
            sort()
        selected_count = min(length(categories), 5)
        pickerInput(ns("category_selector"), paste(agg_val_desc, "Filter"),
                    categories,
                    options=list(`actions-box`=TRUE, `live-search`=TRUE),
                    multiple=TRUE,
                    selected=sample(categories, selected_count))
    })

    # OVER TIME FUNCTIONALLITY ####
    over_time_plot_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        req(input$category_selector)

        plot_df <- input_plot_df %>%
            filter(!!sym(agg_val) %in% input$category_selector &
                       relative_term_index <= 12) %>%
            group_by_at( c(agg_val,
                           "relative_term_index",
                           "relative_term_desc") ) %>%
            summarize( y_plot=n_distinct(pidm)) %>%
            drop_na() %>%
            mutate(grouping=!!sym(agg_val),
                   x_plot=relative_term_index ) %>%
            ungroup()
        # Pause plot execution if df has no values. This eliminates an error message.
        req( nrow(plot_df) > 0 )
        return( plot_df )
    })
    output$over_time_plot <- renderPlotly({

        generate_standard_plot(over_time_plot_df(),
                               x=x_plot,
                               y=y_plot,
                               grouping=grouping,
                               x_label="Term",
                               y_label=paste(info_desc, "Headcount"),
                               y_format=add_comma,
                               x_format=relative_to_actual_semester,
                               group_labeling=paste(agg_val_desc, ": ", !!sym(agg_val), "</br>",
                                                    sep=''),
                               title=paste(info_desc, "Headcounts Over Time"),
                               sub_title="Where we examine the progress of cohorts."
                               #,legend_title=agg_val_desc
        )
    })

}


# implementation 2 ####
over_cohorts_plot_UI <- function(id) {
    ns <- NS(id)
    tagList(
        useShinyjs(),
        fluidRow(
            column(3, wellPanel(
                uiOutput(ns('category_selection_ui')),
                uiOutput(ns('cohort_selection_ui')),
                pickerInput(ns("relative_term_selector"), "Term Selection",
                            list("Spring 1", "Fall 2", "Spring 2 (2nd Year)"="Spring 2",
                                 "Fall 3", "Spring 3", "Fall 4", "Spring 4 (4th year)"="Spring 4",
                                 "Fall 5", "Spring 5", "Fall 6", "Spring 6 (6th year)"="Spring 6"),
                            options=list(`actions-box`=TRUE, `live-search`=TRUE),
                            multiple=TRUE,
                            selected="Spring 1"),
                checkboxInput(ns("achievement_split"),
                              "Achievement Split",
                              value=FALSE),
                radioButtons(ns("demographic_agg_selector"), "Demographic Split",
                             list("None"="all",
                                  "Age Group"="age_group",
                                  "Recorded Sex"="recorded_sex",
                                  "Race / Ethnicity"="ethnicity",
                                  "Residency Status"="residency_status",
                                  "Initial Effort"="initial_effort",
                                  "Initial Goal"="initial_goal"),
                             selected="all")

            ) ),
            column(9, plotlyOutput(ns("rate_metric_plot")) )
        )
    )
}

over_cohorts_plot_server <- function(input, output, session, agg_val, agg_val_desc, input_plot_df, info_desc) {
    ns <- session$ns

    # RETENTION RATE FUNCTIONALLITY ####
    metric_rate_plot_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        req(input$relative_term_selector,
            input$demographic_agg_selector)

        headcounts <- input_plot_df %>%
            group_by_at( c(agg_val, input$demographic_agg_selector) ) %>%
            summarize( initial_headcount=n_distinct(pidm) )

        group <- c(agg_val, input$demographic_agg_selector)
        if (input$achievement_split) {
            group <- c("achievement_type", group)
        }

        plot_df <- input_plot_df %>%
            group_by_at( group ) %>%
            summarize( rate_metric_count=n_distinct(pidm[relative_term_desc %in% input$relative_term_selector]) ) %>%
            inner_join( headcounts, by=c(agg_val, input$demographic_agg_selector) ) %>%
            filter( rate_metric_count != 0 ) %>%
            mutate( achievement_split=input$achievement_split ) %>%
            mutate(y_plot=rate_metric_count/initial_headcount,
                   grouping=ifelse(achievement_split,
                                   paste0(!!sym(input$demographic_agg_selector), ' (', achievement_type, ')'),
                                   !!sym(input$demographic_agg_selector)) ) %>%
            drop_na() %>%
            ungroup()
        # Pause plot execution if df has no values. This eliminates an error message.
        req( nrow(plot_df) > 0 )
        return( plot_df )
    })

    output$rate_metric_plot <- renderPlotly({

        generate_standard_plot(metric_rate_plot_df(),
                               x=!!sym(agg_val),
                               y=y_plot,
                               x_label=agg_val_desc,
                               y_label=paste(info_desc, "Rate"),
                               y_format=make_percent,
                               x_angle=45,
                               grouping=grouping,
                               group_labeling=paste("Demographic: ", !!sym(input$demographic_agg_selector),  "<br>",
                                                    "Student Count: ", rate_metric_count, "<br>",
                                                    "Population Total: ", initial_headcount, "<br>",
                                                    sep=''),
                               title=paste(info_desc, "Rates By Cohort Year"),
                               sub_title="A deeper dive, where we can choose terms to include, and split by demographics."
                               #,legend_title="Achievement (Demographic)"
                               ,lin_reg=TRUE
        )

    })

}

