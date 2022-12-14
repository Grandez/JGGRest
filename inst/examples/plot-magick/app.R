#!/usr/bin/env Rscript

## ---- load packages ----

library(JGGRest)
library(stats)
library(magick)
library(mime)


## ---- create handler for the HTTP requests ----

magick_handler = function(request, response) {
  img_type = request$parameters_query[["format"]]
  # default type
  if (is.null(img_type)) {
    img_type = "png"
  }
  if (!img_type %in% c("png", "jpeg", "gif")) {
    raise(HTTPError$bad_request())
  }
  img = image_graph(width = 480, height = 480, bg = "white")
  plot(cars)
  lines(lowess(cars))
  dev.off()
  response$body = image_write(img, format = img_type, quality = 100)
  response$content_type = mimemap[[img_type]]
}


## ---- create application -----

app = Application$new(
  content_type = "image/png"
)


## ---- register endpoints and corresponding R handlers ----

app$add_get(
  path = "/plot",
  FUN = magick_handler
)


## ---- start application ----
backend = BackendRserve$new()
# backend$start(app, http_port = 8080)
