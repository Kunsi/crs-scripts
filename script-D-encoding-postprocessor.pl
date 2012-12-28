#!/usr/bin/perl -W

#require fusevdv;
require C3TT::Client;
require boolean;

# Call this script with secret and project slug as parameter!

my ($secret, $project) = (shift, shift);

if (!defined($project)) {
	# print usage
	print STDERR "Too few parameters given!\nUsage:\n\n";
	print STDERR "./script-.... <secret> <project slug>\n\n";
	exit 1;
}

my $tracker = C3TT::Client->new('http://tracker.29c3.fem-net.de/rpc', 'C3TT', $secret);
$tracker->setCurrentProject($project);
my $ticket = $tracker->assignNextUnassignedForState('postprocessing');

if (!defined($ticket) || ref($ticket) eq 'boolean' || $ticket->{id} <= 0) {
	print "currently no tickets for postprocessing\n";
} else {
	my $tid = $ticket->{id};
	print "postprocessing ticket # $tid\n";

	# fetch metadata

	my $props = $tracker->getTicketProperties($tid);
	my $basename = $props->{'EncodingProfile.Basename'};
	my $slug = '';
	if ($basename =~ /_([^_]+$)/) {
		$slug = $1;
	}
	my $srcfile = $props->{'Processing.Path.Output'} . "/" . $props->{'Fahrplan.ID'} . "-" . $slug . "." . $props->{'EncodingProfile.Extension'};
	if (! -f $srcfile) {
		$srcfile = $props->{'Processing.Path.Output'} . "/" . $props->{'Encoding.Basename'} . "." . $props->{'EncodingProfile.Extension'};
		if (! -f $srcfile) {
			$tracker->setTicketFailed($tid, 'Encoding postprocessor: srcfile '.$srcfile.' not found!');
			exit 1;
		}
	}
	my $return = system ("scp -i /root/.ssh/id_rsa $srcfile ecki\@chief-mirror.fem-net.de:~/release/ ");

	print "$srcfile \n$return\n";

	# write metadata back to tracker (?)

	if ($return eq '0') {
		$tracker->setTicketDone($tid, 'Encoding postprocessor: copy to chief-mirror completed.');
	} else {
		$tracker->setTicketFailed($tid, 'Encoding postprocessor: scp to chief-mirror failed');
	}
}


