tabMainTables <- 
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