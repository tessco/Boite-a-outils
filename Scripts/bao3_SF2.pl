#/usr/bin/perl
open(FILE,"$ARGV[0]");
#--------------------------------------------------
# le patron cherché ici est du type "NOM PREP NOM";
#--------------------------------------------------
my @lignes=<FILE>;
close(FILE);
while (@lignes) {
    my $ligne=shift(@lignes);
    chomp $ligne;
    my $sequence="";
    my $longueur=0;
    if ( $ligne =~ /^([^\t]+)\t[^\t]+\tNC.*/) {
	 my $forme=$1;
	 $sequence.=$forme;
	 $longueur=1;
	 my $nextligne=$lignes[0];
	 if ( $nextligne =~ /^([^\t]+)\t[^\t]+\tPREP.*/) {
	     my $forme=$1;
	     $sequence.=" ".$forme;
	     $longueur=2;
         my $nextnextlinge=$linges[1];
         if ($nextnextlinge=~ /^([^\t]+)\t[^\t]+\tNC.*/) {
             my $forme=$1;
             $sequence.=" ".$forme;
             $longueur=3;
 	     	 }
     }
    }   
    if ($longueur == 3) {
    print $sequence, "\n";
    }
}