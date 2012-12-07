#!/usr/bin/perl -w

use Email::Simple;
use Data::Dumper;
use File::Util;

my $email_dir = '/home/paul/aa/tmpE';

my $f = File::Util->new();
my @files = $f->list_dir($email_dir,'--files-only');

foreach my $file (@files) {
    my $matched = 0;

    next if ($file !~ /\.eml$/);
    my $f = File::Util->new();
    my $contents = $f->load_file($file);

    my $email = Email::Simple->new($contents);
    my $email_from = $email->header("From");
    my $email_to = $email->header("To");
    my $email_cc = $email->header("CC");

    my (@to, @cc);
    my $from = $email_from;
    @to = split( /,\s*/, $email_to) if defined($email_to);
    @cc = split( /,\s*/, $email_cc) if defined($email_cc);
    my $x = $email->header("X-Uniform-Type-Identifier");

    my $pattern = '\@glossybox\.ca';

    my $from_match = ($from =~ /$pattern/) ? 1 : 0;
    my $to_match = scalar(grep( /$pattern/, @to));
    my $cc_match = scalar(grep( /$pattern/, @cc));
    my $x_match = defined($x) ? 1 : 0;

    if (
        $x_match
        or ( $from_match and ( $to_match or $cc_match ) )
        or ( $to_match and $cc_match )
        or ( $to_match > 1 )
        or ( $cc_match > 1 )
    )
    {
        print "$file\n";
        $matched = 1;
    }

    next;

    print "From -> ${from}\nTo -> @{to}\nCC -> @{cc}\n";
    print "----\n";
    print "From Match -> $from_match\n";
    print "To Match -> $to_match\n";
    print "CC Match -> $cc_match\n";
    print "X Match -> $x_match\n";
    print "====================================================================\n";
}