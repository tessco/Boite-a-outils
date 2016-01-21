#!/usr/bin/perl
#Le programme du JMD...
#lecture du fichier cordial et d'un fichier de patrons
#important: tout est en iso
#1è argument: le fichier des patrons morphsyntaxique
open(TERMINO, "<$ARGV[0]");
while (my $terme=<TERMINO>) {
	chomp($terme);
	$terme=~s/ +/ /g;
	$terme=~s/\r//g; #troisimè colonne de fichier cordial, marcher avec DET, trouver DET extrait le
	open(CORDIAL, "<$ARGV[1]");
	while ($ligne=<CORDIAL>) {
		chomp ($ligne);
		$ligne=~s/\r//g;
		if ($ligne!~/PCT/){
			my @LISTE=split(/\t/,$ligne);
			#print "PATRON LU $terme: Lingne lue <@LISTE>\n";
			push(@POS,$LISTE[2]);
			push(@TOKEN,$LISTE[0]);

		}
		else {
			#on est arrivé sur un PCT, on va la traiter..
			#print "<@TOKEN>\n";
			#print "<@POS>\n";
			#print "TERME CHERCHE: $terme \n";
			#my $a=<STDIN>;
			#on doit chercher si le "scalaire" $terme qui est dans @POS
			#pour cela on va transformer $terme sous la forme d'une liste
			#pour ensuite faire le match entre la liste TERME et la scalaire POS
			#si "match" on va imprimer...
			my $pos=join(" ",@POS);
			my $token=join(" ",@TOKEN);
			my $cmptdetrouvage=0;
			while ($pos=~/$terme/g){
				$cmptdetrouvage++;
				#print "Youpi, TROUVE $cmptdetrouvage fois \n ";
				#print " En effet: $terme est bien dans $pos!!! \n";
				my $avantlacorrespondance=$`;# pb pb pb 
				#on compte le nb de blanc dans avant..
				#super methode: my $comptagedebalanc=() =$avantlacorrespondance=~/ /g;
				my $comptagedebalancdansterme=0;
				while ($terme=~/ /g){
					$comptagedebalancdansterme++;
				}
				my $comptagedebalanc=0;
				#print " AVANT : $avantlacorrespondance \n";
				while ($avantlacorrespondance=~/ /g) {
					$comptagedebalanc++;	
				}
				for (my $i=$comptagedebalanc; $i<=$comptagedebalanc+$comptagedebalancdansterme; $i++) {
					print $TOKEN [$i]." ";
				}
				print "\n";
			}
			#ceci fini pour la recherche du match
			# on vide les 2 listes de travail avant de recommencer de les remplir
			@POS=();
			@TOKEN=();
		}
	   	# body...
	}
	close(CORDIAL);   
}
close(TERMINO);