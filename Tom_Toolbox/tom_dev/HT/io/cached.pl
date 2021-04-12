#!/usr/bin/perl -w


use strict;
use warnings;

use IO::Socket;
use IO::Handle;
use Errno;

use Time::HiRes qw(gettimeofday);

#use Digest::MD5;



if (scalar(@ARGV) == 1 && ($ARGV[0] eq '-h' || $ARGV[0] eq '--help')) {
    print STDOUT "$0 [PORT]\n" .
                 "Opens tcp-socket at [PORT].\n" .
                 "Clients can send commands line per line.\nOptions are separated by \\t; commands terminated by \\n.\n" .
                 "supported commands: \n" .
                 "readf\tFILENAME\t[-repeat\tNREPEAT[xNDELAY]]\n".
                 "    Reads the file FILENAME (to put the file into the file cache of the OS).\n" .
                 "    This reading is repeated NREPEAT times, with NDELAY seconds pause in between.\n" .
                 "    The option -repeat can be ommited. The order of FILENAME and the options are arbitrary. \n" .
                 "    Send a second command, with the (exactly) same filename to replace the -repeat options\n".
                 "    e.g. \"readf\tfilename\t-repeat\t10x60\" reads the file filename 10 times every 60 seconds.\n" .
                 "         \"readf\tfilename\t-repeat\t0\" causes to cancel that job before its finished.\n" .
                 "    Caution when using relative pathnames and the working directory from which the deamon were started.\n" .
                 "clear\n" .
                 "    Removes all files from the joblist which were inserted by readf.\n" .
                 "exit | quit\n" .
                 "    Exits daemon.\n";
    exit(0);
}

my $measuretime = 1;
my $measuretime_start;
my $measuretime_duration;




my $serverport = shift @ARGV;
(defined($serverport) && $serverport =~ /^[0-9]+$/)  or $serverport=21332;

print STDERR "Start $0 at port $serverport....\n";

# Open socket.
my $sock = new IO::Socket::INET(LocalHost => 'localhost',
                                  LocalPort => $serverport,
                                  Proto => 'tcp',
                                  Listen => 1,
                                  Reuse => 1,
                                 );

die "Could not create socket: $!\n" unless $sock;

my %csocks;
my ($csock);
my $checklist_r;
my $checklist_w;
my $checklist_e;

my $line;
my $FNULL;

open($FNULL, "> /dev/null");

my %files;

my $filename;


my $cnt = 0;
my $timeout;
my $nexttimeout = undef;
my ($nfound,$timeleft);

