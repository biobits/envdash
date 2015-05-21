# EnvDash

EnvDash is a Dashboard-Application developed with shiny and shinydesktop to display environmental data (temperature and humidity).
The data is stored in a sqlite database 

The Application can be launched by typing

```r
shiny::runApp('/path/to/shiny/app',host = getOption('shiny.host', '0.0.0.0'),port=8080)

```
in your R console.


## License
This software is free and open source software, licensed under GPL.
