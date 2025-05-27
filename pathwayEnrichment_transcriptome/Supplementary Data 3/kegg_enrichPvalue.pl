#!usr/bin/perl -w
use strict;
die "Usage: perl $0 <all keg of the organism> <diff. expression keg> \n" unless @ARGV==2;
open KG, "$ARGV[0]" or die "$! $ARGV[0]\n";
open IN, "$ARGV[1]" or die "$! $ARGV[1]\n";
my $k=`grep "^D" $ARGV[1]|sort|uniq|grep -c ""`;
my $mPLUSn=`grep "^D" $ARGV[0]|sort|uniq|grep -c ""`; #print"$k\n";
my($A, $B, $C, %As, %Bs, %Cs, %diffAs, %diffBs, %diffCs);
while(<KG>){
	chomp;
        if(/^A\d+/){
                $A=$_;$As{$A}=0;
        }elsif(/^B\s+(.+)$/){
                $B=$1;$Bs{$B}=0;
        }elsif(/^C\s+(.+)$/){
                $C=$1;  $Cs{$C}=0;
        }elsif(/^D\s+/){
                my @a=split /\s+/;
                $As{$A}++;$Bs{$B}++;$Cs{$C}++;
        }
}
close KG;
open OUT, ">$ARGV[1].keggEnrichPvalue.R" or die "$!\n";
print OUT "df <- file\( \"$ARGV[1].keggEnrichPvalue\", \"w\" \)\n";
while(<IN>){
	chomp;
        if(/^A\d+/){
                $A=$_;$diffAs{$A}=0;
        }elsif(/^B\s+(.+)$/){
                $B=$1;$diffBs{$B}=0;
        }elsif(/^C\s+(.+)$/){
                $C=$1;  $diffCs{$C}=0;
        }elsif(/^D\s+/){
                my @a=split /\s+/;
                $diffAs{$A}++;$diffBs{$B}++;$diffCs{$C}++;
        }
}
close IN;
foreach my $key(keys %diffCs){
	my $x=$k;
	$x=$Cs{$key} if($Cs{$key} < $k);
	my $n=$mPLUSn-$Cs{$key};
	print OUT "for (i in 1\:$x) {\nx=paste(\"$key\", i, dhyper(i, $Cs{$key}, $n, $k,log = FALSE ), sep=\"\\t\" )\nwriteLines( x, df )\n}\n";
}
print OUT "close (df)\n";
close IN;
close OUT;
