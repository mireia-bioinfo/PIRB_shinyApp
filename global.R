library(shiny)
library(shinycssloaders)
library(shinythemes)
library(markdown)
library(GenomicRanges)
library(plotRegulome)
library(DT)

## Add informtion for link preview
share <- list(
  title = "The Islet Regulome Browser",
  url = "http://http://isletregulome.com",
  image = "http://http://isletregulome.com/isletregulome/favicon.png",
  description = "The Islet Regulome Browser is a visualization tool that provides access to interactive exploration of pancreatic islet genomic data.",
  twitter_user = "isletregulome"
)

## Path for IsletRegulome files
path <- "static_data/RData/"
# path <- "../../isletregulomebrowser_shiny/static_data/RData/"

## Create chromosome names
chr.names <- paste0("chr", c(1:23, "X", "Y"))

## Load chr lengths
load(paste0(path, "shared/hg19_len.rda"))

## Load gene names
load(paste0(path, "shared/gene_names.rda"))

## Load info from baits (Virtual 4C)
load(paste0(path, "shared/baitID_and_name_virtual4C.rda"))
ids <-  unique(ids[order(ids$baitName), 1:2])

# Select only those for which a file exists
files = paste0(path,
               "hg19/",
               "new_Virtual4C/bw/",
               "bg0_score/",
               sapply(ids$baitID, substr, 1,1),
               "/",
               "PI_Merged_Digest_Human_HindIII_BaitID", ids$baitID, "_bg0_score.bw")
ids.sel <- ids[file.exists(files),]

list.art4C <- ids.sel$baitID
names(list.art4C) <- ids.sel$baitName
rm(ids)
