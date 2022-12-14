#!/usr/bin/env Rscript

## ---- load packages ----

library(JGGRest)
library(profvis)
library(htmlwidgets)


## ---- set options ----

options(keep.source = TRUE)


## ---- import application ----

# App file
app_file = system.file("examples", "hello", "app.R", package = "JGGRest")
# Don't run
run_app = FALSE
# Source code
source(app_file)

## ---- profiling ----

r1 = Request$new(
  path = "/hello"
)

p1 = profvis(
  expr = {
    for (i in seq_len(1000)) {
      app$process_request(r1)
    }
  },
  interval = 0.005
)
saveWidget(p1, "prof_hello_ok.html")


r2 = Request$new(
  path = "/not-found"
)

p2 = profvis(
  expr = {
    for (i in seq_len(1000)) {
      app$process_request(r2)
    }
  },
  interval = 0.005
)

saveWidget(p1, "prof_hello_404.html")
