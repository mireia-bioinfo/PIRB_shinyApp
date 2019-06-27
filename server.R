server <- function(input, output, session) {
  
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
                    inputId = 'contacts.type', 
                    choices = c("None" = "-", list.art4C),
                    selected=183446,#"PDX1-AS1;PDX1",
                    server = TRUE)
  
  updateSelectizeInput(session = session, 
                       inputId = 'gene', 
                       choices = c(Choose="", gene.names),
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
      load(paste0(path,
                      input$genome, "/",input$genome, "_genesCoding_ensemblv75.rda"))
      genes <- genes[genes$gene_name==input$gene,]
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
                       value = start(ranges(coordinates())))
    updateNumericInput(session, "end", 
                       value = end(ranges(coordinates())))
    updateSelectInput(session, "ranges",
                      selected=0)
  })
  
  ## Render slider once coordinates are present
  ##----------------------------------------------------------------
  output$SLIDER = renderUI({
    sliderInput(inputId="zoom",
                label="Coordinates",
                value=c(start(ranges(coordinates())),
                        end(ranges(coordinates()))),
                min=max(start(ranges(coordinates()))-width(ranges(coordinates()))*4, 
                        1),
                max=min(end(ranges(coordinates()))+width(ranges(coordinates()))*4,
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
    
    # if (input$doPlot==0) return()
    as.character(coordinates())
  })
  
  ## Function to draw plot regulome
  ##----------------------------------------------------------------
  makePlot <- eventReactive(input$doPlot, {
    # if(input$doPlot==0) return()
    
    if (input$contacts.type!="-" &
        input$contacts.type!="") {
      files.contacts <- paste0(path,
                               input$genome, "/",
                               "new_Virtual4C/bw/",
                               "bg", c(0,3,5), "_score/",
                               substr(input$contacts.type, 1,1),
                               "/",
                               "PI_Merged_Digest_Human_HindIII_BaitID", input$contacts.type, "_bg", c(0,3,5), "_score.bw")
    } else {
      files.contacts <- ""
    }
    
    if (input$coordType==1) nm <- input$gene else nm <- as.character(coordinates())
    message(paste0(">>>Creating_regulomePlot/", Sys.time(), "/", nm,
                  "/", input$snps.type, "/", input$maps.type, "/", input$contacts.type,
                  "/", input$clusters.type, "/", input$tfs.type))
    
    suppressWarnings(
      plotRegulome(coordinates(),
                   snps.type=gsub("-", "", input$snps.type),
                   contacts.type=files.contacts,
                   maps.type=gsub("-", "", input$maps.type),
                   cluster.type=gsub("-", "", input$clusters.type),
                   tfs.type=gsub("-", "", input$tfs.type),
                   showLongestTranscript=TRUE,
                   genome=input$genome,
                   path=path))
  })
  
  ## Output Regulome Plot
  ##----------------------------------------------------------------
  output$testPlot <- renderPlot ({
    makePlot()
  }#,
  # width=900, height=600, res=80
  )
  
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
             width=12, height=6, unit="in")
    }
  )
  
  ## Add UCSC link to plot
  ##----------------------------------------------------------------
  output$UCSCLink <- renderUI({
    url <- paste0("https://genome.ucsc.edu/cgi-bin/hgTracks?hgS_doOtherUser=submit&hgS_otherUserName=mramos&hgS_otherUserSessionName=hg19_IRB&position=",
                  input$chr, "%3A", input$start, "-", input$end)

    actionButton("UCSCLink", label="UCSC",
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
                                  maps.type=gsub("-", "", input$maps.type),
                                  genome=input$genome,
                                  path=path)
    
    tfs.l <- create_tfsRegulome(coordinates=coordinates(),
                                  tfs.type=gsub("-", "", input$tfs.type),
                                  genome=input$genome,
                                  path=path)
    
    if (maps.l$name!="" & tfs.l$name!="") {
      ## Add tfs data
      ol <- findOverlaps(maps.l$value,
                         tfs.l$value)
      
      tfs.ol <- split(tfs.l$value$TF[subjectHits(ol)],
                      queryHits(ol))
      tfs.ol <- sapply(tfs.ol, unique)
      tfs.ol <- sapply(tfs.ol, paste0, collapse=", ")
      
      maps.l$value$TFBS <- "-"
      maps.l$value$TFBS[as.numeric(names(tfs.ol))] <- tfs.ol
      
      ## Convert to data.frame
      maps.l$value <- data.frame(maps.l$value)[,c(6, 1:3, 7)]
      colnames(maps.l$value) <- c("Class", "Chr", "Start", "End", "TFBS")
    } else if (maps.l$name!="" & tfs.l$name=="") {
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
                                snps.type=gsub("-", "", input$snps.type),
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
  genes.df <- eventReactive(input$doPlot, {
    genes.sel <- plotRegulome:::create_genesRegulome(coordinates=coordinates(),
                                                     showLongestTranscript=TRUE,
                                                      genome=input$genome,
                                                     path=path)
    names <- unique(genes.sel$value$gene_name)
    
    ## Load gene RNA data
    load(paste0(path,"new_rna_expr/",
                    input$genome, "/", input$genome, "_genes_", input$chr, ".rda"))
    genes <- unique(genes[genes$Gene %in% names,c(7,6,8)])
    # genes <- dplyr::left_join(genes, 
    #                           data.frame(genes.sel$value)[genes.sel$value$type=="GENE",c(1:3,9)], by=c("Gene"="gene_name"))
    # genes <- genes[,c(1:2,4:6,3)]
    # colnames(genes) <- c("Gene Symbol", "Gene ID (UCSC)", "Chr", "Start", "End",
    #                      "Expression (RPKM)")
    colnames(genes) <- c("Gene Symbol", "Gene ID (UCSC)",
                         "Expression (RPKM)")
    genes <- genes[order(genes[,3], decreasing=TRUE),]
    
    genes
  })
  output$genesTable <- DT::renderDataTable({
    formattable::as.datatable(formattable::formattable(genes.df(),
                                                       list("Expression (RPKM)"=formattable::color_tile("transparent", 
                                                                                           "steelblue3"))),
                              rownames=FALSE)
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