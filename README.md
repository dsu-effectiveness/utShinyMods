# utShinyMods

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

utShinyMods is an R package that makes it easy to build modular, reusable components for Shiny applications. With utShinyMods, you can create self-contained pieces of Shiny UI and server logic, known as "modules," and use them in your Shiny apps just like any other Shiny UI or server component. This allows you to create complex Shiny apps by breaking them down into smaller, more manageable pieces, and easily reuse and share those pieces with others. Additionally, utShinyMods makes it easier to manage and test your Shiny code, since each module is a standalone piece of code that can be tested and debugged independently.

## Installation

To install utShinyMods, you can use the `install_github()` function from the `devtools` package.

``` r
# Install devtools if necessary
install.packages("devtools")

# Install utShinyMods
devtools::install_github("dsu-effectiveness/utShinyMods")
```

## Usage

To use utShinyMods, you first need to include the `library(utShinyMods)` statement in your Shiny app. Then, you can use the pre-defined Shiny modules in the package by calling their UI and server functions and specifying a unique identifier for each instance of the module. For example, you might use the `mod_over_time_line_chart` module, which creates a line chart that shows data over time, as follows:

```r
# Called in the UI function
utShinyMods::mod_over_time_line_chart_ui("over_time_line_chart_1")

# Called in the server function
utShinyMods::mod_over_time_line_chart_server("over_time_line_chart_1")
```

You can customize the behavior and appearance of the module by passing additional arguments to the server function. For example, you can specify the data frame to use, the columns to use for the time and metric variables, and the function to use for summarizing the metric data. See the package documentation for a complete list of arguments and their default values.

Here is simple, bare-bones example of a complete Shiny app that uses utShinyMods:


```r
library(shiny)
library(utShinyMods)

ui <- fluidPage(
  utShinyMods::mod_over_time_line_chart_ui("over_time_line_chart_1")
)

server <- function(input, output, session) {
  utShinyMods::mod_over_time_line_chart_server("over_time_line_chart_1")
}

shinyApp(ui, server)
```


## Contributing

We welcome contributions to utShinyMods. If you have an idea for a new module or other improvement, please open an issue on the GitHub repository to discuss it before submitting a pull request. Please follow the <a href="https://style.tidyverse.org/" target="_new">tidyverse style guide</a> for your code and include comprehensive tests and documentation for your changes. **The best place to start contributing is to become familiar with the contents of the dev folder in the code base.**

## License

utShinyMods is licensed under the <a href="https://github.com/dsu-effectiveness/utShinyMods/blob/main/LICENSE" target="_new">MIT License</a>.