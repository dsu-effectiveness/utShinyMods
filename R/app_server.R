#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#'
#' @import shiny
#' @importFrom magrittr %>%
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  student_term_course_section <- utHelpR::get_data_from_sql_url(query_url=here::here("inst", "sql", "student_term_course_section.sql"),
                                                                dsn="edify") %>%
      dplyr::mutate(all="All") %>%
      dplyr::filter(term_id != '202240')

  mod_over_time_line_chart_server("gpa_over_time_line_chart",
                                  df=student_term_course_section,
                                  entity_id_col=c("Student"="student_full_name"),
                                  time_col=c("Term"="term_id"),
                                  metric_col=c("GPA"="course_section_grade_points"),
                                  metric_summarization_function=mean,
                                  grouping_cols=c("Course Section"="course_section_description",
                                                  "Student College"="student_college",
                                                  "Student Program"="student_program",
                                                  "Has Scholarship"="student_has_accepted_scholarship"),
                                  chart_title="Student Athlete - Term GPA",
                                  chart_sub_title="Where we can choose, and view, the term GPA of various student athlete groupings." )

  mod_over_time_line_chart_server("over_time_line_chart_2")
  mod_over_time_line_chart_server("over_time_line_chart_3")
}
