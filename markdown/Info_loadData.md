Upload your data
========================

Variants or regions files can be uploaded by the user for temporary display. The file size of the uploaded file should not exceed 50Mb. If a file contains a header, this should start with the "#" symbol.

A **variant file** should consist of three or four tab-delimited fields. Mandatory fields are those of chromosome, position, and p-value. The files can also contain an optional fourth field with the names of the variants. Other columns after the fourth, will be ignored. For instance:

- column 1: Chromosome, a number between 1 and 22 or the letters X, Y, preceded by the prefix 'chr' (eg. chr1, chr2....chrY)
- column 2: Position, a positive integer (eg. 32541241)
- column 3: P-value, a numerical value (eg. 0.000005)
- column 4: Name, any alphanumeric string (eg. rs9581940)

A **region file** has a typical BED file format and should be composed of at least 3 mandatory tab-delimited fields: chromosome, start, and end. Other columns after the third, will be ignored. For instance:

- column 1: Chromosome, a number between 1 and 22 or the letters X, Y, preceded by the prefix 'chr' (eg. chr1, chr2....chrY)
- column 2: Start, a positive integer (eg. 49356749)
- column 3: End, a positive integer (eg. 51674938)

To avoid errors during the upload remember that the chromosomes should be named as follow: chr1, chr2, chr3, chr4, chr5, chr6, chr7, chr8, chr9, chr10, chr11, chr12, chr13, chr14, chr15, chr16, chr17, chr18, chr19, chr20, chr21, chr22, chrX, chrY.

The fields with positional information should only contain integer values while the p-values should be numerical values.

Upon data upload, a **Share uploaded files** button may be clicked. This will generate a URL that can be copy-pasted to a browser address bar in order to reproduce the Islet Regulome Browser session in use, including the uploaded data. Such link may be shared with other users in order to share data on the Islet Regulome Browser. Data uploaded by the user will be available for one month.
