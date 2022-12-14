# Test Response class

# Test empty object
r = Response$new()
expect_true(inherits(r, "Response"))
expect_equal(r$body, NULL)
expect_equal(r$content_type, "text/plain")
expect_true(inherits(r$context, "environment"))
expect_true(inherits(r$headers, "list"))
expect_equal(length(r$headers), 1L) # Server header
expect_null(r$encode)
expect_true(inherits(r$status_code, "integer"))
expect_equal(length(r$status_code), 1L)
expect_equal(r$status_code, 200L)

backend = JGGRest:::BackendRserve$new()

server_header = paste("Server", getOption("JGGRest.headers.server"), sep = ": ")
expect_equal(backend$convert_response(r), list(raw(), "text/plain", server_header, 200L))

# Test parse_headers
h = list("Test-Header" = "value",
      "Test-Header2" = "value2")
r = Response$new(headers = h)
expect_equal(r$headers[["Test-Header"]], "value")
expect_equal(r$headers[["Test-Header2"]], "value2")

# Test has_header method
h = list("Test-Header" = "value")
r = Response$new(headers = h)
expect_false(r$has_header("test"))
expect_true(r$has_header("Test-Header"))

# Test get_header method
h = list("Test-Header" = "value")
r = Response$new(headers =  h)
expect_null(r$get_header("test"))
expect_equal(r$get_header("Test-Header"), "value")

# Test set_header method
r = Response$new()
expect_error(r$set_header("name", NA))
r$set_header("test", "test-value")
expect_equal(r$get_header("test"), "test-value")
expect_warning(r$set_header("Content-type", "custom/type"), "not accepted by Rserve")
expect_null(r$get_header("Content-type"))
expect_warning(r$set_header("Content-length", "0"), "not accepted by Rserve")
expect_null(r$get_header("Content-length"))
expect_warning(r$set_header("Set-cookie", "param=value"), "Use 'set_cookie' method instread")
expect_null(r$get_header("Set-cookie"))

# Test delete_header method
r = Response$new()
r$set_header("test", "test-value")
expect_true(r$delete_header("test"))
expect_false(r$has_header("test"))

# Test append_header method
r = Response$new()
r$append_header("accept", "text/plain")
r$append_header("accept", "text/html")
expect_equal(r$get_header("accept"), c("text/plain", "text/html"))
r$append_header("cookie", "param1=value1")
r$append_header("cookie", "param2=value2")
expect_equal(r$get_header("cookie"), c("param1=value1", "param2=value2"))
expect_warning(r$append_header("Content-type", "custom/type"), "not accepted by Rserve")
expect_null(r$get_header("Content-type"))
expect_warning(r$append_header("Content-length", "0"), "not accepted by Rserve")
expect_null(r$get_header("Content-length"))
expect_warning(r$append_header("Set-cookie", "param=value"), "Use 'set_cookie' method instread")
expect_null(r$get_header("Set-cookie"))

# Test set_status_code method
r = Response$new(status_code = 200L)
expect_equal(r$status_code, 200L)
r$set_status_code(400L)
expect_equal(r$status_code, 400L)

# Test set_content_type method
r = Response$new()
r$set_content_type("test/type")
expect_equal(r$content_type, "test/type")
r$set_content_type("test/type2")
expect_equal(r$content_type, "test/type2")

# Test body assign in constructor
r = Response$new(
  body = list(),
  content_type = "application/json",
  encode = to_json
)
expect_equal(r$body, list())
expect_equal(r$content_type, "application/json")
expect_equal(r$encode, to_json)

# Test set_date method
r = Response$new()
r$set_date(.POSIXct(1564760173, tz = "GMT"))
expect_equal(r$get_header("Date"), structure("Fri, 02 Aug 2019 15:36:13 GMT", class = "HTTPDate"))

# Test unset_date method
r = Response$new()
r$set_date(.POSIXct(1564760173, tz = "GMT"))
r$unset_date()
expect_null(r$get_header("Date"))

