## code to prepare `entity_time_metric_categories_df` dataset goes here

possible_terms <- c( "202220", "202230", "202240", "202120", "202130", "202140" )
categories_1 <- c( "Baseball", "Football", "Basketball", "Tennis", "Soccer" )
categories_2 <- c( "Scholarship", "No Scholarship" )

entity_time_metric_categories_df <- data.frame(
    entity_id = sample(1:100, 1000, replace=TRUE),
    time_column = sample(possible_terms, 1000, replace=TRUE),
    time_column_2 = sample(-150:21, 1000, replace=TRUE) ,
    metric_column = rnorm(1000, sd=10),
    entity_category_1 = sample(categories_1, 1000, replace=TRUE),
    entity_category_2 = sample(categories_2, 1000, replace=TRUE),
    entity_category_3 = sample(1:12, 1000, replace=TRUE),
    entity_outcome = sample(c(TRUE, FALSE), 1000, replace=TRUE),
    population="All"
)

usethis::use_data(entity_time_metric_categories_df, overwrite = TRUE)
