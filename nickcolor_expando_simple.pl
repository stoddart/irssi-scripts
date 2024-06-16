use strict;
use warnings;
use Irssi qw(signal_add_first signal_add);
use Irssi::Irc;

our $VERSION = "0.1";
our %IRSSI = (
    authors     => 'Thorsten Leemhuis',
    contact     => 'fedora@leemhuis.info',
    name        => 'nickcolor_expando_simple',
    description => 'Provides a $nickcolor expando, simple (e.g. only for 16 color terminals)',
    license     => 'GNU General Public License',
);

# Customize your preferred colors here
my @colors = (2, 4, 6, 8, 10, 12, 14);  # Example custom colors

my %cache = ();

sub get_color {
    my ($nick) = @_;
    return $cache{$nick} if exists $cache{$nick};
    my $sum;
    $sum += ord $_ for split //, lc $nick;
    $cache{$nick} = $colors[$sum % @colors];
    return $cache{$nick};
}

signal_add_first 'print text' => sub {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};
    return unless $server;
    my $channel = $server->channel_find($dest->{target});
    return unless $channel;
    my $nick = $channel->nick_find($stripped);
    return unless $nick;
    my $color = get_color($nick->{nick});
    $$stripped =~ s/\Q$nick->{nick}\E/\x03$color$nick->{nick}\x03/;
};

