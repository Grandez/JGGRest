#!/usr/bin/env Rscript

## ---- load packages ----

library(JGGRest)


## ---- create handler for the HTTP requests ----

# simple response
hello_handler = function(request, response) {
  response$body = "Hello, World!"
}

# handle query parameter
heelo_query_handler = function(request, response) {
  # user name
  nm = request$parameters_query[["name"]]
  # default value
  if (is.null(nm)) {
    nm = "anonym"
  }
  response$body = sprintf("Hello, %s!", nm)
}

# handle path variable
hello_path_handler = function(request, response) {
  # user name
  nm = request$parameters_path[["name"]]
  response$body = sprintf("Hello, %s!", nm)
}


## ---- create application -----

app = Application$new(
  content_type = "text/plain"
)


## ---- register endpoints and corresponding R handlers ----

app$add_get(
  path = "/hello",
  FUN = hello_handler
)

app$add_get(
  path = "/hello/query",
  FUN = heelo_query_handler
)

app$add_get(
  path = "/hello/path/{name}",
  FUN = hello_path_handler,
  match = "regex"
)


## ---- start application ----
backend = BackendRserve$new()
# backend$start(app, http_port = 8080)
