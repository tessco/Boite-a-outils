#/usr/bin/perl
open(FILE,"$ARGV[0]");
#--------------------------------------------
# le patron cherché ici est du type NOM ADJ";
# le modifier pour extraire NOM PREP NOM
#--------------------------------------------
my @lignes=<FILE>;
close(FILE);
while (@lignes) {
    my $ligne=shift(@lignes);
	#on lit une premiere ligne et on le vire dans la liste
    chomp $ligne;
    my $sequence="";
    my $longueur=0;
    if ( $ligne =~ /^([^\t]+)\t[^\t]+\tNC.*/){
	#on prend le premier element de la ligne qui contient un nom
	 my $forme=$1;
	 $sequence.=$forme;
	 $longueur=1;
	 my $nextligne=$lignes[0];
	 if ( $nextligne =~ /^([^\t]+)\t[^\t]+\tPREP.*/){
	     my $forme=$1;
	     $sequence.=" ".$forme;
	     $longueur=2;
		 my $nextligne2=$lignes[1];
		 if ( $nextligne2 =~ /^([^\t]+)\t[^\t]+\tNC.*/){
	        my $forme=$1;
	        $sequence.=" ".$forme;
	        $longueur=3;
			}
	 }
    }
    if ($longueur == 3) {
	#on extrait que des formes positives qui a une longueur en 2.
	print $sequence,"\n";
    }
}