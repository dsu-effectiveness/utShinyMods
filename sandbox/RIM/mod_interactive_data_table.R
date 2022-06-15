# UI FUNCTION ####
# TODO: move all data specific UI generation functions to server
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
    DT::dataTableOutput("workload_summary_table")
)


# SERVER FUNCTION ####

# UI Generation ####
# TODO: to be filled in

# Reactive Dataframe ####
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

# Datatable Rendering ####
output$workload_summary_table <- DT::renderDataTable(workload_exploration_df_reactive(),
                                                     filter="top",
                                                     options=list( scrollX = TRUE,
                                                                   lengthMenu=list( c(10, 25, 100, -1),
                                                                                    c(10, 25, 100, "All") )
                                                     ),
                                                     rownames=FALSE,
                                                     colnames=colnames( clean_names(workload_exploration_df_reactive(), case="title") ) )

