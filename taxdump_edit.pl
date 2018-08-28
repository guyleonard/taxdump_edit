#!/bin/env perl
use strict;
use warnings;

use File::Basename;
use File::Copy;
use Getopt::Long;

our $VERSION = 0.1;
my $version = "taxdump_edit.pl v$VERSION";

# user inputs
my $nodes;
my $names;
my $override;

## names.dmp specific
my $new_name        = '';                   # the name itself
my $new_name_unique = '';                   # the unique variant of this name if name not unique
my $new_name_class  = 'scientific name';    # see name class

## nodes.dmp specific
my $parent_tax_id            = '';          # parent node id in GenBank taxonomy database
my $rank                     = '';          # rank of this node (superkingdom, kingdom, ...)
my $embl_code                = '';          # locus-name prefix; not unique
my $division_id              = '';          # see division.dmp file
my $inherited_div_flag       = '1';         # (1 or 0) 1 if node inherits division from parent
my $genetic_code_id          = '1';         # see gencode.dmp file
my $inherited_GC_flag        = '1';         # (1 or 0) 1 if node inherits genetic code from parent
my $mito_gen_code_id         = '1';         # see gencode.dmp file
my $inherited_MGC_flag       = '1';         # (1 or 0) 1 if node inherits mitochondrial gencode from parent
my $gb_hidden_flag           = '1';         # (1 or 0) 1 if name is suppressed in GenBank entry lineage
my $hidden_subtree_root_flag = '1';         # (1 or 0) 1 if this subtree has no sequence data yet
my $comments                 = '';          # free-text comments and citations

# getops
GetOptions(

    # required
    'nodes=s'    => \$nodes,
    'names=s'    => \$names,
    'taxa=s'     => \$new_name,
    'parent=i'   => \$parent_tax_id,
    'rank=s'     => \$rank,
    'division=i' => \$division_id,
    'override=i' => \$override,

    # optional

    # other
    'version|v' => sub { print "$version\n" },
    'h'         => sub { help_message( "Welcome to $version", 0 ) },
    'help'      => sub { help_message( "Welcome to $version", 1 ) }
) or help_message( "Hello :) Something is missing...", 0 );

help_message( "The nodes.dmp location must be specified.", 0 )
  unless defined $nodes;
help_message( "The names.dmp location must be specified.", 0 )
  unless defined $names;
help_message( "The taxon name or group name must be specified.", 0 )
  unless defined $new_name;
help_message( "The parent taxa ID must be specified.", 0 )
  unless defined $parent_tax_id;
help_message( "The rank must be specified.", 0 ) unless defined $rank;
help_message( "The division must be specified.", 0 )
  unless defined $division_id;

# Get the largest Tax ID from the user specified nodes.dmp
my $largest_taxid = get_largest_tax_id($nodes);

# $largest_taxid increased by a factor of 10 to it's length - 1, to avoid conflicts
my $new_taxid;
if ( defined $override ) {
    $new_taxid = $override;
}
else {
    $new_taxid = $largest_taxid + ( 10**( length($largest_taxid) - 1 ) );
}

print "Your calculated TaxID = $new_taxid. Please use this with makeblastdb and your fasta sequences.\n";

## Edit Names.dmp
# Backup original file
my ( $file, $dir, $ext ) = fileparse $names, '\.dmp';
my $names_backup = "$dir\/$file\_backup$ext";
print "Backing up orginal names.dmp\n";
copy( $names, $names_backup ), or die "Copy failed: $!";

# append new line
print "Appending new line\n";
open( my $names_edit_fh, '>>', $names );
print $names_edit_fh "$new_taxid\t\|\t$new_name\t\|\t$new_name_unique\t\|\t$new_name_class\t\|\n";
close($names_edit_fh);
print "Done.\n";

## Edit Names.dmp
# Backup original file
( $file, $dir, $ext ) = fileparse $nodes, '\.dmp';
my $nodes_backup = "$dir\/$file\_backup$ext";
print "Backing up orginal nodes.dmp\n";
copy( $nodes, $nodes_backup ), or die "Copy failed: $!";

# append new line
print "Appending new line\n";
open( my $nodes_edit_fh, '>>', $nodes );
print $nodes_edit_fh
"$new_taxid\t\|\t$parent_tax_id\t\|\t$rank\t\|\t$embl_code\t\|\t$division_id\t\|\t$inherited_div_flag\t\|\t$genetic_code_id\t\|\t$inherited_GC_flag\t\|\t$mito_gen_code_id\t\|\t$inherited_MGC_flag\t\|\t$gb_hidden_flag\t\|\t$hidden_subtree_root_flag\t\|\t$comments\n";
print "Finished.\n";

#############
# subroutines
#############

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

