# Test parse_multipart

# source helpsers
source("setup.R")

# import functions
cpp_parse_multipart_boundary = JGGRest:::cpp_parse_multipart_boundary
cpp_parse_multipart_body = JGGRest:::cpp_parse_multipart_body

# Test cpp_parse_multipart_boundary with empty object
expect_error(cpp_parse_multipart_boundary(NULL))
expect_error(cpp_parse_multipart_boundary(NA))
expect_error(cpp_parse_multipart_boundary(NA_character_))
expect_error(cpp_parse_multipart_boundary(""))

# Test cpp_parse_multipart_boundary
boundary = "------------------gc0p4Jq0M2Yt08jU534c0p"
ctype = paste0("multipart/form-data; boundary=", boundary)
ctype_sq = paste0("multipart/form-data; boundary=", sQuote(boundary, FALSE))
ctype_dq = paste0("multipart/form-data; boundary=", dQuote(boundary, FALSE))
expect_equal(cpp_parse_multipart_boundary(ctype), boundary)
expect_equal(cpp_parse_multipart_boundary(ctype_sq), boundary)
expect_equal(cpp_parse_multipart_boundary(ctype_dq), boundary)

# Test cpp_parse_multipart_body with empty object
expect_error(cpp_parse_multipart_body(NULL, NULL))
expect_error(cpp_parse_multipart_body(NA_character_, NA_character_))
expect_error(cpp_parse_multipart_body("", ""))
expect_error(cpp_parse_multipart_body(charToRaw("body string"), "test"),
             "Boundary string not found.")
expect_error(cpp_parse_multipart_body(charToRaw("test\r\nbody string"), "test"),
             "Boundary string not found.")
expect_equal(cpp_parse_multipart_body(raw(), character(1)), list())

# Test cpp_parse_multipart_body
# text file
tmp_txt = system.file("DESCRIPTION", package = "JGGRest")
# rds file
tmp_rds = tempfile(fileext = ".rds")
saveRDS(letters, tmp_rds)
# form values
params = list(
  "param1" = "value1",
  "param2" = "value2"
)
# form files
files = list(
  "desc_file" = list(
    path = tmp_txt,
    ctype = "plain/text"
  ),
  "raw_file" = list(
    path = tmp_rds,
    ctype = "application/octet-stream"
  )
)

body = make_multipart_body(params, files)
boundary = cpp_parse_multipart_boundary(attr(body, "content-type"))
parsed = cpp_parse_multipart_body(body, boundary)

expect_true(inherits(parsed, "list"))
expect_equal(names(parsed), c("files", "values"))
expect_true(inherits(parsed$values, "list"))
expect_equal(length(parsed$values), 2L)
expect_equal(parsed$values$param1, "value1")
expect_equal(parsed$values$param2, "value2")
expect_true(inherits(parsed$files, "list"))
expect_equal(length(parsed$files), 2L)

# Test text file
expect_equal(parsed$files[["desc_file"]]$filename, basename(tmp_txt))
expect_equal(parsed$files[["desc_file"]]$content_type, "plain/text")
expect_equal(parsed$files[["desc_file"]]$length, file.size(tmp_txt))
expect_identical(get_multipart_file(body, parsed$files[["desc_file"]]),
                 readBin(tmp_txt, raw(), file.size(tmp_txt)))

# Test binary file
expect_equal(parsed$files[["raw_file"]]$filename, basename(tmp_rds))
expect_equal(parsed$files[["raw_file"]]$content_type, "application/octet-stream")
expect_equal(parsed$files[["raw_file"]]$length, file.size(tmp_rds))
expect_identical(get_multipart_file(body, parsed$files[["raw_file"]]),
                 readBin(tmp_rds, raw(), file.size(tmp_rds)))