# Test set_cookie method
r = Response$new()
r$set_cookie(name = "param", value = "value")
expect_equal(r$cookies[["param"]], list(name = "param", value = "value"))

# Test unset_cookie method
r = Response$new()
r$set_cookie(name = "param", "value")
expect_equal(r$cookies[["param"]], list(name = "param", value = "value"))
r$unset_cookie("param")
expect_null(r$cookies[["param"]])

# Test to_rserve method with empty response
r = Response$new()
rs = backend$convert_response(r)
expect_equal(rs[[1]], raw())
expect_equal(rs[[2]], "text/plain")
expect_equal(rs[[3]], server_header)
expect_equal(rs[[4]], 200L)

# Test to_rserve method with empty response
r = Response$new()
r$set_body(raw())
rs = backend$convert_response(r)
expect_equal(rs[[1]], raw())
expect_equal(rs[[2]], "text/plain")
expect_equal(rs[[3]], server_header)
expect_equal(rs[[4]], 200L)

# Test to_rserve method with complex response
r = Response$new()
r$set_date(.POSIXct(1564760173, tz = "GMT"))
r$set_body("{status: ok}")
r$set_content_type("applicaiton/json")
r$set_status_code(200L)
r$set_header("Custom-Header", "text")
r$set_cookie(name = "param", "value")
h = paste(
  server_header,
  "Date: Fri, 02 Aug 2019 15:36:13 GMT",
  "Custom-Header: text",
  "Set-Cookie: param=value",
  sep = "\r\n"
)
rs = backend$convert_response(r)
expect_equal(rs[[1]], "{status: ok}")
expect_equal(rs[[2]], "applicaiton/json")
expect_equal(rs[[3]], h)
expect_equal(rs[[4]], 200L)

# Test to_rserve with static file body
r = Response$new()
tmp = tempfile(fileext = ".html")
r$set_body(c("file" = tmp))
r$set_content_type("text/html")
rs = backend$convert_response(r)
expect_equal(names(rs)[[1]], "file")
expect_equal(rs[[1]], tmp)
expect_equal(rs[[2]], "text/html")
expect_equal(rs[[3]], server_header)
expect_equal(rs[[4]], 200L)

# Test to_rserve with static file body
r = Response$new()
tmp = tempfile(fileext = ".html")
r$set_body(c("tmpfile" = tmp))
r$set_content_type("text/html")
rs = backend$convert_response(r)
expect_equal(names(rs)[[1]], "tmpfile")
expect_equal(rs[[1]], tmp)
expect_equal(rs[[2]], "text/html")
expect_equal(rs[[3]], server_header)
expect_equal(rs[[4]], 200L)

# Test set_response method
r = Response$new()
r$set_response(404L, "No no", "text/unknown")
expect_equal(r$status_code, 404L)
expect_equal(r$body, "No no")
expect_equal(r$content_type, "text/unknown")

# Test status method
r = Response$new()
expect_equal(r$status, "200 OK")
r$set_status_code(400L)
expect_equal(r$status, "400 Bad Request")

# Test print method
rs = Response$new(
  body = "0",
  content_type = "application/json",
  headers = list(
    "Last-Modified" = as(Sys.time(), "HTTPDate"),
    "Custom-field" = "value"
  ),
  status_code = 200
)
expect_silent(print(rs))

# Test reset method
rs = Response$new(
  body = list(a = 'body'),
  content_type = 'application/json',
  headers = list(h1 = 'h1'),
  status_code = 400L,
  encode = identity
)
rs$set_cookie(name = 'cookie_name', value = 'cookie_val')
rs$context[['some_context']] = list(a = 1)

rs$reset()
expect_equal(rs$body, NULL)
expect_equal(rs$content_type, "text/plain")
expect_equal(rs$headers, list(Server = getOption("JGGRest.headers.server")))
expect_equal(rs$status_code, 200L)
expect_equal(rs$encode, NULL)
expect_equal(rs$cookies, list())
expect_equal(rs$context, new.env(parent = emptyenv()))
