rate_metric_UI <- function(id) {
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
                                  "Initial Goal"="initial_goal"))
            )
            ),
            column(9, plotlyOutput(ns("rate_metric_plot"), width=NULL))
        )
    )
}

rate_metric_server <- function(input, output, session, agg_val, agg_val_desc, input_plot_df, info_desc) {
    ns <- session$ns

    output$category_selection_ui <- renderUI({
        categories <- input_plot_df[[agg_val]] %>%
            unique() %>%
            sort()
        selected_count = min(length(categories), 8)
        pickerInput(ns("category_selector"), paste(agg_val_desc, "Filter"),
                    categories,
                    options=list(`actions-box`=TRUE, `live-search`=TRUE),
                    multiple=TRUE,
                    selected=sample(categories, selected_count))
    })

    output$cohort_selection_ui <- renderUI({
        cohorts <- input_plot_df$cohort_year %>%
            unique() %>%
            sort()
        pickerInput(ns("cohort_selection"), "Cohort Filter",
                    cohorts,
                    options=list(`actions-box`=TRUE, `live-search`=TRUE),
                    multiple=TRUE,
                    selected=cohorts)
    })

    metric_rate_plot_df <- reactive({
        # Pause plot execution while input values evaluate. This eliminates an error message.
        req(input$category_selector,
            input$cohort_selection,
            input$demographic_agg_selector,
            input$relative_term_selector)

        headcounts <- input_plot_df %>%
            filter( cohort_year %in% input$cohort_selection ) %>%
            group_by_at( c(agg_val, input$demographic_agg_selector) ) %>%
            summarize( initial_headcount=n_distinct(pidm) )

        group <- c(agg_val, input$demographic_agg_selector)
        if (input$achievement_split) {
            group <- c("achievement_type", group)
        }

        plot_df <- input_plot_df %>%
            filter(!!sym(agg_val) %in% input$category_selector
                   & cohort_year %in% input$cohort_selection) %>%
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
        generate_grouped_bar_plot(metric_rate_plot_df(),
                                  x=!!sym(agg_val),
                                  y=y_plot,
                                  x_label=agg_val_desc,
                                  y_label=paste(info_desc, "Rate"),
                                  y_format=make_percent,
                                  grouping=grouping,
                                  group_labeling=paste("Demographic: ", !!sym(input$demographic_agg_selector), " Students", "<br>",
                                                       "Student Count: ", rate_metric_count, "<br>",
                                                       "Population Total: ", initial_headcount, "<br>",
                                                       sep=''),
                                  title=paste(info_desc, "Rates by", agg_val_desc),
                                  sub_title="Examine any number of cohorts by including terms, and splitting by demographics.",
                                  plot_height=800
        )
    })

}


# other implementation ####
cohort_metric_bar_chart_UI <- function(id) {
    ns <- NS(id)
    plotlyOutput(ns("cohort_metric_plot"))
}

cohort_metric_bar_chart_server <- function(input, output, session, current_term_code, metric_term_col, metric_desc, input_plot_df, info_desc) {
    ns <- session$ns
    output$cohort_metric_plot <- renderPlotly({
        df <- input_plot_df %>%
            mutate( numerator_metric = (!!sym(metric_term_col)==current_term_code) ) %>%
            group_by( cohort_year ) %>%
            summarize( population_headcount = n_distinct(pidm),
                       numerator_metric = sum(numerator_metric) ) %>%
            mutate( y_plot = numerator_metric / population_headcount )

        generate_grouped_bar_plot(df,
                                  x=cohort_year,
                                  y=y_plot,
                                  x_label="Cohort Year",
                                  y_label=paste(info_desc, "Rate"),
                                  y_format=make_percent,
                                  grouping=as.character(cohort_year),
                                  group_labeling=paste(paste(metric_desc, " Count: "), numerator_metric, "<br>",
                                                       "Population Total: ", population_headcount, "<br>",
                                                       sep=''),
                                  title="Current Retention Rates By Cohort Year",
                                  sub_title="Fall 2021 retention rates"
        )
    })

}
