# The Islet Regulome Browser

## Description
The Islet Regulome Browser is a dynamic website that allows you to explore genetic and epigenetic data from islet-related cell-types and tissues.

## Before Running
You need to have installed the following packages:

- CRAN
    - [shiny](https://CRAN.R-project.org/package=shiny)
    - [shinycssloaders](https://CRAN.R-project.org/package=shinycssloaders)
    - [shinythemes](https://CRAN.R-project.org/package=shinythemes)
    - [ggplot2](https://CRAN.R-project.org/package=ggplot2)
    - [DT](https://CRAN.R-project.org/package=DT)
- Bioconductor
    - [GenomicRanges](https://bioconductor.org/packages/release/bioc/html/GenomicRanges.html)
- Github
    - [formattable](https://github.com/renkun-ken/formattable)
    - plotRegulome

## Pending to implement  
- ~~Add TF info to chromatin maps table.~~
- ~~Color islet-specific genes in another color.~~
- ~~Create/add WashU Browser session.~~
- ~~Add navigation bar on top.~~
- ~~Add UCSC link.~~
- ~~Add download plot.~~
- ~~Add tabs (one for plot, one for tables).~~
- ~~Implement tables for the regions selected~~ + ~~Download tables (for classes, SNPs and genes)~~ ~~--> Color tables with **[formattable](https://github.com/renkun-ken/formattable)**.~~
    - ~~Maps table --> Also add info regarding TF(?)~~
- Possibility of uploading SNPs data and/or regions for chromatin maps.
- ~~Add description and information in the navbar sections.~~
- ~~Include **new datasets** from Jorge Ferrer lab~~
    - ~~Artificial 4C~~
    - ~~New T2D SNPs [link](http://cg.bsc.es/70kfort2d/)~~
    - ~~New regulome classification.~~

## Current Bugs  
- ~~When plotting coordinates `chr2:182487815-182595603` with NeuroD1 contacts, returns an error: `Warning: Error in $<-.data.frame: replacement has 252 rows, data has 130`. Error happens in `plot.contactsRegulome` probably???~~
- ~~Fix coordinates in slider input --> Never < 1, adapt to region being plotted (% of width??), never more than chromosome length~~
- ~~Fix table error when no snps/genes/maps are selected~~

