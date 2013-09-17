#!/usr/bin/perl

package BedtimeDB;

use Exporter;
use DBI;
use strict;

our @ISA = qw( Exporter );
our @EXPORT_OK = qw( dbconn, get_val );

sub dbconn {
   open (CONF,'/etc/bedtime.conf') or die "Cannot open configuration file - $!\n";
   # Read the conf file into an array and filter out all lines consisting of just white space and comments
   my @conf = <CONF>; close CONF;
   @conf = grep (!/^\s*$/,@conf);
   @conf = grep (!/^#/,@conf);

   # Read the remaining lines into a hash split on =
   my %vals;
   foreach (@conf) {
      chomp;
      my @pair = split(/\s*=\s*/);
      $vals{$pair[0]}=$pair[1];
   }

   # Collect the credentials and connect to the database
   my $user = $vals{'dbuser'};
   my $pass = $vals{'dbpass'};
   my $dbis = "DBI:mysql:".$vals{'dbname'}.":".$vals{'dbhost'};
   DBI->connect($dbis,$user,$pass) or die "Cannot connect to database $dbis with user $user - $!\n";
}

sub get_val {
   my $var = shift;
   my $dbh = &dbconn;
   my $sth = $dbh->prepare("select value from settings where variable='$var';") or die "Cannot prepare query: $dbh->errstr";
   my $res = $sth->execute or die "Cannot execute query: $sth->errstr";
   $sth->fetchrow_array();
}

1;
