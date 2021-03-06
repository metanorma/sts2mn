<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:mml="http://www.w3.org/1998/Math/MathML" 
		xmlns:tbx="urn:iso:std:iso:30042:ed-1" 
		xmlns:xlink="http://www.w3.org/1999/xlink" 
		xmlns:xalan="http://xml.apache.org/xalan" 
		xmlns:java="http://xml.apache.org/xalan/java" 
		xmlns:redirect="http://xml.apache.org/xalan/redirect"
		exclude-result-prefixes="mml tbx xlink xalan java" 
		extension-element-prefixes="redirect"
		version="1.0">

	<xsl:output method="text" encoding="UTF-8"/>
	
	<xsl:param name="split-bibdata">false</xsl:param>
	
	<xsl:param name="debug">false</xsl:param>

	<xsl:param name="docfile_name">document</xsl:param> <!-- Example: iso-tc154-8601-1-en , or document -->
	<xsl:param name="docfile_ext">adoc</xsl:param> <!-- adoc -->
	
	<xsl:param name="pathSeparator" select="'/'"/>
	
	<xsl:param name="outpath"/>
	
	<xsl:param name="imagesdir" select="'images'"/>
	
	<xsl:variable name="language" select="//standard/front/*/doc-ident/language"/>
	
	<xsl:variable name="organization">
	<xsl:choose>
			<xsl:when test="/standard/front/nat-meta/@originator = 'BSI' or /standard/front/nat-meta/@originator = 'PAS' or /standard/front/iso-meta/secretariat = 'BSI'">BSI</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/standard/front/*/doc-ident/sdo"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="path_" select="concat('body', $pathSeparator, 'body-#lang.adoc[]')"/>
			
	<xsl:variable name="path" select="java:replaceAll(java:java.lang.String.new($path_),'#lang',$language)"/>
	
	<xsl:variable name="refs">
		<xsl:for-each select="//ref">
			<xsl:variable name="text" select="concat(std/std-ref, std/italic/std-ref, std/bold/std-ref, std/italic2/std-ref, std/bold2/std-ref)"/>
			<ref id="{@id}" std-ref="{$text}"/>
			
			<xsl:variable name="isDated">
				<xsl:choose>
					<xsl:when test="string-length($text) - string-length(translate($text, ':', '')) = 1">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$isDated = 'true'">
				<ref id="{@id}" std-ref="{substring-before($text, ':')}"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="sdo">
		<xsl:choose>
			<xsl:when test="normalize-space(//standard/front/*/doc-ident/sdo) != ''">
				<xsl:value-of  select="java:toLowerCase(java:java.lang.String.new(//standard/front/*/doc-ident/sdo))"/>
			</xsl:when>
			<xsl:otherwise>iso</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="taskCopyImagesFilename" select="concat($outpath, '/task.copyImages.adoc')"/>
	
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test=".//sub-part"> <!-- multiple documents in one xml -->
				<xsl:variable name="xml">
					<xsl:copy-of select="."/>
				</xsl:variable>
				
				<!-- create separate document for each  sub-part -->
				<xsl:variable name="documents">
					<xsl:for-each select="standard/body/sub-part">
					
						<xsl:variable name="number"><xsl:number/></xsl:variable>
						
						<xsl:apply-templates select="xalan:nodeset($xml)" mode="sub-part">
							<xsl:with-param name="doc-number" select="number($number)"/>
						</xsl:apply-templates>
						
					</xsl:for-each>
				</xsl:variable>
				
				<!-- process each document separately -->
				<xsl:for-each select="xalan:nodeset($documents)/*"> 
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				
				<!-- create document.yml file -->
				<redirect:write file="{$outpath}/{$docfile_name}.yml">
					<xsl:call-template name="insertCollectionData">
						<xsl:with-param name="documents" select="$documents"/>
					</xsl:call-template>
				</redirect:write>
				
				<redirect:open file="{$taskCopyImagesFilename}"/>
				<xsl:call-template name="insertTaskImageList"/>
				
				<xsl:for-each select="xalan:nodeset($documents)/*">
					<xsl:variable name="doctype">
						<xsl:apply-templates select=".//nat-meta/std-ident/doc-type | .//iso-meta/std-ident/doc-type | .//std-meta/std-ident/doc-type"/>
					</xsl:variable>
					<xsl:if test="contains($doctype,'publicly-available-specification')"> <!-- PAS -->
						<redirect:write file="{$taskCopyImagesFilename}">
							<xsl:text>copyimage::</xsl:text><xsl:call-template name="getCoverPageImage"/><xsl:text>&#xa;</xsl:text>
						</redirect:write>
					</xsl:if>
					
				</xsl:for-each>
				<redirect:close file="{$taskCopyImagesFilename}"/>
				
			</xsl:when>
			<xsl:otherwise><!-- no sub-part elements -->
				<xsl:apply-templates />
				<xsl:call-template name="insertTaskImageList"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="adoption">
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:open file="{$outpath}/{$docfile}"/>
		<xsl:apply-templates />
		<redirect:close file="{$outpath}/{$docfile}"/>
	</xsl:template>
	
	<xsl:template match="standard">
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:open file="{$outpath}/{$docfile}"/>
		<xsl:apply-templates />
		<redirect:close file="{$outpath}/{$docfile}"/>
	</xsl:template>
	
	
	<!-- <xsl:template match="adoption/text() | adoption-front/text()"/> -->
	
	<!-- <xsl:template match="/*"> -->
	<xsl:template match="//standard/front | //adoption/adoption-front">
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
	
			<!-- nat-meta -> iso-meta -> reg-meta -> std-meta -->
			<xsl:for-each select="nat-meta">
				<xsl:call-template name="xxx-meta">
					<xsl:with-param name="include_iso_meta">true</xsl:with-param>
					<xsl:with-param name="include_reg_meta">true</xsl:with-param>
					<xsl:with-param name="include_std_meta">true</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			
			<xsl:if test="not(nat-meta)">
				<xsl:for-each select="iso-meta">
					<xsl:call-template name="xxx-meta">
						<xsl:with-param name="include_reg_meta">true</xsl:with-param>
						<xsl:with-param name="include_std_meta">true</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			
				<xsl:if test="not(iso-meta)">
					<xsl:for-each select="reg-meta">
						<xsl:call-template name="xxx-meta">
							<xsl:with-param name="include_std_meta">true</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
					
					<xsl:if test="not(reg-meta)">
						<xsl:for-each select="std-meta">
							<xsl:call-template name="xxx-meta"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			
			
			<xsl:text>:mn-document-class: </xsl:text><xsl:value-of select="$sdo"/>
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>:mn-output-extensions: xml,html</xsl:text> <!-- ,doc,html_alt -->
			<xsl:text>&#xa;</xsl:text>
			
			<xsl:text>:local-cache-only:</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>:data-uri-image:</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			
			<xsl:text>:imagesdir: </xsl:text><xsl:value-of select="$imagesdir"/>
			<xsl:text>&#xa;</xsl:text>
			
			<!-- The :docfile: attribute is no longer used -->
			<!-- <xsl:if test="normalize-space($docfile) != ''">
				<xsl:text>:docfile: </xsl:text><xsl:value-of select="$docfile"/>
				<xsl:text>&#xa;</xsl:text>
			</xsl:if> -->
			
			<xsl:text>&#xa;</xsl:text>

		</redirect:write>

		<xsl:if test="$split-bibdata != 'true'">
			
			<!-- if in front there are another elements, except xxx-meta -->
			<xsl:for-each select="*[local-name() != 'iso-meta' and local-name() != 'nat-meta' and local-name() != 'reg-meta' and local-name() != 'std-meta']">
				<xsl:variable name="number_"><xsl:number /></xsl:variable>
				<xsl:variable name="number" select="format-number($number_, '00')"/>
				<xsl:variable name="section_name">
					<xsl:value-of select="@sec-type"/>
					<xsl:if test="not(@sec-type)"><xsl:value-of select="@id"/></xsl:if>
				</xsl:variable>
				<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
				<xsl:variable name="filename">
					<xsl:value-of select="$sectionsFolder"/><xsl:text>/00-</xsl:text><xsl:value-of select="$number"/>-<xsl:value-of select="$section_name"/><xsl:text>.adoc</xsl:text>
				</xsl:variable>
				<redirect:write file="{$outpath}/{$filename}">
					<xsl:text>&#xa;</xsl:text>
					<xsl:apply-templates select="."/>
				</redirect:write>
				<redirect:write file="{$outpath}/{$docfile}">
					<xsl:text>include::</xsl:text><xsl:value-of select="$filename"/><xsl:text>[]</xsl:text>
					<xsl:text>&#xa;&#xa;</xsl:text>
				</redirect:write>
			</xsl:for-each>
			
			<!-- <xsl:apply-templates select="/standard/body"/>			
			<xsl:apply-templates select="/standard/back"/> -->
		</xsl:if>
		
		
	</xsl:template>
	
	<xsl:template name="xxx-meta">
		<xsl:param name="include_iso_meta">false</xsl:param>
		<xsl:param name="include_reg_meta">false</xsl:param>
		<xsl:param name="include_std_meta">false</xsl:param>
		<xsl:param name="originator"/>
		
		<!-- = ISO 8601-1 -->
		<xsl:apply-templates select="std-ident"/> <!-- * -> iso-meta -->
		<!-- :docnumber: 8601 -->
		<xsl:apply-templates select="std-ident/doc-number"/>		
		<!-- :partnumber: 1 -->
		<xsl:apply-templates select="std-ident/part-number"/>		
		<!-- :edition: 1 -->
		<xsl:apply-templates select="std-ident/edition"/>		
		<!-- :copyright-year: 2019 -->
		<xsl:apply-templates select="permissions/copyright-year"/>
		
		
		<!-- :published-date: -->
		<xsl:apply-templates select="pub-date"/>
		
		<!-- :date: release 2020-01-01 -->
		<xsl:apply-templates select="release-date"/>
		
		
		<!-- :language: en -->
		<xsl:apply-templates select="doc-ident/language"/>
		<!-- :title-intro-en: Date and time
		:title-main-en: Representations for information interchange
		:title-part-en: Basic rules
		:title-intro-fr: Date et l'heure
		:title-main-fr: Représentations pour l'échange d'information
		:title-part-fr: Règles de base -->
		<xsl:apply-templates select="title-wrap"/>		
		<!-- :doctype: international-standard -->
		<xsl:variable name="doctype">
			<xsl:apply-templates select="std-ident/doc-type"/>		
		</xsl:variable>
		<xsl:text>:doctype: </xsl:text><xsl:value-of select="$doctype"/>
		<xsl:text>&#xa;</xsl:text>
		
		<!-- :docstage: 60
		:docsubstage: 60 -->		
		<xsl:apply-templates select="doc-ident/release-version"/>
		
		<xsl:if test="ics">
			<xsl:text>:library-ics: </xsl:text>
			<xsl:for-each select="ics">
				<xsl:value-of select="."/><xsl:if test="position() != last()">,</xsl:if>
			</xsl:for-each>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		
		<xsl:apply-templates select="custom-meta-group/custom-meta[meta-name = 'ISBN']/meta-value"/>
		
		<xsl:choose>
			<xsl:when test="$organization = 'BSI'">
				<xsl:variable name="data">
					<xsl:for-each select="comm-ref[normalize-space() != '']">
						<item>Committee reference <xsl:value-of select="."/></item> <!-- Example: Committee reference DEF/1 -->
					</xsl:for-each>
					<xsl:if test="std-xref[@type='isPublishedFormatOf']">
						<item>
							<xsl:text>Draft for comment </xsl:text>
							<xsl:for-each select="std-xref[@type='isPublishedFormatOf']">
								<xsl:value-of select="std-ref"/><!-- Example: Draft for comment 20/30387670 DC -->
								<xsl:if test="position() != last()">,</xsl:if>
							</xsl:for-each>
					</item>
					</xsl:if>
				</xsl:variable>
				<!-- Example: :bsi-related: Committee reference DEF/1; Draft for comment 20/30387670 DC -->
				<xsl:if test="xalan:nodeset($data)//item">
					<xsl:text>:bsi-related: </xsl:text>
					<xsl:for-each select="xalan:nodeset($data)//item">
						<xsl:value-of select="."/>
						<xsl:if test="position() != last()">; </xsl:if>
					</xsl:for-each>
					<xsl:text>&#xa;</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
					<!-- 
					:technical-committee-type: TC
					:technical-committee-number: 154
					:technical-committee: Processes, data elements and documents in commerce, industry and administration
					:workgroup-type: WG
					:workgroup-number: 5
					:workgroup: Representation of dates and times -->		
					<xsl:apply-templates select="comm-ref"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- :secretariat: SAC -->
		<xsl:apply-templates select="secretariat"/>
		
		<!-- relation bibitem -->
		<xsl:if test="$include_iso_meta = 'true'">
			<xsl:for-each select="ancestor::front/iso-meta">
				<!-- https://github.com/metanorma/sts2mn/issues/31 -->
				<!-- <xsl:call-template name="xxx-meta"/> --> <!-- process iso-meta -->
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="$include_reg_meta = 'true'">
			<xsl:for-each select="ancestor::front/reg-meta">
				<!-- https://github.com/metanorma/sts2mn/issues/31 -->
				<!-- <xsl:call-template name="xxx-meta"> --> <!-- process reg-meta -->
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="$doctype = 'publicly-available-specification'"> <!-- PAS -->
			<xsl:text>:coverpage-image: </xsl:text>
			<xsl:value-of select="$imagesdir"/>
			<xsl:text>/</xsl:text>
			<xsl:call-template name="getCoverPageImage"/>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>

	</xsl:template>
	
	<xsl:template name="getCoverPageImage">
		<xsl:variable name="doc-number" select="ancestor-or-self::standard/@doc-number" />
		<xsl:text>coverpage</xsl:text>
		<xsl:if test="$doc-number != ''">.<xsl:value-of select="$doc-number"/></xsl:if>
		<xsl:text>.png</xsl:text>
	</xsl:template>
	
	<xsl:template match="//standard/body">
		<xsl:if test="$split-bibdata != 'true'">
			<!-- <xsl:apply-templates select="../back/fn-group" mode="footnotes"/> -->
			<xsl:apply-templates />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//standard/back">
		<xsl:if test="$split-bibdata != 'true'">		
			<xsl:apply-templates select="ref-list[@content-type = 'bibl']" />
			<xsl:apply-templates select="*[not(local-name() = 'ref-list' and @content-type = 'bibl')]" />
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]">
		<xsl:text>= </xsl:text>
		<xsl:value-of select="originator"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="doc-number"/>
		
		<xsl:if test="part-number != ''">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="part-number"/>
		</xsl:if>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/doc-number[normalize-space(.) != '']">
		<xsl:text>:docnumber: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/part-number[normalize-space(.) != '']">		
		<xsl:text>:partnumber: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/edition[normalize-space(.) != '']">
		<xsl:text>:edition: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="permissions[ancestor::front or ancestor::adoption-front]/copyright-year[normalize-space(.) != '']">
		<xsl:text>:copyright-year: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="pub-date[ancestor::front or ancestor::adoption-front]">
		<xsl:if test="normalize-space() != ''">
			<xsl:text>:published-date: </xsl:text><xsl:value-of select="."/>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="release-date[ancestor::front or ancestor::adoption-front]">
		<xsl:if test="normalize-space() != ''">
			<xsl:text>:date: release </xsl:text><xsl:value-of select="."/>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="doc-ident[ancestor::front or ancestor::adoption-front]/language[normalize-space(.) != '']">
		<xsl:text>:language: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/text()"/>
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]">	
		<xsl:choose>
			<xsl:when test="$organization = 'BSI'">
				
				<!-- priority: get intro and compl from separate field -->
				<xsl:variable name="titles">
					<xsl:apply-templates select="intro[normalize-space() != '']" mode="bibdata"/>
					<xsl:apply-templates select="compl[normalize-space() != '']" mode="bibdata"/>
					<xsl:if test="normalize-space(main) = ''">
						<xsl:apply-templates select="full[normalize-space() != '']" mode="bibdata_title_full"/>
					</xsl:if>
					<xsl:if test="normalize-space(intro) = ''">
						<xsl:apply-templates select="main[normalize-space() != '']" mode="bibdata_title_full"/>
					</xsl:if>
					<xsl:if test="normalize-space(intro) != ''">
						<xsl:apply-templates select="main[normalize-space() != '']" mode="bibdata"/>
					</xsl:if>
				</xsl:variable>

				<xsl:variable name="title_components">
					<xsl:copy-of select="xalan:nodeset($titles)/*[@type='title-intro'][1]"/>
					<xsl:copy-of select="xalan:nodeset($titles)/*[@type='title-main'][1]"/>
					<xsl:copy-of select="xalan:nodeset($titles)/*[@type='title-part'][1]"/>
				</xsl:variable>
				
				<xsl:variable name="lang" select="@xml:lang"/>
				<xsl:for-each select="xalan:nodeset($title_components)/*">
					<xsl:text>:</xsl:text><xsl:value-of select="@type"/><xsl:text>-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
					<xsl:text>&#xa;</xsl:text>
				</xsl:for-each>
				
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="lang" select="@xml:lang"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="title-wrap/full | title-wrap/main" mode="bibdata_title_full">
	
		<xsl:variable name="title" select="translate(., '–', '—')"/> <!-- replace en dash to em dash -->
		<xsl:variable name="parts">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="$title"/>
				<xsl:with-param name="sep" select="'—'"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="lang" select="../@xml:lang"/>
		<xsl:for-each select="xalan:nodeset($parts)/*">
			<xsl:if test="position() = 1">
				<title language="{$lang}" format="text/plain" type="title-intro">
					<xsl:apply-templates mode="bibdata"/>
				</title>
			</xsl:if>
			<xsl:if test="position() = 2">
				<title language="{$lang}" format="text/plain" type="title-main">
					<xsl:apply-templates mode="bibdata"/>
				</title>
			</xsl:if>
			<xsl:if test="position() &gt; 2">
				<title language="{$lang}" format="text/plain" type="title-part">
					<xsl:apply-templates mode="bibdata"/>
				</title>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template match="title-wrap/intro" mode="bibdata">
		<title language="{../@xml:lang}" format="text/plain" type="title-intro">
			<xsl:apply-templates mode="bibdata"/>
		</title>
	</xsl:template>
	
	<xsl:template match="title-wrap/main" mode="bibdata">
		<title language="{../@xml:lang}" format="text/plain" type="title-main">
			<xsl:apply-templates mode="bibdata"/>
		</title>
	</xsl:template>
	
	<xsl:template match="title-wrap/compl" mode="bibdata">
		<title language="{../@xml:lang}" format="text/plain" type="title-part">
			<xsl:apply-templates mode="bibdata"/>
		</title>
	</xsl:template>
	
	
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/intro[normalize-space(.) != '']">
		<xsl:param name="lang"/>
		<xsl:text>:title-intro-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/main[normalize-space(.) != '']">
		<xsl:param name="lang"/>
		
		<xsl:variable name="title_items">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="."/>
				<xsl:with-param name="sep" select="'—'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="count(xalan:nodeset($title_items)//item) &gt; 1">
				<xsl:for-each select="xalan:nodeset($title_items)//item">
					<xsl:choose>
						<xsl:when test="position() = 1">
							<xsl:text>:title-intro-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="normalize-space(translate(., '&#xA0;', ' '))"/>
						</xsl:when>
						<xsl:when test="position() = 2">
							<xsl:text>:title-main-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="normalize-space(translate(., '&#xA0;', ' '))"/>
						</xsl:when>
						<xsl:when test="position() = 3">
							<xsl:text>:title-part-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="normalize-space(translate(., '&#xA0;', ' '))"/>
						</xsl:when>
					</xsl:choose>
					<xsl:text>&#xa;</xsl:text>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:title-main-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
				<xsl:text>&#xa;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/compl[normalize-space(.) != '']">
		<xsl:param name="lang"/>
		<xsl:text>:title-part-</xsl:text><xsl:value-of select="$lang"/><xsl:text>: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	
	
	<xsl:template match="title-wrap[ancestor::front or ancestor::adoption-front]/full[normalize-space(.) != '']">
		<xsl:text></xsl:text>
	</xsl:template>
	
	<xsl:template match="std-ident[ancestor::front or ancestor::adoption-front]/doc-type[normalize-space(.) != '']">
		<xsl:variable name="value" select="java:toLowerCase(java:java.lang.String.new(.))"/>
		<!-- https://www.niso-sts.org/TagLibrary/niso-sts-TL-1-0-html/element/doc-type.html -->
		<xsl:choose>
			<xsl:when test="$organization = 'BSI'">
				<xsl:variable name="originator" select=" normalize-space(ancestor::std-ident/originator)"/>
				<xsl:choose>
					<xsl:when test="starts-with($originator, 'BS') and $value = 'standard'">standard</xsl:when>
					<xsl:when test="starts-with($originator, 'PAS') and ($value = 'publicly available specification' or $value = 'standard')">publicly-available-specification</xsl:when>
					<xsl:when test="starts-with($originator, 'PD') and $value = 'published document'">published-document</xsl:when>
					<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$value = 'is'">international-standard</xsl:when>
			<xsl:when test="$value = 'r'">recommendation</xsl:when>
			<xsl:when test="$value = 'spec'">spec</xsl:when>
			 <xsl:otherwise>
				<xsl:value-of select="$value"/>
			 </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="doc-ident[ancestor::front or ancestor::adoption-front]/release-version[normalize-space(.) != '']">
		<!-- https://www.niso-sts.org/TagLibrary/niso-sts-TL-1-0-html/element/release-version.html -->
		<!-- Possible values: WD, CD, DIS, FDIS, IS -->
		<xsl:variable name="value" select="java:toUpperCase(java:java.lang.String.new(.))"/>
		<xsl:variable name="doctype" select="java:toLowerCase(java:java.lang.String.new(../../std-ident/doc-type))"/>
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
			<xsl:when test="$doctype = 'standard'">
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
		<xsl:choose>
			<xsl:when test="contains('TC ', .) or contains('SC ', .) or contains('WG ', .)">
				<xsl:variable name="comm-ref">
					<xsl:call-template name="split">
						<xsl:with-param name="pText" select="."/>
					</xsl:call-template>
				</xsl:variable>			
				<xsl:value-of select="count(xalan:nodeset($comm-ref)/*)"/>
				<xsl:for-each select="xalan:nodeset($comm-ref)/*">				
					<xsl:choose>
						<xsl:when test="starts-with(., 'TC ')">
							<xsl:text>:technical-committee-type: TC</xsl:text>
							<xsl:text>&#xa;</xsl:text>
							<xsl:text>:technical-committee-number: </xsl:text>					
							<xsl:value-of select="normalize-space(substring-after(., ' '))"/>
							<xsl:text>&#xa;</xsl:text>
							<!-- <xsl:text>:technical-committee: </xsl:text>
							<xsl:text>&#xa;</xsl:text> -->
						</xsl:when>
						<xsl:when test="starts-with(., 'SC ')">
							<xsl:text>:subcommittee-type: SC</xsl:text>
							<xsl:text>&#xa;</xsl:text>
							<xsl:text>:subcommittee-number: </xsl:text>
							<xsl:value-of select="normalize-space(substring-after(., ' '))"/>
							<xsl:text>&#xa;</xsl:text>
							<!-- <xsl:text>:subcommittee: </xsl:text>				
							<xsl:text>&#xa;</xsl:text> -->
						</xsl:when>
						<xsl:when test="starts-with(., 'WG ')">					
							<xsl:text>:workgroup-type: WG</xsl:text>
							<xsl:text>&#xa;</xsl:text>
							<xsl:text>:workgroup-number: </xsl:text>
							<xsl:value-of select="normalize-space(substring-after(., ' '))"/>
							<xsl:text>&#xa;</xsl:text>
							<!-- <xsl:text>:workgroup: </xsl:text>
							<xsl:text>&#xa;</xsl:text> -->
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:technical-committee-code: </xsl:text><xsl:value-of select="."/>
				<xsl:text>&#xa;</xsl:text>
				<xsl:variable name="tc_name">
					<xsl:choose>
						<xsl:when test="starts-with(., 'DEF/')">Defence standardization</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="normalize-space($tc_name) != ''">
					<xsl:text>:technical-committee-name: </xsl:text><xsl:value-of select="$tc_name"/>
					<xsl:text>&#xa;</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="secretariat[ancestor::front or ancestor::adoption-front][normalize-space(.) != '']">
		<xsl:text>:secretariat: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="custom-meta-group/custom-meta[meta-name = 'ISBN']/meta-value">
		<xsl:text>:isbn: </xsl:text><xsl:value-of select="."/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<!-- =========== -->
	<!-- end bibdata (standard/front) -->
	<!-- =========== -->
	
	<xsl:template match="front/sec[@sec-type = 'publication_info']" priority="2">
		<!-- process only Amendments/corrigenda table, because other data implemented in metanorma gem -->
		<xsl:if test="*[@content-type = 'ace-table']">
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>[.preface,type=corrigenda]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>== </xsl:text><xsl:apply-templates select="*[@content-type = 'ace-table']/caption/title[1]" mode="corrigenda_title"/>
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates select="*[@content-type = 'ace-table']"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="front/sec[@sec-type = 'publication_info']//*[@content-type = 'ace-table']/caption/title[1]" priority="2"/>
	<xsl:template match="*[@content-type = 'ace-table']/caption/title[1]" mode="corrigenda_title">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="front/sec[@sec-type = 'intro']" priority="2"> <!-- don't need to add [[introduction]] in annex, example <sec id="sec_A.1" sec-type="intro">  -->
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>[[introduction]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="body/sec[@sec-type = 'intro']" priority="2">
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$sectionsFolder}/00-introduction.adoc">
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>[[introduction]]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates />
		</redirect:write>
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
			<xsl:text>include::</xsl:text><xsl:value-of select="$sectionsFolder"/><xsl:text>/00-introduction.adoc[]</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</redirect:write>
	</xsl:template>
	
	<xsl:template match="body/sec[@sec-type = 'scope'] | front/sec[@sec-type = 'scope']" priority="2">
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$sectionsFolder}/01-scope.adoc">
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates />
		</redirect:write>
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
			<xsl:text>include::</xsl:text><xsl:value-of select="$sectionsFolder"/><xsl:text>/01-scope.adoc[]</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</redirect:write>
	</xsl:template>
	
	<!-- ======================== -->
	<!-- Normative references -->
	<!-- ======================== -->
	<xsl:template match="body/sec[@sec-type = 'norm-refs'] | front/sec[@sec-type = 'norm-refs']" priority="2">
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$sectionsFolder}/02-normrefs.adoc">
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>[bibliography]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates />
		</redirect:write>
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
			<xsl:text>include::</xsl:text><xsl:value-of select="$sectionsFolder"/><xsl:text>/02-normrefs.adoc[]</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</redirect:write>
	</xsl:template>
	
	<!-- Text before references -->
	<xsl:template match="sec[@sec-type = 'norm-refs']/p" priority="2">
		<xsl:if test="not(preceding-sibling::*[1][self::p])"> <!-- first p in norm-refs -->
			<xsl:text>[NOTE,type=boilerplate]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>--</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:call-template name="p"/>
		<xsl:if test="not(following-sibling::*[1][self::p])"> <!-- last p in norm-refs -->
			<xsl:text>--</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- ======================== -->
	<!-- END Normative references -->
	<!-- ======================== -->
	
	<!-- ======================== -->
	<!-- Terms and definitions -->
	<!-- ======================== -->
	<!-- first element in Terms and definitions section -->
	<xsl:template match="sec[@sec-type = 'terms']/title | sec[@sec-type = 'terms']//sec/title" priority="2">
	
		<xsl:call-template name="title"/>
	
		<xsl:text>[.boilerplate]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="addon">1</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$level"/>
		<xsl:choose>
			<!-- if there isn't paragraph after title -->
			<!-- https://www.metanorma.org/author/topics/document-format/section-terms/#overriding-predefined-text -->
			<xsl:when test="following-sibling::*[1][self::term-sec] or following-sibling::*[1][self::sec]">
				<xsl:text> {blank}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> My predefined text</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	<!-- ======================== -->
	<!-- END Terms and definitions -->
	<!-- ======================== -->
	
	
	<xsl:template match="body/sec">
		<xsl:variable name="sec_number" select="format-number(label, '00')" />
		<xsl:variable name="title" select="normalize-space(translate(title, ',&#x200b;&#xa0;‑','    '))"/> <!-- get first word -->
		<xsl:variable name="sec_title_">
			<xsl:choose>
				<xsl:when test="contains($title, ' ')"><xsl:value-of select="substring-before($title,' ')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$title"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sec_title" select="java:toLowerCase(java:java.lang.String.new($sec_title_))"/>
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$sectionsFolder}/{$sec_number}-{$sec_title}.adoc">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="setIdOrType"/>
			<xsl:apply-templates />
		</redirect:write>
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
			<xsl:text>include::</xsl:text><xsl:value-of select="$sectionsFolder"/><xsl:text>/</xsl:text><xsl:value-of select="$sec_number"/>-<xsl:value-of select="$sec_title"/><xsl:text>.adoc[]</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</redirect:write>
	</xsl:template>
	
	<xsl:template match="sec">
		<xsl:call-template name="setIdOrType"/>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="sec/text() | list-item/text() | list/text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
	
	<!-- ignore index -->
	<xsl:template match="sec[@sec-type = 'index'] | back/sec[@id = 'ind']" priority="2"/> 
	
	<xsl:template match="term-sec">
		<!-- [[ ]] -->
		<!-- <xsl:call-template name="setId"/>
		<xsl:text>&#xa;</xsl:text>		 -->
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tbx:termEntry">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:value-of select="$level"/><xsl:text> </xsl:text>
		<!-- <xsl:call-template name="setId"/> --><!-- [[ ]] -->
		<xsl:apply-templates select=".//tbx:term" mode="term"/>	
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="title" name="title">
		<xsl:choose>
			<xsl:when test="parent::sec/@sec-type = 'foreword'">
				<xsl:text>== </xsl:text>
				<xsl:apply-templates />
				<xsl:text>&#xa;&#xa;</xsl:text>
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
				<xsl:choose>
					<xsl:when test="../tbx:normativeAuthorization/@value = 'admittedTerm'">alt</xsl:when>
					<xsl:when test="../tbx:normativeAuthorization/@value = 'deprecatedTerm'">deprecated</xsl:when>
					<xsl:otherwise>alt</xsl:otherwise>
				</xsl:choose>
				<xsl:text>:[</xsl:text>
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
	
	<xsl:template match="p" name="p">
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:choose>
			<xsl:when test="ancestor::list-item and not(following-sibling::p) and following-sibling::non-normative-note"></xsl:when>
			<xsl:when test="ancestor::non-normative-note and not(following-sibling::p)"></xsl:when>
			<xsl:when test="not(following-sibling::p) and ancestor::list/following-sibling::non-normative-note"></xsl:when>
			<xsl:when test="ancestor::sec[@sec-type = 'norm-refs'] and not(following-sibling::*[1][self::p])"></xsl:when>
			<xsl:otherwise><xsl:text>&#xa;</xsl:text></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
		
	<xsl:template match="tbx:entailedTerm">
		<xsl:variable name="target" select="substring-after(@target, 'term_')"/>
		<xsl:variable name="term">
			<xsl:choose>
				<xsl:when test="contains(., concat('(', $target, ')'))">
					<!-- <xsl:text>_</xsl:text> -->
					<xsl:value-of select="normalize-space(substring-before(., concat('(', $target, ')')))"/>
					<!-- <xsl:text>_</xsl:text> -->
				</xsl:when>
				<xsl:otherwise>
					<!-- <xsl:text>_</xsl:text> -->
					<xsl:value-of select="."/>
					<!-- <xsl:text>_</xsl:text> -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="term_real" select="normalize-space(//*[@id = current()/@target]//tbx:term)"/>
		<!-- term:[objectives] -->
		<!-- term:[objectives,objective] -->
		<xsl:text>term:[</xsl:text>
		<xsl:value-of select="$term"/>
		<xsl:if test="$term != $term_real">
			<xsl:text>,</xsl:text><xsl:value-of select="$term_real"/>
		</xsl:if>
		<xsl:text>]</xsl:text>
		
		<!-- <xsl:text> (</xsl:text>
		<xsl:text>&lt;&lt;</xsl:text><xsl:value-of select="@target"/><xsl:text>&gt;&gt;</xsl:text>
		<xsl:text>)</xsl:text>		 -->
	</xsl:template>
	
	<xsl:template match="tbx:note" name="tbx_note">
		<xsl:text>NOTE: </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="non-normative-note[ancestor::list-item]" priority="3">
		<xsl:text>+</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>--</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>NOTE: </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>--</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="non-normative-note[count(*[not(local-name() = 'label')]) &gt; 1]" priority="2">
		<xsl:text>[NOTE]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="non-normative-note">
		<xsl:text>NOTE: </xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	
	<!-- empty 
		<std>
			<std-ref/>
		</std>
	-->
	<xsl:template match="std[normalize-space() = '']">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<!-- Example:
		<std std-id="ISO 12345:2011" type="dated">
			<std-ref>ISO 12345:2011</std-ref>
		</std>
	-->
	<xsl:template match="std">
	
		<xsl:variable name="space_before"><xsl:if test="local-name(preceding-sibling::node()[1]) != ''"><xsl:text> </xsl:text></xsl:if></xsl:variable>
		<xsl:variable name="space_after"><xsl:if test="local-name(following-sibling::node()[1]) != ''"><xsl:text> </xsl:text></xsl:if></xsl:variable>
		<xsl:value-of select="$space_before"/>
		
		<xsl:if test="italic">_</xsl:if>
		<xsl:if test="italic2">__</xsl:if>
		<xsl:if test="bold">*</xsl:if>
		<xsl:if test="bold2">**</xsl:if>
		
		<xsl:text>&lt;&lt;</xsl:text>
		
		<xsl:variable name="clause" select="substring-after(@std-id, ':clause:')"/>
		<xsl:variable name="locality">
			<xsl:choose>
				<xsl:when test="$clause != '' and translate(substring($clause, 1, 1), '0123456789', '') = ''">,clause=<xsl:value-of select="$clause"/></xsl:when>
				<xsl:when test="$clause != ''">,annex=<xsl:value-of select="$clause"/></xsl:when>
				<xsl:when test="not(@std-id)">
					<!-- get text -->
					<xsl:variable name="std_text_" select="normalize-space(translate(text(), '&#xa0;', ' '))"/>
					<xsl:variable name="std_text">
						<xsl:choose>
							<xsl:when test="starts-with($std_text_, ',')"><xsl:value-of select="normalize-space(substring-after($std_text_, ','))"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$std_text_"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="std_text_lc" select="java:toLowerCase(java:java.lang.String.new($std_text))"/>
					<!-- DEBUG <xsl:value-of select="$std_text"/> -->
					<xsl:choose>
						<xsl:when test="contains($std_text_lc, 'annex') or contains($std_text_lc, 'table')">
							<xsl:text>,</xsl:text>
							<xsl:variable name="pair" select="translate($std_text, ' ', '=')"/>
							<xsl:value-of select="java:toLowerCase(java:java.lang.String.new(substring-before($pair, '=')))"/>
							<xsl:text>=</xsl:text>
							<xsl:value-of select="substring-after($pair, '=')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="parts">
								<xsl:call-template name="split">
									<xsl:with-param name="pText" select="$std_text"/>
									<xsl:with-param name="sep" select="' '"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:for-each select="xalan:nodeset($parts)//item">
								<xsl:choose>
									<xsl:when test="translate(substring(., 1, 1), '0123456789', '') = ''">,clause=<xsl:value-of select="."/></xsl:when>
									<xsl:when test=". = 'and' or . = ','"><!-- skip --></xsl:when>
									<xsl:otherwise>,annex=<xsl:value-of select="."/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- @stdid attribute was added in linearize.xsl -->
		<xsl:variable name="ref_by_stdid" select="//ref[@stdid = current()/@stdid or @stdid_option = current()/@stdid]"/> <!-- find ref by id -->
		
		<xsl:choose>
			<xsl:when test="xalan:nodeset($ref_by_stdid)/*"> <!-- if references in References found, then put id of those reference -->
				<xsl:value-of select="xalan:nodeset($ref_by_stdid)/@id"/>
				<xsl:value-of select="$locality"/>
			</xsl:when>
			<xsl:otherwise> <!-- put id of current std -->
				<xsl:value-of select="@stdid"/>
				<xsl:value-of select="$locality"/>
				<!-- if there isn't in References, then display name -->
				<xsl:text>,</xsl:text><xsl:value-of select=".//std-ref/text()"/>
			</xsl:otherwise>
		</xsl:choose>
		

		<xsl:text>&gt;&gt;</xsl:text>
		
		<xsl:if test="italic">_</xsl:if>
		<xsl:if test="italic2">__</xsl:if>
		<xsl:if test="bold">*</xsl:if>
		<xsl:if test="bold2">**</xsl:if>
		
		<xsl:value-of select="$space_after"/>
	</xsl:template>
	
	<xsl:template match="std/italic | std/bold | std/italic2 | std/bold2" priority="2">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="std-id-group"/>
	
	<!-- <xsl:template match="std[not(ancestor::ref)]/text()">
		<xsl:variable name="text" select="normalize-space(translate(.,'&#xA0;', ' '))"/>
		<xsl:choose>
			<xsl:when test="starts-with($text, ',')">
				<xsl:call-template name="getUpdatedRef">
					<xsl:with-param name="text" select="$text"/>
				</xsl:call-template>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> -->
	
	<xsl:template match="ref//std-ref"> <!-- sec[@sec-type = 'norm-refs'] -->
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- skip -->
	<xsl:template match="std-ref2">
		<xsl:choose>
			<xsl:when test="ancestor::ref"> <!-- sec[@sec-type = 'norm-refs'] -->
				<xsl:apply-templates />
			</xsl:when>
			<xsl:when test="parent::std[@std-id]">
				<xsl:variable name="std_id" select="parent::std/@std-id"/>
				<xsl:variable name="bib_id" select="//back//ref[std/@std-id = $std_id]/@id"/>
				<xsl:choose>
					<xsl:when test="normalize-space($bib_id) != ''"><!-- if there is item in Bibliography, then put id instead std-id -->
						<xsl:value-of select="$bib_id"/>
						<xsl:text>,</xsl:text><xsl:value-of select="."/>
					</xsl:when>
					<xsl:otherwise> <!-- else normalize std-id -->
						<xsl:variable name="std-id_normalized">
							<xsl:call-template name="getNormalizedId">
								<xsl:with-param name="id" select="$std_id"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$std-id_normalized"/>
						<xsl:variable name="text" select="."/>
						<xsl:if test="$text != $std-id_normalized">,<xsl:value-of select="$text"/></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getStdRef"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	
	<xsl:template match="tbx:source">
		<xsl:text>[.source]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:variable name="modified_text" select="' modified — '"/>
		
		<xsl:variable name="source_text" select="normalize-space(translate(., '&#xA0;', ' '))"/>
		<!-- Output examples: <<ref_2,clause=3.1>> -->
		<!-- <<ref_3,clause=3.2>>, The term “cargo rice” is shown as deprecated, and Note 1 to entry is not included here  -->
		
		<xsl:variable name="part1">
			<xsl:choose>
				<xsl:when test="contains($source_text, $modified_text)">
					<xsl:value-of select="substring-before($source_text, $modified_text)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$source_text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="part_modified" select="substring-after($source_text, $modified_text)"/>		
		
		<xsl:text>&lt;&lt;</xsl:text>
		<xsl:choose>
			<xsl:when test="contains($part1, ',')">
				<xsl:variable name="source_parts">
					<xsl:call-template name="split">
						<xsl:with-param name="pText" select="$part1"/>
						<xsl:with-param name="sep" select="','"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:for-each select="xalan:nodeset($source_parts)//item">					
					<!-- text=<xsl:value-of select="."/> -->
					<xsl:choose>
						<xsl:when test="position() = 1">
							<xsl:call-template name="getStdRef">
								<xsl:with-param name="text" select="."/>
							</xsl:call-template>					
						</xsl:when>
						<!-- <xsl:when test="starts-with(., $modified_text)">
							<xsl:text>&gt;&gt;</xsl:text>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="substring-after(., $modified_text)"/>
						</xsl:when>	 -->					
						<xsl:otherwise>
							<xsl:text>,</xsl:text>
							<xsl:call-template name="getUpdatedRef">
								<xsl:with-param name="text" select="."/>
							</xsl:call-template>
							<!-- <xsl:if test="not(contains($source_text,$modified_text)) and position() = last()">
								<xsl:text>&gt;&gt;</xsl:text>
							</xsl:if> -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$part1"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&gt;&gt;</xsl:text>
		<xsl:if test="$part_modified != ''">
			<xsl:text>, </xsl:text><xsl:value-of select="$part_modified"/>
		</xsl:if>
		
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="list">
		<xsl:if test="not(parent::list-item) and not(parent::non-normative-note and preceding-sibling::p)">
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
		<xsl:variable name="first_label" select="translate(..//label[1], ').', '')"/>
		<xsl:variable name="listtype">
			<xsl:choose>
				<xsl:when test=". = 'alpha-lower'"></xsl:when> <!-- loweralpha --> <!-- https://github.com/metanorma/sts2mn/issues/22: on list don't need to be specified because it is default MN-BSI style -->
				<xsl:when test=". = 'alpha-upper'">upperalpha</xsl:when>
				<xsl:when test=". = 'roman-lower'">lowerroman</xsl:when>
				<xsl:when test=". = 'roman-upper'">upperroman</xsl:when>
				<xsl:when test=". = 'arabic'">arabic</xsl:when>
				<xsl:when test="$first_label != '' and translate($first_label, '1234567890', '') = ''">arabic</xsl:when>
				<xsl:when test="$first_label != '' and translate($first_label, 'ixvcm', '') = ''">lowerroman</xsl:when>
				<xsl:when test="$first_label != '' and translate($first_label, 'IXVCM', '') = ''">upperroman</xsl:when>
				<xsl:when test="$first_label != '' and translate($first_label, 'abcdefghijklmnopqrstuvwxyz', '') = ''"></xsl:when> <!-- loweralpha -->
				<xsl:when test="$first_label != '' and translate($first_label, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '') = ''">upperalpha</xsl:when>
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
		<xsl:variable name="list_item_label">
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
		</xsl:variable>
		<xsl:variable name="list_item_content"><xsl:apply-templates/></xsl:variable>
		<xsl:if test="normalize-space($list_item_content) != ''">
			<xsl:value-of select="$list_item_label"/><xsl:value-of select="$list_item_content"/>
		</xsl:if>
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
		<xsl:if test="parent::*[local-name() = 'td' or local-name() = 'th'] and not(preceding-sibling::node())"><xsl:text> </xsl:text></xsl:if>
		<xsl:text>*</xsl:text><xsl:apply-templates /><xsl:text>*</xsl:text>
	</xsl:template>
	
	<xsl:template match="bold2">
		<xsl:if test="parent::*[local-name() = 'td' or local-name() = 'th'] and not(preceding-sibling::node())"><xsl:text> </xsl:text></xsl:if>
		<xsl:text>**</xsl:text><xsl:apply-templates /><xsl:text>**</xsl:text>
	</xsl:template>
	
	<xsl:template match="italic">
		<xsl:text>_</xsl:text><xsl:apply-templates /><xsl:text>_</xsl:text>
	</xsl:template>
	
	<xsl:template match="italic2">
		<xsl:text>__</xsl:text><xsl:apply-templates /><xsl:text>__</xsl:text>
	</xsl:template>
	
	<xsl:template match="underline">
		<xsl:text>[underline]#</xsl:text><xsl:apply-templates /><xsl:text>#</xsl:text>
	</xsl:template>
	
	<xsl:template match="sub">
		<xsl:text>~</xsl:text><xsl:apply-templates /><xsl:text>~</xsl:text>
	</xsl:template>
	
	<xsl:template match="sub2">
		<xsl:text>~~</xsl:text><xsl:apply-templates /><xsl:text>~~</xsl:text>
	</xsl:template>
	
	<xsl:template match="sup">
		<xsl:text>^</xsl:text><xsl:apply-templates /><xsl:text>^</xsl:text>
	</xsl:template>
	
	<xsl:template match="sup">
		<xsl:text>^^</xsl:text><xsl:apply-templates /><xsl:text>^^</xsl:text>
	</xsl:template>
	
	<xsl:template match="monospace">
		<xsl:text>`</xsl:text><xsl:apply-templates /><xsl:text>`</xsl:text>
	</xsl:template>
	
	<xsl:template match="monospace">
		<xsl:text>``</xsl:text><xsl:apply-templates /><xsl:text>``</xsl:text>
	</xsl:template>
	
	<xsl:template match="sc">
		<xsl:text>[smallcap]#</xsl:text>
		<xsl:apply-templates />
		<xsl:text>#</xsl:text>
	</xsl:template>
	
	<xsl:template match="ext-link">
		
		<xsl:choose>
			<xsl:when test="$organization = 'BSI'">
				<xsl:value-of select="translate(@xlink:href, '&#x2011;', '-')"/> <!-- non-breaking hyphen minus -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@xlink:href"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:text>[</xsl:text><xsl:apply-templates /><xsl:text>]</xsl:text>
	</xsl:template>
	
	<!-- <xsl:template match="ext-link/@xlink:href">
		<xsl:text>[</xsl:text><xsl:value-of select="."/><xsl:text>]</xsl:text>
	</xsl:template> -->
	
	<xsl:template match="xref">
		<xsl:variable name="rid_" select="@rid"/>
		<xsl:variable name="rid_tmp">
			<xsl:if test="//array[@id = $rid_]">array_</xsl:if>
			<xsl:value-of select="$rid_"/>
		</xsl:variable>
		<xsl:variable name="rid" select="normalize-space($rid_tmp)"/>
		<xsl:choose>
			<xsl:when test="@ref-type = 'fn' or @ref-type = 'table-fn'">
				<!-- find <fn id="$rid" -->
				<xsl:choose>
					<xsl:when test="//fn[@id = current()/@rid]/ancestor::table-wrap-foot">
						<xsl:apply-templates select="//fn[@id = current()/@rid]"/>
					</xsl:when>
					<!-- in fn in fn-group -->
					<xsl:when test="//fn[@id = current()/@rid]/ancestor::fn-group">
						<xsl:apply-templates select="//fn[@id = current()/@rid]"/>
						<!-- <xsl:text>{</xsl:text>
						<xsl:value-of select="@rid"/>
						<xsl:text>}</xsl:text> -->
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
			<xsl:when test="@ref-type = 'sec' and local-name(//*[@id = current()/@rid]) = 'term-sec'"> <!-- <xref ref-type="sec" rid="sec_3.21"> link to term-->
				<xsl:variable name="term_name" select="//*[@id = current()/@rid]//tbx:term[1]"/>
				
				<!-- <xsl:variable name="term_name" select="java:toLowerCase(java:java.lang.String.new(translate($term_name_, ' ', '-')_))"/>				 -->
				<!-- <xsl:text>&lt;&lt;</xsl:text>term-<xsl:value-of select="$term_name"/><xsl:text>&gt;&gt;</xsl:text> -->
				<xsl:text>term:[</xsl:text><xsl:value-of select="$term_name"/><xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise> <!-- example: ref-type="sec" "table" "app" -->
				<xsl:text>&lt;&lt;</xsl:text><xsl:value-of select="$rid"/><xsl:text>&gt;&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="sup[xref[@ref-type='fn' or @ref-type='table-fn']]">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="fn-group"/><!-- fn from fn-group  moved to after the text -->
	
	<xsl:template match="fn">
		<xsl:text> footnote:[</xsl:text>
			<xsl:apply-templates />
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="fn/p">
		<xsl:apply-templates />
	</xsl:template>

	<!-- process as Note -->
	<xsl:template match="fn[not(@reference) and not(@id)]" priority="2">
		<xsl:call-template name="tbx_note"/>
	</xsl:template>

	
	<xsl:template match="uri">
		<xsl:apply-templates />
		<xsl:text>[</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="mixed-citation">		
		<xsl:text> </xsl:text><xsl:apply-templates/>
	</xsl:template>
		
	<!-- =============== -->
	<!-- Definitions list (dl) -->
	<!-- =============== -->
	<xsl:template match="array">
		<xsl:text>&#xa;</xsl:text>
		<xsl:choose>
			<xsl:when test="count(table/col) + count(table/colgroup/col) = 2 and $organization != 'BSI'">
				<xsl:if test="@content-type = 'figure-index' and label">*<xsl:value-of select="label"/>*&#xa;&#xa;</xsl:if>
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

	<!-- =============== -->
	<!-- End Definitions list (dl) -->
	<!-- =============== -->
	
	<!-- =============== -->
	<!-- Table -->
	<!-- =============== -->
	<xsl:template match="table-wrap">
		<xsl:apply-templates select="@orientation"/>
		<xsl:call-template name="setId"/>
		<xsl:if test="not(label)">[%unnumbered]&#xa;</xsl:if>
		<xsl:apply-templates select="table-wrap-foot/fn-group" mode="footnotes"/>
		<xsl:apply-templates />
		<xsl:apply-templates select="@orientation" mode="after_table"/>
	</xsl:template>
	
	<xsl:template match="table-wrap/@orientation">
		<xsl:text>&#xa;&#xa;</xsl:text>
		<xsl:text>[%</xsl:text><xsl:value-of select="."/><xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&lt;&lt;&lt;</xsl:text>
		<xsl:text>&#xa;&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="table-wrap/@orientation" mode="after_table">
		<xsl:text>&#xa;&#xa;</xsl:text>
		<xsl:text>[%portrait]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&lt;&lt;&lt;</xsl:text>
		<xsl:text>&#xa;&#xa;&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="table-wrap/caption/title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="table">
		<xsl:if test="parent::array/@id">
			<xsl:text>[[array_</xsl:text><xsl:value-of select="parent::array/@id"/><xsl:text>]]&#xa;</xsl:text>
			<xsl:text>[%unnumbered]&#xa;</xsl:text>
		</xsl:if>
		<xsl:text>[</xsl:text>
		<xsl:text>cols="</xsl:text>
		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="colgroup/col or col">
					<xsl:value-of select="count(colgroup/col) + count(col)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="simple-table">
						<xsl:call-template  name="getSimpleTable"/>
					</xsl:variable>
					<xsl:value-of select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>				
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$cols-count = 1">1</xsl:when> <!-- cols="1" -->
			<xsl:when test="colgroup/col or col">				
				<xsl:for-each select="colgroup/col | col">
					<xsl:variable name="width" select="translate(@width, '%cm', '')"/>
					<xsl:variable name="width_number" select="number($width)"/>
					<xsl:choose>
						<xsl:when test="normalize-space($width_number) != 'NaN'">
							<xsl:value-of select="round($width_number * 100)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$width"/>
						</xsl:otherwise>
					</xsl:choose>
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
			<xsl:if test="ancestor::table-wrap/@content-type = 'ace-table'">
				<option>unnumbered</option>
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
		<xsl:apply-templates select="@width" mode="table_header"/>
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates select="tfoot" mode="footer"/>
		<xsl:apply-templates select="../table-wrap-foot" mode="footer">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
	</xsl:template>
	
	<xsl:template match="table/@width" mode="table_header">
		<xsl:text>,width=</xsl:text><xsl:value-of select="."/>
		<xsl:if test="not(contains(., '%')) and not(contains(., 'px'))">px</xsl:if>
	</xsl:template>
  
	<xsl:template match="col"/>
	
	<xsl:template match="thead">
		<xsl:apply-templates />
		<!-- <xsl:text>&#xa;</xsl:text> -->
	</xsl:template>
	
	<xsl:template match="tfoot"/>
	<xsl:template match="tfoot" mode="footer">		
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tbody">
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="tr">
		<!-- <xsl:if test="position() != 1">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if> -->
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="th">
		<xsl:call-template name="spanProcessing"/>
		<xsl:call-template name="alignmentProcessing"/>
		<xsl:call-template name="complexFormatProcessing"/>
		<xsl:text>|</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="td">
		<xsl:call-template name="spanProcessing"/>		
		<xsl:call-template name="alignmentProcessing"/>
		<xsl:call-template name="complexFormatProcessing"/>
		<xsl:text>|</xsl:text>
		<xsl:choose>
			<xsl:when test="position() = last() and normalize-space() = '' and not(*)"></xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="position() = last() and ../following-sibling::tr">
				<xsl:text>&#xa;</xsl:text>
			</xsl:when>
			<xsl:when test="position() = last()">
				<xsl:text></xsl:text>
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
	
	<xsl:template name="alignmentProcessing">
		<xsl:if test="(@align and @align != 'left') or (@valign and @valign != 'top')">
			
			<xsl:variable name="align">
				<xsl:call-template name="getAlignFormat"/>
			</xsl:variable>
			
			<xsl:variable name="valign">
				<xsl:call-template name="getVAlignFormat"/>
			</xsl:variable>
			
			<xsl:value-of select="$align"/>
			<xsl:value-of select="$valign"/>
			
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="complexFormatProcessing">
		<xsl:if test=".//graphic">a</xsl:if> <!-- AsciiDoc prefix before table cell -->
	</xsl:template>
	
	<xsl:template name="getAlignFormat">
		<xsl:choose>
			<xsl:when test="@align = 'center'">^</xsl:when>
			<xsl:when test="@align = 'right'">&gt;</xsl:when>
			<!-- <xsl:otherwise>&lt;</xsl:otherwise> --><!-- left -->
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getVAlignFormat">
		<xsl:choose>
			<xsl:when test="@valign = 'middle'">.^</xsl:when>
			<xsl:when test="@valign = 'bottom'">.&gt;</xsl:when>
			<!-- <xsl:otherwise>&lt;</xsl:otherwise> --> <!-- top -->
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="td/p | th/p">
		<xsl:text> +</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="table-wrap-foot"/>
	
	<xsl:template match="table-wrap-foot" mode="footer">		
		<xsl:param name="cols-count"/>
		
		<xsl:variable name="table_footer">
			<xsl:apply-templates mode="footer"/>
		</xsl:variable>
		
		<xsl:if test="normalize-space($table_footer) != ''">
			<xsl:value-of select="$cols-count"/><xsl:text>+|</xsl:text>		
			<xsl:value-of select="$table_footer"/>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="table-wrap-foot/fn[@id]" mode="footer"/>
	
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
	
	<!-- <xsl:template match="fn-group/fn">
		<xsl:text>:</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>: footnote:[</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template> -->
	
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
	<!-- =============== -->
	<!-- END Table -->
	<!-- =============== -->
	
	<!-- ============================ -->
	<!-- Annex -->
	<!-- ============================ -->
	<xsl:template match="app">
		<xsl:variable name="annex_label_" select="translate(label, ' &#xa0;', '--')" />
		<xsl:variable name="annex_label" select="java:toLowerCase(java:java.lang.String.new($annex_label_))" />
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$sectionsFolder}/{$annex_label}.adoc">
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="setId"/>
			<xsl:text>[appendix</xsl:text>
			<xsl:apply-templates select="annex-type" mode="annex"/>		
			<xsl:text>]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates />
		</redirect:write>
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
			<xsl:text>include::</xsl:text><xsl:value-of select="$sectionsFolder"/><xsl:text>/</xsl:text><xsl:value-of select="$annex_label"/><xsl:text>.adoc[]</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</redirect:write>
	</xsl:template>
	
	<xsl:template match="app/annex-type"/>
	<xsl:template match="app/annex-type" mode="annex">
		<xsl:variable name="obligation" select="java:toLowerCase(java:java.lang.String.new(translate(., '()','')))"/>
		<xsl:choose>
			<xsl:when test="$obligation = 'normative'"></xsl:when><!-- default value in adoc -->
			<xsl:otherwise><xsl:text>,obligation=</xsl:text><xsl:value-of select="$obligation"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================ -->
	<!-- END Annex -->
	<!-- ============================ -->
	
	<!-- ============================ -->
	<!-- References -->
	<!-- ============================ -->
	<xsl:template match="ref-list[@content-type = 'bibl']" priority="2">
		<xsl:variable name="sectionsFolder"><xsl:call-template name="getSectionsFolder"/></xsl:variable>
		<redirect:write file="{$outpath}/{$sectionsFolder}/99-bibliography.adoc">
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>[bibliography]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates />
		</redirect:write>
		<xsl:variable name="docfile"><xsl:call-template name="getDocFilename"/></xsl:variable>
		<redirect:write file="{$outpath}/{$docfile}">
			<xsl:text>include::</xsl:text><xsl:value-of select="$sectionsFolder"/><xsl:text>/99-bibliography.adoc[]</xsl:text>
			<xsl:text>&#xa;&#xa;</xsl:text>
		</redirect:write>
	</xsl:template>
	
	<xsl:template match="ref-list"> <!-- sub-section for Bibliography -->
		<!-- <xsl:if test="@content-type = 'bibl' or parent::ref-list/@content-type = 'bibl'"> -->
		<xsl:if test="title">
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>[bibliography]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref-list/title/bold | ref-list/title/bold2">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref">
		<xsl:variable name="unique"><!-- skip repeating references -->
			<xsl:choose>
				<xsl:when test="@id and preceding-sibling::ref[@id = current()/@id]">false</xsl:when>
				<xsl:when test="std/@std-id and preceding-sibling::ref[std/@std-id = current()/std/@std-id]">false</xsl:when>
				<xsl:when test="std/std-ref and preceding-sibling::ref[std/std-ref = current()/std/std-ref]">false</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="reference">
			<!-- comment repeated references -->
			<xsl:if test="normalize-space($unique) = 'false'">// </xsl:if>
			
			<xsl:text>* </xsl:text>
			<xsl:if test="@id or std/@std-id or std/std-ref">
				<xsl:text>[[[</xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:if test="not(@id)">
					<xsl:variable name="id_normalized">
						<xsl:call-template name="getNormalizedId">
							<xsl:with-param name="id" select="std/@std-id"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$id_normalized"/>
					
					<xsl:if test="normalize-space($id_normalized) = ''">
						
						<xsl:variable name="std_ref">
							<xsl:call-template name="getNormalizedId">
								<xsl:with-param name="id" select="std/std-ref"/>
							</xsl:call-template>
						</xsl:variable>
						
						<xsl:value-of select="$std_ref"/>
					</xsl:if>
				</xsl:if>
				
				<xsl:text>,</xsl:text>
				
				<xsl:variable name="referenceTitle">
				
					<xsl:variable name="std-ref">
						<xsl:apply-templates select="std/std-ref" mode="references"/>
					</xsl:variable>
					<xsl:variable name="mixed-citation">
						<xsl:apply-templates select="mixed-citation/std" mode="references"/>
					</xsl:variable>
					<xsl:variable name="label">
						<xsl:apply-templates select="label" mode="references"/>
					</xsl:variable>
					
					<xsl:if test="(normalize-space($std-ref) != '' or normalize-space($mixed-citation) != '') and normalize-space($label) != ''">
						<xsl:text>(</xsl:text>
					</xsl:if>
					<xsl:value-of select="$std-ref"/>
					<xsl:value-of select="$mixed-citation"/>
					<xsl:if test="(normalize-space($std-ref) != '' or normalize-space($mixed-citation) != '') and normalize-space($label) != ''">
						<xsl:text>)</xsl:text>
					</xsl:if>
					<xsl:value-of select="$label"/>
				</xsl:variable>
				
				<xsl:value-of select="translate($referenceTitle, '&#x2011;', '-')"/> <!-- non-breaking hyphen minus -->
				
				<xsl:text>]]]</xsl:text>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:variable>
		<xsl:value-of select="$reference"/>
		
		<xsl:if test="normalize-space($unique) = 'false'">
			<xsl:message>WARNING: Repeated reference - <xsl:copy-of select="."/></xsl:message>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="ref/std">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref/label" mode="references">
		<!-- <xsl:text>, </xsl:text> -->
		<xsl:variable name="label" select="translate(., '[]', '')"/>
		<xsl:choose>
			<xsl:when test="$label = '—'"></xsl:when>
			<xsl:otherwise><xsl:value-of select="$label"/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="ref/std/std-ref"/>
	<xsl:template match="ref/std/std-ref" mode="references">
		<!-- <xsl:text>,</xsl:text> -->
		<xsl:apply-templates mode="references"/>
	</xsl:template>
	<xsl:template match="ref/std/std-ref/text()" mode="references">
		<xsl:variable name="text" select="translate(translate(.,'[]',''), '&#xA0;', ' ')"/>
		<!-- <xsl:variable name="isDated">
			<xsl:choose>
				<xsl:when test="string-length($text) - string-length(translate($text, ':', '')) = 1">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> -->
		<xsl:value-of select="$text"/>
		<!-- <xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="$isDated = 'true'">
				<xsl:value-of select="substring-before($text, ':')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text> <xsl:value-of select="$text"/> -->
	</xsl:template>
	
	<xsl:template match="ref/mixed-citation/std"/>
	<xsl:template match="ref/mixed-citation/std" mode="references">
		<!-- <xsl:text>,</xsl:text> -->
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ref/std//title">
		<xsl:text>_</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>_</xsl:text>
	</xsl:template>
	
	<xsl:template match="ref/std//title/text()">
		<xsl:value-of select="translate(., '&#xA0;', ' ')"/>
	</xsl:template>
	<!-- ============================ -->
	<!-- References -->
	<!-- ============================ -->
	
	
	
	<!-- ============================ -->
	<!-- Figure -->
	<!-- ============================ -->
	<!-- in STS XML there are two figure's group structure: fig-group/fig* and fig/graphic[title]* (in BSI documents) -->
	<xsl:template match="fig-group | fig[graphic[caption]] | fig[count(graphic) &gt;= 2]">
		<xsl:call-template name="setId"/>
		<xsl:apply-templates select="caption/title" mode="fig-group-title"/>
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates/>		
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>		
	</xsl:template>
	
	<xsl:template match="fig[graphic[caption] or count(graphic) &gt;= 2]/caption/title" priority="2"/>
	<xsl:template match="fig-group/caption/title"/>
	<xsl:template match="fig-group/caption/title | fig/caption/title" mode="fig-group-title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="fig">
		<xsl:if test="not(parent::fig-group)">
			<xsl:if test="parent::tbx:note"><xsl:text> +&#xa;</xsl:text></xsl:if>
			<xsl:call-template name="setId"/>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:if test="(parent::fig-group and position() != last()) or not(parent::fig-group)">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="fig/label" priority="2">
		<xsl:variable name="number" select="normalize-space(substring-after(., '&#xa0;'))"/>
		<xsl:if test="substring($number, 1, 1) = '0'"> <!-- example: Figure 0.1 -->
			<xsl:text>[number=</xsl:text><xsl:value-of select="$number"/><xsl:text>]&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="fig/caption/title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	
	<xsl:template match="graphic | inline-graphic" name="graphic">
		<xsl:apply-templates select="caption/title" mode="graphic-title"/>
		<xsl:text>image::</xsl:text>
		<xsl:if test="not(processing-instruction('isoimg-id'))">
			<xsl:variable name="image_link" select="@xlink:href"/>
			<xsl:value-of select="$image_link"/>
			<xsl:choose>
				<xsl:when test="contains($image_link, 'base64,')"/>
				<xsl:when test="not(contains($image_link, '.png')) and not(contains($image_link, '.jpg')) and not(contains($image_link, '.bmp'))">
					<xsl:text>.png</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:apply-templates select="processing-instruction('isoimg-id')" mode="pi_isoimg-id"/>
		<xsl:apply-templates />
		<xsl:if test="not(alt-text)">[]</xsl:if>
		<xsl:text>&#xa;</xsl:text>
		<xsl:if test="following-sibling::node()">
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="graphic/caption" />
	<xsl:template match="graphic/caption/title" mode="graphic-title">
		<xsl:text>.</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template match="graphic/processing-instruction('isoimg-id')" />
	<xsl:template match="graphic/processing-instruction('isoimg-id')" mode="pi_isoimg-id">
		<xsl:variable name="image_link" select="."/>
		<xsl:choose>
			<xsl:when test="contains($image_link, '.eps')">
				<xsl:value-of select="substring-before($image_link, '.eps')"/><xsl:text>.png</xsl:text>
			</xsl:when>
			<xsl:when test="contains($image_link, '.EPS')">
				<xsl:value-of select="substring-before($image_link, '.EPS')"/><xsl:text>.png</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$image_link"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template match="alt-text">
		<xsl:text>[</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	<!-- ============================ -->
	<!-- END Figure -->
	<!-- ============================ -->


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
		
	<xsl:template match="code | preformat">
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
		<!-- <xsl:text>&#xa;</xsl:text> -->
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
	
	<!-- =============== -->
	<!-- Definitions list (dl) -->
	<!-- =============== -->
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
		<xsl:call-template name="setId">
			<xsl:with-param name="newline">false</xsl:with-param>
		</xsl:call-template>
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
	<!-- =============== -->
	<!-- End Definitions list (dl) -->
	<!-- =============== -->
	
	<xsl:template match="named-content[@content-type = 'ace-tag'][contains(@specific-use, '_start') or contains(@specific-use, '_end')]" priority="2"><!-- start/end tag for corrections -->
	
		<xsl:variable name="space_before"><xsl:if test="local-name(preceding-sibling::node()[1]) != ''"><xsl:text> </xsl:text></xsl:if></xsl:variable>
		<xsl:variable name="space_after"><xsl:if test="local-name(following-sibling::node()[1]) != ''"><xsl:text> </xsl:text></xsl:if></xsl:variable>
		<xsl:value-of select="$space_before"/>
		<xsl:text>add:[]</xsl:text>
		<xsl:value-of select="$space_after"/>
	</xsl:template>
	
	<xsl:template match="named-content">
		<!-- <xsl:text>&lt;&lt;</xsl:text> -->
		<xsl:text>term:[</xsl:text>
		<xsl:variable name="target">
			<xsl:choose>
				<xsl:when test="translate(@xlink:href, '#', '') = ''"> <!-- empty xlink:href -->
					<xsl:value-of select="translate(normalize-space(), ' ()', '---')"/>
				</xsl:when>
				<xsl:when test="starts-with(@xlink:href, '#')">
					<xsl:value-of select="substring-after(@xlink:href, '#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@xlink:href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@content-type = 'term' and (local-name(//*[@id = $target]) = 'term-sec' or local-name(//*[@id = $target]) = 'termEntry')">
				<xsl:variable name="term_name" select="//*[@id = $target]//tbx:term[1]"/>
				<!-- <xsl:variable name="term_name" select="java:toLowerCase(java:java.lang.String.new(translate($term_name_, ' ', '-')))"/> -->
				<!-- <xsl:text>term-</xsl:text><xsl:value-of select="$term_name"/>,<xsl:value-of select="."/> -->
				
				<xsl:variable name="value" select="."/>
				<xsl:if test="$value != $term_name"><xsl:value-of select="$value"/><xsl:text>,</xsl:text></xsl:if>
				<xsl:value-of select="$term_name"/>

			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$target"/>
				<xsl:if test="normalize-space() != ''">
					<xsl:text>,</xsl:text><xsl:apply-templates/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<!-- <xsl:text>&gt;&gt;</xsl:text> -->
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="'/'"/>
		<xsl:if test="string-length($pText) &gt; 0">
			<item>
				<xsl:variable name="value" select="substring-before(concat($pText, $sep), $sep)"/>
				<xsl:value-of select="normalize-space(translate($value, '&#xA0;', ' '))"/>
			</item>
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
				<xsl:with-param name="sep" select="$sep"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="getLevel">
		<xsl:param name="addon">0</xsl:param>
		<xsl:variable name="level_total" select="count(ancestor::*)"/>
		
		<xsl:variable name="level_standard" select="count(ancestor::standard/ancestor::*)"/>
		
		<xsl:variable name="level_">
			<xsl:choose>
				<xsl:when test="ancestor::app-group">
					<xsl:value-of select="$level_total - $level_standard - 2"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level_total - $level_standard - 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="level_max" select="5"/>
		<xsl:variable name="level">
			<xsl:choose>
				<xsl:when test="$level_ &lt;= $level_max">
					<xsl:value-of select="$level_"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$level_max"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$level_ &gt; $level_max">
			<xsl:text>[level=</xsl:text>
			<xsl:value-of select="$level_"/>
			<xsl:text>]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:call-template name="repeat">
			<xsl:with-param name="count" select="$level + $addon"/>
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
	
	<xsl:template name="getStdRef">
		<xsl:param name="text" select="."/>
		<xsl:variable name="std-ref" select="java:replaceAll(java:java.lang.String.new($text),'--','—')"/>
		<!-- <xsl:variable name="ref1" select="//ref[std/std-ref = $std-ref]/@id"/> -->
		<xsl:variable name="ref1" select="xalan:nodeset($refs)//ref[@std-ref = $std-ref]/@id"/>				
		<!-- <xsl:variable name="ref2" select="//ref[starts-with(std/std-ref, concat($std-ref, ' '))]/@id"/> -->
		<xsl:variable name="ref2" select="xalan:nodeset($refs)//ref[starts-with(@std-ref, concat($std-ref, ' '))]/@id"/>		
		<xsl:choose>
			<xsl:when test="$ref1 != ''">
				<xsl:value-of select="$ref1"/>
			</xsl:when>
			<xsl:when test="$ref2 != ''">
				<xsl:value-of select="$ref2"/>
			</xsl:when>
			<xsl:otherwise>
				
				<xsl:variable name="text_normalized">
					<xsl:call-template name="getNormalizedId">
						<xsl:with-param name="id" select="$text"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:if test="$text_normalized != $text"><xsl:value-of select="$text_normalized"/>,</xsl:if>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="getUpdatedRef">
		<xsl:param name="text"/>
		<xsl:variable name="text_items">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="$text"/>
				<xsl:with-param name="sep" select="' '"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="updated_ref">
			<xsl:for-each select="xalan:nodeset($text_items)//item">
				<xsl:variable name="item" select="java:toLowerCase(java:java.lang.String.new(.))"/>
				<xsl:choose>
					<xsl:when test=". = ','">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:when test="$item = 'clause' or $item = 'table' or $item = 'annex'">
						<xsl:value-of select="$item"/><xsl:text>=</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> </xsl:text><xsl:value-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="normalize-space(java:replaceAll(java:java.lang.String.new($updated_ref),'= ','='))"/>
	</xsl:template>
	
	<xsl:template name="setId">
		<xsl:param name="newline">true</xsl:param>
		<xsl:if test="normalize-space(@id) != ''">
			<xsl:text>[[</xsl:text><xsl:value-of select="@id"/><xsl:text>]]</xsl:text>
			<xsl:if test="$newline = 'true'">
				<xsl:text>&#xa;</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="setIdOrType">
		<xsl:if test="parent::front">
			<xsl:text>[.preface</xsl:text>
			<xsl:if test="@sec-type = 'amendment'">
			<xsl:text>,type=corrigenda</xsl:text>
			</xsl:if>
			<xsl:text>]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<xsl:text>[[</xsl:text>
			<xsl:choose>
				<xsl:when test="normalize-space(@id) != ''">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@sec-type"/>
				</xsl:otherwise>
			</xsl:choose>
		<xsl:text>]]</xsl:text>
		<xsl:if test="not(title) and label">
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>==== {blank}</xsl:text>
		</xsl:if>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template name="insertTaskImageList"> 
		<xsl:variable name="imageList">
			<xsl:for-each select="//graphic | //inline-graphic">
				<xsl:variable name="image"><xsl:call-template name="graphic" /></xsl:variable>
				<xsl:if test="not(contains($image, 'base64,'))">
					<image><xsl:value-of select="$image"/></image>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="xalan:nodeset($imageList)//image">
			<redirect:write file="{$taskCopyImagesFilename}"> <!-- this list will be processed and deleted in java program -->
				<xsl:for-each select="xalan:nodeset($imageList)//image">
					<xsl:text>copy</xsl:text><xsl:value-of select="."/>
				</xsl:for-each>
			</redirect:write>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="/" mode="sub-part">
		<xsl:param name="doc-number"/>
		<xsl:apply-templates select="@*|node()" mode="sub-part">
			<xsl:with-param name="doc-number" select="$doc-number"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- add doc-number attribute, will be used in output filename -->
	<xsl:template match="standard" mode="sub-part">
		<xsl:param name="doc-number"/>
		<xsl:copy>
				<xsl:apply-templates select="@*" mode="sub-part"/>
				<xsl:attribute name="doc-number"><xsl:value-of select="$doc-number"/></xsl:attribute>
				<xsl:apply-templates select="node()" mode="sub-part">
					<xsl:with-param name="doc-number" select="$doc-number"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="sub-part">
		<xsl:param name="doc-number"/>
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="sub-part">
					<xsl:with-param name="doc-number" select="$doc-number"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="front" mode="sub-part">
		<xsl:param name="doc-number"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="sub-part">
				<xsl:with-param name="doc-number" select="$doc-number"/>
			</xsl:apply-templates>
			
			<!-- copy data from standard/body/sub-part[number][sub-part] into front-->
			<xsl:apply-templates select="ancestor::standard/body/sub-part[$doc-number][body/sub-part]" mode="sub-part-front">
				<xsl:with-param name="doc-number" select="$doc-number"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="sub-part-front">
		<xsl:param name="doc-number"/>
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="sub-part-front">
					<xsl:with-param name="doc-number" select="$doc-number"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="standard/body/sub-part | standard/body/sub-part/body" mode="sub-part-front">
		<xsl:apply-templates mode="sub-part-front" />
	</xsl:template>
	
	<xsl:template match="standard/body/sub-part/body/sub-part" mode="sub-part-front"/>
	<xsl:template match="standard/body/sub-part/label[normalize-space() = ''] | standard/body/sub-part/title[normalize-space() = '']" mode="sub-part-front"/>
	
	<xsl:template match="front/sec" mode="sub-part">
		<xsl:param name="doc-number"/>
		<!-- doc-number=<xsl:value-of select="$doc-number"/> -->
		<xsl:if test="$doc-number = 1">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="sub-part">
					<xsl:with-param name="doc-number" select="$doc-number"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<!-- remove element body (but not content!), which contains sub-part inside -->
	<xsl:template match="standard/body[sub-part] | standard/body/sub-part/body[sub-part]" mode="sub-part">
		<xsl:param name="doc-number"/>
		<xsl:apply-templates select="@*|node()" mode="sub-part">
			<xsl:with-param name="doc-number" select="$doc-number"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="standard/body/sub-part" mode="sub-part">
		<xsl:param name="doc-number"/>
		<xsl:variable name="current-number"><xsl:number/></xsl:variable>
		<!-- current-number=<xsl:value-of select="$current-number"/> -->
		<xsl:if test="$doc-number = $current-number">
			
			<xsl:apply-templates select="@*|node()" mode="sub-part">
				<xsl:with-param name="doc-number" select="$doc-number"/>
			</xsl:apply-templates>
			
		</xsl:if>
	</xsl:template>
	
	<!-- these elements was moved in sub-part-front templates -->
	<xsl:template match="standard/body/sub-part/body[sub-part]/*[local-name() != 'sub-part']" mode="sub-part"/>
	
	<xsl:template match="standard/body/sub-part/body/sub-part" mode="sub-part">
		<xsl:apply-templates select="@*|node()" mode="sub-part" />
	</xsl:template>
	
	<xsl:template match="standard/body/sub-part/label[normalize-space() = ''] | 
										standard/body/sub-part/title[normalize-space() = ''] |
										standard/body/sub-part/body/sub-part/label[normalize-space() = ''] | 
										standard/body/sub-part/body/sub-part/title[normalize-space() = '']" mode="sub-part"/>
	
	
	<xsl:template match="processing-instruction()[contains(., 'Page_Break')] | processing-instruction()[contains(., 'Page-Break')]">
		<xsl:if test="not(ancestor::table)"> <!-- Conversion gap: <?Para Page_Break?> between table's rows https://github.com/metanorma/mn-samples-bsi/issues/47 -->
			<xsl:text>&#xa;&#xa;</xsl:text>
			<xsl:text>&lt;&lt;&lt;</xsl:text>
			<xsl:text>&#xa;&#xa;&#xa;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="getDocFilename">
		<xsl:variable name="doc-number" select="ancestor-or-self::standard/@doc-number" />
		<xsl:variable name="sfx"><xsl:if test="$doc-number != ''">.<xsl:value-of select="$doc-number"/></xsl:if></xsl:variable>
		<xsl:value-of select="concat($docfile_name, $sfx, '.', $docfile_ext)"/> <!-- Example: iso-tc154-8601-1-en.adoc , or document.adoc -->
	</xsl:template>
	
	<xsl:template name="getSectionsFolder">
		
		<xsl:variable name="doc-number" select="ancestor-or-self::standard/@doc-number" />
		<xsl:variable name="sfx"><xsl:if test="$doc-number != ''">.<xsl:value-of select="$doc-number"/></xsl:if></xsl:variable>
		<xsl:value-of select="concat('sections', $sfx)"/>
	</xsl:template>
	
	<xsl:template name="insertCollectionData">
		<xsl:param name="documents"/>
		<xsl:text>directives:&#xa;</xsl:text>
		<xsl:text>  - documents-inline&#xa;</xsl:text>
		<xsl:text>bibdata:&#xa;</xsl:text>
		<xsl:text>  type: collection&#xa;</xsl:text>
		<xsl:text>  docid:&#xa;</xsl:text>
		<xsl:text>    type: bsi&#xa;</xsl:text>
		<xsl:text>    id: bsidocs&#xa;</xsl:text>
		<xsl:text>manifest:&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>  docref:&#xa;</xsl:text>
		<xsl:for-each select="xalan:nodeset($documents)/*">
			<xsl:text>    - fileref: </xsl:text><xsl:value-of select="$docfile_name"/>.<xsl:value-of select="@doc-number"/><xsl:text>.xml&#xa;</xsl:text>
			<xsl:text>      identifier: bsidocs-</xsl:text><xsl:value-of select="@doc-number"/><xsl:text>&#xa;</xsl:text>
		</xsl:for-each>
		<xsl:text>prefatory-content:&#xa;</xsl:text>
		<xsl:text>|&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>final-content:&#xa;</xsl:text>
		<xsl:text>|&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
	
	<xsl:template name="getNormalizedId">
		<xsl:param name="id"/>
		<xsl:variable name="id_normalized" select="translate($id, ' &#xA0;:', '___')"/> <!-- replace space, non-break space, colon to _ -->
		<xsl:variable name="first_char" select="substring(id_normalized,1,1)"/>
		<xsl:if test="$first_char != '' and translate($first_char, '0123456789', '') = ''">_</xsl:if>
		<xsl:value-of select="$id_normalized"/>
	</xsl:template>
	
</xsl:stylesheet>