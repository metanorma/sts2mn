<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:mml="http://www.w3.org/1998/Math/MathML" 
		xmlns:tbx="urn:iso:std:iso:30042:ed-1" 
		xmlns:xlink="http://www.w3.org/1999/xlink" 
		xmlns:xalan="http://xml.apache.org/xalan" 
		xmlns:java="http://xml.apache.org/xalan/java" 
		exclude-result-prefixes="mml tbx xlink xalan java" 
		version="1.0">

	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:param name="split-bibdata">false</xsl:param>
	
	<xsl:param name="debug">false</xsl:param>

	<xsl:param name="docfile" /> <!-- Example: iso-tc154-8601-1-en.adoc -->
	
	<xsl:param name="pathSeparator" select="'/'"/>
	
	<xsl:template match="/*">
		<!-- = ISO 8601-1 -->
		<xsl:apply-templates select="/standard/front/iso-meta/std-ident"/>
		<!-- :docnumber: 8601 -->
		<xsl:apply-templates select="/standard/front/iso-meta/std-ident/doc-number"/>		
		<!-- :partnumber: 1 -->
		<xsl:apply-templates select="/standard/front/iso-meta/std-ident/part-number"/>		
		<!-- :edition: 1 -->
		<xsl:apply-templates select="/standard/front/iso-meta/std-ident/edition"/>		
		<!-- :copyright-year: 2019 -->
		<xsl:apply-templates select="/standard/front/iso-meta/permissions/copyright-year"/>
		<!-- :language: en -->
		<xsl:apply-templates select="/standard/front/iso-meta/doc-ident/language"/>
		<!-- :title-intro-en: Date and time
		:title-main-en: Representations for information interchange
		:title-part-en: Basic rules
		:title-intro-fr: Date et l'heure
		:title-main-fr: Représentations pour l'échange d'information
		:title-part-fr: Règles de base -->
		<xsl:apply-templates select="/standard/front/iso-meta/title-wrap"/>		
		<!-- :doctype: international-standard -->
		<xsl:apply-templates select="/standard/front/iso-meta/std-ident/doc-type"/>		
		<!-- :docstage: 60
		:docsubstage: 60 -->		
		<xsl:apply-templates select="/standard/front/iso-meta/doc-ident/release-version"/>
		
		<!-- 
		:technical-committee-type: TC
		:technical-committee-number: 154
		:technical-committee: Processes, data elements and documents in commerce, industry and administration
		:workgroup-type: WG
		:workgroup-number: 5
		:workgroup: Representation of dates and times -->		
		<xsl:apply-templates select="/standard/front/iso-meta/comm-ref"/>
		
		<!-- :secretariat: SAC -->
		<xsl:apply-templates select="/standard/front/iso-meta/secretariat"/>
		
		<xsl:text>:local-cache-only:</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>:data-uri-image:</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
		<xsl:text>:docfile: </xsl:text><xsl:value-of select="$docfile"/>
		<xsl:text>&#xa;</xsl:text>
		
		<xsl:text>:mn-document-class: iso</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>:mn-output-extensions: xml,html,doc,html_alt</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>

		<xsl:if test="$split-bibdata != 'true'">

			<xsl:variable name="language" select="/standard/front/iso-meta/doc-ident/language"/>
			
			<xsl:variable name="path_" select="concat('body', $pathSeparator, 'body-#lang.adoc[]')"/>
			
			<xsl:variable name="path" select="java:replaceAll(java:java.lang.String.new($path_),'#lang',$language)"/>
			<xsl:text>include::</xsl:text><xsl:value-of select="$path"/>
			<xsl:text>&#xa;</xsl:text>
			
			<xsl:text>///SPLIT </xsl:text><xsl:value-of select="$path"/>
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates select="/standard/front/*[local-name() != 'iso-meta']"/>
			<xsl:apply-templates select="/standard/body"/>
			
			<xsl:apply-templates select="/standard/back"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/std-ident">
		<xsl:text>= </xsl:text>
		<xsl:value-of select="originator"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="doc-number"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="part-number"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/std-ident/doc-number">
		<xsl:text>:docnumber: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/std-ident/part-number">
		<xsl:text>:partnumber: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/std-ident/edition">
		<xsl:text>:edition: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/permissions/copyright-year">
		<xsl:text>:copyright-year: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/doc-ident/language">
		<xsl:text>:language: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/title-wrap/text()"/>
	<xsl:template match="/standard/front/iso-meta/title-wrap">
		<xsl:apply-templates>
			<xsl:with-param name="lang" select="@xml:lang"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/title-wrap/intro">
		<xsl:param name="lang"/>
		<xsl:text>:title-intro-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="/standard/front/iso-meta/title-wrap/main">
		<xsl:param name="lang"/>
		<xsl:text>:title-main-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="/standard/front/iso-meta/title-wrap/compl">
		<xsl:param name="lang"/>
		<xsl:text>:title-part-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="/standard/front/iso-meta/title-wrap/full">
		<xsl:text></xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/std-ident/doc-type">
		<xsl:variable name="value" select="java:toLowerCase(java:java.lang.String.new(.))"/>
		<xsl:text>:doctype: </xsl:text>
		<!-- https://www.niso-sts.org/TagLibrary/niso-sts-TL-1-0-html/element/doc-type.html -->
		<xsl:choose>
			<xsl:when test="$value = 'is'">international-standard</xsl:when>
			<xsl:when test="$value = 'r'">recommendation</xsl:when>
			<xsl:when test="$value = 'spec'">spec</xsl:when>
			 <xsl:otherwise>
				<xsl:value-of select="."/>
			 </xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/doc-ident/release-version">
		<!-- https://www.niso-sts.org/TagLibrary/niso-sts-TL-1-0-html/element/release-version.html -->
		<!-- Possible values: WD, CD, DIS, FDIS, IS -->
		<xsl:variable name="value" select="java:toUpperCase(java:java.lang.String.new(.))"/>
		<xsl:choose>
			<xsl:when test="$value = 'WD'">
				<xsl:text>:docstage: 20</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:docsubstage: 00</xsl:text>
			</xsl:when>
			<xsl:when test="$value = 'CD'">
				<xsl:text>:docstage: 30</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:docsubstage: 00</xsl:text>
			</xsl:when>
			<xsl:when test="$value = 'DIS'">
				<xsl:text>:docstage: 40</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:docsubstage: 00</xsl:text>
			</xsl:when>
			<xsl:when test="$value = 'FDIS'">
				<xsl:text>:docstage: 50</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:docsubstage: 00</xsl:text>
			</xsl:when>
			<xsl:when test="$value = 'IS'">
				<xsl:text>:docstage: 60</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:docsubstage: 60</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:docstage: </xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:docsubstage: </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/comm-ref">
		<xsl:variable name="comm-ref">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="."/>
			</xsl:call-template>
		</xsl:variable>			
		<xsl:for-each select="xalan:nodeset($comm-ref)/*">				
			<xsl:choose>
				<xsl:when test="starts-with(., 'TC ')">
					<xsl:text>:technical-committee-type: TC</xsl:text>
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>:technical-committee-number: </xsl:text>					
					<xsl:value-of select="normalize-space(substring-after(., ' '))"/>
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>:technical-committee: </xsl:text>
				</xsl:when>
				<xsl:when test="starts-with(., 'SC ')">
					<xsl:text>:subcommittee-type: SC</xsl:text>
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>:subcommittee-number: </xsl:text>
					<xsl:value-of select="normalize-space(substring-after(., ' '))"/>
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>:subcommittee: </xsl:text>				
				</xsl:when>
				<xsl:when test="starts-with(., 'WG ')">					
					<xsl:text>:workgroup-type: WG</xsl:text>
					<xsl:text>:workgroup-number: </xsl:text>
					<xsl:value-of select="normalize-space(substring-after(., ' '))"/>
					<xsl:text>&#xa;</xsl:text>
					<xsl:text>:workgroup: </xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/standard/front/iso-meta/secretariat">
		<xsl:text>:secretariat: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<!-- =========== -->
	<!-- end bibdata -->
	
	
	
	<xsl:template match="sec">
		<xsl:choose>
			<xsl:when test="@sec-type = 'foreword'">
			</xsl:when>
			<xsl:when test="@sec-type = 'intro'">
				<xsl:text>[[introduction]]</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>:sectnums!:</xsl:text>
			</xsl:when>
			<xsl:when test="@sec-type = 'scope'">
				<xsl:text>:sectnums:</xsl:text>			
			</xsl:when>
			<xsl:when test="@sec-type = 'norm-refs'">
				<xsl:text>[bibliography]</xsl:text>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>[[</xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text>]]</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="term-sec">
		<xsl:text>[[</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tbx:termEntry">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:value-of select="$level"/><xsl:text> </xsl:text>
		<xsl:apply-templates select=".//tbx:term" mode="term"/>	
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="title">
		<xsl:choose>
			<xsl:when test="parent::sec/@sec-type = 'foreword'">
				<xsl:text>.</xsl:text>
				<xsl:text> </xsl:text><xsl:apply-templates />
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="level">
					<xsl:call-template name="getLevel"/>
				</xsl:variable>
				
				<xsl:value-of select="$level"/>
				<xsl:text> </xsl:text><xsl:apply-templates />
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>&#xa;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="tbx:term"/>
	<xsl:template match="tbx:term" mode="term">
		<xsl:choose>
			<xsl:when test="position() = 1">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#xa;</xsl:text>
				<xsl:text>alt:[</xsl:text>
				<xsl:apply-templates />
				<xsl:text>]</xsl:text>
			</xsl:otherwise>			
		</xsl:choose>
		
	</xsl:template>
	
	
	
	<xsl:template match="tbx:langSet">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="tbx:langSet/text()"/>
	<!-- <xsl:template match="text()[. = '&#xa;']"/> -->
	
	<xsl:template match="tbx:definition">
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="tbx:tig"/>
	
	<xsl:template match="label"/>
	
	<xsl:template match="p">
		<xsl:apply-templates />
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
		
	<xsl:template match="tbx:entailedTerm">
		<xsl:variable name="target" select="substring-after(@target, 'term_')"/>
		<xsl:choose>
			<xsl:when test="contains(., concat('(', $target, ')'))">
				<xsl:text>_</xsl:text><xsl:value-of select="normalize-space(substring-before(., concat('(', $target, ')')))"/><xsl:text>_</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>_</xsl:text><xsl:value-of select="."/><xsl:text>_</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> (</xsl:text>
		<xsl:text>&lt;&lt;</xsl:text><xsl:value-of select="@target"/><xsl:text>&gt;&gt;</xsl:text>
		<xsl:text>)</xsl:text>		
	</xsl:template>
	
	<xsl:template match="tbx:note">
		<xsl:text>NOTE: </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="non-normative-note">
		<xsl:text>NOTE: </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="std">
		<xsl:text>&lt;&lt;</xsl:text><xsl:apply-templates /><xsl:text>&gt;&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="tbx:source">
		<xsl:text>[.source]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&lt;&lt;</xsl:text><xsl:apply-templates /><xsl:text>&gt;&gt;</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="list">
		<xsl:if test="not(parent::list-item)">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:if test="not(parent::list-item)">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="list/list-item">
		<xsl:choose>
			<xsl:when test="ancestor::list/@list-type = 'bullet'">				
				<xsl:call-template name="getLevelListItem">
					<xsl:with-param name="list-label">*</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>				
				<xsl:call-template name="getLevelListItem">
					<xsl:with-param name="list-label">.</xsl:with-param>
				</xsl:call-template>				
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tbx:example | non-normative-example">
		<xsl:text>[example]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:if test="local-name() = 'example'">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="break">
		<xsl:text> +</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="bold">
		<xsl:text>*</xsl:text><xsl:apply-templates /><xsl:text>*</xsl:text>
	</xsl:template>
	
	<xsl:template match="italic">
		<xsl:text>_</xsl:text><xsl:apply-templates /><xsl:text>_</xsl:text>
	</xsl:template>
	
	<xsl:template match="sub">
		<xsl:text>~</xsl:text><xsl:apply-templates /><xsl:text>~</xsl:text>
	</xsl:template>
	
	<xsl:template match="sup">
		<xsl:text>^</xsl:text><xsl:apply-templates /><xsl:text>^</xsl:text>
	</xsl:template>
	
	<xsl:template match="monospace">
		<xsl:text>`</xsl:text><xsl:apply-templates /><xsl:text>`</xsl:text>
	</xsl:template>
	
	<!-- AsciiDoc not support -->
	<xsl:template match="sc">
		<!-- <smallcap> -->
			<xsl:apply-templates />
		<!-- </smallcap> -->
	</xsl:template>
	
	<xsl:template match="ext-link">
		<xsl:apply-templates />
		<xsl:text>[</xsl:text>
		<xsl:value-of select="@xlink:href"/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="xref">
		<xsl:choose>
			<xsl:when test="@ref-type = 'fn'"/>
			<xsl:when test="@ref-type = 'other'">
				<xsl:text>&lt;</xsl:text><xsl:value-of select="."/><xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&lt;&lt;</xsl:text><xsl:value-of select="@rid"/><xsl:text>&gt;&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="fn">
		<xsl:text> footnote:[</xsl:text>
			<xsl:apply-templates />
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="fn/p">
		<xsl:apply-templates />
	</xsl:template>

	
	<xsl:template match="uri">
		<xsl:apply-templates />
		<xsl:text>[</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="mixed-citation">
		<xsl:text>, </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- <xsl:template match="sc">
		<xsl:text>`</xsl:text><xsl:apply-templates /><xsl:text>`</xsl:text>
	</xsl:template> -->
	
	<xsl:template match="array">
		<xsl:choose>
			<xsl:when test="count(table/col) = 2">				
				<xsl:apply-templates mode="dl"/>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="@*|node()" mode="dl">		
		<xsl:apply-templates select="@*|node()" mode="dl"/>		
	</xsl:template>
	<xsl:template match="table" mode="dl">
		<xsl:apply-templates mode="dl"/>
	</xsl:template>	
	<xsl:template match="col" mode="dl"/>
	<xsl:template match="tbody" mode="dl">
		<xsl:apply-templates mode="dl"/>
	</xsl:template>
	
	<xsl:template match="tr" mode="dl">
		<xsl:variable name="td_1">
			<xsl:apply-templates select="td[1]" mode="dl"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($td_1) != 0">
				<xsl:apply-templates select="td[1]" mode="dl"/>
				<xsl:text>::</xsl:text>		
			</xsl:when>
			<xsl:otherwise>+</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates select="td[2]" mode="dl"/>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="td" mode="dl">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="table-wrap">
		<xsl:text>[[</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="table-wrap/caption/title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="table">
		<xsl:text>[</xsl:text>
		<xsl:if test="col">
			<xsl:text>cols="</xsl:text>
				<xsl:for-each select="col">
					<xsl:variable name="width" select="translate(@width, '%', '')"/>
					<xsl:value-of select="round($width)"/>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>					
			<xsl:text>"</xsl:text>
			<xsl:if test="thead">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:if test="thead">
			<xsl:text>options="header"</xsl:text>
		</xsl:if>
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="col"/>
	
	<xsl:template match="thead">
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="tr">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="th">
		<xsl:text>|</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="td">
		<xsl:text>|</xsl:text>
		<xsl:apply-templates />
		<xsl:choose>
			<xsl:when test="position() = last()">
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="td/p">
		<xsl:text> +</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="app">
		<xsl:text>[[</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>[appendix</xsl:text>
		<xsl:apply-templates select="annex-type" mode="annex"/>		
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="app/annex-type"/>
	<xsl:template match="app/annex-type" mode="annex">
		<xsl:text>,obligation=</xsl:text>
		<xsl:value-of select="translate(., '()','')"/>
	</xsl:template>
	
	<xsl:template match="ref-list">
		<xsl:if test="@content-type = 'bibl'">
			<xsl:text>[bibliography]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref">
		<xsl:text>* [[[</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:apply-templates select="std/std-ref" mode="std"/>
		<xsl:text>]]]</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="ref/std">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref/std/std-ref"/>
	<xsl:template match="ref/std/std-ref" mode="std">
		<xsl:text>,</xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref/std//title">
		<xsl:text>_</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>_</xsl:text>
	</xsl:template>
	
	<xsl:template match="fig-group">
		<xsl:text>[[</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>====</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="fig">
		<xsl:if test="not(parent::fig-group)">
			<xsl:text>[[</xsl:text>
			<xsl:value-of select="@id"/>
			<xsl:text>]]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="fig/caption/title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="graphic">
		<xsl:text>image::</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="graphic/processing-instruction('isoimg-id')">
		<xsl:value-of select="."/>
	</xsl:template>	
	
	<xsl:template match="disp-quote">
		<xsl:text>[quote, </xsl:text><xsl:value-of select="related-object"/><xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>_____</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>_____</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="disp-quote/p">
		<xsl:apply-templates />		
	</xsl:template>
	
	<xsl:template match="disp-quote/related-object"/>
		
	<xsl:template match="code">
		<xsl:text>[source,</xsl:text><xsl:value-of select="@language"/><xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>--</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>--</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="element-citation">
		<xsl:text>&#xa;</xsl:text>		
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="annotation">
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="num" select="//*[@rid = $id]/text()"/>
		<xsl:text>&lt;</xsl:text><xsl:value-of select="$num"/><xsl:text>&gt; </xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="annotation/p">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="disp-formula">
		<xsl:text>stem:[</xsl:text>				
		<xsl:apply-templates />		
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<!-- MathML -->
	<!-- https://www.metanorma.com/blog/2019-05-29-latex-math-stem/ -->
	<xsl:template match="mml:*">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:if test="local-name() = 'math'">
			<xsl:text> xmlns="http://www.w3.org/1998/Math/MathML"</xsl:text>
		</xsl:if>
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:text>="</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:text>&gt;</xsl:text>		
		<xsl:apply-templates />		
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	
	<xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="'/'"/>
		<xsl:if test="string-length($pText) >0">
			<item>
				<xsl:value-of select="normalize-space(substring-before(concat($pText, $sep), $sep))"/>
			</item>
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
				<xsl:with-param name="sep" select="$sep"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="getLevel">
		<xsl:variable name="level_total" select="count(ancestor::*)"/>
		
		<xsl:variable name="level">
			<xsl:value-of select="$level_total - 2"/>
		</xsl:variable>
			
		<xsl:call-template name="repeat">
			<xsl:with-param name="count" select="$level + 1"/>
		</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template name="getLevelListItem">
		<xsl:param name="list-label" select="'*'"/>
		<xsl:variable name="level" select="count(ancestor-or-self::list)"/>
			
		<xsl:call-template name="repeat">
			<xsl:with-param name="char" select="$list-label"/>
			<xsl:with-param name="count" select="$level"/>
		</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template name="repeat">
		<xsl:param name="char" select="'='"/>
		<xsl:param name="count" />
		<xsl:if test="$count &gt; 0">
			<xsl:value-of select="$char" />
				<xsl:call-template name="repeat">
					<xsl:with-param name="char" select="$char" />
					<xsl:with-param name="count" select="$count - 1" />
				</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>