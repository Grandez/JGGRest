#!/usr/bin/env Rscript

## ---- prepare paths ----

ex_dir = system.file("examples", package = "JGGRest")
rserve_app = file.path(ex_dir, "00-rserve", "app.R")
JGGRest_app = file.path(ex_dir, "01-hello-world", "app.R")
wrk_bin = Sys.which("wrk")
wrk_args = c("-c 100", "-d 30s", "-t 4", "http://127.0.0.1:8080/hello")
if (!nzchar(wrk_bin)) {
  stop("'wrk' not found.", call. = FALSE)
}


## ---- benchmark Rserve ----

message("run Rserve demo app")
rserve_pid = sys::r_background(paste("--vanilla -q -f", rserve_app), std_out = FALSE, std_err = FALSE)
Sys.sleep(1)
message("run Rserve demo app benchmark")
rserve_bench = sys::exec_internal(wrk_bin, wrk_args)
message("results Rserve demo app benchmark")
cat(rawToChar(rserve_bench$stdout))
message("stop Rserve demo app")
tools::pskill(rserve_pid)


## ---- benchmark JGGRest ----

message("run JGGRest demo app")
JGGRest_pid = sys::r_background(paste("--vanilla -q -f", JGGRest_app), std_out = FALSE, std_err = FALSE)
Sys.sleep(1)
message("run JGGRest demo app benchmark")
JGGRest_bench = sys::exec_internal(wrk_bin, wrk_args)
message("results JGGRest demo app benchmark")
cat(rawToChar(JGGRest_bench$stdout))
message("stop JGGRest demo app")
tools::pskill(JGGRest_pid)
