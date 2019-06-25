# Define UI for miles per gallon app ----
ui <- fluidPage(theme = shinytheme("yeti"),
  tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico"), # Line to include favicon
            # Facebook OpenGraph tags
            tags$meta(property = "og:title", content = share$title),
            tags$meta(property = "og:type", content = "website"),
            tags$meta(property = "og:url", content = share$url),
            tags$meta(property = "og:image", content = share$image),
            tags$meta(property = "og:description", content = share$description),
            
            # Twitter summary cards
            tags$meta(name = "twitter:card", content = "summary"),
            tags$meta(name = "twitter:site", content = paste0("@", share$twitter_user)),
            tags$meta(name = "twitter:creator", content = paste0("@", share$twitter_user)),
            tags$meta(name = "twitter:title", content = share$title),
            tags$meta(name = "twitter:description", content = share$description),
            tags$meta(name = "twitter:image", content = share$image)
  ),
  # App title ----
  navbarPage(title=div(img(src="favicon.png", width="24px"), "Islet Regulome Browser"),
             windowTitle = "Islet Regulome Browser",
             tabPanel("Home", icon=icon("home"),
                      # navbarMenu("More",
                      #            tabPanel("test"),
                      #            tabPanel("test2")),
                      sidebarLayout(
                        
                        ################################################
                        ## SIDEBAR PANEL (DATA)
                        ################################################
                        sidebarPanel(
                          # Input: Select genome (only hg19 available for now)
                          selectInput('genome', 'Genome', 
                                      c("hg19"), 
                                      selectize=FALSE,
                                      selected="hg19"),
                          # Input: Type of input region (gene or genomic coordinates)
                          radioButtons("coordType", label = h4("Input Region"),
                                       choices = list("Gene Name" = 1, "Coordinates" = 2), 
                                       selected = 1),
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
                                      selected="-",
                                      selectize=TRUE),
                          ## Virtual 4C to load
                          selectizeInput("contacts.type", 
                                         "Virtual 4C (Miguel-Escalada I, et al. 2018)",
                                         choices=NULL,
                                         selected=1),
                          hr(),
                          fluidRow(
                            column(4,
                                   ## Add washu link
                                   actionButton("whashuLink", label="WashU",
                                                icon = icon("link"),
                                                onclick = paste0("window.open(", 
                                                                 shQuote("http://epigenomegateway.wustl.edu/browser/?genome=hg19&session=62hGf7nfcS&statusId=140947077", type="sh"), ",",
                                                                 shQuote("_blank", type="sh"), ")"),
                                                width="100%"
                                   )),
                            column(4,
                                   ## Add UCSC link to region
                                   uiOutput("UCSCLink")),
                            column(4,
                                   actionButton("doPlot",
                                                label="Submit", 
                                                style="color: #fff; background-color: #337ab7; border-color: #2e6da4;",
                                                width="100%"))
                          )
                        , width=4),
                        ################################################
                        ## MAIN PANEL
                        ################################################
                        mainPanel(
                          h2("The Islet Regulome Browser"),
                          p("The Islet Regulome Browser is a visualization tool that provides access to interactive exploration of pancreatic islet genomic data."),
                          tabsetPanel(type="tabs",
                                      tabPanel("Figure",
                                               ##-------------------------------------------------------
                                               ## Include coordinates that are being plotted
                                               ##-------------------------------------------------------
                                               fluidRow(
                                                        # column(2,
                                                        #        br(),
                                                        #        h4("Coordinates:")),
                                                        column(4,
                                                               br(),
                                                               verbatimTextOutput("coordinates")),
                                                        # column(1),
                                                        column(4,
                                                               br(),
                                                               ## Add download button for plot
                                                               downloadButton("downloadPlot", "Download Plot",
                                                                              width="100%")
                                                               )),
                                               ##-------------------------------------------------------
                                               ## Update Slider with coordinates
                                               ##-------------------------------------------------------
                                               uiOutput("SLIDER"),
                                               ##-------------------------------------------------------
                                               ## Regulome Plot
                                               ##-------------------------------------------------------
                                               conditionalPanel(
                                                 condition = "input.doPlot == 0",
                                                 h3("Get started!"),
                                                 img(src="example_IRBPlot.png",
                                                     align="left",
                                                     height="550px")
                                               ),
                                               conditionalPanel(
                                                 condition = "input.doPlot > 0",
                                                 withSpinner(plotOutput("testPlot",
                                                                        height = "550px"
                                                                        # width="1200px"
                                                 ))
                                               )
                                               ),
                                      tabPanel("Tables",
                                               fluidRow(column(3,
                                                               selectInput("dataset", "Choose a dataset:",
                                                                           choices=c("Chromatin Maps"="maps", 
                                                                                     "SNPs"="snps", 
                                                                                     "Gene Expression"="genes"))),
                                                        column(2,
                                                               align="bottom",
                                                               br(),
                                                               downloadButton("downloadDataset", "Download", align="bottom"))
                                                        ),
                                               h3(paste0("Chromatin Maps")),
                                               withSpinner(DT::dataTableOutput("mapsTable")),
                                               h3("SNPs"),
                                               withSpinner(DT::dataTableOutput("snpsTable")),
                                               h3("RNA-seq Expression"),
                                               withSpinner(DT::dataTableOutput("genesTable")))
                          )
                        )
                      )
             ),
             ########################################################
             ## Tabset Panel
             ########################################################
             tabPanel("Data Source", icon=icon("database"),
                      navlistPanel(
                        "Data Source",
                        widths=c(2,10),
                        tabPanel("Adult Human Islets",
                                 includeMarkdown("markdown/DataSource_AdultHI.md")
                        ),
                        tabPanel("Pancreatic Progenitors",
                                 includeMarkdown("markdown/DataSource_PancreaticProgenitors.md")
                        ),
                        tabPanel("GWAS variants",
                                 includeMarkdown("markdown/DataSource_GWASvariants.md")
                        )
                      )),
             tabPanel("Credits", icon=icon("user"),
                      includeMarkdown("markdown/credits.md")#,
                      # a(actionButton("contact", label="How To Cite Us",
                      #                icon = icon("newspaper"),
                      #                onclick=paste0("window.open(", 
                      #                               shQuote("https://www.frontiersin.org/articles/10.3389/fgene.2017.00013/full", type="sh"), ",",
                      #                               shQuote("_blank", type="sh"), ")"),
                      #                width="25%")
                      # )
             ),
             tabPanel("Contact", icon=icon("envelope"),
                      includeMarkdown("markdown/contact.md"),
                      a(actionButton("contact", label="Contact Us",
                                   icon = icon("envelope"),
                                   onclick=paste0("window.open(", 
                                                  shQuote("mailto:info@isletregulome.com", type="sh"), ",",
                                                  shQuote("_self", type="sh"), ")"),
                                   # href="mailto:info@isletregulome.com",
                                   width="25%")
                      )
             ),
             tabPanel("Info", icon=icon("exclamation-circle"),
                      navlistPanel("Info",
                                   widths=c(2,10),
                                   tabPanel("Create a plot",
                                            includeMarkdown("markdown/Info_createPlot.md")
                                            ),
                                   tabPanel("Description of the plot",
                                            includeMarkdown("markdown/Info_description.md")
                                            ),
                                   tabPanel("Moving around",
                                            includeMarkdown("markdown/Info_moving.md")
                                            ),
                                   # tabPanel("Upload your data",
                                   #          includeMarkdown("markdown/Info_loadData.md")
                                   #          ),
                                   tabPanel("Retrieve results",
                                            includeMarkdown("markdown/Info_retrieveResults.md")
                                            ),
                                   tabPanel("How to cite",
                                            includeMarkdown("markdown/Info_howToCite.md")
                                            )
                                   )
             )
        ),
  hr(),
  p("Follow us on twitter!", 
    a("@isletregulome",
      href="https://twitter.com/isletregulome",
      target="_blank"), align="center"),
  p("The IRB is developed and maintained at the",
    a("Endocrine Regulatory Genomics Lab", 
      href="https://www.endoregulatorygenomics.org/",
      target="_blank"),
    "(IGTP, Badalona, Spain)", align="center")

)

  
