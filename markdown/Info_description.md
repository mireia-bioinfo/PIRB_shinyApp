Description of the plot
===============================

<div style="text-align:center"><img src="example_IRBPlot.png" height="500" alt="IRB Example" class="center"/></div>

The plot illustrates regulatory regions, transcription factors binding sites, chromatin interaction data and GWAS variants in which the sequence of the base genome is represented on the horizontal axis. In the upper part of the plot a green line on the chromosome ideogram reflects the portion of the chromosome displayed. 
Each dot represents a genomic variant, being the color intensity of the dot proportional to -Log10 p-value of association, as indicated on the side of the plot. The rs# ID depicts the top associated variants in the locus.

The virtual 4C data is visualized as an interaction frequency histogram plot, where the bait/viewpoint is depict as a black triangle region. A distal peak in the signal indicates that there is a chromatin interaction event with the bait/viewpoint. The interaction significance is depicted by a color code reflecting the [CHiCAGO scores](http://regulatorygenomicsgroup.org/chicago). Such chromatin interaction maps were extracted from promoter capture HiC data centered on the queried bait region, hence, virtual 4C.

The black box in the middle of the plot contains vertical colored bands depicting different chromatin states, open chromatin classes or regulatory elements as described in the legend above the plot. Black lines connecting the circles (each representing a different transcription factor) to the black box, point to the genomic location of each transcription factor binding site. The color intensity of such lines is proportional to the number of co-bound transcription factors. Annotated genes are depicted as horizontal gray lines at the bottom of the plot. Boxes along the line correspond to positions of coding exons. The color of the box indicates the type of annotation: black boxes indicate lncRNAs, grey boxes indicate genes and purple boxes represent islet-specific genes.
