# Taxdump Edit

## Why?
The taxdump file's from NCBI, along with the 'nr' database, are often used in meta -genomics and -transcriptomics software to inform taxonomic identification of reads, contigs and ORFs. However, if you are working with organisms that have little to no representation in the NCBI databases you may find yourself stuck. Many researchers in this situation will have custom databases of genomic/transcriptomic data, but may still find their organism unavailable within the NCBI taxaonomy. If your organism does not have a TaxID in NCBI then you are unable to use many of the software packages that rely on 'taxdump' to extract taxonomic lineage and naming information.

## What?
This tool will allow you to modify the 'taxdump' (names.dmp and nodes.dmp) files from NCBI, to temporarily include your organisms - until they find represenration of their own in the NCBI taxonomy.

## How?
The script will automatically find the largest taxonomic ID, increment from that point (with 10^length-1) and assign it to your new taxa, this is to avoid conflicts with taxdump updates. If you are adding a group.... 

## Usage
```
    perl taxdump_edit.pl ----
```

# More Information 
## Structure of \*.dmp files
As per NCBI's taxdump_readme.txt:
Each of the files store one record in the single line that are delimited by "\t|\n" (tab, vertical bar, and newline) characters. Each record consists of one or more fields delimited by "\t|\t" (tab, vertical bar, and tab) characters. The brief description of field position and meaning for each file follows.

## nodes.dmp
This file represents taxonomy nodes. The description for each node includes the following fields:

	tax_id					-- node id in GenBank taxonomy database
 	parent tax_id				-- parent node id in GenBank taxonomy database
 	rank					-- rank of this node (superkingdom, kingdom, ...) 
 	embl code				-- locus-name prefix; not unique
 	division id				-- see division.dmp file
 	inherited div flag  (1 or 0)		-- 1 if node inherits division from parent
 	genetic code id				-- see gencode.dmp file
 	inherited GC  flag  (1 or 0)		-- 1 if node inherits genetic code from parent
 	mitochondrial genetic code id		-- see gencode.dmp file
 	inherited MGC flag  (1 or 0)		-- 1 if node inherits mitochondrial gencode from parent
 	GenBank hidden flag (1 or 0)            -- 1 if name is suppressed in GenBank entry lineage
 	hidden subtree root flag (1 or 0)       -- 1 if this subtree has no sequence data yet
 	comments				-- free-text comments and citations

## names.dmp
Taxonomy names file has these fields:

	tax_id					-- the id of node associated with this name
	name_txt				-- name itself
	unique name				-- the unique variant of this name if name not unique
	name class				-- (synonym, common name, ...)

## Taxdump Files
```
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
tar zxvf taxdump.tar/gz
```

## Taxdump Readme
```
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump_readme.txt
```
