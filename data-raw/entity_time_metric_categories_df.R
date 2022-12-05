## code to prepare `entity_time_metric_categories_df` dataset goes here

possible_terms <- c( "202220", "202230", "202240", "202120", "202130", "202140" )
possible_categories_1 <- c( "Baseball", "Football", "Basketball", "Tennis", "Soccer" )
possible_categories_2 <- c( "Scholarship", "No Scholarship" )
possible_colleges <- c( "College of Arts and Sciences", "College of Business", "College of Engineering", "College of Education", "College of Nursing" )
possible_departments <- c( "Physics", "Mathematics", "Computer Science", "Biology", "Chemistry", "Economics", "History", "English", "Political Science" )
possible_academic_programs <- c( "B.S. in Computer Science", "B.S. in Biology", "B.A. in English", "B.S. in Economics", "M.S. in Computer Science", "Ph.D. in Physics" )
possible_genders <- c( "Male", "Female", "Non-binary", "Other" )
possible_race_ethnicity <- c( "White", "Black", "Asian", "Native American", "Pacific Islander", "Latino" )

entity_time_metric_categories_df <- data.frame(
    entity_id = sample(1:100, 1000, replace=TRUE),
    time_column = sample(possible_terms, 1000, replace=TRUE),
    time_column_2 = sample(-150:21, 1000, replace=TRUE) ,
    metric_column = rnorm(1000, sd=10),
    entity_category_1 = sample(possible_categories_1, 1000, replace=TRUE),
    entity_category_2 = sample(possible_categories_2, 1000, replace=TRUE),
    entity_category_3 = sample(1:12, 1000, replace=TRUE),
    entity_outcome = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    population="All",
    spring_returned = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    second_fall_returned = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    third_fall_returned = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    fourth_fall_returned = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    fifth_fall_returned = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    sixth_fall_returned = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    college = sample(possible_colleges, 1000, replace=TRUE),
    department = sample(possible_departments, 1000, replace=TRUE),
    program = sample(possible_academic_programs, 1000, replace=TRUE),
    gender = sample(possible_genders, 1000, replace=TRUE),
    race_ethnicity = sample(possible_race_ethnicity, 1000, replace=TRUE),
    cohort = sample(1980:2023, 1000, replace=TRUE)
)

usethis::use_data(entity_time_metric_categories_df, overwrite = TRUE)
