

# UI ####
tagList( downloadButton("report_download_csv", "CSV"),
         downloadButton("report_download_excel", "Excel") )

# Server ####
# Download Handlers ####
output$report_download_csv <- downloadHandler(filename=function(){ "report.csv" },
                                              content=function(file){
                                                   readr::write_csv(df, file)
                                               })

output$report_download_excel <- downloadHandler(filename=function(){ "report.xlsx" },
                                                content=function(file){
                                                   writexl::write_xlsx(df, file)
                                               })





# Util functions
format_and_save_graduation_report <- function(df, file) {
    ipeds_graduation_report <- format_graduation_report(df)
    write_delim(ipeds_graduation_report,
                file,
                quote="none",
                delim="",
                col_names=FALSE)
}

save_data_as_file <- function(input_df, file_name, delim="|", with_header=FALSE, quote=FALSE) {
    file_location <- here::here("sensitive", file_name)
    write.table( input_df,
                 file = file_location,
                 sep = delim,
                 na = "",
                 row.names = FALSE,
                 col.names = with_header,
                 quote = quote )
    return( NULL )
}

save_data_as_file <- function(input_df, file, delim=",", with_header=TRUE, quote=TRUE) {
    write.table( input_df,
                 file = file,
                 sep = delim,
                 na = "",
                 row.names = FALSE,
                 col.names = with_header,
                 quote = quote )
}
