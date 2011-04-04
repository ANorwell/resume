#!/usr/local/bin/perl
use warnings;
use strict;
use XML::LibXML;

our $LOGLEVEL = 0;
our $DELIM = '##';

#When a section has a transform, it may use this variable name to indicate
#where the entry values get placed.
#(syntactic sugar to allow simple transforms to be applied to entries easily)
our $SECTION_NO_NAME = 'VAL';

our ($INFO, $TEMPLATE, $TRANSFORM) = @ARGV;

my $base_entry = openRoot($INFO);
my $transform = openRoot($TRANSFORM);

#slurp the template-file to a variable
my $template;
{
    open my $fh, '<', $TEMPLATE || die "template $TEMPLATE missing: $!";
    local $/;
    $template = <$fh>;
    close $fh;
}

print processEntry($template, $transform, $base_entry);

#Given a template containing ##name## variables to be resolved,
#and $root, an entry
sub processEntry {
    my ($template, $transform_map, $root) = @_;

    while ($template =~ m/$DELIM(\w+)$DELIM/) {
        my $sec_name = $1;
        logg(1, "found var $sec_name in template");

        #If the template has an unnamed variable, then the current entry
        #contains the value of that variable, and we should set this directly
        #bug: may not play nice if ##VAL## coexists in template with
        #other variables.
        if ($sec_name eq $SECTION_NO_NAME) {
            my $v = $root->textContent;
            $template =~ s/$DELIM$sec_name$DELIM/$v/g;
            next;
        }

        my @sections = getNamedSections($root,$sec_name);
        unless (@sections) {
            die "$sec_name does not resolve to anything in: $template\n";
        }

        foreach my $sec (@sections) {
            my $section_value = processSection($sec, $sec_name, $transform_map);
            $template =~ s/$DELIM$sec_name$DELIM/$section_value/;
        }
    }
    return $template;
}

#Given a section ##NAME##, gets the resolved value of that section.
sub processSection {
    my ($sec, $sec_name, $transform_map) = @_;
    my $section_value = '';

    foreach my $entry (getEntries($sec)) {

        #apply transform, if there is one
        my $trans = getTransform($transform_map, $sec_name);

        if ($trans) {
            #Recursively resolve the transformed section, using only
            #The sections contained in this entry.
            logg(1, "transform is $trans");
            logg(1, "Doing recursive lookup an entry for $sec_name");
            $section_value .= processEntry($trans, $transform_map, $entry);
        } else {
            #Base case: no transforms, so just replace the var with
            #all the entries.
            $section_value .= $entry->textContent;
            logg(1, "Base case: entry is $section_value");
        }
    }
    return $section_value;
}

sub openRoot {
    my $file = shift;
    my $parser = XML::LibXML->new();
    my $doc = $parser->load_xml(location => $file);
    my $root = $doc->documentElement();
    logg(1, "Opening root " . $root->nodeName);
    return $root;
}

sub getNamedSections {
    my ($root, $name) = @_;
    return grep {$_->getAttribute('name') eq $name }
      $root->getChildrenByTagName('section')
}

sub getEntries {
    my $node = shift;
    my @entries = $node->getChildrenByTagName('entry'); ;

    #If there is only a single entry, then the entry tag maybe omitted. We may
    #return a list with the current node in this case; then, which will be
    #treated as an entry node.
    return @entries if (scalar @entries);
    return ($node);
}

sub getTransform {
    my ($root, $name) = @_;
    my @trans = grep {$_->getAttribute('name') eq $name }
      $root->getChildrenByTagName('transform');

    if (@trans) {
        return $trans[0]->textContent;
    }
    return 0;
}

sub logg {
    my ($level, $msg) = @_;
    if ($level <= $LOGLEVEL) {
        print STDERR "LOG:", $msg, "\n";
    }
}
