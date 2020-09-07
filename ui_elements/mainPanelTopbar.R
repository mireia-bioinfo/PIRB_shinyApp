topbar <- 
  fluidRow(
    column(4,
           actionButton("toggleSidebar", "Hide sidebar", icon=icon("eye-slash"),
                        width="100%")),
    disabled(column(3,
           actionButton("doPlot",
                        label="Submit", 
                        style="color: #fff; background-color: #337ab7; border-color: #2e6da4;",
                        width="100%"))),
    column(1,
           ## Add WashU link to region
             uiOutput("WashULink")),
    column(1,
           ## Add UCSC link to region
             uiOutput("UCSCLink")),
    column(3,
           verbatimTextOutput("coordinates", placeholder=T))
  )
