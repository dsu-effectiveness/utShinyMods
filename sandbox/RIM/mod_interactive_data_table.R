# UI FUNCTIONS ####
wellPanel(
    fluidRow(
        column(4,
               uiOutput('college_selection_ui'),
        ),
        column(4,
               uiOutput('department_selection_ui')
        )
    ),
    fluidRow(
        column(4,
               pickerInput("status_selection_workload_exploration",  "Instructor Status",
                           all_status,
                           options=list(`actions-box`=TRUE, `live-search`=TRUE),
                           multiple=TRUE,
                           selected=all_status)
        ),
        column(4,
               pickerInput("rank_selection_workload_exploration",  "Instructor Rank",
                           all_ranks,
                           options=list(`actions-box`=TRUE, `live-search`=TRUE),
                           multiple=TRUE,
                           selected=all_ranks)
        )
    ),
    fluidRow(
        column(4,
               radioButtons("time_aggregator", "Timeframe Aggregator",
                            choices=list("Term"="term",
                                         "Academic Year"="academic_year"),
                            selected="term")
        )
    ),
    p("Select rows to expand and see more details in the 'Courses Taught' and 'Non-Instructional' tables below."),
    DT::dataTableOutput("workload_summary_table")
)


# SERVER FUNCTIONS ####
workload_exploration_df_reactive <- reactive({
    faculty_base <- instructional_faculty_workload_df %>%
        filter( instructor_college %in% input$college_selection &
                    instructor_department %in% input$department_selection )
    faculty_include <- sort(unique(faculty_base$instructor_info))
    get_workload_exploration_df(input$time_aggregator, faculty_include) %>%
        filter( instructor_status %in% input$status_selection_workload_exploration &
                    instructor_rank %in% input$rank_selection_workload_exploration ) %>%
        select(-instructor_info)
})
output$workload_summary_table <- DT::renderDataTable(workload_exploration_df_reactive(),
                                                     filter="top",
                                                     options=list( scrollX = TRUE,
                                                                   lengthMenu=list( c(10, 25, 100, -1),
                                                                                    c(10, 25, 100, "All") )
                                                     ),
                                                     rownames=FALSE,
                                                     colnames=colnames( clean_names(workload_exploration_df_reactive(), case="title") ) )
get_filtered_expansion_df <- function(base_df) {
    df <- workload_exploration_df_reactive()
    person_selection <- df[input$workload_summary_table_rows_selected,]$banner_id
    # this section of code is what causes the warning
    # needs to be fixed by looking at input$time_aggregator to eliminate warning
    term_selection <- df[input$workload_summary_table_rows_selected,]$term
    academic_year_selection <- df[input$workload_summary_table_rows_selected,]$academic_year
    base_df %>%
        filter(  banner_id %in% person_selection &
                     ( term %in% term_selection | academic_year %in% academic_year_selection ) )
}
reactive_instructional_expansion_df <- reactive({
    get_filtered_expansion_df(instructional_faculty_workload_df)
})
reactive_non_instructional_expansion_df <- reactive({
    get_filtered_expansion_df(non_instructional_faculty_workload_df)
})
output$instructional_workload_expansion_table <- DT::renderDataTable( reactive_instructional_expansion_df(),
                                                                      options=list( scrollX = TRUE ),
                                                                      rownames=FALSE,
                                                                      colnames=colnames( clean_names(reactive_instructional_expansion_df(), case="title") ))
output$non_instructional_workload_expansion_table <- DT::renderDataTable( reactive_non_instructional_expansion_df(),
                                                                          options=list( scrollX = TRUE ),
                                                                          rownames=FALSE,
                                                                          colnames=colnames( clean_names(reactive_non_instructional_expansion_df(), case="title") ))

