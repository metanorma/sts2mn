<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:mml="http://www.w3.org/1998/Math/MathML" 
		xmlns:tbx="urn:iso:std:iso:30042:ed-1" 
		xmlns:xlink="http://www.w3.org/1999/xlink" 
		xmlns:xalan="http://xml.apache.org/xalan" 
		xmlns:java="http://xml.apache.org/xalan/java" 
		exclude-result-prefixes="mml tbx xlink xalan java" 
		version="1.0">

	<xsl:preserve-space elements="code mml:*"/>
	
	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="text()[not(parent::code) and not(parent::preformat) and not(parent::mml:*)]">
		<xsl:choose>
			<xsl:when test="parent::standard or parent::body or parent::sec or parent::term-sec or parent::tbx:termEntry or parent::back or parent::app-group or parent::app or parent::ref-list or parent::fig or parent::caption or parent::table-wrap or parent::tr or parent::thead or parent::colgroup or parent::table or parent::tbody or parent::fn">
				<xsl:value-of select="normalize-space()"/>
			</xsl:when>
			<xsl:when test="contains(., '&#xa;')">
				<xsl:variable name="text_" select="translate(., '&#xa;', ' ')"/>
				<xsl:variable name="text" select="java:replaceAll(java:java.lang.String.new($text_),' +',' ')"/>
				<xsl:if test="normalize-space($text) != ''">
					<xsl:value-of select="$text"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	
</xsl:stylesheet>