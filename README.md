# Taxdump Edit

## Why?
The taxdump files from NCBI, along with the 'nr' database, are often used in meta -genomics and -transcriptomics software to inform taxonomic identification of reads, contigs and ORFs. However, if you are working with organisms that have little to no representation in the NCBI databases then you may find yourself a bit stuck.

Many researchers in this situation will have custom databases of genomic/transcriptomic data and want to use it, but may still find their organism(s) unavailable within the NCBI taxonomy DB. If your organism does not have a valid TaxID in NCBI then you are unable to use many of the software packages that rely on 'taxdump' to extract taxonomic lineage and naming information with your custom DBs.

## What?
This tool will allow you to modify the 'taxdump' (names.dmp and nodes.dmp) files from NCBI, to temporarily include your organisms - until they find represenration of their own in the NCBI taxonomy lineage.

## How?
The script will automatically find the largest taxonomic ID in nodes.dmp and increment from that point (with a 10^length-1 addition) and assign it to your new taxa. This large addition is to avoid future conflicts with taxdump updates. If you are adding a group.... 

## Usage
```
    perl taxdump_edit.pl ----
    
    required input
        node.dmp location
	names.dmp location
	parent taxID
	rank
	division
    optional input (names)
        unique name
    default values (names)
        name class = scientific name
    optional input (nodes)
        embl code
	genetic code (1)
	mitochondria genetic code (1)
	comments
    default values (nodes)
        inherited div flag = 1
	inherited GC flag = 1
	inherited MGC flag = 1
	GenBank hidden flag = 1
	hidden subtree root flag = 1
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
