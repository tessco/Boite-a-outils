#!/usr/bin/perl
#-------------
#A aider les script de SF et JMD à extraire les patrons dans tous les fichiers
#La même technique que bao1
#-------------
my $patrons="Extract_patron/";
# Création d'un dossier de sorties pour les patrons 
if (! -e $patrons){ 
	mkdir($patrons) or die ("Pb à la création du répertoire : $!"); 
}

#______________________________________________________


my $path="$ARGV[0]";
$path=~s/[\/]$//;
my $patron="$ARGV[1]";
opendir(DIR, $path) or die "on ne peut pas ouvrir $path: $!\n";
my @files=readdir(DIR);
closedir(DIR);
#----------------------------------------


foreach my $file (@files){
	next if $file=~/^\.\.?$/;
	my $txt="$patrons".$file.'-'.$patron;
	$txt=~s/\.cnr//; 
	$file=$path."/".$file;
	system("perl JMD.pl(ou SF) $patron $file > $txt");#usage
}