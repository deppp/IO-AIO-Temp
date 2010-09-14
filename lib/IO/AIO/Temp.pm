package IO::AIO::Temp;
use common::sense;

=head1 NAME

IO::AIO::Temp - Create tempfile asynchronously

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use POSIX;
use Fcntl;

use File::Spec;
use Guard;

use IO::AIO;

require Exporter;

our @ISA = 'Exporter';
our @EXPORT = qw(
    aio_tempfile
);

our $VERSION = '0.01';

# This is a list of characters that can be used in random filenames

my @CHARS = (qw/ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
                 a b c d e f g h i j k l m n o p q r s t u v w x y z
                 0 1 2 3 4 5 6 7 8 9 _
               /);

# Maximum number of tries to make a temp file before failing
use constant MAX_TRIES => 1000;

# Minimum number of X characters that should be in a template
use constant MINX => 4;

# Default template when no template supplied
use constant TEMPXXX => 'X' x 10;

# Constants for the security level
use constant STANDARD => 0;
use constant MEDIUM   => 1;
use constant HIGH     => 2;

my $MODE = 0777;
my $OPENFLAGS = O_CREAT | O_EXCL | O_RDWR;

=head2 aio_tempfile

=cut

sub aio_tempfile (@) {
    my $cb = pop;
    my ($template) = @_;
    
    $template ||= TEMPXXX;
    $template = File::Spec->catfile(File::Spec->tmpdir, $template);
    
    my $end = ( $] >= 5.006 ? "\\z" : "\\Z" );
    $template =~ s/X(?=X*$end)/$CHARS[ int( rand( @CHARS ) ) ]/ge;
    
    aio_open $template, $OPENFLAGS, $MODE, sub {
        my $fh = shift ||
            $cb->(undef, $!);
        
        my $g = guard {
            aio_close $fh, sub {
                close $fh;
                aio_unlink $template, sub {};
            };
        };
        
        $cb->($fh, $template, $g);
    };
}

=head1 AUTHOR

Mikhail Maluyk <mikhail.maluyk@gmail.com> 2010

=cut

1;
