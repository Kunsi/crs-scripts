#!/usr/bin/perl -W

BEGIN { push @INC, 'lib'; }

require fusevdv;
require C3TT::Client;
require Data::Dumper;

# Call this script with secret and project slug as parameter!

my ($secret, $project, $tid) = ($ENV{'CRS_SECRET'}, $ENV{'CRS_SLUG'}, shift);

if (!defined($tid)) {
	# print usage
	print STDERR "Too few parameters given!\nUsage:\n\n";
	print STDERR "./script-.... <secret> <project slug> <ticket id>\n\n";
	exit 1;
}

my $tracker = C3TT::Client->new('http://tracker.fem.tu-ilmenau.de/rpc', 'C3TT', $secret);
$tracker->setCurrentProject($project);
my $props = $tracker->getTicketProperties($tid);
print "Properties of Ticket $tid:\n" . Dumper($props). "\n\n";
