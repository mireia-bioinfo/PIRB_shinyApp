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
                 height="600px")
           ),
           # Update plot -------------
           conditionalPanel(
             condition = "input.doPlot > 0",
             # withSpinner(plotOutput("testPlot",
             #                        height = "550px")),
             withSpinner(imageOutput("imagePlot", height="600px")),
             br(),
             ## Add download button for plot
             fluidRow(
               column(4, ""),
               column(4, downloadButton("downloadPlot", "Download Plot",
                            width="100%")))
  ))
