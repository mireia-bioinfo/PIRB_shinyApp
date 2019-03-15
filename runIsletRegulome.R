#!/usr/bin/env R

library(shiny)

# get the container ip so we can start the server in the correct interface
host <- nsl(Sys.info()[["nodename"]])
port <- 3838
runApp('.', host = host, port = port) 
