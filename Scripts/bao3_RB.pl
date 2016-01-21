#/usr/bin/perl
<<DOC; 
Nom : Rachid Belmouhoub
Avril 2012
 usage : perl bao3_rb_new.pl fichier_tag fichier_motif
DOC

use strict; #verification directement, nom 
use utf8;#pour les entrŽs et sorties
use XML::LibXML;# faut installer

# Définition globale des encodage d'entrée et sortie du script à utf8
binmode STDIN,  ':encoding(utf8)'; #
binmode STDOUT, ':encoding(utf8)';

# On vérifie le nombre d'arguments de l'appel au script ($0 : le nom du script)
if($#ARGV!=1){
	print "usage : perl $0 fichier_tag fichier_motif";
	exit;
}# $0 est par dŽfaut de perl, le nom du script

# Enregistrement des arguments de la ligne de commande dans les variables idoines
my $tag_file= shift @ARGV;
my $patterns_file = shift @ARGV;#patron par ligne, comme NOM ADJ, NOM PRR NOM, programme a 2 fichiers: perl et ficher de patron

# crŽation de l'objet XML::XPath pour explorer le fichier de sortie tree-tagger XML
my $xp = XML::LibXML->new(XML_LIBXML_RECOVER => 2);# creer un objet, lire et memoriser arborasecnece xml, il va tout gŽrer, (XML_LIBXML_RECOVER => 2)est tableau de hashge,2 est valeur 2, invocation de methode, 

$xp->recover_silently(1);                          #creer moi un new objet de type XML::LibXML
#donner un mŽthode recover_silently ˆ $xp
my $dom    = $xp->load_xml( location => $tag_file );#ˆ traver load_xml(opŽrateur)on modifie soit un fichier soit notre $tag_file
my $root   = $dom->getDocumentElement();# acces ˆ un attribut, adresse de parcours

my $xpc    = XML::LibXML::XPathContext->new($root);# il prend racine $root

# Ouverture du fichiers de motifs
open(PATTERNSFILE, $patterns_file) or die "can't open $patterns_file: $!\n";

# lecture du fichier contenant les motifs, un motif par ligne (par exemple : NOM ADJ)
while (my $ligne = <PATTERNSFILE>) {  
	# Appel à  la procédure d'extraction des motifs
	&extract_pattern($ligne);# lire notre fichier qui contient NOM ADJ
}

# Fermeture du fichiers de motifs
close(PATTERNSFILE);

