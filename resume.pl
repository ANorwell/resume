#!/usr/local/bin/perl
use warnings;
use strict;

use XML::LibXML;

our $LOGLEVEL = 3;

our $DELIM = '##';

##TODO: special replacement for this allowing <entry>s that have just text.
our $SECTION_NO_NAME = 'DATA';

our ($ENTRIES, $TEMPLATE, $TRANSFORM) = @ARGV;

my $entries = openRoot($ENTRIES);
my $transform = openRoot($TRANSFORM);

#slurp the template-file to a variable
my $template;
{
    open my $fh, '<', $TEMPLATE || die $!;
    local $/;
    $template = <$fh>;
    close $fh;
}

print processTemplate($template, $transform, $entries);

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

sub getEntries { return (+shift)->getChildrenByTagName('entry'); }

sub getTransform {
    my ($root, $name) = @_;
    my @trans = grep {$_->getAttribute('name') eq $name }
      $root->getChildrenByTagName('transform');

    if (@trans) {
        return $trans[0]->textContent;
    }
    return 0;
}

sub processTemplate {
    my ($template, $transform_map, $root) = @_;

    while ($template =~ m/$DELIM(\w+)$DELIM/) {
        my $sec_name = $1;
        logg(1, "found var $sec_name in template");

        my @sections = getNamedSections($root,$sec_name);
        unless (@sections) {
            die "$sec_name does not resolve to anything in template $template\n";
        }
        
        foreach my $sec (@sections) {
            logg(1,"sec loop for $sec_name");
            my $entry_value = '';
            foreach my $entry (getEntries($sec)) {


                #apply transform, if there is one
                my $trans = getTransform($transform_map, $sec_name);

                if ($trans) {
                    #Recursively resolve the transformed section, using only
                    #The sections contained in this entry.
                    logg(1, "transform is $trans");
                    logg(1, "Doing recursive lookup an entry for $sec_name");
                    $entry_value .= processTemplate($trans, $transform_map, $entry);
                } else {
                    #Base case: no transforms, so just replace the var with all the entries.
                    $entry_value .= $entry->textContent;
                    logg(1, "Base case: entry is $entry_value");
                }
            }

            #The actual replacement.
            logg(1,"Replacing");
            $template =~ s/$DELIM$sec_name$DELIM/$entry_value/;
        }
    }
    return $template;
}


sub processTemplateOld {
    my ($file, $template_file, $transform_file) = @_;
    my $parser = XML::LibXML->new();
    my $doc = $parser->load_xml(location => $file);
    my $root = $doc->documentElement();
    logg(1,$root->nodeName);

    #slurp the template-file to a variable
    my $template;
    {
        open my $fh, '<', $template_file || die $!;
        local $/;
        $template = <$fh>;
        close $fh;
    }

    getTransformInfo($transform_file);

    foreach my $elt ($root->getChildrenByTagName('section')) {

        $template = processSection($elt, $template);
    }

    print $template;
}

sub getTransformInfo {
    my $file = shift;
    my $parser = XML::LibXML->new();
    my $doc = $parser->load_xml(location => $file);
    my $root = $doc->documentElement();
}
    

sub processSection {
    my ($section, $template) = @_;
    my $name = $section->getAttribute('name');
    my $match = $DELIM . $name . $DELIM;
    logg(1, "Processing section $name, $match ");

    #If there are entry children, use them.
    #Otherwise, the text child forms the single entry.
    my @ents = map {$_->textContent } $section->getChildrenByTagName('entry');
    $ents[0] = $section->textContent unless (@ents);

    foreach my $ent (@ents) {
        logg(1,"Processing entry $ent");
        #We do a SINGLE replacement of this entry in the template
        $template =~ s/$match/$ent/;
    }
    return $template;
}


sub findTemplates {
    opendir(my $dirh, './') || die "Couldn't open dir: $!";
}

sub logg {
    my ($level, $msg) = @_;
    if ($level <= $LOGLEVEL) {
        print STDERR "LOG:", $msg, "\n";
    }
}
