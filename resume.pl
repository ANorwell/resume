#!/usr/bin/perl
use warnings;
use strict;
use XML::LibXML;
use JSON;

our $LOGLEVEL = 0;
our $DELIM = '##';

#When a section has a transform, it may use this variable name to indicate
#where the entry values get placed.
#(syntactic sugar to allow simple transforms to be applied to entries easily)
our $SECTION_NO_NAME = 'VAL';

our ($INFO, $TEMPLATE, $TRANSFORM) = @ARGV;

my $rb = ResumeBuilder->new($TRANSFORM, $TEMPLATE);
print $rb->processEntry($rb->{template}, ResumeBuilder::openRoot($INFO));

package ResumeBuilder;

sub new {
    my $class = shift;
    my ($transform_file, $template_file) = @_;
    my $self;

    #slurp the template-file to a variable
    my $template;
    {
        open my $fh, '<', $template_file || die "template $template_file missing: $!";
        local $/;
        $template = <$fh>;
        close $fh;
    }

    $self->{transform_map} = openRoot($transform_file);
    $self->{template}= $template; 
    bless $self, $class;
}

#Given a template containing ##name## variables to be resolved,
#and $info_root, the root of the info file used to populate the template,
#returns the template with template variables replaced with the info
sub processEntry {
    my ($self, $template, $info_root) = @_;
    
    while ($template =~ m/$DELIM(\w+)$DELIM/) {
        my $sec_name = $1;
        logg(1, "found var $sec_name in template");

        #If the template has an unnamed variable, then the current entry
        #contains the value of that variable, and we should set this directly
        #bug: may not play nice if ##VAL## coexists in template with
        #other variables.
        if ($sec_name eq $SECTION_NO_NAME) {
            my $v = $self->getText($info_root);
            $template =~ s/$DELIM$sec_name$DELIM/$v/g;
            next;
        }

        my @sections = $self->getNamedSections($info_root,$sec_name);
        unless (@sections) {
            die "$sec_name does not resolve to anything in: $template\n";
        }

        foreach my $sec (@sections) {
            my $section_value = $self->processSection($sec, $sec_name);
            $template =~ s/$DELIM$sec_name$DELIM/$section_value/;
        }
    }
    return $template;
}

#Given a section ##NAME##, gets the resolved value of that section.
sub processSection {
    my ($self, $sec, $sec_name) = @_;
    my $section_value = '';

    foreach my $entry ($self->getEntries($sec)) {

        #apply transform, if there is one
        my $trans = $self->getTransform($sec_name);

        if ($trans) {
            #Recursively resolve the transformed section, using only
            #The sections contained in this entry.
            logg(1, "transform is $trans");
            logg(1, "Doing recursive lookup an entry for $sec_name");
            $section_value .= $self->processEntry($trans, $entry);
        } else {
            #Base case: no transforms, so just replace the var with
            #all the entries.
            $section_value .= $self->getText($entry);
            logg(1, "Base case: entry is $section_value");
        }
    }
    return $section_value;
}

sub logg {
    my ($level, $msg) = @_;
    if ($level <= $LOGLEVEL) {
        print STDERR "LOG:", $msg, "\n";
    }
}

###Abstract
sub getNamedSections;
sub getEntries;
sub openRoot;
sub getTransform;
sub getText;

###XML versions


#Given a node in a section tree, returns the sections of the given name
sub getNamedSections {
    my ($self, $info_root, $name) = @_;
    return grep {$_->getAttribute('name') eq $name }
      $info_root->getChildrenByTagName('section')
}

sub getEntries {
    my ($self, $node) = @_;
    my @entries = $node->getChildrenByTagName('entry'); ;

    #If there is only a single entry, then the entry tag maybe omitted. We may
    #return a list with the current node in this case; then, which will be
    #treated as an entry node.
    return @entries if (scalar @entries);
    return ($node);
}

sub getTransform {
    my ($self, $name) = @_;
    my @trans = grep {$_->getAttribute('name') eq $name }
      $self->{transform_map}->getChildrenByTagName('transform');

    if (@trans) {
        return $trans[0]->textContent;
    }
    return 0;
}



#BUGBUG: should escape special characters here.
sub getText {
    my ($self, $obj) = @_;
    return $obj->textContent;
};

#Helper function
#Returns the libxml2 root object for the provided XMl file.
sub openRoot {
    my $file = shift;
    my $parser = XML::LibXML->new();
    my $doc = $parser->load_xml(location => $file);
    my $root = $doc->documentElement();
    logg(1, "Opening root " . $root->nodeName);
    return $root;
}
