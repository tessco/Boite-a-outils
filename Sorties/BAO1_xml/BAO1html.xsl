<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" version="4.0" encoding="utf-8" indent="yes"/>
  <xsl:template match="/EXTRACTION">
<xsl:variable name="rubrique" select="local-name(./*[preceding-sibling::NOM])"/> <!-- nom du rubrique -->
<html>
    <head>
        <meta charset="utf-8"/>
        <link rel="stylesheet" type="text/css" href="bao1_html.css"/><!-- css pour enjoliver le html -->
        <title><xsl:value-of select="$rubrique"/></title><!-- nom du rubrique -->
	<link rel="icon" type="image/ico" href="../../Images/bao.ico"/> 
    </head>
    <body>
        <div id="contenu">
            <h1><xsl:value-of select="$rubrique"/></h1>
            <table>
                <xsl:apply-templates select="*/file"/> <!-- contenu du tableau -->
            </table>
        </div>
    </body>
</html>  
  
  </xsl:template>
  
  <xsl:template match="file"> <!-- tous fichier -->
    <xsl:if test="./items/item"><!-- s'il existe des items dans le fichier -->
      <xsl:variable name="fullname" select="./name"/><!-- nom du fichier -->
      <xsl:variable name="name" select="substring-before($fullname, '.')"/> <!--nom du ficher sans l'extension -->
      <xsl:variable name="lengthname" select="string-length($name)"/><!-- Longueur du nom du fichier -->
      <xsl:variable name="filename" select="substring($name, $lengthname - 13, $lengthname)"/><!-- nom du fichier sans le chemin -->
      <tr>
          <th colspan="2" class="fileheader"><xsl:value-of select="$filename"/><xsl:text> (</xsl:text><xsl:value-of select="date"/><xsl:text>)</xsl:text></th></tr>
          <tr><th>Titre</th><th>Description</th></tr><!-- titres des colonnes : titre et fichiers-->
          <xsl:apply-templates select="items/item"/><!-- ajouter des items -->
      </xsl:if>
  </xsl:template>
  
  <xsl:template match="item">
    <tr>
	<td><xsl:value-of select="title"/></td><!-- ajouter itre -->
        <td><xsl:value-of select="description"/></td><!-- ajouter description -->
    </tr>
  </xsl:template>
</xsl:stylesheet>

