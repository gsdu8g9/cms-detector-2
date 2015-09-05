use strict;
use Net::DNS;
my $resolver = Net::DNS::Resolver->new();
use Data::Dumper;
use List::Util qw/max/;

sub getNSList{
  my $host = shift;
  my @parts = split /\./, $host;
  my @sockets;
  my $sel = IO::Select->new();
  for(0 .. $#parts-1){
    my $tryingHost = join '.', @parts[ $_ .. $#parts];
    push @socket, $resolver->bgsend($tryingHost,"NS");
  }
  for my $s(@sockets){
    
  }
}

getNSList("www.mail.ru");
