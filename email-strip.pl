#!/usr/bin/perl -w

use Email::Simple;
use Data::Dumper;
use File::Util;
use Digest::MD5 qw(md5_hex);

my $email_dir = '/home/paul/aa/tmpF';

my $f = File::Util->new();
my @files = $f->list_dir($email_dir,'--files-only');
my $data = {};
@files = @files[0..5];

foreach my $file (@files) {

    next if ($file !~ /\.eml$/);

    my $f = File::Util->new();
    my $contents = $f->load_file($file);
    my $digest = md5_hex($contents);

    $data->{$digest}->{'filename'} = $file;

    my $email = Email::Simple->new($contents);
    $data->{$digest}->{'header'}->{'from'} = $email->header("From");
    $data->{$digest}->{'header'}->{'to'} = $email->header("To");
    $data->{$digest}->{'header'}->{'cc'} = $email->header("CC");
    $data->{$digest}->{'header'}->{'x'} = $email->header("X-Uniform-Type-Identifier");

    $data->{$digest}->{'to'} =  defined($data->{$digest}->{'header'}->{'to'}) ? [split( /,\s*/, $data->{$digest}->{'header'}->{'to'})] : [];
    $data->{$digest}->{'cc'} =  defined($data->{$digest}->{'header'}->{'cc'}) ? [split( /,\s*/, $data->{$digest}->{'header'}->{'cc'})] : [];

    $pattern = '\@glossybox\.ca';
    $data->{$digest}->{'match'}->{'from'} = ($data->{$digest}->{'header'}->{'from'} =~ /$pattern/) ? 1 : 0;
    $data->{$digest}->{'match'}->{'to'} = scalar(grep( /$pattern/, @{$data->{$digest}->{'to'}}));
    $data->{$digest}->{'match'}->{'cc'} = scalar(grep( /$pattern/, @{$data->{$digest}->{'cc'}}));
    $data->{$digest}->{'match'}->{'x'} = defined($data->{$digest}->{'header'}->{'x'}) ? 1 : 0;

    $data->{$digest}->{'match'}->{'have_internal_copy'} = (
        $data->{$digest}->{'match'}->{'x'}
        or ( $data->{$digest}->{'match'}->{'from'} and ( $data->{$digest}->{'match'}->{'to'} or $data->{$digest}->{'match'}->{'cc'} ) )
        or ( $data->{$digest}->{'match'}->{'to'} and $data->{$digest}->{'match'}->{'cc'} )
        or ( $data->{$digest}->{'match'}->{'to'} > 1 )
        or ( $data->{$digest}->{'match'}->{'cc'} > 1 )
    )
        ? 1
        : 0;
}

print "\n";
print Dumper($data);
