#!/bin/env perl
use strict;
use warnings;

# user inputs
my $nodes = 'nodes.dmp';
my $names = 'names.dmp';

## names.dmp specific
my $new_name        = '';
my $new_unique_name = '';
my $new_class       = '';

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
my $gb_hidden_flag     = ''; # (1 or 0) 1 if name is suppressed in GenBank entry lineage
my $hidden_subtree_root_flag = ''; # (1 or 0) 1 if this subtree has no sequence data yet
my $comments           = ''; # free-text comments and citations

# flow
my $largest_taxid = get_largest_tax_id($nodes);

## shared variables
my $new_taxid = $largest_taxid + 1;

print "$largest_taxid + 1 = $new_taxid\n";

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
