#!/usr/bin/env Rscript

## ---- load packages ----

library(JGGRest)
library(ggplot2)


## ---- create handler for the HTTP requests ----

ggplot_handler = function(request, response) {
  # make plot and save it in temp file
  tmp = tempfile(fileext = ".png")
  p = ggplot(mtcars, aes(wt, mpg)) + geom_point()
  ggsave(tmp, p, "png")
  # on.exit(unlink(tmp))
  # response$body = readBin(tmp, raw(), file.size(tmp))
  response$body = c("tmpfile" = tmp)
}


## ---- create application -----

app = Application$new(
  content_type = "image/png"
)


## ---- register endpoints and corresponding R handlers ----

app$add_get(
  path = "/plot",
  FUN = ggplot_handler
)


## ---- start application ----
backend = BackendRserve$new()
# backend$start(app, http_port = 8080)
