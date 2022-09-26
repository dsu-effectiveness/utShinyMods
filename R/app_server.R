#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#'
#' @import shiny
#' @importFrom magrittr %>%
#'
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  waiter::waiter_show( # show the waiter
    html = tagList( waiter::spin_fading_circles(), # use a spinner
                    "Loading Insights..."
    ),
    color="#c2c5c8"
  )

  student_term_course_section <- utHelpR::get_data_from_sql_file(file_name="student_term_course_section.sql", dsn="edify", context="shiny")

  student_term_course_section_retention_mod <- student_term_course_section %>%
    dplyr::filter( season == "Fall" )

  academic_portal_upload_report <- utHelpR::get_data_from_sql_file(file_name="academic_portal_upload_report.sql", dsn="edify", context="shiny")


  # Student Athletes Summary Module ####
  mod_summarized_data_table_server("athletes_summary_data_table",
                                    module_title="Student Athletes",
                                    module_sub_title="A view of student athlete team, academic, and demographic data.",
                                    df=student_term_course_section,
                                    record_uniqueness_cols=c("student_full_name", "student_id", "term"),
                                    filter_col=c("Term"="term"),
                                    metric_columns = c("student_team",
                                                       "student_is_athletic_aid_awarded",
                                                       "student_has_ever_applied_for_graduation",
                                                       "student_overall_cumulative_gpa",
                                                       "student_overall_cumulative_credits_earned",
                                                       "student_overall_cumulative_credits_attempted",
                                                       "student_is_degree_seeking",
                                                       "student_primary_degree",
                                                       "student_primary_major",
                                                       "student_program",
                                                       "student_college",
                                                       "student_department",
                                                       "student_has_graduated_with_primary_degree",
                                                       "student_cumulative_transfer_credits_earned",
                                                       "student_cumulative_transfer_gpa"),
                                    metric_columns_summarization_functions=c("Team"=function(x){ as.factor( ngram::concatenate(unique(na.omit(x)), collapse=', ') ) },
                                                                             "Is Athletic Aid Awarded"=any,
                                                                             "Has Applied for Graduation"=any,
                                                                             "GPA"=function(x){ round(mean(x, na.rm=TRUE), 2) },
                                                                             "Credits Earned"=function(x){ mean(x, na.rm=TRUE) },
                                                                             "Credits Attempted"=function(x){ mean(x, na.rm=TRUE) },
                                                                             "Is Degree Seeking"=any,
                                                                             "Degree"=dplyr::first,
                                                                             "Major"=dplyr::first,
                                                                             "Program"=dplyr::first,
                                                                             "College"=dplyr::first,
                                                                             "Department"=dplyr::first,
                                                                             "Has Graduated"=any,
                                                                             "Transfer Credits Earned"=function(x){ mean(x, na.rm=TRUE) },
                                                                             "Transfer GPA"=function(x){ mean(x, na.rm=TRUE) } ) )

  # Final Grades Module ####
  mod_summarized_data_table_server("final_grades_data_table",
                                    module_title="Final Grades",
                                    module_sub_title="A view of all student athletes and their grades.",
                                    df=student_term_course_section,
                                    record_uniqueness_cols=c('student_full_name', 'student_id', 'course', 'term'),
                                    filter_col=c("Term"="term"),
                                    metric_columns = c("course_section_grade",
                                                       "course_section_grade_points"),
                                    metric_columns_summarization_functions=c("Final Grade"=function(x){ ngram::concatenate(unique(na.omit(x)), collapse=', ') },
                                                                             "Grade Points"=function(x){ round(mean(x, na.rm=TRUE), 2) }))

  # Teams Module ####
  mod_summarized_data_table_server("teams_data_table",
                                    module_title="Teams",
                                    module_sub_title="A view of all student athlete teams.",
                                    df=student_term_course_section,
                                    record_uniqueness_cols=c("student_team", "term"),
                                    filter_col=c("Term"="term"),
                                    metric_columns = c("student_id",
                                                       "student_overall_cumulative_gpa",
                                                       "student_full_name"),
                                    metric_columns_summarization_functions=c("Number of Players"=dplyr::n_distinct,
                                                                             "Team GPA"=function(x){ round(mean(x, na.rm=TRUE), 2) },
                                                                             "Team Members"=function(x){ ngram::concatenate(sort(unique(x)), collapse='; ') }))


  # Fall to Spring Retention Module ####
  mod_rate_metric_bar_chart_server("fall_to_spring_retention_rate_metric_bar_chart",
                                    df=student_term_course_section_retention_mod,
                                    time_col=c("Fall Term"="term"),
                                    rate_metric_uniqueness_col=c("Student ID"="student_id"),
                                    rate_metric_criteria_col=c("Spring Returned"="is_returned_next_spring"),
                                    rate_metric_desc="Fall to Spring Retention Rate",
                                    grouping_cols=c("Student Team"="student_team"),
                                    module_title="Fall to Spring Retention Rates",
                                    module_sub_title="Where we can choose, and view, the fall to spring retention rates of various student athlete groupings.")


  # Fall to Fall Retention Module ####
  mod_rate_metric_bar_chart_server("fall_to_fall_retention_rate_metric_bar_chart",
                                    df=student_term_course_section_retention_mod,
                                    time_col=c("Fall Term"="term"),
                                    rate_metric_uniqueness_col=c("Student ID"="student_id"),
                                    rate_metric_criteria_col=c("Fall Returned"="is_returned_next_fall"),
                                    rate_metric_desc="Fall to Fall Retention Rate",
                                    grouping_cols=c("Student Team"="student_team"),
                                    module_title="Fall to Fall Retention Rates",
                                    module_sub_title="Where we can choose, and view, the fall to fall retention rates of various student athlete groupings.")

  # Trending GPA Module ####
  mod_over_time_line_chart_server("gpa_over_time_line_chart",
                                  df=student_term_course_section,
                                  time_col=c("Term"="term_id"),
                                  metric_col=c("GPA"="student_overall_cumulative_gpa"),
                                  metric_summarization_function=function(x){ round(mean(x, na.rm=TRUE), 2) },
                                  grouping_cols=c("Student Team" = "student_team",
                                                  "Student College"="student_college",
                                                  "Student Department"="student_department",
                                                  "Student Program"="student_program",
                                                  "Is Athletic Aid Awarded"="student_is_athletic_aid_awarded"),
                                  module_title="Trending GPA",
                                  module_sub_title="Where we can choose, and view, the trending GPA of various student athlete groupings." )

   # Trending Credit Hours Module ####
   mod_over_time_line_chart_server("credits_earned_over_time_line_chart",
                                  df=student_term_course_section,
                                  time_col=c("Term"="term_id"),
                                  metric_col=c("Average Credits Earned"="student_overall_cumulative_credits_earned"),
                                  metric_summarization_function=function(x){ round(mean(x, na.rm=TRUE), 2) },
                                  grouping_cols=c("Student Team" = "student_team",
                                                  "Student College"="student_college",
                                                  "Student Department"="student_department",
                                                  "Student Program"="student_program",
                                                  "Is Athletic Aid Awarded"="student_is_athletic_aid_awarded"),
                                  module_title="Trending Credits Earned",
                                  module_sub_title="Where we can choose, and view, the trending credits earned of various student athlete groupings." )

  # Academic Portal Report Module ####
  mod_downloadable_data_table_server("academic_portal_upload_report_downloadable_data_table",
                                     df=academic_portal_upload_report,
                                     module_title="Academic Portal Report",
                                     module_sub_title="A downloadable report, with data required for reporting to NCAA.")


  waiter::waiter_hide() # hide the waiter
}
