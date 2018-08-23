#!/bin/env perl
use strict;
use warnings;

# user inputs
my $nodes = 'nodes.dmp';
my $names = 'names.dmp';

## names.dmp specific
my $new_name        = ''; # the name itself
my $new_name_unique = ''; # the unique variant of this name if name not unique
my $new_name_class       = ''; # acronym, anamorph, authority, blast name, common name, equivalent name, genbank acronym, genbank anamorph, genbank common name, genbank synonym, includes, in-part, misnomer, misspelling, scientific name, synonym, teleomorph, type material

## nodes.dmp specific
my $parent_tax_id      = ''; # parent node id in GenBank taxonomy database
my $rank               = ''; # rank of this node (superkingdom, kingdom, ...)
my $embl_code          = ''; # locus-name prefix; not unique
my $division_id   	   = ''; # see division.dmp file
my $inherited_div_flag = ''; # (1 or 0) 1 if node inherits division from parent
my $genetic_code_id    = ''; # see gencode.dmp file
my $inherited_GC_flag  = ''; # (1 or 0) 1 if node inherits genetic code from parent
my $mito_gen_code_id   = ''; # see gencode.dmp file
my $inherited_MGC_flag = ''; # (1 or 0) 1 if node inherits mitochondrial gencode from parent
my $gb_hidden_flag     = '0'; # (1 or 0) 1 if name is suppressed in GenBank entry lineage
my $hidden_subtree_root_flag = '1'; # (1 or 0) 1 if this subtree has no sequence data yet
my $comments           = ''; # free-text comments and citations

# flow
my $largest_taxid = get_largest_tax_id($nodes);

## shared variables
my $new_taxid = $largest_taxid + 1;

print "$largest_taxid + 1 = $new_taxid\n";


# nodes.dmp examples
#16	|	32011	|	genus	|		|	0	|	1	|	11	|	1	|	0	|	1	|	0	|	0	||
#23	|	66288	|	genus	|		|	1	|	1	|	1	|	1	|	1	|	1	|	0	|	0	||

# name.dmp examples
#1	|	all	|		|	synonym	|
#1	|	root	|		|	scientific name	|
#2	|	Bacteria	|	Bacteria <prokaryotes>	|	scientific name	|
#2304220	|	unclassified Planchonella	|		|	scientific name	|
#2304234	|	unclassified Panax	|		|	scientific name	|
#2304343	|	Odontostomatea	|		|	scientific name	|
#2304349	|	Blattamonas Treitli et al. 2018	|		|	authority	|


#############
# subroutines

# get the last line of the nodes or names file
# return the value in the first tab column
# assumes file is sorted
sub get_largest_tax_id {
    my $filename = shift;
    open my $fh, "<$filename" or die "Can't open: $filename $!\n";

    my $lastline;
    $lastline = $_ while <$fh>;
    $lastline =~ /(\d+)\t.*/;
    $lastline = $1;

    return $lastline;
}

# ranks
# class
# cohort
# family
# forma
# genus
# infraclass
# infraorder
# kingdom
# no rank
# order
# parvorder
# phylum
# species
# species group
# species subgroup
# subclass
# subfamily
# subgenus
# subkingdom
# suborder
# subphylum
# subspecies
# subtribe
# superclass
# superfamily
# superkingdom
# superorder
# superphylum
# tribe
# varietas

# division
# 0	Bacteria
# 1	Invertebrates
# 2	Mammals
# 3	Phages
# 4	Plants and Fungi
# 5	Primates
# 6	Rodents
# 7	Synthetic and Chimeric
# 8	Unassigned - dissalowed
# 9	Viruses
# 10	Vertebrates
# 11	Environmental samples

# genetic code
# 0	Unspecified
# 1	Standard
# 2	Vertebrate Mitochondrial
# 3	Yeast Mitochondrial
# 4	Mold Mitochondrial; Protozoan Mitochondrial; Coelenterate Mitochondrial; Mycoplasma; Spiroplasma
# 5	Invertebrate Mitochondrial
# 6	Ciliate Nuclear; Dasycladacean Nuclear; Hexamita Nuclear
# 9	Echinoderm Mitochondrial; Flatworm Mitochondrial
# 10	Euplotid Nuclear
# 11	Bacterial, Archaeal and Plant Plastid
# 12	Alternative Yeast Nuclear
# 13	Ascidian Mitochondrial
# 14	Alternative Flatworm Mitochondrial
# 15	Blepharisma Macronuclear
# 16	Chlorophycean Mitochondrial
# 21	Trematode Mitochondrial
# 22	Scenedesmus obliquus mitochondrial
# 23	Thraustochytrium mitochondrial code
# 24	Pterobranchia Mitochondrial
# 25	Candidate Division SR1 and Gracilibacteria
# 26	Pachysolen tannophilus Nuclear
# 27	Karyorelict Nuclear
# 28	Condylostoma Nuclear
# 29	Mesodinium Nuclear
# 30	Peritrich Nuclear
# 31	Blastocrithidia Nuclear
