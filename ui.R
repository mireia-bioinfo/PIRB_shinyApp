# Define UI for miles per gallon app ----
ui <- fluidPage(theme = shinytheme("yeti"),
  
  ## Site metadata ------------------------            
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
  useShinyjs(),
  navbarPage(
    title=div(img(src="favicon.png", width="24px"), "Islet Regulome Browser"),
    windowTitle = "Islet Regulome Browser",
    tabPanel("Home", icon=icon("home"),
             ## TOPBAR ------------------------------
             p("The Islet Regulome Browser is a visualization tool that provides access to interactive exploration of pancreatic islet genomic data."),
             topbar,
             fluidRow(
               ## SIDEBAR PANEL (DATA) -----------------------
               column(width=4, id="sidebar", 
                      sidebar
                      ),
               ## MAIN PANEL ---------------------------------
               column(width=8, id="main",
                      ## TABS MAIN ------------------------------
                      br(),
                      tabsetPanel(type="tabs", 
                                  tabMainPlot,
                                  tabMainTables)
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
             includeMarkdown("markdown/credits.md")
    ),
    tabPanel("Contact", icon=icon("envelope"),
             includeMarkdown("markdown/contact.md"),
             p(a(actionButton("contact", label="Contact Us",
                              icon = icon("envelope"),
                              onclick=paste0("window.open(", 
                                             shQuote("mailto:info@isletregulome.com", type="sh"), ",",
                                             shQuote("_self", type="sh"), ")"),
                              width="25%")
             ), align="center")
    ),
    tabPanel("Info", icon=icon("exclamation-circle"),
             navlistPanel("Info",
                          widths=c(2,10),
                          tabPanel("Generate a plot",
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
  ## Footer --------------------------------
  hr(),
  p("Follow us on twitter!", 
    a("@isletregulome",
      href="https://twitter.com/isletregulome",
      target="_blank"), align="center"),
  p("The IRB is developed and maintained at the",
    a("Endocrine Regulatory Genomics Lab", 
      href="https://www.endoregulatorygenomics.org/",
      target="_blank"),
    "(UPF, Barcelona, Spain)", align="center")
)

  
