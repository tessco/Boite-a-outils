#!/usr/bin/perl
#programme d'extraction et de filtrage d'un fil RSS pour ne garder le contenu textuel des balises 
#title et description
#pour lancer: perl toto.pl toto2.xml
#$encodage='file -i $ARGV[0]';#sous unix
<<DOC; 
<file>
	<name>nom du fichier</name><date>date d'édition</date>
	<item><titre>Titre<description>Description</description></item>...
</file>
DOC

use strict; # http://blog.csdn.net/helpxs/article/details/7001059
use HTML::Entities;
use Unicode::String qw(utf8);


my $rep="$ARGV[0]"; #on s'assure que le nom du répertoire ne se termine pas par un "/"ml
# on s'assure que le nom du répertoire ne se termine pas par un "/"
$rep=~ s/[\/]$//; #on initialise une variable contenant le flux de sortie       

# ----------- Création des répertoires de sortie -----------
my $sortie="Sorties/";
if (! -e $sortie){	
	mkdir($sortie) or die ("Erreur de la création : $!");
}

$sortie="Sorties/Bao_1/"; 
if (! -e $sortie){
	mkdir($sortie) or die ("Erreur de la création : $!");
}

# initialiser des variables qui contient les flux de sorties
my %dicoTitres=(); #vider
my %dicoDescrip=(); #si le titre ou la description ne se trouvent pas déjà dans les tables, alors on les extrait. 
my %dicoRub=();

# ----------------------------------------------------------
&repererubriques($rep); 
# recurse
my @listeRubriques = keys(%dicoRub);    
 # mettre les cles de dico_rubriques dans une liste
foreach my $rub (@listeRubriques) { # pour chaque element dans la liste rubrique
    #print $rub,"\n";
    my $output1 = $sortie.$rub.".xml"; #sortie des fichiers xml
    my $output2 = $sortie.$rub.".txt"; #sortie des fichiers txt
    if (!open (out_XML,">:encoding(utf-8)", $output1)) { die "Erreur d'ouvrir file $output1"};   
    if (!open (out_TXT,">:encoding(utf-8)", $output2)) { die "Erreur d'ouvrir file $output2"};   
    print out_XML "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
    print out_XML "<EXTRACTION>\n";
    close(out_XML);
    close(out_TXT);
}

# --Parcours de l'arborescence et traitement des fichiers xml--

