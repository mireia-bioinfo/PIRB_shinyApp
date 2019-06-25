tabMainPlot <- 
  tabPanel("Figure",
           ## Regulome Plot ----------------------------------------------
           # Update Slider with coordinates -----------------------------
           uiOutput("SLIDER"),
           # Landing page -----------
           conditionalPanel(
             condition = "input.doPlot == 0",
             h3("Get started!"),
             img(src="example_IRBPlot.png",
                 align="left",
                 height="550px")
           ),
           # Update plot -------------
           conditionalPanel(
             condition = "input.doPlot > 0",
             withSpinner(plotOutput("testPlot",
                                    height = "550px")),
             br(),
             ## Add download button for plot
             p(downloadButton("downloadPlot", "Download Plot",
                            width="100%"), align="center")
           )
  )
