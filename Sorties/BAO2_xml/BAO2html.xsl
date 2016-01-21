<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" version="4.0" encoding="utf-8" indent="yes"/>
<xsl:template match="/EXTRACTION">
	<xsl:variable name="rubrique" select="local-name(./*[preceding-sibling::NOM])"/><!-- nom du rubrique -->
	<html>
	<head>
		<meta charset="utf-8"/>
		<link rel="stylesheet" type="text/css" href="BAO2html.css"/><!--css pour le html -->
		<title><xsl:value-of select="$rubrique"/></title><!-- nom du rubrique -->
	</head>
	<body>
		<div id="contenu"><!-- conteneur -->
			<h1><xsl:value-of select="$rubrique"/></h1><!-- titre -->
			<table>
				<xsl:apply-templates select="*/file"/><!-- Le contenu du tableau -->
			</table>
		</div>
	</body>
</html>  
  </xsl:template>
<!-- tous les fichiers-->  
<xsl:template match="file">
	<xsl:if test="./items/item">
		<xsl:if test="position() &lt; 10">
			<xsl:variable name="fullname" select="./name"/><!-- Nom du fichier -->
			<xsl:variable name="name" select="substring-before($fullname, '.')"/>
			<xsl:variable name="lengthname" select="string-length(./name)"/><!-- longueur du nom du fichier -->
			<xsl:variable name="filename" select="substring($name, $lengthname - 17, $lengthname)"/><!-- nom du fichier sans le chemin -->
			<tr>
				<th colspan="2" class="fileheader"><xsl:value-of select="$filename"/><xsl:text>  (</xsl:text><xsl:value-of select="date"/><xsl:text>)</xsl:text></th>
			</tr><!-- diviser-->
			<tr><th>Titre</th><th>Description</th></tr><!-- titres des colonnes : titre et fichiers-->
			<xsl:apply-templates select="items/item"/><!-- ajouter des items -->
		</xsl:if>
	</xsl:if>
  </xsl:template>  
  <!-- tous les item-->
  <xsl:template match="item">
	  <xsl:if test="position() &lt; 10">
		<tr>
			<td><xsl:apply-templates select="title"/></td><!-- ajouter le titre -->
			<td><xsl:apply-templates select="description"/></td>
		</tr><!-- ajouter la description -->
	  </xsl:if>
  </xsl:template>  
  <!-- pour chaque titre ou description -->
  <xsl:template match="title|description">
	  <xsl:apply-templates select="element"/><!-- Appliquer les modèles -->
  </xsl:template>
  
  
  <xsl:template match="element">
	  
	  <span class="forme"><xsl:value-of select="data[contains(@type, 'string')]"/></span><!-- forme du mot -->
	  <span class="small"><xsl:text>[</xsl:text><!-- Crochet -->
	  <span class="type"><xsl:value-of select="data[contains(@type, 'type')]"/></span><xsl:text>/</xsl:text><!-- La catégorie syntaxique -->
	  <span class="lemma"><xsl:value-of select="data[contains(@type, 'lemma')]"/></span><!-- le lemme -->
	  <xsl:text>]</xsl:text></span><xsl:text> </xsl:text>
  </xsl:template>
</xsl:stylesheet>

