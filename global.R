## Load necessary packages
library(shiny)
library(shinycssloaders)
library(shinyjs)
library(shinythemes)
library(markdown)
library(GenomicRanges)
library(DT)
# library(plotRegulome)
devtools::load_all("~/tools/IRB/plotregulome/")

## Add informtion for link preview
share <- list(
  title = "The Islet Regulome Browser",
  url = "http://http://isletregulome.com",
  image = "http://http://isletregulome.com/isletregulome/favicon.png",
  description = "The Islet Regulome Browser is a visualization tool that provides access to interactive exploration of pancreatic islet genomic data.",
  twitter_user = "isletregulome"
)

## Path for IsletRegulome files
path <- "IRB_database/"

## Create chromosome names
chr.names <- paste0("chr", c(1:23, "X", "Y"))

## Load chr lengths
load(paste0(path, "shared/hg19_len.rda"))

## Load gene names
load(paste0(path, "shared/genes_key.rda"))

## Load info from baits (Virtual 4C)
load(paste0(path, "hg19/virtual4c/baitID_keyTable.rda"))
ids <-  unique(ids[order(ids$baitName), c(1:2,7)])

# Select only those for which a file exists
ids <- ids[ids$fileExists,]

list.art4C <- ids$baitID
names(list.art4C) <- ids$baitName

## Load UI elements ---------------------------
source("ui_elements/sidebarPanel.R")
source("ui_elements/mainPanelPlot.R")
source("ui_elements/mainPanelTable.R")
source("ui_elements/mainPanelTopbar.R")