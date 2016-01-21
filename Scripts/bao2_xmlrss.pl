#!/usr/bin/perl
use strict; # http://blog.csdn.net/helpxs/article/details/7001059
use Unicode::String qw(utf8);
use HTML::Entities; #http://courshtml.free.fr/donnees/charset.htm
use XML::RSS;

my $rep="$ARGV[0]";
# on s'assure que le nom du répertoire ne se termine pas par un "/"
$rep=~ s/[\/]$//;        
# ----------- Création des répertoires de sortie -----------
my $sortie="Sorties/";
if (! -e $sortie){	
	mkdir($sortie) or die ("Erreur de création file : $!");
}
$sortie="Sorties/BAO_1/";
if (! -e $sortie){
	mkdir($sortie) or die ("Erreur de création file : $!");
}
my %dicoTitres=();
my %dicoDescrip=();
my %dicoRub=();

# ----------------------------------------------------------
&repererubriques($rep); 
    
my @listeRubriques = keys(%dicoRub);    
# parcours de la liste des rubriques et créer le fichier
foreach my $rub (@listeRubriques) {
    #print $rub,"\n";
    my $output1 = $sortie.$rub.".xml"; 
    my $output2 = $sortie.$rub.".txt";
    if (!open (out_XML,">:encoding(utf-8)", $output1)) { die "Erreur d'ouvrir file $output1"};   
    if (!open (out_TXT,">:encoding(utf-8)", $output2)) { die "Erreur d'ouvrir file $output2"};   
    print out_XML "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
    print out_XML "<EXTRACTION>\n";
    close(out_XML);
    close(out_TXT);
}
# ----------------------------------------------------------
&parcoursarborescencefichiers($rep);

foreach my $rub (@listeRubriques) {
    my $output1=$sortie.$rub.".xml";
    if (!open (out_XML,">>:encoding(utf-8)", $output1)) { die "Erreur d'ouvrir file $output1"};
    print out_XML "</EXTRACTION>\n";
    close(out_XML);    
}
exit;
# ----------------------------------------------------------
# Parcours de l'arborescence et traitement des fichiers xml 
sub parcoursarborescencefichiers {
    my $path = shift(@_);
    opendir(DIR, $path) or die "Can't open $path: $!\n";
    my @files = readdir(DIR);
    closedir(DIR);
    foreach my $file (@files) {
	next if $file =~ /^\.\.?$/;
	$file = $path."/".$file;
	if (-d $file) {
	    &parcoursarborescencefichiers($file);	
	}
	if (-f $file) {
	    if (($file=~/\.xml$/) && ($file!~/\/fil.+\.xml$/)) {
		open(FILE, $file);
		print "Traitement de : $file\n";
		my $texte="";
		while (my $ligne=<FILE>) {
		    $ligne =~ s/\n//g;
		    $ligne =~ s/\r//g;
		    $texte .= $ligne;
		}
		close(FILE);

		$texte=~/encoding ?= ?[\'\"]([^\'\"]+)[\'\"]/i;
		my $encodage=$1;
		print "ENCODAGE : $encodage\n";
		if ($encodage ne "") {
		    my $texteXML="<file>\n";
			$texteXML.="<name>$file</name><date>2014</date>";
		    $texteXML.="<items>\n";
		    my $texteBRUT="";
		    open(FILE,"<:encoding($encodage)", $file);
		    #print "Traitement de : $file\n";
		    $texte="";
		    while (my $ligne=<FILE>) {
			$ligne =~ s/\n//g;
			$ligne =~ s/\r//g;
			$texte .= $ligne;
		    }
		    close(FILE);
			$texte =~ s/> *</></g;
		    # recherche de la rubrique
		    $texte=~/(<channel>|<atom.+>)<title>([^<]+)<\/title>/;
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
		    $rub=uc($rub);
		    $rub=~s/-LEMONDE.FR//g;
			$rub=~s/:TOUTEL'ACTUALITESURLEMONDE.FR.//g;
		    print "RUBRIQUE : $rub\n";
		    #----------------------------------------
		    my $output1=$sortie.$rub.".xml";
		    my $output2=$sortie.$rub.".txt";
		    if (!open (out_XML,">>:encoding(utf-8)", $output1)) { die "Erreur d'ouvrir file $output1"};
		    if (!open (out_TXT,">>:encoding(utf-8)", $output2)) { die "Erreur d'ouvrir file $output2"};
		    #--------------------------------------------------------
			# Stockage des titres et descriptions dans des variables
		    # Création d'un objet XML::RSS stocké dans la variable $rss + parcours du fichier 
			my $rss = new XML::RSS;
			$rss->parsefile($file);
			
			foreach my $item(@{$rss->{'items'}}){
				my $titre = $item->{'title'};
				my $descrip = $item->{'description'};

				if (uc($encodage) ne "UTF-8"){
				   utf8($titre);
				   utf8($descrip);
				}				
				$titre = HTML::Entities::decode($titre);# traiter les caractère diachrités avec HTML::Entities
				$descrip = HTML::Entities::decode($descrip);
				$titre = &nettoyage($titre);
				$descrip = &nettoyage($descrip);

				if (!(exists $dicoTitres{$titre}) and (!(exists $dicoDescrip{$descrip}))){# ou cas où l'encodage n'est pas utf8, réen	 
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
# ----------------------------------------------------------
# - Parcours de l'arborescence pour repérer les rubriques 

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

		my $texte="";
		while (my $ligne=<FILE>) {
		    $ligne =~ s/\n//g;
		    $ligne =~ s/\r//g;
		    $texte .= $ligne;
		}
		close(FILE);
		$texte =~ s/> *</></g;
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
			$rub=uc($rub);  
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
#----------------------------------------------
sub etiquetage
{
	my $texte=shift;
	my $temp="fichier_temp.txt";
	open(TEMP, ">:encoding(utf-8)", $temp); # fichier temporaire pour stocker le texte
	print TEMP $texte;
	close(TEMP);
	system("perl ./utf8-tokenize.pl $temp | tree-tagger.exe french.par -lemma -token -no-unknown -sgml > etiquetage.txt");
	# treetagger2xml
	system("perl ./treetagger2xml.pl etiquetage.txt");
	open(OUT_Tagged,"<:encoding(utf-8)","etiquetage.txt.xml");

	my $texte_tag="";
	while (my $ligne=<OUT_Tagged>){
		$texte_tag.=$ligne;
	}
	close(OUT_Tagged);
	return $texte_tag;
}