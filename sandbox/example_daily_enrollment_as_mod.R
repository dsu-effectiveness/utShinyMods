
  daily_enrollment <- utHelpR::get_data_from_sql_file(file_name="daily_enrollment.sql", dsn="edify", context="shiny")

  # Daily Enrollment Module ####
  mod_over_time_line_chart_server("daily_enrollment_line_chart",
                                  df=daily_enrollment,
                                  time_col=c("Days Until Class Start"="days_to_class_start"),
                                  metric_col=c("Headcount"="student_id"),
                                  metric_summarization_function=dplyr::n_distinct,
                                  grouping_cols=c("Term" = "term_desc",
                                                  "Season" = "season",
                                                  "Academic Year" = "academic_year",
                                                  "College" = "college",
                                                  "Department" = "department",
                                                  "Program" = "program",
                                                  "Gender" = "gender",
                                                  "Race/Ethnicity"="race_ethnicity"),
                                  filter_cols=c("Term" = "term_desc",
                                                "Season" = "season",
                                                "Academic Year" = "academic_year",
                                                "College" = "college",
                                                "Department" = "department",
                                                "Program" = "program",
                                                "Gender" = "gender",
                                                "Race/Ethnicity"="race_ethnicity"),
                                  module_title="",
                                  module_sub_title="" )
