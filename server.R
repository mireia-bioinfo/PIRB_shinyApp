server <- function(input, output, session) {
  
  ## Start with disabled submit button to avoid crashing the app
  ##----------------------------------------------------------------
  observe({
    if (!(input$gene=="" & input$chr=="chr1" & input$start==1 & input$end==2 & input$contact=="")) enable("doPlot")
  })
  
  ## Hide or show sidebar panel
  ##----------------------------------------------------------------
  observeEvent(input$toggleSidebar, {
    shinyjs::toggle(id = "sidebar")

    if (input$toggleSidebar %% 2 != 0) {
      updateActionButton(session,
                         "toggleSidebar",
                         label = "Show sidebar",
                         icon = icon("eye"))
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
    } else if (input$toggleSidebar %% 2 == 0) {
      updateActionButton(session,
                         "toggleSidebar",
                         label = "Hide sidebar",
                         icon = icon("eye-slash"))
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
    }
  })
  

  ## Add options for virtual 4C and genes (improve loading time)
  ##----------------------------------------------------------------
  updateSelectizeInput(session = session, 
                    inputId = 'contacts.dataset', 
                    choices = c("None" = "", list.art4C),
                    selected=183446,#"PDX1-AS1;PDX1",
                    server = TRUE)
  
  updateSelectizeInput(session = session, 
                       inputId = 'gene', 
                       choices = c(Choose="", genes.key$gene_name),
                       selected="PDX1",
                       server = TRUE)

  ## Get coordinates to plot
  ##----------------------------------------------------------------
  coordinates <- eventReactive(input$doPlot, {
    if (input$coordType==2) {
      coord <- GRanges(paste0(input$chr, ":", 
                     input$start-as.numeric(input$ranges), 
                     "-", input$end+as.numeric(input$ranges)))
    } else if (input$coordType==1) {
      load(paste0(path, input$genome, "/genes/",
                  input$genome, "_gene_annotation_ensemblv75_", 
                  genes.key$chr[genes.key$gene_name %in% input$gene], ".rda"))
      genes <- genes[genes$gene_name==input$gene &
                       genes$type=="GENE" &
                       genes$longest,]
      coord <- regioneR::extendRegions(genes, 
                                       extend.start=as.numeric(input$ranges),
                                       extend.end=as.numeric(input$ranges))
    }
    
    if (width(coord)>5e6) coord <- resize(coord, width=5e6, fix="center", ignore.strand=TRUE)
    
    return(coord)
  })
  
  
  ## Update coordinates
  ##----------------------------------------------------------------
  observeEvent(input$doPlot, {
    updateRadioButtons(session, "coordType",
                       selected = 2)
  })
  
  observe({
    updateSelectInput(session, "chr",
                      selected=as.character(seqnames(coordinates())))
    updateNumericInput(session, "start", 
                       value = start(coordinates()))
    updateNumericInput(session, "end", 
                       value = end(coordinates()))
    updateSelectInput(session, "ranges",
                      selected=0)
  })
  
  ## Render slider once coordinates are present
  ##----------------------------------------------------------------
  output$SLIDER = renderUI({
    sliderInput(inputId="zoom",
                label="Coordinates",
                value=c(start(coordinates()),
                        end(coordinates())),
                min=max(start(coordinates())-width(coordinates())*4, 
                        1),
                max=min(end(coordinates())+width(coordinates())*4,
                        len$length[len$chr==as.character(seqnames(coordinates()))]),
                width="100%")
  })
  
  ## Update coordinates to slider values
  ##----------------------------------------------------------------
  observe({
    print(input$zoom)
    updateNumericInput(session, "start", 
                       value = input$zoom[1])
    updateNumericInput(session, "end", 
                       value = input$zoom[2])
  })
  
  ## Output coordinates in text
  ##----------------------------------------------------------------
  output$coordinates <- renderText({ 
    as.character(coordinates())
  })
  
  ## Function to draw plot regulome
  ##----------------------------------------------------------------
  makePlot <- eventReactive(input$doPlot, {
    if (input$coordType==1) nm <- input$gene else nm <- as.character(coordinates())
    
    message(paste0(">>>Creating_regulomePlot/", Sys.time(), "/", nm,
                  "/", input$snps.dataset, "/", input$maps_dataset, "/", input$contacts.dataset,
                  "/", input$clusters.dataset, "/", input$tfs.dataset))
    
    plotRegulome(coordinates(),
                 snps_dataset=gsub("-", "", input$snps.dataset),
                 contacts_dataset=gsub("-", "", input$contacts.dataset),
                 maps_dataset=gsub("-", "", input$maps_dataset),
                 clusters_dataset=gsub("-", "", input$clusters.dataset),
                 tfs_dataset=gsub("-", "", input$tfs.dataset),
                 genome=input$genome,
                 path=path)
  })
  
  ## Output Regulome Plot
  ##----------------------------------------------------------------
  output$testPlot <- renderPlot ({
    makePlot()
  })
  
  output$imagePlot <- renderImage ({
    # For high-res displays, this will be greater than 1
    # pixelratio <- session$clientData$pixelratio
    pixelratio <- 1
    
      # Read myImage's width and height. These are reactive values, so this
      # expression will re-run whenever they change.
      width  <- session$clientData$output_imagePlot_width*pixelratio
      height <- session$clientData$output_imagePlot_height*pixelratio
      
      dpi=100*pixelratio
      
      # A temp file to save the output.
      outfile <- tempfile(fileext='.png')
      
      # Generate the image file
      ggplot2::ggsave(filename=outfile, 
                      plot=makePlot(),
                      width=width/dpi,
                      height=height/dpi, 
                      unit="in")
      
      # Return a list containing the filename
      list(src = outfile,
           width = width,
           height = height,
           alt = "This is alternate text")
    }, deleteFile = TRUE) # delete the temp file when finished

  ## Download Regulome Plot
  ##----------------------------------------------------------------
  output$downloadPlot <- downloadHandler(
    filename = function() {
      coordinates <- coordinates()
      filename <- paste0("IRBplot_", as.character(coordinates), ".pdf")
      return(filename)
    },
    content = function(file) {
      ggplot2::ggsave(filename=file, plot=makePlot(),
             width=12, height=6.5, unit="in")
    }
  )
  
  ## Add UCSC link to plot
  ##----------------------------------------------------------------
  output$UCSCLink <- renderUI({
    url <- paste0("https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg19&hubUrl=https://raw.githubusercontent.com/mireia-bioinfo/IRB_hub/master/hub.txt&hubUrl=https://raw.githubusercontent.com/mireia-bioinfo/CYT_hub/master/hub.txt&position=",
                  input$chr, ":", input$start, "-", input$end)

    actionButton("UCSCLink", label="UCSC",
                 icon = icon("link"),
                 onclick = paste0("window.open(", shQuote(url, type="sh"), ",",
                                  shQuote("_blank", type="sh"), ")"),
                 width="100%"
                 )
  })

    output$WashULink <- renderUI({
    url <- paste0("http://epigenomegateway.wustl.edu/browser/?genome=hg19&hub=https://raw.githubusercontent.com/mireia-bioinfo/IRB_hub/master/washu_new_session.json&position=",
                  input$chr, ":", input$start, "-", input$end)

    actionButton("WashULink", label="WashU",
                 icon = icon("link"),
                 onclick = paste0("window.open(", shQuote(url, type="sh"), ",",
                                  shQuote("_blank", type="sh"), ")"),
                 width="100%"
                 )
  })
  
  ## Close all connections to avoid error
  closeAllConnections()
  
  ##----------------------------------------------------------------
  ## Create Tables
  ##----------------------------------------------------------------
  ## Maps table
  maps.df <- eventReactive(input$doPlot, {
    maps.l <- create_mapsRegulome(coordinates=coordinates(),
                                  maps_dataset=gsub("-", "", input$maps_dataset),
                                  genome=input$genome,
                                  path=path)
    
    tfs.l <- create_tfsRegulome(coordinates=coordinates(),
                                  tfs_dataset=gsub("-", "", input$tfs.dataset),
                                  genome=input$genome,
                                  path=path)
    
    if (maps.l$name!="" & tfs.l$name!="" & length(maps.l$value)>0) {
      ## Add tfs data
      ol <- findOverlaps(maps.l$value,
                         tfs.l$value)
      
      tfs.ol <- split(tfs.l$value$TF[subjectHits(ol)],
                      queryHits(ol))
      tfs.ol <- lapply(tfs.ol, unique)
      tfs.ol <- sapply(tfs.ol, paste0, collapse=", ")
      
      maps.l$value$TFBS <- "-"
      maps.l$value$TFBS[as.numeric(names(tfs.ol))] <- tfs.ol
      
      ## Convert to data.frame
      maps.l$value <- data.frame(maps.l$value)[,c(6, 1:3, 7)]
      colnames(maps.l$value) <- c("Class", "Chr", "Start", "End", "TFBS")
    } else if (maps.l$name!="" & tfs.l$name=="" & length(maps.l$value)>0) {
    maps.l$value$TFBS <- "-"
    maps.l$value <- data.frame(maps.l$value)[,c(6, 1:3, 7)]
    colnames(maps.l$value) <- c("Class", "Chr", "Start", "End", "TFBS")
    } else {
      maps.l$value <- data.frame("Class"=NA,
                                 "Chr"=NA,
                                 "Start"=NA,
                                 "End"=NA, 
                                 "TFBS"=NA)
    }

    maps.l
  })
  output$mapsTable <- DT::renderDataTable({
    col <- rep("black", length(maps.df()$col))
    col[grep("black", maps.df()$col)] <- "white"
    col[grep("#000000", maps.df()$col)] <- "white"
    
    DT::datatable(maps.df()$value,
                  rownames=FALSE) %>%
      formatStyle("Class",
                  backgroundColor=styleEqual(names(maps.df()$col),
                                             adjustcolor(maps.df()$col, alpha.f=0.7)),
                  color=styleEqual(names(maps.df()$col),
                                   col)
                  
      )
  })
  
  ## SNPs table
  snps.df <- eventReactive(input$doPlot, {
    snps <- create_snpsRegulome(coordinates=coordinates(),
                                snps_dataset=gsub("-", "", input$snps.dataset),
                                genome=input$genome,
                                path=path)
    if (snps$name!="") {
      snps <- data.frame(snps$value)[,c(1,2,6:7)]
      snps <- snps[order(snps$PVAL),]
      colnames(snps) <- c("Chr", "Position", "rsID", "P-value")
    } else {
      snps <- data.frame("Chr"=NA,
                               "Position"=NA,
                               "rsID"=NA,
                               "P-value"=NA)
    }
    
    snps
  })
  
  output$snpsTable <- DT::renderDataTable({
    DT::datatable(snps.df(),
                  rownames=FALSE)
  })
  
  ## Genes table
  genes.df <- eventReactive(c(input$doPlot, input$rnadb), {
    ## Load gene RNA data
    load(paste0(path,input$genome, "/genes/",
                input$genome, "_gene_", input$rnadb, "_", input$chr, ".rda"))
    genes <- subsetByOverlaps(genes, coordinates())
    
    if (input$rnadb=="moran") {
      genes <- data.frame(genes)[,c(7,6,8)]
      colnames(genes) <- c("Gene Symbol", "Gene ID (UCSC)",
                           "Expression (RPKM)")
      genes <- genes[order(genes[,3], decreasing=TRUE),]
      
      genes
    } else {
      genes <- data.frame(genes)[,c(7,6,8:10)]
      colnames(genes) <- c("Gene Symbol", "Gene ID (Ensembl)",
                           "Control Expression*", "Cytokine-induced Expression*",
                           "log2 fold-change")
      genes$`log2 fold-change` <- round(genes$`log2 fold-change`, 2)
      genes <- genes[order(genes[,5], decreasing=TRUE),]
    }

  })
  
  output$genesTable <- DT::renderDataTable({
    if (input$rnadb=="moran") {
      formattable::as.datatable(formattable::formattable(genes.df(),
                                                         list("Expression (RPKM)"=formattable::color_tile("transparent", 
                                                                                                          "steelblue3"))),
                                rownames=FALSE)
    } else {
      formattable::as.datatable(formattable::formattable(genes.df(),
                                                         list("log2 fold-change"=formattable::formatter("span",
                                                                                           style = x ~ formattable::style(color = ifelse(x >= 1, 
                                                                                                                            "green", "gray"))))),
                                rownames=FALSE) %>%
        DT::formatRound(columns=c("Control Expression*", "Cytokine-induced Expression*","log2 fold-change"), 
                        digits=2)
      
    }
    
  })
  
  ##----------------------------------------------------------------
  ## Download Tables
  ##----------------------------------------------------------------
  datasetInput <- reactive({
    switch(input$dataset,
           "maps"=maps.df()$value,
           "snps"=snps.df(),
           "genes"=genes.df())
  })
  
  output$downloadDataset <- downloadHandler(
    filename = function() {
      filename <- paste0(input$dataset, "_", as.character(coordinates()), ".csv")
      return(filename)
    },
    content = function(file) {
      write.csv(as.data.frame(datasetInput()), file, row.names=FALSE, quote=FALSE)
    }
  )
  
  
  ## Close all connections to avoid error
  closeAllConnections()
  
}
