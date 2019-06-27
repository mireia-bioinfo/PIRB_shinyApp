sidebar <-
  wellPanel(
    # Input: genome -------------------------
    selectInput('genome', 'Genome', 
                c("hg19"), 
                selectize=FALSE,
                selected="hg19"),
    # Input: Type of input region (gene or genomic coordinates)
    radioButtons("coordType", label = h4("Input Region"),
                 choices = list("Gene Name" = 1, "Coordinates" = 2), 
                 selected = 1, inline=T),
    # Conditional panel depending on radio Butons
    ## Gene name input
    conditionalPanel(
      condition = "input.coordType == 1",
      selectizeInput("gene",
                     label="Gene",
                     choices=NULL,
                     selected=1)
    ),
    ## Coordinates input
    conditionalPanel(
      condition = "input.coordType == 2",
      fluidRow(
        column(4,
               selectInput("chr", "Chr",
                           chr.names,
                           selectize=FALSE)),
        column(4,
               numericInput("start", "Start", value=1)),
        column(4,
               numericInput("end", "End", value=2))
      )
    ),
    ## Extend coordinates to each side
    selectInput("ranges",
                label="Extend Coordinates",
                choices=list("0bp"=0,
                             "1kb"=1e3,
                             "5kb"=5e3,
                             "10kb"=1e4,
                             "50kb"=5e4,
                             "100kb"=1e5,
                             "500kb"=5e5,
                             "1Mb"=1e6),
                selected=5e4),
    hr(),
    # Input: Datasets to show
    h4("Features"),
    ## Chromatin maps
    selectInput("maps.type",
                label="Chromatin Maps",
                c(Choose="", list("Adult Islets - Chromatin Classes (Miguel-Escalada I, et al. 2018)" = "chromatinClassesReduced",
                                  "Adult Islets - Chromatin Classes (Pasquali L, et al. 2014)" = "openChromatinClasses",
                                  "Adult Islets - Chromatin States (Parker SC, et al. 2013)" = "chromatinStates",
                                  "Pancreatic Progenitors (Cebola I, et al. 2015)" = "progenitors")),
                selected="chromatinClassesReduced"),
    ## Cluster types
    selectInput("clusters.type",
                label="Enhancer Clustering Annotation",
                c(Choose="", list("Enhancer Clusters (Pasquali L, et al. 2014)"="enhancerClusters",
                                  "Stretch Enhancers (Parker SC, et al. 2013)"="stretchEnhancers",
                                  "Super Enhancers (Miguel-Escalada I, et al. 2018)"="superEnhancers",
                                  "Enhancer Hubs (Miguel-Escalada I, et al. 2018)"="enhancerHubs",
                                  "COREs (Gaulton KJ, et al. 2010)"="cores")),
                selected="enhancerClusters"),
    ## TFs type
    selectInput("tfs.type",
                label="Transcription Factors",
                list("Adult Islets - Tissue-specific (Pasquali L, et al. 2014)" = "adult",
                     "Adult Islet - Structural (Miguel-Escalada I, et al. 2018)"="structure",
                     "Pancreatic Progenitors (Cebola I, et al. 2015)" = "progenitors",
                     "None"="-"),
                selected="adult"),
    ## SNPs type
    selectInput("snps.type",
                label="SNPs",
                list("None"="-",
                     "70KforT2D"="70KforT2D",
                     "Diagram" = "diagram", 
                     "Magic" = "magic"),
                selected="70KforT2D",
                selectize=TRUE),
    ## Virtual 4C to load
    selectizeInput("contacts.type", 
                   "Virtual 4C (Miguel-Escalada I, et al. 2018)",
                   choices=NULL,
                   selected=1)
  )
