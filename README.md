# The Islet Regulome Browser

## Description
The Islet Regulome Browser is a dynamic website that allows you to explore genetic and epigenetic data from islet-related cell-types and tissues.

This repository contains the app that can be found at [http://isletregulome.com](http://isletregulome.com). It uses the `shiny` R package to create the user interface, recieve user queries and return the output. The main IRB plot is drawn using the [plotRegulome](https://github.com/mireia-bioinfo/plotRegulome) package.

## Pre-requisites
You need to have installed the following packages:

- CRAN
    - [shiny](https://CRAN.R-project.org/package=shiny)
    - [shinycssloaders](https://CRAN.R-project.org/package=shinycssloaders)
    - [shinyjs](https://deanattali.com/shinyjs/)
    - [shinythemes](https://CRAN.R-project.org/package=shinythemes)
    - [DT](https://CRAN.R-project.org/package=DT)
    - [formattable](https://github.com/renkun-ken/formattable)
- Bioconductor
    - [GenomicRanges](https://bioconductor.org/packages/release/bioc/html/GenomicRanges.html)
- Github
    - [plotRegulome](https://github.com/mireia-bioinfo/plotRegulome)
    
In the R console (R version >= 3.5.0) type the following to install the requiered packages:

```
install.packages(c("shiny",
                   "shinycssloaders",
                   "shinyjs"
                   "shinythemes",
                   "DT",
                   "formttable",
                   "BiocManager", # Required for installing Bioconductor packages
                   "devtools" # Required for installing github packages
                   )) 

BiocManager::install("GenomicRanges")

devtools::install_github("mireia-bioinfo/plotRegulome")
```