# routine de construction des chemins XPath
sub construit_XPath{
	# On récupère la ligne du motif recherché
	my $local_ligne=shift @_;# @_ est argument, ice c'est un tableau, on le met dans $local_ligne
	
	# initialisation du chemin XPath ˆ vide
	my $search_path="";
	
	# on supprime avec la fonction chomp un éventuel retour à la ligne
	chomp($local_ligne);# j'enlve les retour ˆ la ligne
	
	# on élimine un éveltuel retour chariot hérité de windows
	$local_ligne=~ s/\r$//;# j enlve r, ou cas ou on est sous windows
	
	# Construction au moyen de la fonction split d'un tableau dont chaque élément a pour valeur un élément du motif recherché
	
	
	my @tokens=split(/ /,$local_ligne);# split(/-s/) si on a espace entre NOM et ADJ
	
	# On commence ici la construction du chemin XPath
	# Ce chemin correspond au premier noeud "element" de l'arbre XML qui répond au motif cherché 
	
	
	$search_path="//element[contains(data[\@type=\"type\"],\"$tokens[0]\")]";#"//element[contains(data[\@type=\"type\"],"NOM")]"
	
	# Initialisation du compteur pour la boucle de construction du chemin XPath
	my $i=1;
	while ($i < $#tokens) {
		$search_path.="[following-sibling::element[1][contains
		(data[\@type=\"type\"],\"$tokens[$i]\")]";
		$i++;
	}
	my $search_path_suffix="]";
	
	# on utilise l'opŽrateur x qui permet de rŽpŽter la chaine de caractre ˆ
	 sa gauche autant de fois que l'entier de sa droite,
	# soit $i fois $search_path_suffix
	$search_path_suffix=$search_path_suffix x $i;
	
	# le chemin XPath final
	$search_path.="[following-sibling::element[1][contains(data[\@type=\"type\"],
	\"".$tokens[$#tokens]."\")]"
								.$search_path_suffix;
		# print  "$search_path\n";

	# on renvoie à la procédure appelante le chein XPath et le tableau des éléments du motif
	return ($search_path,@tokens);
}

# routine d'extraction du motif
sub extract_pattern{
	# On récupère la ligne du motif recherché
	my $ext_pat_ligne= shift @_;

	# Appel de la fonction construit_XPath pour le motif lu à la ligne courrante du fichier de motif
	my ($search_path,@tokens) = &construit_XPath($ext_pat_ligne);# @tokens est tableau contient nom pre nom
	#print $search_path, est xpath complet
	# définition du nom du fichier de résultats pour le motif en utilisant la fonction join
	my $match_file = "res_extract-".join('_', @tokens).".txt";#join transfert une chaine de caractre, sortie nom_prp_nom, join est contraire de split
	#-s//
	#c'est le nom de ficier
	# Ouverture du fichiers de résultats encodé en UTF-8
	open(MATCHFILE,">:encoding(UTF-8)", "$match_file") or die "can't open $match_file: $!\n";
	
	# création de l'objet XML::XPath pour explorer le fichier de sortie tree-tagger XML
	
	# Parcours des noeuds du ficher XML correspondant au motif, au moyen de la méthode findnodes
	# qui prend pour argument le chemin XPath construit précédement
	# avec la fonction "construit_XPath"
	my @nodes=$root->findnodes($search_path);#chercher l'arboracence par xpath, avec prŽdicat 
	foreach my $noeud ( @nodes) { #noeud est "element"
		# Initialisation du chemin XPath relatif du noeud "data" contenant
		# la forme correspondant au premier élément du motif
		# Ce chemin est relatif au premier noeud "element" du bloc retourné
		# et pointe sur le troisième noeud "data" fils du noeud "element"
		# en l'identifiant par la valeur "string" de son attribut "type"
		my $form_xpath="";
		$form_xpath="./data[\@type=\"string\"]";#. est l'endroit de xml
		
		# Initialisation du compteur pour la boucle d'éxtraction des formes correspondants
		# aux éléments suivants du motif
		my $following=0;

		# Recherche du noeud data contenant la forme correspondant au premier élément du motif		
		# au moyen de la fonction "find" qui prend pour arguments:
		#			1. le chemin XPath relatif du noeud "data"
		#			2. le noeud en cours de traitement dans cette boucle foreach
		# la fonction "find" retourne par défaut une liste de noeuds, dans notre cas cette liste
		# ne contient qu'un seul élément que nous récupérons avec la fonction "get_node"
		# enfin nous en imprimons le contenu textuel au moyen de la méthode string_value
		print MATCHFILE $xpc->findvalue($form_xpath,$noeud);#je suis ˆ element, $noeud pointe ˆ element, dans ce context lˆ, 
		#findvalue travers le chemin $form_xpath cherche $noeud, dans $noeud je fais une requete xpath
		
		# Boucle d'éxtraction des formes correspondants aux éléments suivants du motif
		# On descend dans chaque noeud element du bloc
		while ( $following < $#tokens) {
			# Incrémentation du compteur $following de cette boucle d'éxtraction des formes
			$following++;
			
			# Construction du chemin XPath relatif du noeud "data" contenant
			# la forme correspondant à l'élément suivant du motif
			# Notez bien l'utilisation du compteur $folowing tant dans la condition de la boucle ci-dessus
			# que dans la construction du chemin relatif XPath
			my $following_elmt="following-sibling::element[".$following."]";#chemin xpath chercher frere de 			
			$form_xpath=$following_elmt."/data[\@type=\"string\"]"; #il y a 2 boucles, 1 on trouve NOM ex:pre puis dans 2e boucle, on traite PEP: de, puis NOM: Pire

			#	Impression du contenu textuel du noeud data contenant la forme correspondant à l'élément suivant du motif
			print MATCHFILE " ",$xpc->findvalue($form_xpath,$noeud);
		
			# Incrémentation du compteur $following de cette boucle d'éxtraction des formes
			# $following++;
		}
		print MATCHFILE "\n";# on fait retour ˆ ligne
	}
	# Fermeture du fichiers de motifs
	close(MATCHFILE);
}