sub help_message {
    my $message = $_[0];
    my $verbose = $_[1];
    if ( defined $message && length $message ) {
        $message .= "\n"
          unless $message =~ /\n$/;
    }
    my $command = $0;
    $command =~ s#^.*/##;

    print "$message\n";
    print "usage: $command -names names.dmp -nodes nodes.dmp -taxa NAME -parent XXX -rank NAME -division X\n";
    print << "HELP"; 
Required Input:
\t-names names.dmp location
\t-nodes nodes.dmp location
\t-taxa new taxa/group name
\t-parent parent TaxID
\t-rank rank name (see -help)
\t-division division ID (see -help)
Optional Input
\t-override TaxID from previous
Optional Input (names.dmp):
\tunique name
Default Values (names.dmp):
\tname class (scientific name) (see -help)
Optional Input (nodes.dmp):
\tembl code
\tgenetic code (1) (see -help)
\tmitochondria genetic code (1) (see -help)
\tcomments
Default Values (nodes.dmp):
\tinherited div flag = 1
\tinherited GC flag = 1
\tinherited MGC flag = 1
\tGenBank hidden flag = 1
\thidden subtree root flag = 1
HELP
    print "Use -help for a more verbose help message.\n";

    my %divisions = (
        "0"  => "Bacteria",
        "1"  => "Invertebrates",
        "2"  => "Mammals",
        "3"  => "Phages",
        "4"  => "Plants and Fungi",
        "5"  => "Primates",
        "6"  => "Rodents",
        "7"  => "Synthetic and Chimeric",
        "8"  => "Unassigned - Do Not Use",
        "9"  => "Viruses",
        "10" => "Vertebrates",
        "11" => "Environmental Samples"
    );

    my %genetic_code = (
        "0"  => "Unspecified",
        "1"  => "Standard",
        "2"  => "Vertebrate Mitochondrial",
        "3"  => "Yeast Mitochondrial",
        "4"  => "Mold Mitochondrial; Protozoan Mitochondrial; Coelenterate Mitochondrial; Mycoplasma; Spiroplasma",
        "5"  => "Invertebrate Mitochondrial",
        "6"  => "Ciliate Nuclear; Dasycladacean Nuclear; Hexamita Nuclear",
        "9"  => "Echinoderm Mitochondrial; Flatworm Mitochondrial",
        "10" => "Euplotid Nuclear",
        "11" => "Bacterial, Archaeal and Plant Plastid",
        "12" => "Alternative Yeast Nuclear",
        "13" => "Ascidian Mitochondrial",
        "14" => "Alternative Flatworm Mitochondrial",
        "15" => "Blepharisma Macronuclear",
        "16" => "Chlorophycean Mitochondrial",
        "21" => "Trematode Mitochondrial",
        "22" => "Scenedesmus obliquus mitochondrial",
        "23" => "Thraustochytrium mitochondrial code",
        "24" => "Pterobranchia Mitochondrial",
        "25" => "Candidate Division SR 1 and Gracilibacteria",
        "26" => "Pachysolen tannophilus Nuclear",
        "27" => "Karyorelict Nuclear",
        "28" => "Condylostoma Nuclear",
        "29" => "Mesodinium Nuclear",
        "30" => "Peritrich Nuclear",
        "31" => "Blastocrithidia Nuclear"
    );

    my $name_class =
"Acronym\nAnamorph\nAuthority\nBlast Name\nCommon Name\nEquivalent Name\nGenbank Acronym\nGenbank Anamorph\nGenbank Common Name\nGenbank Synonym\nIncludes\nIn-part\nMisnomer\nMisspelling\nScientific Name\nSynonym\nTeleomorph\nType Material";

    my $taxonomic_rank =
"no rank\nsuperkingdom\n\tkingdom\n\t\tsubkingdom\nsuperphylum\n\tphylum\n\t\tsubphylum\nsuperclass\n\tclass\n\t\tsubclass\n\t\t\tinfraclass\ncohort\nsuperorder\n\torder\n\t\tsuborder\n\t\t\tinfraorder\n\t\t\t\tparvorder\nsuperfamily\n\tfamily\n\t\tsubfamily\n\t\ttribe\n\t\t\tsubtribe\n\tgenus\n\t\tsubgenus\nspecies group\n\tspecies\n\tspecies subgroup\n\t\tsubspecies\n\t\t\tvarietas\n\t\t\t\tforma\n";

    if ( $verbose == 1 ) {
        print "\nDivisions (use number code):\n";
        foreach ( sort { $a <=> $b } keys %divisions ) {
            print "$_: $divisions{$_}\n";
        }

        print "\nGenetic Codes (use number code):\n";
        foreach ( sort { $a <=> $b } keys %genetic_code ) {
            print "$_: $genetic_code{$_}\n";
        }

        print "\nName Class (use name):\n$name_class\n";

        print "\nTaxonomic Rank (use name):\n$taxonomic_rank\n";
    }

    exit(1);
}
