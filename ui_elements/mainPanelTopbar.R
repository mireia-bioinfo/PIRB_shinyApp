topbar <- 
  fluidRow(
    column(4,
           actionButton("toggleSidebar", "Hide sidebar", icon=icon("eye-slash"),
                        width="100%")),
    column(3,
           actionButton("doPlot",
                        label="Submit", 
                        style="color: #fff; background-color: #337ab7; border-color: #2e6da4;",
                        width="100%")),
    column(1,
           ## Add washu link
           actionButton("whashuLink", label="WashU",
                          icon = icon("link"),
                          onclick = paste0("window.open(",
                                           shQuote("http://epigenomegateway.wustl.edu/browser/?genome=hg19&session=62hGf7nfcS&statusId=140947077", type="sh"), ",",
                                           shQuote("_blank", type="sh"), ")"),
                          width="100%")),
    column(1,
           ## Add UCSC link to region
             uiOutput("UCSCLink")),
    column(3,
           verbatimTextOutput("coordinates", placeholder=T))
  )