#!/usr/bin/perl

my $favs = $ARGV[0];	#these are your genes of interest, i.e. a list of favorite TFs
my $new = $ARGV[1];		#these are the new gene lists; i.e. a new microarray dataset

my @times = localtime(time);
my $time = "$times[2]:$times[1]";
my $year = $times[5] - 100;

open(IN1, "<$favs");
open(IN2, "<$new");
open(OUT, ">overlap.$favs.vs.$new.txt");
open(OUT2,">overlap.lists.$favs.txt");

my $header = "List1\tList2\tList1_length\tList2_length\tOverlap\tList1_alone\tList2_alone\tn";
my $title = "null";
my @hashes;
my $i = 0;
my %fav;
my @favcounts;			#used to hold counts of length of each favorites list
my @favnames;			#used to hold names of favorite gene lists
my $count1;				#used to count lengths of favorties lists

while(<IN1>) {
	chomp;
	my $line = $_;
	if (($line =~ m/^>/) or ($line =~ m/END/)) {
		print "$line\n";
		if ($line =~ m/^>/) {
			$title = substr($line, 1);
			push(@favnames, $title);
		}
		if ($i > 0) {
			push(@hashes, {%fav});
			push(@favcounts, $count1);
		}
		$i++;
		$count1 = 0;
		%fav = {};
	}
	else {
		uc($line);
		my ($gene) = $line =~ m/(AT[\dMC]G\d{5})/;
		$fav{$gene} = $title;
		$count1++;
	}
}

print OUT "$header\n";

#print "$hashes[0]{AT4G24570}\n";	

my $list = "null";		#variable to hold the name of the input list
my $x = 0;				#variable used to loop through the @hashes
my $y = 0;
my $count2 = 0;			#used to count length of each input list
my $print;				#used to hold string for printing
my $length = @hashes;
my %input = {};

while(<IN2>) {
	chomp;
	my $line = $_;
	if (($line =~ m/^>/) or ($line =~ m/END/)) {
		if ($y > 0 ) {
			$print = "$list";
			while ($x < $length) {
				my $match = 0;
				print OUT2 ">@favnames[$x] vs $list\n";
				foreach my $key (keys %input) {
						if ( exists($hashes[$x]{$key})) {
						$match++;
						print OUT2 "$key\n";
					}
				}
				my $n = 27416 - $favcounts[$x];
				my $list1 = $count2 - $match;
				my $list2 = $favcounts[$x] - $match;
				$print = join("\t",$print,@favnames[$x],$count2,$favcounts[$x],$match,$list1, $list2,$n);
				print OUT "$print\n";
				$x++;
				$print = "$list";
			}
			#print OUT "$print\n";			
		}
		$list = substr($line,1);
		%input = {};
		$count2 = 0;
		$x = 0;
		$y++;
	}
	else{
		uc($line);
		my ($gene) = $line =~ m/(AT[\dMC]G\d{5})/;
		$input{$gene} = $list;
		$count2++;
	}
}

close IN1;
close IN2;
close OUT;
close OUT2;
		
		
		