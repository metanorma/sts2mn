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
	
	<xsl:variable name="language" select="//standard/front/iso-meta/doc-ident/language"/>
	
	<xsl:variable name="path_" select="concat('body', $pathSeparator, 'body-#lang.adoc[]')"/>
			
	<xsl:variable name="path" select="java:replaceAll(java:java.lang.String.new($path_),'#lang',$language)"/>
	
	<xsl:template match="adoption">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="standard">		
		<xsl:apply-templates />
	</xsl:template>
	
	
	<!-- <xsl:template match="adoption/text() | adoption-front/text()"/> -->
	
	<!-- <xsl:template match="/*"> -->
	<xsl:template match="//standard/front | //adoption/adoption-front">
		<!-- = ISO 8601-1 -->
		<xsl:apply-templates select="*/std-ident"/> <!-- * -> iso-meta -->
		<!-- :docnumber: 8601 -->
		<xsl:apply-templates select="*/std-ident/doc-number"/>		
		<!-- :partnumber: 1 -->
		<xsl:apply-templates select="*/std-ident/part-number"/>		
		<!-- :edition: 1 -->
		<xsl:apply-templates select="*/std-ident/edition"/>		
		<!-- :copyright-year: 2019 -->
		<xsl:apply-templates select="*/permissions/copyright-year"/>
		<!-- :language: en -->
		<xsl:apply-templates select="*/doc-ident/language"/>
		<!-- :title-intro-en: Date and time
		:title-main-en: Representations for information interchange
		:title-part-en: Basic rules
		:title-intro-fr: Date et l'heure
		:title-main-fr: Représentations pour l'échange d'information
		:title-part-fr: Règles de base -->
		<xsl:apply-templates select="*/title-wrap"/>		
		<!-- :doctype: international-standard -->
		<xsl:apply-templates select="*/std-ident/doc-type"/>		
		<!-- :docstage: 60
		:docsubstage: 60 -->		
		<xsl:apply-templates select="*/doc-ident/release-version"/>
		
		<!-- 
		:technical-committee-type: TC
		:technical-committee-number: 154
		:technical-committee: Processes, data elements and documents in commerce, industry and administration
		:workgroup-type: WG
		:workgroup-number: 5
		:workgroup: Representation of dates and times -->		
		<xsl:apply-templates select="*/comm-ref"/>
		
		<!-- :secretariat: SAC -->
		<xsl:apply-templates select="*/secretariat"/>
		
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
			
			<xsl:if test="not(//adoption)"> <!-- for adoption create a one adoc -->
				<xsl:text>include::</xsl:text><xsl:value-of select="$path"/>
				<xsl:text>&#xa;</xsl:text>
				
				<xsl:text>///SPLIT </xsl:text><xsl:value-of select="$path"/>
				<xsl:text>&#xa;</xsl:text>
			</xsl:if>
			
			<xsl:apply-templates select="*[local-name() != 'iso-meta' and local-name() != 'std-meta']"/>
			<!-- <xsl:apply-templates select="/standard/body"/>			
			<xsl:apply-templates select="/standard/back"/> -->
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//standard/body">
		<xsl:if test="$split-bibdata != 'true'">
			<xsl:apply-templates select="../back/fn-group" mode="footnotes"/>
			<xsl:apply-templates />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//standard/back">
		<xsl:if test="$split-bibdata != 'true'">			
			<xsl:apply-templates />
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]">
		<xsl:text>= </xsl:text>
		<xsl:value-of select="originator"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="doc-number"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="part-number"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/doc-number">
		<xsl:text>:docnumber: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/part-number">
		<xsl:text>:partnumber: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/edition">
		<xsl:text>:edition: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="permissions[ancestor::front or ancestor::adoption-front]/copyright-year">
		<xsl:text>:copyright-year: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="doc-ident[ancestor::front or ancestor::adoption-front]/language">
		<xsl:text>:language: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/text()"/>
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]">
		<xsl:apply-templates>
			<xsl:with-param name="lang" select="@xml:lang"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/intro">
		<xsl:param name="lang"/>
		<xsl:text>:title-intro-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/main">
		<xsl:param name="lang"/>
		<xsl:text>:title-main-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/compl">
		<xsl:param name="lang"/>
		<xsl:text>:title-part-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/full">
		<xsl:text></xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/doc-type">
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
	
	<xsl:template match="doc-ident[ancestor::front or ancestor::adoption-front]/release-version">
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
	
	<xsl:template match="comm-ref[ancestor::front or ancestor::adoption-front]">
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
	
	<xsl:template match="secretariat[ancestor::front or ancestor::adoption-front]">
		<xsl:text>:secretariat: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<!-- =========== -->
	<!-- end bibdata (standard/front) -->
	
	
	
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
					<xsl:choose>
						<xsl:when test="@id">
							<xsl:value-of select="@id"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@sec-type"/>
						</xsl:otherwise>
					</xsl:choose>
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
		<xsl:if test="local-name(preceding-sibling::node()) != ''">
			<xsl:text> </xsl:text>
		</xsl:if>		
		<xsl:text>&lt;&lt;</xsl:text><xsl:apply-templates /><xsl:text>&gt;&gt;</xsl:text>
		<xsl:if test="local-name(preceding-sibling::node()) != ''">
			<xsl:text> </xsl:text>
		</xsl:if>		
	</xsl:template>
	
	<xsl:template match="std-id-group"/>
	
	<xsl:template match="std-ref">
		<xsl:apply-templates />
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
		<xsl:apply-templates select="@list-type"/>
		
		<xsl:apply-templates/>
		<xsl:if test="not(parent::list-item)">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="list/@list-type">
		<xsl:variable name="listtype">
			<xsl:choose>
				<xsl:when test=". = 'alpha-lower'">loweralpha</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$listtype != ''">		
			<xsl:text>[</xsl:text>
			<xsl:value-of select="$listtype"/>
			<xsl:text>]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="list/list-item">
		<xsl:choose>
			<xsl:when test="ancestor::list/@list-type = 'bullet' or 
							ancestor::list/@list-type = 'dash' or
							ancestor::list/@list-type = 'simple'">				
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
	
	<xsl:template match="sc">
		<xsl:text>[smallcap]#</xsl:text>
		<xsl:apply-templates />
		<xsl:text>#</xsl:text>
	</xsl:template>
	
	<xsl:template match="ext-link">
		<xsl:apply-templates />
		<xsl:apply-templates select="@xlink:href"/>
	</xsl:template>
	
	<xsl:template match="ext-link/@xlink:href">
		<xsl:text>[</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="xref">
		
		<xsl:choose>
			<xsl:when test="@ref-type = 'fn'">
				<xsl:variable name="rid" select="@rid"/>
				<!-- find <fn id="$rid" -->
				<xsl:choose>
					<!-- in fn in fn-group -->
					<xsl:when test="//fn[@id = current()/@rid]/ancestor::fn-group">
						<xsl:text>{</xsl:text>
						<xsl:value-of select="@rid"/>
						<xsl:text>}</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<!-- fn will be processed after xref -->
						<!-- no need to process right now -->
						<!-- <xsl:apply-templates select="//fn[@id = current()/@rid]"/> -->
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:when>
			<!-- <xsl:when test="@ref-type = 'fn' and ancestor::td">
				<xsl:choose>
					<xsl:when test="//fn[@id = current()/@rid]/ancestor::fn-group">
						<xsl:text>{</xsl:text>
						<xsl:value-of select="@rid"/>
						<xsl:text>}</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> footnote:</xsl:text>
						<xsl:value-of select="@rid"/>
						<xsl:text>[]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@ref-type = 'fn' and ancestor::def-item">
				<xsl:text> footnote:</xsl:text>
				<xsl:value-of select="@rid"/>
				<xsl:text>[]</xsl:text>
			</xsl:when>
			<xsl:when test="@ref-type = 'fn'"/> -->
			<xsl:when test="@ref-type = 'other'">
				<xsl:text>&lt;</xsl:text><xsl:value-of select="."/><xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise> <!-- example: ref-type="sec" "table" "app" -->
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
		<xsl:apply-templates/>
	</xsl:template>
		
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
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>+</xsl:text>
				<xsl:text>&#xa; </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:apply-templates select="td[2]" mode="dl"/>
		<xsl:text>&#xa;</xsl:text>
		
		<xsl:if test="count(following-sibling::tr[1]/td[1]//node()) &gt; 0 or position() = last()">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<!-- count=<xsl:value-of select="count(following-sibling::tr/td[1]//node())"/> -->
		<!-- <xsl:if test="following-sibling::tr/td[1]/* != 0">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if> -->
	</xsl:template>
	
	<xsl:template match="td" mode="dl">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="table-wrap">
		<xsl:text>[[</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates select="table-wrap-foot/fn-group" mode="footnotes"/>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="table-wrap/caption/title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="table">
		<xsl:text>[</xsl:text>
		<xsl:text>cols="</xsl:text>
		<xsl:variable name="simple-table">
			<xsl:call-template  name="getSimpleTable"/>
		</xsl:variable>
		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="col">
					<xsl:value-of select="count(col)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>				
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="col">				
				<xsl:for-each select="col">
					<xsl:variable name="width" select="translate(@width, '%cm', '')"/>
					<xsl:value-of select="round($width)"/>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="cols">
					<xsl:call-template name="repeat">
						<xsl:with-param name="char" select="'1,'"/>
						<xsl:with-param name="count" select="$cols-count"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="substring($cols,1,string-length($cols)-1)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>"</xsl:text>
		<xsl:if test="thead">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:variable name="options">
			<xsl:if test="thead">
				<option>header</option>
			</xsl:if>
			<xsl:if test="ancestor::table-wrap/table-wrap-foot[count(*[local-name() != 'fn-group']) != 0]">
				<option>footer</option>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="count(xalan:nodeset($options)/option) != 0">
			<xsl:text>options="</xsl:text>
				<xsl:for-each select="xalan:nodeset($options)/option">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
			<xsl:text>"</xsl:text>
			<xsl:if test="count(thead/tr) &gt; 1">
				<xsl:text>,headerrows=</xsl:text>
				<xsl:value-of select="count(thead/tr)"/>
			</xsl:if>
		</xsl:if>
		<!-- <xsl:if test="thead">
			<xsl:text>options="header"</xsl:text>
		</xsl:if> -->
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates select="../table-wrap-foot" mode="footer">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>
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
		<xsl:if test="position() != 1">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="th">
		<xsl:call-template name="spanProcessing"/>
		<xsl:text>|</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="td">
		<xsl:call-template name="spanProcessing"/>		
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
	
	<xsl:template name="spanProcessing">		
		<xsl:if test="@colspan &gt; 1 or @rowspan &gt; 1">
			<xsl:choose>
				<xsl:when test="@colspan &gt; 1 and @rowspan &gt; 1">
					<xsl:value-of select="@colspan"/><xsl:text>.</xsl:text><xsl:value-of select="@rowspan"/>
				</xsl:when>
				<xsl:when test="@colspan &gt; 1">
					<xsl:value-of select="@colspan"/>
				</xsl:when>
				<xsl:when test="@rowspan &gt; 1">
					<xsl:text>.</xsl:text><xsl:value-of select="@rowspan"/>
				</xsl:when>
			</xsl:choose>			
			<xsl:text>+</xsl:text>
		</xsl:if>
		<xsl:if test="list or def-list">a</xsl:if>
	</xsl:template>
	
	<xsl:template match="td/p">
		<xsl:text> +</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="table-wrap-foot"/>
	<xsl:template match="table-wrap-foot" mode="footer">		
		<xsl:param name="cols-count"/>
		<xsl:if test="*[local-name() != 'fn-group']">
			<xsl:value-of select="$cols-count"/><xsl:text>+</xsl:text>		
			<xsl:apply-templates/>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="table-wrap-foot/fn-group"/>
	<xsl:template match="back/fn-group"/>
	
	<xsl:template match="fn-group" mode="footnotes">
		<xsl:apply-templates/>	
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="fn-group">
		<xsl:apply-templates/>	
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="fn-group/fn">
		<xsl:text>:</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>: footnote:[</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="fn-group/fn/label"/>
	
	<xsl:template match="fn-group/fn/p">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- <xsl:template match="fn-group">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="fn-group/fn">
		<xsl:apply-templates />
		<xsl:if test="position() != last()">
			<xsl:text> +</xsl:text>
		</xsl:if>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="fn-group/fn/label">
		<xsl:value-of select="."/><xsl:text>| </xsl:text>
	</xsl:template>	
	 -->
	
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
		<xsl:text>* </xsl:text>
		<xsl:if test="@id or std/std-ref">
			<xsl:text>[[[</xsl:text>
			<xsl:value-of select="@id"/>
			<xsl:apply-templates select="std/std-ref" mode="std"/>
			<xsl:apply-templates select="mixed-citation/std" mode="std"/>
			<xsl:text>]]]</xsl:text>
		</xsl:if>
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
	
	<xsl:template match="ref/mixed-citation/std" mode="std">
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
		<xsl:if test="not(processing-instruction('isoimg-id'))">
			<xsl:value-of select="@xlink:href"/>
		</xsl:if>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="graphic/processing-instruction('isoimg-id')">
		<xsl:value-of select="."/>
	</xsl:template>	

	<xsl:template match="object-id">
		<xsl:choose>
			<xsl:when test="@pub-id-type = 'publisher-id'">
				<xsl:text>[</xsl:text>
					<xsl:apply-templates />
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
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
	
	<xsl:template match="inline-formula">		
		<xsl:text>stem:[</xsl:text>				
		<xsl:apply-templates />		
		<xsl:text>]</xsl:text>		
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
		<!-- <xsl:text>a+b</xsl:text> -->
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
	
	
	<xsl:template match="def-list">
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="def-list/title">
		<xsl:text>*</xsl:text><xsl:apply-templates /><xsl:text>*</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="def-item">
		<xsl:apply-templates />		
	</xsl:template>
	
	<xsl:template match="def-item/term">
		<xsl:apply-templates/>
		<xsl:if test="count(node()) = 0"><xsl:text> </xsl:text></xsl:if>
		<xsl:text>::</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="def-item/def">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<xsl:template match="named-content">
		<xsl:apply-templates/><xsl:text> </xsl:text>
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
		
		<xsl:variable name="level_standard" select="count(ancestor::standard/ancestor::*)"/>
		
		<xsl:variable name="level">
			<xsl:choose>
				<xsl:when test="ancestor::back">
					<xsl:value-of select="$level_total - $level_standard - 3"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level_total - $level_standard - 2"/>
				</xsl:otherwise>
			</xsl:choose>
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
	
	
		<!-- Table normalization (colspan,rowspan processing for adding TDs) for column width calculation -->
	<xsl:template name="getSimpleTable">
		<xsl:variable name="simple-table">
		
			<!-- Step 1. colspan processing -->
			<xsl:variable name="simple-table-colspan">
				<tbody>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</tbody>
			</xsl:variable>
			
			<!-- Step 2. rowspan processing -->
			<xsl:variable name="simple-table-rowspan">
				<xsl:apply-templates select="xalan:nodeset($simple-table-colspan)" mode="simple-table-rowspan"/>
			</xsl:variable>
			
			<xsl:copy-of select="xalan:nodeset($simple-table-rowspan)"/>
					
			<!-- <xsl:choose>
				<xsl:when test="current()//*[local-name()='th'][@colspan] or current()//*[local-name()='td'][@colspan] ">
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="current()"/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:variable>
		<xsl:copy-of select="$simple-table"/>
	</xsl:template>
		
	<!-- ===================== -->
	<!-- 1. mode "simple-table-colspan" 
			1.1. remove thead, tbody, fn
			1.2. rename th -> td
			1.3. repeating N td with colspan=N
			1.4. remove namespace
			1.5. remove @colspan attribute
			1.6. add @divide attribute for divide text width in further processing 
	-->
	<!-- ===================== -->	
	<xsl:template match="*[local-name()='thead'] | *[local-name()='tbody']" mode="simple-table-colspan">
		<xsl:apply-templates mode="simple-table-colspan"/>
	</xsl:template>
	<xsl:template match="*[local-name()='fn']" mode="simple-table-colspan"/>
	
	<xsl:template match="*[local-name()='th'] | *[local-name()='td']" mode="simple-table-colspan">
		<xsl:choose>
			<xsl:when test="@colspan">
				<xsl:variable name="td">
					<xsl:element name="td">
						<xsl:attribute name="divide"><xsl:value-of select="@colspan"/></xsl:attribute>
						<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
						<xsl:apply-templates mode="simple-table-colspan"/>
					</xsl:element>
				</xsl:variable>
				<xsl:call-template name="repeatNode">
					<xsl:with-param name="count" select="@colspan"/>
					<xsl:with-param name="node" select="$td"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="td">
					<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@colspan" mode="simple-table-colspan"/>
	
	<xsl:template match="*[local-name()='tr']" mode="simple-table-colspan">
		<xsl:element name="tr">
			<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
			<xsl:apply-templates mode="simple-table-colspan"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="simple-table-colspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-colspan"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- repeat node 'count' times -->
	<xsl:template name="repeatNode">
		<xsl:param name="count"/>
		<xsl:param name="node"/>
		
		<xsl:if test="$count &gt; 0">
			<xsl:call-template name="repeatNode">
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
			<xsl:copy-of select="$node"/>
		</xsl:if>
	</xsl:template>
	<!-- End mode simple-table-colspan  -->
	<!-- ===================== -->
	<!-- ===================== -->
	
	<!-- ===================== -->
	<!-- 2. mode "simple-table-rowspan" 
	Row span processing, more information http://andrewjwelch.com/code/xslt/table/table-normalization.html	-->
	<!-- ===================== -->		
	<xsl:template match="@*|node()" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-rowspan"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="tbody" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:copy-of select="tr[1]" />
				<xsl:apply-templates select="tr[2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="tr[1]" />
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="tr" mode="simple-table-rowspan">
		<xsl:param name="previousRow"/>
		<xsl:variable name="currentRow" select="." />
	
		<xsl:variable name="normalizedTDs">
				<xsl:for-each select="xalan:nodeset($previousRow)//td">
						<xsl:choose>
								<xsl:when test="@rowspan &gt; 1">
										<xsl:copy>
												<xsl:attribute name="rowspan">
														<xsl:value-of select="@rowspan - 1" />
												</xsl:attribute>
												<xsl:copy-of select="@*[not(name() = 'rowspan')]" />
												<xsl:copy-of select="node()" />
										</xsl:copy>
								</xsl:when>
								<xsl:otherwise>
										<xsl:copy-of select="$currentRow/td[1 + count(current()/preceding-sibling::td[not(@rowspan) or (@rowspan = 1)])]" />
								</xsl:otherwise>
						</xsl:choose>
				</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="newRow">
				<xsl:copy>
						<xsl:copy-of select="$currentRow/@*" />
						<xsl:copy-of select="xalan:nodeset($normalizedTDs)" />
				</xsl:copy>
		</xsl:variable>
		<xsl:copy-of select="$newRow" />

		<xsl:apply-templates select="following-sibling::tr[1]" mode="simple-table-rowspan">
				<xsl:with-param name="previousRow" select="$newRow" />
		</xsl:apply-templates>
	</xsl:template>
	<!-- End mode simple-table-rowspan  -->
	<!-- ===================== -->	
	<!-- ===================== -->	
	
</xsl:stylesheet>