do {
    $timeout = $nexttimeout;

    $cnt++;
    print(STDERR "===========================\n$cnt: SELECT (". keys(%csocks)." clients, " . keys(%files) . " files). Timeout in " . (defined($timeout) ? $timeout : 'UNDEF') . " sec.\n");

    # Create list with filehandles to check...
    $checklist_r = $checklist_w = '';
    vec($checklist_r, fileno($sock), 1) = 1;
    for $csock (keys %csocks) {
        vec($checklist_r, $csock, 1) = 1;
    }
    #$checklist_w = $checklist_r;
    $checklist_e = $checklist_r | $checklist_w;

    # SELECT: wait until there is some data available.
    ($nfound,$timeleft) = select($checklist_r, $checklist_w, $checklist_e, $timeout);
    $timeleft = (defined($timeout) && defined($timeleft)) ? $timeout-$timeleft : 0;

    my $action_from_socket = 0;
    if ($nfound < 0 ) {
        # ERROR!
        if ( $! == Errno::EINTR ) {
            print(STDERR "SELECT: got signal $!.\n");
        } else {
            die("SELECT: $!\n");
        }
    } elsif ($nfound == 0) {
        # Simple timeout.
        print(STDERR "SELECT: timeout.\n");
    } else {
        # There is something to read/write.
        print(STDERR "SELECT: $nfound handles active (slept for " . (defined($timeout) ? $timeleft : "UNDEF") . " sec.).\n");
        if (vec($checklist_r, fileno($sock), 1)) {
            # The server socket has a new connection available.
            $csock = $sock->accept();
            delete $csocks{$csock->fileno};
            $csocks{$csock->fileno}{'socket'} = $csock;
            print(STDERR "ACCEPT: new client #" . $csock->fileno . " connected...\n");
            $action_from_socket = 1;
        }

        # Check the client sockets...
        for $csock (keys %csocks) {
            if (vec($checklist_r, $csock, 1)) {
                $action_from_socket = 1;
                print(STDERR "RECV FROM #$csock: ");
                if (!defined($line = readline($csocks{$csock}{'socket'}))) {
                    # Nothing read: Connection to client is closed.
                    print(STDERR "close connection.\n");
                    $csocks{$csock}{'socket'}->close();
                    delete($csocks{$csock});
                } else {
                    # Parse the recived command.
                    $line =~ s/\r?\n$//; # Remove trailing newline character.
                    print(STDERR "read line \"$line\".\n");
                    if ($line =~ /^$/) {
                        # Do nothing
                    } elsif ($line =~ /^exit/ || $line =~ /^quit/) {
                        if ($line =~ /^((exit)|(quit))(.+)$/) {
                            print(STDERR "    $csock:PARSE CMD \"$line\": unknown trailing line '$4' for command '$1': IGNORE.\n");
                        }
                        print STDERR "bye bye\n";
                        exit(0);
                    } elsif ($line =~ /^clear/) {
                        if ($line =~ /^(clear)(.+)$/) {
                            print(STDERR "    $csock:PARSE CMD \"$line\": unknown trailing line '$2' for command '$1': IGNORE.\n");
                        }
                        print(STDERR "    $csock: clear command removes all " . scalar(keys %files) . " entries from list.\n");
                        %files = ();
                    } elsif ($line =~ /^readf([^a-zA-Z\/\\\-0-9])/) {
                        # Command readf...
                        my $sepchar = $1;
                        my (@cmd) = split(/[$sepchar]+/, $line);
                        #@cmd = grep(!/^$/, @cmd); # Remove empty entities.
                        $filename = undef;
                        my $delaydefault = '60';
                        my $delay = $delaydefault;
                        my $nrepeat = '1';
                        for (my($i)=1; $i<=$#cmd; $i++) {
                            if ($cmd[$i] eq '-repeat') {
                                $i++;
                                if ($i > $#cmd || !($cmd[$i] =~ /^([0-9]+)((.)([0-9]+))?$/)) {
                                    print(STDERR "    $csock:PARSE CMD \"$line\": option -repeat has parameter nrepeat[#sdelay].\n");
                                } else {
                                    $nrepeat = $1;
                                    $delay = defined($4) ? $4 : '1';
                                }
                            } elsif (!defined($filename)) {
                                $filename = $cmd[$i];
                            } else {
                                print(STDERR "    $csock:PARSE CMD \"$line\": unknown option $cmd[$i].\n");
                            }
                        }
                        if (!defined($filename)) {
                            print(STDERR "    $csock:PARSE CMD \"$line\": readfile needs filename as parameter.\n");
                        } elsif (!(-r $filename && -f $filename)) {
                            print(STDERR "    $csock:PARSE CMD \"$line\": file $filename is not readable or does not exist.\n");
                        } else {
                            if ($nrepeat < 1) {
                                delete $files{$filename};
                            } else {
                                $files{$filename} = { 'timeout' => $timeleft,
                                                    'nrepeat' => $nrepeat,
                                                    'delay' => $delay };
                            }
                        }
                    } else {
                        print(STDERR "    $csock: unknown command! IGNORE\n");
                    }
                }
            }
            if (vec($checklist_w, $csock, 1)) {
                $action_from_socket = 1;
                # Writing is not expected.
                print(STDERR "$csock:ready for writing (NOT EXPECTED!)...\n");
            }
            if (vec($checklist_e, $csock, 1)) {
                $action_from_socket = 1;
                # Errors are not checked.
                print(STDERR "$csock:error... (NOT EXPECTED!)\n");
            }
        }
    }


    # Check the list of files, if the have to be reread!
    $nexttimeout = undef;
    my (@files_keys) = sort { $files{$a}{'timeout' } <=> $files{$b}{'timeout'} } keys %files;
    for $filename (@files_keys) {
        print(STDERR "FILE $filename: nrep=$files{$filename}{'nrepeat'}; delay=$files{$filename}{'delay'}; tleft=$files{$filename}{'timeout'}-$timeleft; \n");
        if ((($files{$filename}{'timeout'} -= $timeleft) <= 0) && !$action_from_socket) {
            # Commands from the sockets have a higher priority. so that if there are new commands available,
            # first these are interpreted before, something commands are executed...
            if (($files{$filename}{'nrepeat'} -= 1) >= 0) {

                $files{$filename}{'timeout'} += $files{$filename}{'delay'};

                if (open(FILE, $filename)) {
                    if ($measuretime) {
                        $measuretime_start = gettimeofday();
                    }

                    while (<FILE>) { ; } # READ THE FILE

                    #binmode(FILE);
                    #print(STDERR "     MD5: " . Digest::MD5->new->addfile(*FILE)->hexdigest . "\n");
                    close(FILE);
                    if ($measuretime) {
                        $measuretime_duration = gettimeofday() - $measuretime_start;
                        print STDERR "    reading took $measuretime_duration seconds. Adjust left time.\n";
                        $timeleft += $measuretime_duration;
                    }


                } else {
                    print(STDERR "     could not open (remove from list)\n");
                    delete $files{$filename};
                    next;
                }
                $action_from_socket = 1; # Read only one file.
            }
            if ($files{$filename}{'nrepeat'} <= 0) {
                print(STDERR "    finished! remove from list\n");
                delete $files{$filename};
                next;
            }
        }
        print(STDERR "     $filename: nrep=$files{$filename}{'nrepeat'}; delay=$files{$filename}{'delay'}; tleft=$files{$filename}{'timeout'}; \n");
        if (!defined($nexttimeout) || $nexttimeout > $files{$filename}{'timeout'}) {
            $nexttimeout = $files{$filename}{'timeout'};
        }
    }
    (!defined($nexttimeout) || $nexttimeout >= 0) or $nexttimeout = 0;

    #$cnt < 30 or die "max repeat";
} while (1);


