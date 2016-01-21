<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<xsl:output method="html"/>
<xsl:template match="/">
<html>
<body  bgcolor="#e0ffff">
	<table align="center" width="52%"  bgcolor="white" bordercolor="#add8e6" border="1">
		<tr>
			<th bgcolor="pink" colspan="2"><font face="fantasy" color="white" size="6">Extraction de patron 2014</font></th>
		</tr>
		<tr>
			<td bgcolor="#ffe4e1" align="center"><font face="fantasy" color="#fa8072"><b>NOM</b></font><xsl:text> </xsl:text><font face="fantasy" color="#8b4513"><b>ADJ</b></font></td>
			<td bgcolor="#ffe4e1" align="center"><font face="fantasy" color="#fa8072"><b>NOM</b></font><xsl:text> </xsl:text><font face="fantasy" color="#ba55d3"><b>PREP</b></font><xsl:text> </xsl:text><font face="fantasy" color="#fa8072"><b>NOM</b></font></td>	
		</tr>
		<tr>
			<td valign="top"><xsl:apply-templates select="./EXTRACTION/file/items/item/*/element[contains(data[1], 'NOM')][following-sibling::element[1][contains(data[1], 'ADJ')]]"/></td>					
			<td valign="top"><xsl:apply-templates select="./EXTRACTION/file/items/item/*/element[contains(data[1], 'NOM')][following-sibling::element[1][contains(data[1], 'PRP')]][following-sibling::element[2][contains(data[1], 'NOM')]]"/></td>				
		</tr>
	</table>
</body>
</html>
</xsl:template>

<xsl:template match="element[contains(data[1], 'NOM')][following-sibling::element[1][contains(data[1], 'ADJ')]]">
  <font size="4" face="fantasy" color="#fa8072"><xsl:value-of select="./data[3]"/></font><xsl:text> </xsl:text><font size="4" face="fantasy" color="#8b4513"><xsl:value-of select="following-sibling::element[1]/data[3]"/></font><br/>
</xsl:template>

<xsl:template match="element[contains(data[1], 'NOM')][following-sibling::element[1][contains(data[1], 'PRP')]][following-sibling::element[2][contains(data[1], 'NOM')]]">
  <font size="4" face="fantasy" color="#fa8072"><xsl:value-of select="./data[3]"/></font><xsl:text> </xsl:text><font size="4" face="fantasy" color="#ba55d3"><xsl:value-of select="following-sibling::element[1]/data[3]"/></font><xsl:text> </xsl:text><font size="4" face="fantasy" color="#fa8072"><xsl:value-of select="following-sibling::element[2]/data[3]"/></font><br/>
</xsl:template>

</xsl:stylesheet>