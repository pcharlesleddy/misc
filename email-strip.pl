#!/usr/bin/perl -w

use Email::Simple;
use Data::Dumper;
use File::Util;
use Digest::MD5 qw(md5_hex);

my $email_dir = '/home/paul/aa/tmpF';

my $f = File::Util->new();
my @files = $f->list_dir($email_dir,'--files-only');
my $data = {};
@files = @files[ 0 .. 200 ];

foreach my $file (@files) {

    next if ($file !~ /\.eml$/);
    my $f = File::Util->new();
    my $contents = $f->load_file($file);
    my $digest = md5_hex($contents);

    my $email = Email::Simple->new($contents);
    $data->{$digest}->{'from'} = $email->header("From");
    $data->{$digest}->{'to'} = $email->header("To");
    $data->{$digest}->{'cc'} = $email->header("CC");
    $data->{$digest}->{'x'} = $email->header("X-Uniform-Type-Identifier");

    $data->{$digest}->{'to'} =  defined($data->{$digest}->{'to'}) ? [split( /,\s*/, $data->{$digest}->{'to'})] : [];
    $data->{$digest}->{'cc'} =  defined($data->{$digest}->{'cc'}) ? [split( /,\s*/, $data->{$digest}->{'cc'})] : [];

    $pattern = '\@glossybox\.ca';
    $data->{$digest}->{'match'}->{'from'} = ($data->{$digest}->{'from'} =~ /$pattern/) ? 1 : 0;
    $data->{$digest}->{'match'}->{'to'} = scalar(grep( /$pattern/, @{$data->{$digest}->{'to'}}));
    $data->{$digest}->{'match'}->{'cc'} = scalar(grep( /$pattern/, @{$data->{$digest}->{'cc'}}));
    $data->{$digest}->{'match'}->{'x'} = defined($data->{$digest}->{'x'}) ? 1 : 0;

    $data->{$digest}->{'match'}->{'have_internal_copy'} = (
        $data->{$digest}->{'match'}->{'x'}
        or ( $data->{$digest}->{'match'}->{'from'} and ( $data->{$digest}->{'match'}->{'to'} or $data->{$digest}->{'match'}->{'cc'} ) )
        or ( $data->{$digest}->{'match'}->{'to'} and $data->{$digest}->{'match'}->{'cc'} )
        or ( $data->{$digest}->{'match'}->{'to'} > 1 )
        or ( $data->{$digest}->{'match'}->{'cc'} > 1 )
    )
        ? 1
        : 0
}

print "\n";
print Dumper($data);