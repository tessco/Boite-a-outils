<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" version="4.0" encoding="utf-8" indent="yes"/>
<xsl:template match="/PARCOURS">
	<xsl:variable name="rubrique" select="local-name(./*[preceding-sibling::NOM])"/><!-- Nom du rubrique -->
	<html>
	<head>
		<meta charset="utf-8"/>
		<link rel="stylesheet" type="text/css" href="BAO2html.css"/><!--css pour enjoliver le html -->
		<title><xsl:value-of select="$rubrique"/></title><!-- Nom du rubrique -->
	</head>
	<body>
		<div id="contenu"><!-- conteneur -->
			<h1><xsl:value-of select="$rubrique"/></h1><!-- Titre -->
			<table>
				<xsl:apply-templates select="*/file"/><!-- Le contenu du tableau -->
			</table>
		</div>
	</body>
</html>  
  </xsl:template>

<!-- Pour chaque fichier -->  
<xsl:template match="file">
	<xsl:if test="./items/item"><!-- S'il existe des items dans le fichier -->
		<xsl:if test="position() &lt; 10">
			<xsl:variable name="fullname" select="./name"/><!-- Nom du fichier -->
			<xsl:variable name="name" select="substring-before($fullname, '.')"/><!--Nom du ficher sans l'extension -->
			<xsl:variable name="lengthname" select="string-length(./name)"/><!-- Longueur du nom du fichier -->
			<xsl:variable name="filename" select="substring($name, $lengthname - 17, $lengthname)"/><!-- Nom du fichier sans le chemin -->
			<tr>
				<th colspan="2" class="fileheader"><xsl:value-of select="$filename"/><xsl:text>  (</xsl:text><xsl:value-of select="date"/><xsl:text>)</xsl:text></th>
			</tr><!-- Diviseur par fichier -->
			<tr><th>Titre</th><th>Description</th></tr><!-- Titres des colonnes : titre et fichiers-->
			<xsl:apply-templates select="items/item"/><!-- Ajouter des items -->
		</xsl:if>
	</xsl:if>
  </xsl:template>
  
  <!-- Pour chaque item -->
  <xsl:template match="item">
	  <xsl:if test="position() &lt; 10">
		<tr>
			<td><xsl:apply-templates select="titre"/></td><!-- Ajouter le titre -->
			<td><xsl:apply-templates select="description"/></td>
		</tr><!-- Ajouter la description -->
	  </xsl:if>
  </xsl:template> 
  
  <!-- Pour chaque titre ou description -->
  <xsl:template match="titre|description">
	  <xsl:apply-templates select="document/article/element"/><!-- Appliquer les modèles -->
  </xsl:template>
  
  <!-- Pour chaque element (correspondant à un mot) -->
  <xsl:template match="element">
	  <!-- Chaque élément reçoit des styles selon son type (voir le css pour le formatage correspondant) -->
	  <span class="forme"><xsl:value-of select="data[contains(@type, 'string')]"/></span><!-- Ecrire la forme du mot -->
	  <span class="small"><xsl:text>[</xsl:text><!-- Crochet -->
	  <span class="type"><xsl:value-of select="data[contains(@type, 'type')]"/></span><xsl:text>/</xsl:text><!-- La catégorie syntaxique -->
	  <span class="lemma"><xsl:value-of select="data[contains(@type, 'lemma')]"/></span><!-- Le lemme -->
	  <xsl:text>]</xsl:text></span><xsl:text> </xsl:text><!-- Crochet + espace -->
  </xsl:template>
  
</xsl:stylesheet>

