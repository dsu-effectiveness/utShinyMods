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

  mod_interactive_data_table_server("athletes_summary_data_table",
                                    module_title="Student Athletes Summary",
                                    module_sub_title="A view of summarized student athlete data.",
                                    table_title="",
                                    df=student_term_course_section,
                                    entity_id_col=c("Student ID"="student_id"),
                                    metric_columns = c("student_has_accepted_scholarship",
                                                       "course_section_grade",
                                                       "student_overall_cumulative_gpa",
                                                       "student_overall_cumulative_gpa",
                                                       "student_overall_cumulative_gpa",
                                                       "student_overall_cumulative_credits_earned",
                                                       "student_overall_cumulative_credits_earned"),
                                    metric_columns_summarization_functions=c("Has Accepted Scholarship"=any,
                                                                             "Final Grades"=function(x){ ngram::concatenate(x, collapse=', ') },
                                                                             "Trending GPA"=mean,
                                                                             "Above 3.2 GPA"=function(x){ all(x > 3.2) },
                                                                             "Between 3.0 and 3.19 GPA"=function(x){ all(x < 3.2 & x > 3.0) },
                                                                             "Above 120 Credits"=function(x){ all(x > 120) },
                                                                             "Between 100 and 120 Credits"= function(x){ all(x > 100 & x < 120) }),
                                    grouping_cols=c("Term"="term_id"))

  # Trending GPA Module ####
  mod_over_time_line_chart_server("gpa_over_time_line_chart",
                                  df=student_term_course_section,
                                  entity_id_col=c("Student"="student_full_name"),
                                  time_col=c("Term"="term_id"),
                                  metric_col=c("GPA"="student_overall_cumulative_gpa"),
                                  metric_summarization_function=mean,
                                  grouping_cols=c("Student College"="student_college",
                                                  "Student Program"="student_program",
                                                  "Has Scholarship"="student_has_accepted_scholarship"),
                                  chart_title="Student Athletes - Trending GPA",
                                  chart_sub_title="Where we can choose, and view, the trending GPA of various student athlete groupings." )

   # Trending Credit Hours Module ####
   mod_over_time_line_chart_server("credits_earned_over_time_line_chart",
                                  df=student_term_course_section,
                                  entity_id_col=c("Student"="student_full_name"),
                                  time_col=c("Term"="term_id"),
                                  metric_col=c("Average Credits Earned"="student_overall_cumulative_credits_earned"),
                                  metric_summarization_function=mean,
                                  grouping_cols=c("Student College"="student_college",
                                                  "Student Program"="student_program",
                                                  "Has Scholarship"="student_has_accepted_scholarship"),
                                  chart_title="Student Athletes - Trending Credits Earned",
                                  chart_sub_title="Where we can choose, and view, the trending credits earned of various student athlete groupings." )

}
