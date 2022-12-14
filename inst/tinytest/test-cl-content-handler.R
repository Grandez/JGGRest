# Test HTTPErrorFactory class

# Test class directly for the coverage stats
obj = JGGRest:::ContentHandlersFactory$new()
cl = JGGRest:::ContentHandlersFactory$new()

# Test empty object
expect_true(inherits(obj, "ContentHandlers"))
expect_true(inherits(obj$handlers, "environment"))
expect_equal(length(obj$handlers), 6L)
expect_true(inherits(obj$handlers[["text/plain"]], "list"))
expect_equal(length(obj$handlers[["text/plain"]]), 2L)
expect_equal(names(obj$handlers[["text/plain"]]), c("encode", "decode"))
expect_true(inherits(obj$handlers[["text/plain"]]$encode, "function"))
expect_true(inherits(obj$handlers[["text/plain"]]$decode, "function"))

# Test list method
expect_true(inherits(obj$list(), "list"))
expect_equal(sort(names(obj$list())), sort(c("application/json", "text/plain", "text/html", "text/css",
                                             "application/javascript", "image/png")))

# Test unknown handlers
e = tryCatch(obj$get_decode("unknown"), error = function(e) e)
expect_error(obj$get_decode("unknown"))
expect_true(inherits(e, "HTTPErrorRaise"))
expect_error(obj$get_encode("unknown"))

f = function() TRUE
ct = "custom/type1"
obj$set_decode(ct, f)
expect_true(ct %in% names(obj$handlers))
expect_equal(obj$get_decode(ct), f)
expect_equal(obj$handlers[[ct]][["decode"]], f)
expect_null(obj$handlers[[ct]][["encode"]])

f = function() FALSE
ct = "custom/type2"
obj$set_encode(ct, f)
expect_true(ct %in% names(obj$handlers))
expect_equal(obj$get_encode(ct), f)
expect_equal(obj$handlers[[ct]][["encode"]], f)
expect_null(obj$handlers[[ct]][["decode"]])

f = function() NULL
ct = "custom/type3"
obj$set_encode(ct, f)
obj$set_decode(ct, f)
expect_true(ct %in% names(obj$handlers))
expect_equal(obj$get_encode(ct), f)
expect_equal(obj$get_decode(ct), f)
expect_equal(obj$handlers[[ct]][["encode"]], f)
expect_equal(obj$handlers[[ct]][["decode"]], f)

# Test predefined JSON decoder
decoder = obj$get_decode("application/json")
body = charToRaw("{\"param\":\"value\"}")
expect_equal(decoder(body), list("param" = "value"))
expect_error(decoder(rawToChar("1 = 1")))

# Test predefined JSON decoder when charset is provided
decoder = obj$get_decode("application/json; charset=utf-8")
body = charToRaw("{\"param\":\"value\"}")
expect_equal(decoder(body), list("param" = "value"))
expect_error(decoder(rawToChar("1 = 1")))

# Test predefined encoders when charset and that ContentHandlers functions are case insensitive
for (ct in c("application/json; charset=utf-8", "APPlication/JSON; charset=utf-8")) {
  encoder = obj$get_encode(ct)
  expect_equal(encoder(list(param = 'value')), "{\"param\":\"value\"}")
}
for (ct in c("text/plain; charset=utf-8", "TEXT/plain; charset=latin1")) {
  encoder = obj$get_encode(ct)
  expect_equal(encoder(list(param = 'value')), "value")
}

# Test predefined text decoder
decoder = obj$get_decode("text/plain")
b = "Test!!!"
expect_equal(decoder(b), b)
expect_equal(decoder(charToRaw(b)), b)

# Test argument asserts for decode
expect_error(obj$get_decode(c("application/json", "text/plain")))
expect_error(obj$get_decode(1))
expect_error(obj$get_decode(c(1, 2)))
expect_error(obj$set_decode("application/json", list()))
expect_error(obj$set_decode(1, identity))

# Test argument asserts for encode
expect_error(obj$get_encode(c("application/json", "text/plain")))
expect_error(obj$get_encode(1))
expect_error(obj$get_encode(c(1, 2)))
expect_error(obj$set_encode("application/json", list()))
expect_error(obj$set_encode(1, identity))

# Test it throws error for unsupported content types
expect_error(obj$get_decode('application/json10'))
err = try(obj$get_decode('application/json10'), silent = TRUE)
expect_equal(attr(err, 'condition')$response$status_code, 415L)

# Test it throws 500 error for invalid content-type
err = try(obj$get_encode(25), silent = TRUE)
expect_equal(attr(err, 'condition')$response$status_code, 500L)

# Test reset method works
obj$reset()
expect_equal(obj, cl)
