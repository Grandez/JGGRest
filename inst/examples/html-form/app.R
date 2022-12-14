#!/usr/bin/env Rscript

## ---- load packages ----

library(JGGRest)
library(htmltools)


## ---- create handler for the HTTP requests ----

# simple response
form_handler = function(request, response) {
  doc = tags$html(
    tags$head(
      tags$title("From page")
    ),
    tags$body(
      h1("From"),
      tags$form(
        action = "/sent",
        method = "GET",
        tags$label("for" = "name", "Enter your name:"),
        tags$input(
          type = "text",  name = "uname"
        ),
        br(),
        tags$label("for" = "number", "Enter any number:"),
        tags$input(
          type = "number",  name = "num"
        ),
        br(),
        tags$label("for" = "password", "Enter password:"),
        tags$input(
          type = "password",  name = "pwd"
        ),
        br(),
        tags$input(
          type = "submit", value = "Submit form"
        )
      )
    )
  )
  response$body = as.character(doc)
}

sent_hanlder = function(request, response) {
  user_name = request$parameters_query[["uname"]]
  num = request$parameters_query[["num"]]

  doc = tags$html(
    tags$head(
      tags$title("Result page")
    ),
    tags$body(
      h1("Form sent success"),
      p("Hi, ", strong(user_name), "."),
      p("Yor number is ", dQuote(num), ".")
    )
  )
  response$body = as.character(doc)
}


## ---- create application -----

app = Application$new(
  content_type = "text/html"
)


## ---- register endpoints and corresponding R handlers ----

app$add_get(
  path = "/form",
  FUN = form_handler
)

app$add_get(
  path = "/sent",
  FUN = sent_hanlder
)


## ---- start application ----
backend = BackendRserve$new()
# backend$start(app, http_port = 8080)