sub parcoursarborescencefichiers {
    my $path = shift(@_);
    opendir(DIR, $path) or die "Erreur d'ouvrir $!\n";
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
	next if $file =~ /^\.\.?$/;
	$file = $path."/".$file;
	if (-d $file) {
	    &parcoursarborescencefichiers($file);	
	}
	if (-f $file) { # -f 如果 $file是正常文件
	    if (($file=~/\.xml$/) && ($file!~/\/fil.+\.xml$/)) { 
	    # On commence ensuite le traitement si le fichier trouvé se termine par ".xml", et s'il ne commence pas par "fil" 
	    # autres fichiers faisant partie de l'arborescence, qui ne nous intéressent pas
		open(FILE, $file);
		print "Traitement de : $file\n";
		my $texte="";
		while (my $ligne=<FILE>) {
		    $ligne =~ s/\n//g;
		    $ligne =~ s/\r//g;
		    $texte .= $ligne; 
		}# suppression des sauts de ligne
		close(FILE);
		$texte=~s/> *</></g;# supprimer les espaces entre les balises
		# recherche de l'encodage
		$texte=~/encoding ?= ?[\'\"]([^\'\"]+)[\'\"]/i;
		my $encodage=$1;
		print "ENCODAGE : $encodage\n";
		# si l'encodage n'est pas vide, faire le traitement
		if ($encodage ne "") {
		    my $texteXML="<file>\n";
			$texteXML.="<name>$file</name><date>2014</date>";
		    $texteXML.="<items>\n";
		    my $texteBRUT="";
		    open(FILE,"<:encoding($encodage)", $file);
		    $texte="";
			# suppression des sauts de ligne
		    while (my $ligne=<FILE>) {
			$ligne =~ s/\n//g;
			$ligne =~ s/\r//g;
			$texte .= $ligne;
		    }
		    close(FILE);
			
			$texte=~s/> *</></g;# supprimer les espaces entre les balises
		    # recherche de la rubrique
		    $texte=~/(<channel>|<atom.+>)<title>([^<]+)<\/title>/; # pour "channel" et "atom" on utilise "()" au lieu de "[]"
		    my $rub=$1;
		    $rub=~s/Le ?Monde.fr ?://g;
			$rub=~s/ ?: ?Toute l'actualité sur Le Monde.fr.//g;
			$rub=~s/\x{E9}/e/g;#é   
			$rub=~s/\x{E8}/e/g;#è
			$rub=~s/\x{E0}/a/g;#à 
			$rub=~s/\x{C9}/e/g;#É
			$rub=~s/\x{7E}/e/g;#~
			$rub=~s/\x{2E}/e/g;#.
			$rub=~s/\x{3A}/e/g;#:
		    $rub=~s/ //g;
		    $rub=uc($rub); # en majuscules
		    $rub=~s/-LEMONDE.FR//g;
			$rub=~s/:TOUTEL'ACTUALITESURLEMONDE.FR.//g;
		    print "RUBRIQUE : $rub\n";
		    #----------------------------------------
		    my $output1=$sortie.$rub.".xml";
		    my $output2=$sortie.$rub.".txt";
		    
		    if (!open (out_XML,">>:encoding(utf-8)", $output1)) { die "Erreur d'ouvrir file $output1"};
		    if (!open (out_TXT,">>:encoding(utf-8)", $output2)) { die "Erreur d'ouvrir file $output2"};
		 
			#--Stockage des titres et descriptions dans des variables--#
		
		    while ($texte =~ /<item><title>(.+?)<\/title>.+?<description>(.+?)<\/description>/g) {
				my $titre=$1;
				my $descrip=$2;

				
				if (uc($encodage) ne "UTF-8"){ # ou cas où l'encodage n'est pas utf8, réencoder via le module Unicode::String
				   utf8($titre);
				   utf8($descrip);
				}
				
				$titre = HTML::Entities::decode($titre);# traiter les caractère accentuées avec HTML::Entities
				$descrip = HTML::Entities::decode($descrip);
				$titre = &nettoyage($titre);
				$descrip = &nettoyage($descrip);

				
				if (!(exists $dicoTitres{$titre}) and (!(exists $dicoDescrip{$descrip}))){# verifierles doublons	 
					$dicoTitres{$titre}++;
					$dicoDescrip{$descrip}++;
					$texteXML.="<item>\n<title>$titre</title>\n<description>$descrip</description>\n</item>\n";  
					print out_TXT "$titre\n";
					print out_TXT "$descrip\n";
				}
		    }
		    $texteXML.="</items>\n</file>\n";
		    
		    print out_XML $texteXML;
		    print out_TXT $texteBRUT;

		    close(out_XML);
		    close(out_TXT);
		}
		else {
		    print "$file ==> encodage non détecté \n";
		}
	    }
	}
	}
}
#Attention: il faudra ajouter ici un processus permettant de ne pas écrire en sortie 
# 2 fois les mêmes contenus...
# suppression des éléments non pertinents, remplacement des caractères spéciaux
sub nettoyage {
    my $texte=shift;
	$texte=~s/<img[^>]+>//g;
	$texte=~s/<a href[^>]+>//g;
	$texte=~s/<\/a>//g;
	$texte=~s/<[^>]+>//g;
	$texte=~s/&/et/g;
	$texte=~s/\x{0153}/œ/g; 
	$texte=~s/\x{0152}/Œ/g;
	$texte=~s/\x{20ac}/€/g;
	$texte=~s/\x{2019}/'/g;
	$texte=~s/\x{2018}/‘/g;
	$texte=~s/\x{201c}/“/g; #left double quotation mark
	$texte=~s/\x{201d}/”/g;
	$texte=~s/\x{2013}/-/g;
	$texte=~s/\x{2192}/→/g;
	$texte=~s/\x{2026}/.../g;
	return $texte;
}
# - Parcours de l'arborescence pour repérer les rubriques - 
sub repererubriques {
    my $path = shift(@_);
    opendir(DIR, $path) or die "can't open $path: $!\n";
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
	next if $file =~ /^\.\.?$/;
	$file = $path."/".$file;
	if (-d $file) {
	    &repererubriques($file);	
	}
	if (-f $file) {
	    if (($file=~/\.xml$/) && ($file!~/\/fil.+\.xml$/)) {
		open(FILE,$file);
		#print "Traitement de : $file\n";
		my $texte="";
		while (my $ligne=<FILE>) {
		    $ligne =~ s/\n//g;
		    $ligne =~ s/\r//g;
		    $texte .= $ligne;
		}
		close(FILE);
		$texte=~s/> *</></g;
		$texte=~/encoding ?= ?[\'\"]([^\'\"]+)[\'\"]/i;
		my $encodage = $1;
		#print "ENCODAGE : $encodage\n";
		if ($encodage ne "") {
		    open(FILE,"<:encoding($encodage)", $file);
		    #print "Traitement de :\n$file\n";
		    $texte="";
		    while (my $ligne=<FILE>) {
			$ligne =~ s/\n//g;
			$ligne =~ s/\r//g;
			$texte .= $ligne;
		    }
		    close(FILE);
		    $texte =~ s/> *</></g;
		    if ($texte=~ /(<channel>|<atom.+>)<title>([^<]+)<\/title>/) {
			my $rub=$1;
			$rub=~s/Le ?Monde.fr ?://g;
			$rub=~s/ ?: ?Toute l'actualité sur Le Monde.fr.//g;
			$rub=~s/\x{E9}/e/g;#é   
			$rub=~s/\x{E8}/e/g;#è
			$rub=~s/\x{E0}/a/g;#à 
			$rub=~s/\x{C9}/e/g;#É
			$rub=~s/\x{7E}/e/g;#~
			$rub=~s/\x{2E}/e/g;#.
			$rub=~s/\x{3A}/e/g;#:        
			$rub=~s/ //g;      
			$rub=uc($rub);  #en majuscules
			$rub=~s/-LEMONDE.FR//g;  
			$rub=~s/:TOUTEL'ACTUALITESURLEMONDE.FR.//g;
			# mémoriser les rubriques 
			$dicoRUB{$rub}++;    
		    }
		}
		else {
		    print "$file ==> encodage non détecté \n";
		}
	    }
	}
	}
}
