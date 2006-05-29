#! /usr/bin/perl -w

# find projections of LEDs in images 
# it spreads the job to all specified processors/machines
# It requires:
# - matlab
# - configdata.m
# - expname
#
# script is useful if more machines or more processors
# are available.
# automatic ssh authentication is necessary, see
# http://www.cs.umd.edu/~arun/misc/ssh.html
# http://www.cvm.uiuc.edu/~ms-drake/linux/ssh_nopw.html

# $Author: svoboda $
# $Revision: 2.0 $
# $Id: im2pmultiproc.pl,v 2.0 2003/06/19 12:06:52 svoboda Exp $
# $State: Exp $

use Env;
# use XML::Simple;
# use Data::Dumper;

# name of the m-file template
$mfile="im2imstat";
$mvariable="CamsIds";
$donefile=".done";

# not yet ready
# $config = XMLin('multiprocAtlantic.xml');
# print Dumper($config);
# @processes = @$config->

# load the info about local machines and parallel processes
use atlantic;

# just a debug cycle   
foreach $process (@processes) {
	print "$process->{'compname'} \n";
	foreach $camId (@{$process->{'camIds'}}) {
		print "$camId \n";
	}
}
  
# create temporary m-files with using the template m-file
# store their names for delete at the very end
# each process must have its own temporary m-file

# compose the names and commands
foreach $process (@processes) {
	$idfile="";
	$str4cmd="";
	foreach $camId (@{$process->{'camIds'}}) {
		$idfile = "$idfile$camId";
		$str4cmd = "$str4cmd $camId";
	}
	$process->{'scriptName'} = "$ENV{'PWD'}/$mfile${idfile}.m";
	$process->{'donefile'} = "$ENV{'PWD'}/${donefile}${idfile}";
	$process->{'catcmd'} = "echo \"${mvariable} = [${str4cmd}]; donefile='$process->{'donefile'}'; addpath $ENV{'PWD'}; addpath $ENV{'PWD'}/../Cfg; \" | cat - ${mfile}.m > $process->{'scriptName'}";
	$process->{'mcmd'} = "ssh $process->{'compname'} /usr/sepp/bin/matlab -nosplash -nojvm < $process->{'scriptName'} > $process->{'scriptName'}.out &";
}

print "*************************** \n";

# create the auxiliary scripts
foreach $process (@processes) {
	system($process->{'catcmd'});
}

# run the parallel matlabs
foreach $process (@processes) {
	system($process->{'mcmd'});
}

# wait until all processing is done
print "Image processing in progress. Plase be patient \n";
do {
	sleep 10;
	@donefiles = glob("${donefile}*");
} while (@donefiles < @processes);

# copy the data files to a coomon disc space yet to be implemented

# final cleaning of the auxiliary files
# foreach $process (@processes) {
# 	system("rm -f $process->{'donefile'}");
# 	system("rm -f $process->{'scriptName'}");
# 	system("rm -f $process->{'scriptName'}.out");
# }
# system("rm -f *.out");

