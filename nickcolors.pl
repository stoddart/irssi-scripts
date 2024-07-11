use strict;
use warnings;
use Irssi;
use Irssi::Irc;

our $VERSION = '2.0';
our %IRSSI = (
    authors     => 'Timo Sirainen, Ian Peters, David Leadbeater, Thorsten Leemhuis',
    contact     => 'tss@iki.fi, itp@gnu.org, dgl@dgl.cx, fedora@leemhuis.info',
    name        => 'nickcolor',
    description => 'assign a different color for each nick',
    license     => 'GPLv2 or later',
    url         => 'https://scripts.irssi.org/',
    changed     => '2019-01-20'
);

my %saved_colors;
my @colors = (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
my $debug = 0;

sub load_colors {
    open my $fh, '<', Irssi::get_irssi_dir() . '/nickcolor' or return;
    while (<$fh>) {
        chomp;
        my ($nick, $color) = split ':';
        $saved_colors{$nick} = $color;
    }
    close $fh;
}

sub save_colors {
    open my $fh, '>', Irssi::get_irssi_dir() . '/nickcolor';
    foreach my $nick (keys %saved_colors) {
        print $fh "$nick:$saved_colors{$nick}\n";
    }
    close $fh;
}

sub get_color {
    my $nick = shift;
    return $saved_colors{$nick} if exists $saved_colors{$nick};

    my $sum;
    $sum += ord $_ for split //, $nick;
    my $color = $colors[$sum % @colors];
    $saved_colors{$nick} = $color;
    save_colors();
    return $color;
}

sub sig_public {
    my ($server, $msg, $nick, $address, $target) = @_;
    my $color = get_color($nick);
    $msg =~ s/\Q$nick\E/\%K$color$nick\%n/;
    Irssi::signal_continue($server, $msg, $nick, $address, $target);
}

Irssi::signal_add('message public', 'sig_public');
load_colors();
