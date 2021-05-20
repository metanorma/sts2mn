<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
					xmlns:mml="http://www.w3.org/1998/Math/MathML" 
					xmlns:tbx="urn:iso:std:iso:30042:ed-1" 
					xmlns:xlink="http://www.w3.org/1999/xlink" 
					xmlns:xalan="http://xml.apache.org/xalan" 
					xmlns:java="http://xml.apache.org/xalan/java" 
					exclude-result-prefixes="xalan mml tbx xlink java"
					xmlns="https://www.metanorma.org/ns/iso"
					version="1.0">

	<xsl:output version="1.0" method="xml" encoding="UTF-8" indent="yes"/>
	
	<xsl:param name="debug">false</xsl:param>
	
	<xsl:param name="split-bibdata">false</xsl:param>

	<xsl:variable name="organization" select="/standard/front/*/doc-ident/sdo"/>

	<xsl:template match="/*">	
		<xsl:variable name="xml_result">
			<xsl:choose>
				<xsl:when test="$split-bibdata = 'true'">
					<xsl:apply-templates select="front"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="iso-standard">
						 <xsl:apply-templates />
						 <xsl:if test="body/sec[@sec-type = 'norm-refs'] or back/ref-list">
							<bibliography>
								<xsl:apply-templates select="body/sec[@sec-type = 'norm-refs']" mode="bibliography"/>
								<xsl:apply-templates select="back/ref-list" mode="bibliography"/>
							</bibliography>
						 </xsl:if>
						 <xsl:apply-templates select="//sec[@sec-type = 'index']" mode="index"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy-of select="$xml_result"/>
		
		<!-- non-processed element checking -->
		<xsl:variable name="xml_result_namespace">https://www.metanorma.org/ns/iso</xsl:variable>
		<xsl:variable name="xml_namespace">http://www.w3.org/XML/1998/namespace</xsl:variable>
		<xsl:variable name="mathml_namespace">http://www.w3.org/1998/Math/MathML</xsl:variable>
		<xsl:variable name="unknown_elements">
			<xsl:for-each select="xalan:nodeset($xml_result)//*">
				<xsl:if test="namespace::*[. != $xml_result_namespace and . != $xml_namespace and . != $mathml_namespace]">
					<element>
						<xsl:for-each select="ancestor-or-self::*">
							<xsl:value-of select="local-name()"/><xsl:if test="position() != last()">/</xsl:if>
						</xsl:for-each>
					</element>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
	
		<xsl:for-each select="xalan:nodeset($unknown_elements)/*">
			<xsl:if test="position() = 1">
				<xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
				<xsl:text>&#xa;Non-processed elements found:&#xa;</xsl:text></xsl:if>
			<xsl:if test="not(preceding-sibling::*/text() = current()/text())">
				<xsl:value-of select="normalize-space()"/><xsl:text>&#xa;</xsl:text>
			</xsl:if>
			<xsl:if test="position() = last()">
				<xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>

	<!-- ============= -->
	<!-- front -> bib data -->
	<!-- ============= -->
	<xsl:template match="front" > <!-- mode="bibdata" -->
		
		<xsl:for-each select="iso-meta | nat-meta">
			<bibdata type="standard">
			
					<xsl:call-template name="xxx-meta" />
					
			</bibdata>
		</xsl:for-each>
	
		
		<xsl:if test="not ($split-bibdata = 'true')">
			<xsl:if test="/standard/front/iso-meta">
				<boilerplate>
					<copyright-statement>
						
							<clause>
								<p id="boilerplate-year">© <xsl:value-of select="/standard/front/iso-meta/permissions/copyright-holder"/><xsl:text> </xsl:text><xsl:value-of select="/standard/front/iso-meta/permissions/copyright-year"/></p>
								<p id="boilerplate-message"><xsl:apply-templates select="/standard/front/iso-meta/permissions/copyright-statement" mode="bibdata"/></p>
							</clause>
						
						<!-- <xsl:if test="/standard/front/nat-meta">
							<clause>
								<p id="boilerplate-year">© <xsl:value-of select="/standard/front/nat-meta/permissions/copyright-holder"/><xsl:text> </xsl:text><xsl:value-of select="/standard/front/nat-meta/permissions/copyright-year"/></p>
								<p id="boilerplate-message"><xsl:apply-templates select="/standard/front/nat-meta/permissions/copyright-statement" mode="bibdata"/></p>
							</clause>
						</xsl:if> -->
					</copyright-statement>
				</boilerplate>
			</xsl:if>
			<xsl:if test="sec">
				<preface>
					<xsl:apply-templates select="sec" mode="preface"/>
					<xsl:if test="$organization = 'BSI'">
						<xsl:apply-templates select="/standard/body/sec[@sec-type = 'intro']" mode="preface"/>
					</xsl:if>
				</preface>
			</xsl:if>
		</xsl:if>
		
		<!-- check non-processed elements in bibdata -->
		<xsl:variable name="bibdata_check">
			<xsl:apply-templates mode="bibdata_check"/>
		</xsl:variable>			
		<xsl:if test="normalize-space($bibdata_check) != '' or count(xalan:nodeset($bibdata_check)/*) &gt; 0">
			<xsl:text>WARNING! There are unprocessed elements in 'front':
			</xsl:text>
			<xsl:apply-templates select="xalan:nodeset($bibdata_check)" mode="display_check"/>
		</xsl:if>
		
	</xsl:template>

	<xsl:template name="xxx-meta">
		<!-- title @type="main", "title-intro", type="title-main", type="title-part" -->
		<xsl:apply-templates select="title-wrap" mode="bibdata"/>
		
		<!-- docidentifier @type="iso", "iso-with-lang", "iso-reference" -->
		<xsl:apply-templates select="std-ref[@type='dated']" mode="bibdata"/>	
		<xsl:apply-templates select="doc-ref" mode="bibdata"/>	
		
		<xsl:apply-templates select="custom-meta-group/custom-meta[meta-name = 'ISBN']/meta-value" mode="bibdata"/>	
		
		<!-- docnumber -->
		<xsl:apply-templates select="std-ident/doc-number" mode="bibdata"/>
		
		<!-- date @type="published"  on -->
		<xsl:apply-templates select="pub-date" mode="bibdata"/>
		<xsl:apply-templates select="release-date" mode="bibdata"/>
		
		<!-- contributor role @type="author" -->
		<xsl:apply-templates select="doc-ident/sdo" mode="bibdata"/>
		
		<!-- contributor role @type="publisher -->
		<xsl:apply-templates select="std-ident/originator" mode="bibdata"/>
		
		<!-- edition -->
		<xsl:apply-templates select="std-ident/edition" mode="bibdata"/>
		
		<!-- version revision-date -->
		<xsl:apply-templates select="std-ident/version" mode="bibdata"/>
		
		<!-- language -->
		<xsl:apply-templates select="content-language" mode="bibdata"/>
		
		<!-- status/stage @abbreviation , substage -->
		<xsl:apply-templates select="doc-ident/release-version" mode="bibdata"/>
		
		<!-- relation bibitem -->
		<xsl:apply-templates select="std-xref" mode="bibdata"/>
		
		<xsl:if test="local-name() != 'reg-meta'">
			<xsl:apply-templates select="ancestor::front/reg-meta" mode="bibdata" />
		</xsl:if>
		
		<!-- copyright from, owner/organization/abbreviation -->
		<xsl:apply-templates select="permissions" mode="bibdata"/>
		
		<xsl:if test="std-ident/doc-type or comm-ref or std-ident or doc-ident/release-version">
			<ext>
				<xsl:apply-templates select="std-ident/doc-type" mode="bibdata"/>
				
				<xsl:apply-templates select="comm-ref" mode="bibdata"/>
				
				<!-- project number -->
				<xsl:choose>
					<xsl:when test="normalize-space(doc-ident/proj-id) != ''">
						<xsl:apply-templates select="doc-ident" mode="bibdata_project_number"/>		
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="std-ident" mode="bibdata"/>		
					</xsl:otherwise>
				</xsl:choose>
				<stagename>
					<xsl:value-of select="doc-ident/release-version"/>
				</stagename>
				
			</ext>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*|node()" mode="display_check">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="display_check"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="text()"  mode="display_check">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="@*|node()" mode="bibdata_check">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="bibdata_check"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="text()" mode="bibdata_check">
		<xsl:value-of select="."/>
	</xsl:template>

	
	
	<xsl:template match="iso-meta | nat-meta | reg-meta |
																title-wrap" mode="bibdata_check">
		<xsl:apply-templates mode="bibdata_check"/>
	</xsl:template>
	
	
	
	<xsl:template match="title-wrap/intro |
															title-wrap/main |
															title-wrap/compl |
															title-wrap/full |
															iso-meta/doc-ref |
															nat-meta/doc-ref |
															reg-meta/doc-ref |
															iso-meta/std-ref |
															nat-meta/std-ref |
															reg-meta/std-ref |
															iso-meta/pub-date |
															nat-meta/pub-date |
															reg-meta/pub-date |
															iso-meta/release-date |
															nat-meta/release-date |
															reg-meta/release-date |
															iso-meta/meta-date |															
															iso-meta/std-ident/doc-number |
															nat-meta/std-ident/doc-number |
															reg-meta/std-ident/doc-number |
															iso-meta/doc-ident/sdo |
															nat-meta/doc-ident/sdo |
															reg-meta/doc-ident/sdo |
															iso-meta/doc-ident/proj-id |
															nat-meta/doc-ident/proj-id |
															reg-meta/doc-ident/proj-id |
															iso-meta/doc-ident/language |
															nat-meta/doc-ident/language |
															reg-meta/doc-ident/language |
															iso-meta/doc-ident/urn |
															iso-meta/std-ident/originator |
															nat-meta/std-ident/originator |
															reg-meta/std-ident/originator |
															iso-meta/std-ident/edition |
															nat-meta/std-ident/edition |
															reg-meta/std-ident/edition |
															iso-meta/std-ident/version |
															nat-meta/std-ident/version |
															reg-meta/std-ident/version |
															iso-meta/content-language |
															nat-meta/content-language |
															reg-meta/content-language |
															iso-meta/doc-ident/release-version |
															nat-meta/doc-ident/release-version |
															reg-meta/doc-ident/release-version |
															iso-meta/permissions/copyright-year |
															nat-meta/permissions/copyright-year |
															reg-meta/permissions/copyright-year |
															iso-meta/permissions/copyright-holder |
															nat-meta/permissions/copyright-holder |
															reg-meta/permissions/copyright-holder |
															iso-meta/permissions/copyright-statement |
															nat-meta/permissions/copyright-statement |
															reg-meta/permissions/copyright-statement |
															iso-meta/std-ident/doc-type |
															nat-meta/std-ident/doc-type |
															reg-meta/std-ident/doc-type |
															iso-meta/comm-ref |
															nat-meta/comm-ref |
															reg-meta/comm-ref |
															iso-meta/secretariat |
															nat-meta/secretariat |
															reg-meta/secretariat |
															iso-meta/ics |
															nat-meta/ics |
															reg-meta/ics |
															iso-meta/std-ident/part-number |
															nat-meta/std-ident/part-number |
															reg-meta/std-ident/part-number |
															iso-meta/page-count |
															iso-meta/std-xref |
															nat-meta/std-xref |
															reg-meta/std-xref |
															reg-meta/meta-date |
															reg-meta/wi-number |
															reg-meta/page-count |
															reg-meta/release-version-id |
															iso-meta/custom-meta-group |
															nat-meta/custom-meta-group |
															reg-meta/custom-meta-group |
															iso-meta/std-ident/suppl-number |
															nat-meta/std-ident/suppl-number |
															reg-meta/std-ident/suppl-number |
															iso-meta/std-ident/suppl-version |
															nat-meta/std-ident/suppl-version |
															reg-meta/std-ident/suppl-version |
															nat-meta/std-ident/suppl-type |
															reg-meta/std-ident/suppl-type |
															front/sec" mode="bibdata_check"/>
	
	
	<xsl:template match="iso-meta/doc-ident | nat-meta/doc-ident | reg-meta/doc-ident |
															iso-meta/std-ident | nat-meta/std-ident |  reg-meta/std-ident |
															iso-meta/permissions | nat-meta/permissions | reg-meta/permissions" mode="bibdata_check">
		<xsl:apply-templates mode="bibdata_check"/>
	</xsl:template>
	
	<xsl:template match="doc-ident" mode="bibdata">
		<xsl:apply-templates mode="bibdata"/>
	</xsl:template>
	
	
	
	
	
	<xsl:template match="iso-meta/title-wrap | nat-meta/title-wrap | reg-meta/title-wrap" mode="bibdata">
		<!-- <xsl:variable name="lang" select="@xml:lang"/>
		<title language="{$lang}" format="text/plain" type="main">
			<xsl:apply-templates select="full" mode="bibdata"/>
		</title>
		<title language="{$lang}" format="text/plain" type="title-intro">
			<xsl:apply-templates select="intro" mode="bibdata"/>
		</title>
		<title language="{$lang}" format="text/plain" type="title-main">
			<xsl:apply-templates select="main" mode="bibdata"/>
		</title>
		<title language="{$lang}" format="text/plain" type="title-part">
			<xsl:apply-templates select="compl" mode="bibdata"/>
		</title> -->
		<xsl:apply-templates select="full" mode="bibdata"/>
		<xsl:apply-templates select="intro" mode="bibdata"/>
		<xsl:apply-templates select="main" mode="bibdata"/>
		<xsl:apply-templates select="compl" mode="bibdata"/>
	</xsl:template>
	
	<xsl:template match="title-wrap/full" mode="bibdata">
		<title language="{../@xml:lang}" format="text/plain" type="main">
			<xsl:apply-templates mode="bibdata"/>
		</title>
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
  
  
  
	<xsl:template match="iso-meta/std-ref[@type='dated'] | nat-meta/std-ref[@type='dated'] | reg-meta/std-ref[@type='dated']" mode="bibdata">
		<docidentifier type="iso">
			<xsl:apply-templates mode="bibdata"/>
		</docidentifier>
		<xsl:variable name="language_" select="substring(//*[contains(local-name(), '-meta')]/doc-ident/language,1,1)"/> <!-- iso-meta -->
		<xsl:variable name="language" select="java:toUpperCase(java:java.lang.String.new($language_))"/>
		<docidentifier type="iso-with-lang">
			<xsl:apply-templates mode="bibdata"/>
			<xsl:text>(</xsl:text><xsl:value-of select="$language"/><xsl:text>)</xsl:text>
		</docidentifier>
		<docidentifier type="iso-reference">
			<xsl:apply-templates mode="bibdata"/>
			<xsl:text>(</xsl:text><xsl:value-of select="$language"/><xsl:text>)</xsl:text>
		</docidentifier>
	</xsl:template>
	
	<xsl:template match="iso-meta/doc-ref | nat-meta/doc-ref | reg-meta/doc-ref" mode="bibdata">
		<docidentifier type="iso-reference">
			<xsl:apply-templates mode="bibdata"/>
		</docidentifier>
	</xsl:template>

	<xsl:template match="custom-meta-group/custom-meta[meta-name = 'ISBN']/meta-value" mode="bibdata">
		<docidentifier type="ISBN"><xsl:apply-templates mode="bibdata"/></docidentifier>
	</xsl:template>
	
	<xsl:template match="iso-meta/std-ident/doc-number | nat-meta/std-ident/doc-number | reg-meta/std-ident/doc-number" mode="bibdata">
		<docnumber>
			<xsl:apply-templates mode="bibdata"/>
		</docnumber>
	</xsl:template>
	

	<xsl:template match="iso-meta/pub-date | nat-meta/pub-date | reg-meta/pub-date" mode="bibdata">
		<date type="published">
			<on>
				<xsl:apply-templates mode="bibdata"/>
			</on>
		</date>
	</xsl:template>
	
	<xsl:template match="iso-meta/release-date | nat-meta/release-date | reg-meta/release-date" mode="bibdata">
		<date type="published">
			<on>
				<xsl:apply-templates mode="bibdata"/>
			</on>
		</date>
	</xsl:template>
			
	
	<xsl:template match="iso-meta/doc-ident/sdo | nat-meta/doc-ident/sdo | reg-meta/doc-ident/sdo" mode="bibdata">
		<contributor>
			<role type="author"/>
			<organization>				
				<abbreviation>
					<xsl:apply-templates mode="bibdata"/>
				</abbreviation>
			</organization>
		</contributor>
	</xsl:template>
	
	
	<xsl:template match="iso-meta/std-ident/originator | nat-meta/std-ident/originator | reg-meta/std-ident/originator" mode="bibdata">
		<contributor>
			<role type="publisher"/>
				<organization>
					<abbreviation>
						<xsl:apply-templates mode="bibdata"/>
					</abbreviation>
				</organization>
		</contributor>
	</xsl:template>
	
	<xsl:template match="iso-meta/std-ident/edition | nat-meta/std-ident/edition | reg-meta/std-ident/edition" mode="bibdata">
		<edition>
			<xsl:apply-templates mode="bibdata"/>
		</edition>
	</xsl:template>
	
	<xsl:template match="iso-meta/std-ident/version | nat-meta/std-ident/version | reg-meta/std-ident/version" mode="bibdata">
		<version>
			<xsl:apply-templates mode="bibdata"/>
			<!-- <revision-date>
			</revision-date> -->
		</version>
	</xsl:template>
	
	<xsl:template match="iso-meta/content-language | nat-meta/content-language | reg-meta/content-language" mode="bibdata">
		<language>
			<xsl:apply-templates mode="bibdata"/>
		</language>
	</xsl:template>
		
	<xsl:template match="iso-meta/doc-ident/release-version | nat-meta/doc-ident/release-version | reg-meta/doc-ident/release-version" mode="bibdata">
		<xsl:variable name="value" select="java:toUpperCase(java:java.lang.String.new(.))"/>
		<xsl:variable name="stage">
			<xsl:choose>
				<xsl:when test="$value = 'WD'">20</xsl:when>
				<xsl:when test="$value = 'CD'">30</xsl:when>
				<xsl:when test="$value = 'DIS'">40</xsl:when>
				<xsl:when test="$value = 'FDIS'">50</xsl:when>
				<xsl:when test="$value = 'IS'">60</xsl:when>				
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="substage">
			<xsl:choose>
				<xsl:when test="$value = 'WD' or $value = 'CD' or $value = 'DIS' or $value = 'FDIS'">00</xsl:when>
				<xsl:when test="$value = 'IS'">60</xsl:when>				
			</xsl:choose>
		</xsl:variable>
		<status>
			<stage>
				<xsl:attribute name="abbreviation">
					<xsl:apply-templates mode="bibdata"/>
				</xsl:attribute>
				<xsl:value-of select="$stage"/>
			</stage>
			<substage>
				<xsl:value-of select="$substage"/>
			</substage>
		</status>		
	</xsl:template>
	
	<xsl:template match="iso-meta/std-xref | nat-meta/std-xref | reg-meta/std-xref" mode="bibdata">
		<relation type="{@type}">
			<xsl:apply-templates mode="bibdata"/>
		</relation>
	</xsl:template>
	
	<xsl:template match="front/reg-meta" mode="bibdata">
		<relation type="adopted-from">
			<xsl:call-template name="xxx-meta"/>
		</relation>
	</xsl:template>
	
	<xsl:template match="iso-meta/std-xref/std-ref | nat-meta/std-xref/std-ref | reg-meta/std-xref/std-ref" mode="bibdata">
		<bibitem>
			<xsl:apply-templates mode="bibdata"/>
		</bibitem>
	</xsl:template>
	
	<xsl:template match="iso-meta/permissions | nat-meta/permissions | reg-meta/permissions" mode="bibdata">
		<copyright>
			<xsl:apply-templates select="copyright-year" mode="bibdata"/>
			<xsl:apply-templates select="copyright-holder" mode="bibdata"/>			
		</copyright>
	</xsl:template>
		
	<xsl:template match="iso-meta/permissions/copyright-year | nat-meta/permissions/copyright-year | reg-meta/permissions/copyright-year" mode="bibdata">
		<from>
			<xsl:apply-templates mode="bibdata"/>
		</from>
	</xsl:template>
	
	<xsl:template match="iso-meta/permissions/copyright-holder | nat-meta/permissions/copyright-holder | reg-meta/permissions/copyright-holder" mode="bibdata">
		<owner>
				<organization>
					<xsl:choose>
						<xsl:when test="string-length(text()) != string-length(translate(text(),' ',''))">
							<name>
								<xsl:apply-templates mode="bibdata"/>
							</name>
						</xsl:when>
						<xsl:otherwise>
							<abbreviation>
								<xsl:apply-templates mode="bibdata"/>
							</abbreviation>
						</xsl:otherwise>
					</xsl:choose>
				</organization>
			</owner>
	</xsl:template>
	

	<xsl:template match="iso-meta/std-ident/doc-type | nat-meta/std-ident/doc-type | reg-meta/std-ident/doc-type" mode="bibdata">
		<xsl:variable name="value" select="java:toLowerCase(java:java.lang.String.new(.))"/>
		<doctype>
			<xsl:choose>
				<xsl:when test="$value = 'is'">international-standard</xsl:when>
				<xsl:when test="$value = 'r'">recommendation</xsl:when>
				<xsl:when test="$value = 'spec'">spec</xsl:when>
				 <xsl:otherwise>
					<xsl:value-of select="."/>
				 </xsl:otherwise>
			</xsl:choose>
		</doctype>
	</xsl:template>
	
	<xsl:template match="iso-meta/comm-ref | nat-meta/comm-ref | reg-meta/comm-ref" mode="bibdata">
		<editorialgroup>
			<xsl:variable name="comm-ref">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="."/>
				</xsl:call-template>
			</xsl:variable>			
			
			<xsl:variable name="TC_SC_WG">
				<xsl:for-each select="xalan:nodeset($comm-ref)/*">
					<xsl:choose>
						<xsl:when test="starts-with(., 'TC ')">
							<technical-committee number="{normalize-space(substring-after(., ' '))}" type="TC"></technical-committee>
						</xsl:when>
						<xsl:when test="starts-with(., 'SC ')">
							<subcommittee number="{normalize-space(substring-after(., ' '))}" type="SC"></subcommittee>
						</xsl:when>
						<xsl:when test="starts-with(., 'WG ')">
							<workgroup number="{normalize-space(substring-after(., ' '))}" type="WG"></workgroup>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="xalan:nodeset($TC_SC_WG)/*">
					<xsl:copy-of select="$TC_SC_WG"/>
				</xsl:when>
				<xsl:otherwise>
					<technical-committee number="{.}"></technical-committee>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="../secretariat" mode="bibdata"/>			
		</editorialgroup>
		
		<xsl:apply-templates select="../ics" mode="bibdata"/>			
	</xsl:template>
	
	<xsl:template match="iso-meta/secretariat | nat-meta/secretariat | reg-meta/secretariat" mode="bibdata">
		<secretariat>
			<xsl:apply-templates mode="bibdata"/>
		</secretariat>
	</xsl:template>
	
	<xsl:template match="iso-meta/ics | nat-meta/ics | reg-meta/ics" mode="bibdata">
		<ics>
			<code>
				<xsl:apply-templates mode="bibdata"/>
			</code>
		</ics>
	</xsl:template>
	
	<xsl:template match="iso-meta/std-ident | nat-meta/std-ident | reg-meta/std-ident" mode="bibdata">
		<xsl:if test="$organization != 'BSI'">
			<structuredidentifier>
				<project-number part="{part-number}">
					<xsl:value-of select="originator"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="doc-number"/>
				</project-number>
			</structuredidentifier>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="iso-meta/doc-ident | nat-meta/doc-ident | reg-meta/doc-ident" mode="bibdata_project_number">
		<structuredidentifier>
			<project-number>
				<xsl:value-of select="proj-id"/>
			</project-number>
			<xsl:if test="../std-ident/part-number">
				<partnumber><xsl:value-of select="../std-ident/part-number"/></partnumber>
			</xsl:if>
		</structuredidentifier>		
	</xsl:template>
	
	<xsl:template match="@*" mode="bibdata">
		<xsl:value-of select="."/>
	</xsl:template>	
	<xsl:template match="text()" mode="bibdata">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="*" mode="bibdata">
		<xsl:apply-templates />
	</xsl:template>	
	<!-- ============= -->
	<!-- END front -> bib data -->
	<!-- ============= -->


	<xsl:template match="@*|node()">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>	
	
	<!-- <xsl:template match="processing-instruction()"/> -->
	<xsl:template match="processing-instruction('foreward')"/>
	
	
	<xsl:template match="front/sec | body/sec[@sec-type = 'intro']" mode="preface">
		<xsl:variable name="sec_type" select="normalize-space(@sec-type)"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="$sec_type = 'intro'">introduction</xsl:when>
				<xsl:when test="$sec_type = ''">clause</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$sec_type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$name}">
			<xsl:copy-of select="@id"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="front//sec">
		<clause id="{@id}">
			<xsl:if test="normalize-space(@sec-type) != ''">
				<xsl:attribute name="type"><xsl:value-of select="@sec-type"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</clause>
	</xsl:template>
	
	<xsl:template match="body">
		<sections>
			<xsl:apply-templates />
		</sections>
	</xsl:template>
	
	
	<xsl:template match="body/sec[@sec-type = 'norm-refs']" priority="2"/> <!-- See Bibliography processing below -->
  
	<xsl:template match="body//sec">
		<xsl:choose>
			<xsl:when test="$organization = 'BSI' and @sec-type = 'intro'"></xsl:when> <!-- introduction added in preface tag for BSI -->
			<xsl:otherwise>
				<clause id="{@id}">
					<xsl:choose>
						<xsl:when test="@sec-type = 'scope'">
							<xsl:attribute name="type">scope</xsl:attribute>
						</xsl:when>
						<xsl:when test="@sec-type = 'intro'">
							<xsl:attribute name="type">intro</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates />
				</clause>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="body//sec[./term-sec]" priority="2">
		<terms id="{@id}">
			<xsl:apply-templates />
		</terms>
	</xsl:template>
	
	<xsl:template match="body//sec[./array[count(table/col) = 2]]" priority="2">
		<definitions id="{@id}">
			<xsl:apply-templates />
		</definitions>
	</xsl:template>
	
	<xsl:template match="term-sec">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tbx:termEntry">
		<term id="{@id}">			
			<xsl:apply-templates />
		</term>
	</xsl:template>
	
	<xsl:template match="tbx:langSet">
		<xsl:apply-templates select="tbx:tig" mode="preferred"/>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tbx:definition">
		<definition>
			<p>
				<xsl:apply-templates />
			</p>
		</definition>
	</xsl:template>
	
	<xsl:template match="tbx:entailedTerm">
		<xsl:variable name="target" select="substring-after(@target, 'term_')"/>
		<xsl:choose>
			<xsl:when test="contains(., concat('(', $target, ')'))">
				<em><xsl:value-of select="normalize-space(substring-before(., concat('(', $target, ')')))"/></em>
			</xsl:when>
			<xsl:otherwise>
				<em><xsl:value-of select="."/></em>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> (</xsl:text>
		<xref target="{@target}"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="tbx:note">
		<termnote>
			<p>
				<xsl:apply-templates />
			</p>
		</termnote>
	</xsl:template>
	
	<xsl:template match="tbx:tig"/>
	<xsl:template match="tbx:tig" mode="preferred">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tbx:tig/tbx:term">
		<xsl:variable name="element_name">
			<xsl:choose>
				<xsl:when test="../tbx:normativeAuthorization/@value = 'preferredTerm'">preferred</xsl:when>
				<xsl:when test="../tbx:normativeAuthorization/@value = 'admittedTerm'">admitted</xsl:when>
				<xsl:when test="../tbx:normativeAuthorization/@value = 'deprecatedTerm'">deprecates</xsl:when>
				<xsl:otherwise>preferred</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element_name}">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="tbx:normativeAuthorization"/>
	
	<xsl:template match="tbx:partOfSpeech"/>
	
	<xsl:template match="tbx:example">
		<termexample>
			<xsl:apply-templates />
		</termexample>
	</xsl:template>
	
	<xsl:template match="tbx:source">
		<termsource>
			<origin citeas="{.}"/>
		</termsource>
	</xsl:template>
	
	<xsl:template match="non-normative-note">
		<note>
			<xsl:apply-templates />
		</note>
	</xsl:template>
	
	<xsl:template match="body//uri">
		<link target="{.}"/>
	</xsl:template>
	
	<xsl:template match="ref-list//uri">
		<link target="{.}"/>
	</xsl:template>
	
	<!-- =============== -->
	<!-- Definitions list (dl) -->
	<!-- =============== -->
	<xsl:template match="array">
		<xsl:choose>
			<xsl:when test="count(table/col) = 2">
				<dl id="{@id}">
					<xsl:apply-templates mode="dl"/>
				</dl>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="dl">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="dl"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="table" mode="dl">
		<xsl:apply-templates mode="dl"/>
	</xsl:template>
	
	<xsl:template match="col" mode="dl"/>
	<xsl:template match="tbody" mode="dl">
		<xsl:apply-templates mode="dl"/>
	</xsl:template>
	
	<xsl:template match="tr" mode="dl">
		<dt>
			<xsl:apply-templates select="td[1]" mode="dl"/>
		</dt>
		<dd>
			<p>
				<xsl:apply-templates select="td[2]" mode="dl"/>
			</p>
		</dd>
	</xsl:template>
	
	<xsl:template match="td" mode="dl">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="def-list">
		<dl>
			<xsl:apply-templates />
		</dl>
	</xsl:template>
	
	<xsl:template match="def-list/def-item">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="def-item/term">
		<dt>
			<xsl:copy-of select="parent::*/@id"/>
			<xsl:apply-templates />
		</dt>
	</xsl:template>
	
	<xsl:template match="def-item/def">
		<dd>
			<xsl:apply-templates />
		</dd>
	</xsl:template>
	<!-- =============== -->
	<!-- End Definitions list (dl) -->
	<!-- =============== -->
	
	
	<!-- ============= -->
	<!-- Table processing -->
	<!-- ============= -->
	<xsl:template match="table">
		<table>
			<xsl:copy-of select="@*"/>
			<xsl:if test="not(@id)">
				<xsl:attribute name="id">
					<xsl:choose>
						<xsl:when test="parent::table-wrap/@id"><xsl:value-of select="parent::table-wrap/@id"/></xsl:when>
						<xsl:when test="parent::array/@id"><xsl:value-of select="parent::array/@id"/></xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="parent::table-wrap/caption/title"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="parent::table-wrap/table-wrap-foot" mode="table"/>
		</table>
	</xsl:template>
	
	<xsl:template match="table-wrap-foot"/>
	<xsl:template match="table-wrap-foot" mode="table">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="table-wrap">
		<!-- <xsl:apply-templates select="@*" /> -->
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="table-wrap/caption"/>	
	
	<xsl:template match="table-wrap/caption/title">
		<name>
			<xsl:apply-templates/>
		</name>
	</xsl:template>
	
	<xsl:template match="col | tbody | thead | th| td | tr | colgroup">
		<xsl:element name="{local-name()}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- ============= -->
	<!-- End Table processing -->
	<!-- ============= -->
	

	
	<xsl:template match="p">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="title">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ext-link">
		<link target="{@xlink:href}">			
			<xsl:apply-templates />
		</link>
	</xsl:template>
	
	<xsl:template match="break">
		<br/>
	</xsl:template>
	
	<xsl:template match="bold">
		<strong>
			<xsl:apply-templates />
		</strong>
	</xsl:template>
	
	<xsl:template match="italic">
		<em>
			<xsl:apply-templates />
		</em>
	</xsl:template>
	
	<xsl:template match="underline">
		<underline>
			<xsl:apply-templates />
		</underline>
	</xsl:template>
	
	<xsl:template match="sub">
		<sub>
			<xsl:apply-templates />
		</sub>
	</xsl:template>
	
	<xsl:template match="sup">
		<sup>
			<xsl:apply-templates />
		</sup>
	</xsl:template>
	
	<xsl:template match="monospace">
		<tt>
			<xsl:apply-templates />
		</tt>
	</xsl:template>
	
	<xsl:template match="sc">
		<smallcap>
			<xsl:apply-templates />
		</smallcap>
	</xsl:template>
	
	<xsl:template match="std">
		<eref type="inline" citeas="{std-ref}">
			<xsl:apply-templates />
		</eref>
	</xsl:template>
	<xsl:template match="std/std-ref"/>
	
	<xsl:template match="std[italic]" priority="2">
		<em>
			<eref type="inline" citeas="{italic/std-ref}">
				<xsl:apply-templates />
			</eref>
		</em>
	</xsl:template>
	<xsl:template match="std[bold]" priority="2">
		<strong>
			<eref type="inline" citeas="{italic/std-ref}">
				<xsl:apply-templates />
			</eref>
		</strong>
	</xsl:template>
	<xsl:template match="std/italic | std/bold" priority="2">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="std/italic/std-ref | std/bold/std-ref" priority="2"/>
	
	
	<xsl:template match="list">
		<xsl:choose>
			<xsl:when test="@list-type = 'bullet' or @list-type = 'simple'">
				<ul>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates />
				</ul>
			</xsl:when>
			<xsl:otherwise>
				<ol>
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates />
				</ol>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="list/@list-type">
		<xsl:variable name="first_label" select="translate(..//label[1], ').', '')"/>
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test=". = 'alpha-lower'">alphabet</xsl:when>
				<xsl:when test=". = 'alpha-upper'">alphabet_upper</xsl:when>
				<xsl:when test=". = 'roman-lower'">roman</xsl:when>
				<xsl:when test=". = 'roman-upper'">roman_upper</xsl:when>
				<xsl:when test=". = 'arabic'">arabic</xsl:when>
				<xsl:when test="translate($first_label, '1234567890', '') = ''">arabic</xsl:when>
				<xsl:when test="translate($first_label, 'ixvcm', '') = ''">roman</xsl:when>
				<xsl:when test="translate($first_label, 'IXVCM', '') = ''">roman_upper</xsl:when>
				<xsl:when test="translate($first_label, 'abcdefghijklmnopqrstuvwxyz', '') = ''">alphabet</xsl:when>
				<xsl:when test="translate($first_label, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '') = ''">alphabet_upper</xsl:when>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:attribute name="type">
			<xsl:value-of select="$type"/>
		</xsl:attribute>
		
		<xsl:variable name="start">
			<xsl:choose>
				<xsl:when test="$type = 'arabic' and $first_label != '1'"><xsl:value-of select="$first_label"/></xsl:when>
				<xsl:when test="$type = 'roman' and $first_label != 'i'"><xsl:value-of select="$first_label"/></xsl:when>
				<xsl:when test="$type = 'roman_upper' and $first_label != 'I'"><xsl:value-of select="$first_label"/></xsl:when>
				<xsl:when test="$type = 'alphabet' and $first_label != 'a'"><xsl:value-of select="$first_label"/></xsl:when>
				<xsl:when test="$type = 'alphabet_upper' and $first_label != 'A'"><xsl:value-of select="$first_label"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space($start) != ''">
			<xsl:attribute name="start">
				<xsl:value-of select="$start"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="list-item">
		<li>
			<xsl:apply-templates />
		</li>
	</xsl:template>
	
	<xsl:template match="label"/>
	
	<xsl:template match="xref">
		<xsl:choose>
			<xsl:when test="@ref-type = 'fn' and following-sibling::*[1][self::fn]"/>
			<xsl:when test="@ref-type = 'fn'">
				<fn>
					<xsl:attribute name="reference">
							<xsl:value-of select="normalize-space(translate(., ')',''))"/>
						</xsl:attribute>
						<xsl:apply-templates select="//fn-group/fn[@id = current()/@rid]/node()" />
				</fn>
			</xsl:when>
			<xsl:when test="@ref-type = 'table-fn'">
				<fn>
					<xsl:attribute name="reference">
							<xsl:value-of select="normalize-space(translate(., ')',''))"/>
						</xsl:attribute>
						<xsl:apply-templates select="ancestor::table-wrap//fn[@id = current()/@rid]/node()" />
				</fn>
			</xsl:when>
			
			<xsl:otherwise>
				<xref target="{@rid}">
					<xsl:apply-templates />
				</xref>		
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="sup[xref[@ref-type='fn']]">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="fn-group | table-wrap-foot/fn"/>
	
	<xsl:template match="fn">
		<fn>
			<xsl:attribute name="reference">
				<xsl:value-of select="preceding-sibling::xref//text()"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</fn>
	</xsl:template>
	
	<xsl:template match="non-normative-example">
		<example>
			<xsl:apply-templates />
		</example>
	</xsl:template>
	
	<xsl:template match="back">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="app-group">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="app">
		<annex id="{@id}">			
			<xsl:attribute name="obligation">
				<xsl:value-of select="translate(annex-type, '()','')"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</annex>
	</xsl:template>
	
	<xsl:template match="annex-type"/>
	
	<xsl:template match="app//sec">
		<clause id="{@id}">
			<xsl:apply-templates />
		</clause>
	</xsl:template>
	
	<xsl:template match="back/ref-list" priority="2"/> <!-- See Bibliography processing below -->
		
	
	<xsl:template match="ref">
		<bibitem id="{@id}" type="{@content-type}">
			<xsl:apply-templates />
		</bibitem>
	</xsl:template>
	
	<xsl:template match="ref-list/ref/label">
		<docidentifier type="metanorma"><xsl:apply-templates /></docidentifier>
	</xsl:template>
	
	<xsl:template match="mixed-citation">
		<title>
			<xsl:apply-templates />
		</title>
	</xsl:template>
	
	<xsl:template match="disp-formula">
		<formula id="{mml:math/@id}">
			<stem type="MathML">
				<xsl:apply-templates />
			</stem>
		</formula>
	</xsl:template>
	
	<xsl:template match="inline-formula">
		<stem type="MathML">
			<xsl:apply-templates />
		</stem>
	</xsl:template>
	
	
	<xsl:template match="sec[@sec-type = 'index']" priority="2"/>
	<xsl:template match="sec[@sec-type = 'index']" mode="index">
		<indexsect id="{@id}">
			<xsl:apply-templates />
		</indexsect>
	</xsl:template>
	
	<xsl:template match="mml:math">
		<math xmlns="http://www.w3.org/1998/Math/MathML">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates />
		</math>
	</xsl:template>
	
	<xsl:template match="mml:math/@id"/>
	
	<xsl:template match="mml:*">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="fig">
		<figure id="{@id}">
			<xsl:apply-templates />
		</figure>
	</xsl:template>
	
	<xsl:template match="fig/caption">
		<name>
			<xsl:apply-templates />
		</name>
	</xsl:template>
	
	<xsl:template match="fig/caption/title">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="graphic | inline-graphic">
		<image height="auto" width="auto">
			<xsl:if test="@xlink:href and not(processing-instruction('isoimg-id'))">
				<xsl:attribute name="src">
					<xsl:value-of select="@xlink:href"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</image>
	</xsl:template>
	
	<xsl:template match="graphic/processing-instruction('isoimg-id')">
		<xsl:attribute name="src">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="fig-group">
		<figure id="{@id}">
			<xsl:apply-templates />
		</figure>
	</xsl:template>
	
	<xsl:template match="disp-quote">
		<quote>
			<xsl:apply-templates />
		</quote>
	</xsl:template>
	
	<xsl:template match="disp-quote/related-object">
		<source>
			<xsl:apply-templates />
		</source>
	</xsl:template>
	
	<xsl:template match="code">
		<sourcecode lang="{@language}">
			<xsl:apply-templates />
		</sourcecode>
	</xsl:template>
	
	<xsl:template match="element-citation">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="named-content">
		<xref>
			<xsl:attribute name="target">
				<xsl:choose>
					<xsl:when test="starts-with(@xlink:href, '#')">
						<xsl:value-of select="substring-after(@xlink:href, '#')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@xlink:href"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:copy-of select="@content-type"/>
			<xsl:apply-templates />
		</xref>
	</xsl:template>
	
	<xsl:template match="sub-part">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- Bibliography processing -->
	<xsl:template match="body/sec[@sec-type = 'norm-refs']" mode="bibliography">
		<references id="{@id}" normative="true">
			<xsl:apply-templates />
		</references>
	</xsl:template>
	
	<xsl:template match="body/sec[@sec-type = 'norm-refs']/ref-list">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="back/ref-list" mode="bibliography">
		<references id="{@id}">
			<xsl:apply-templates />
		</references>
	</xsl:template>
	
	<xsl:template match="back/ref-list/ref-list">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- END Bibliography processing -->
	
	<xsl:template match="processing-instruction('doi')">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="preformat">
		<sourcecode>
			<xsl:apply-templates />
		</sourcecode>
	</xsl:template>
	
	<xsl:template match="styled-content">
		<!-- copy opening tag with attributes -->
		<xsl:text disable-output-escaping="yes">&lt;!--STS: &lt;</xsl:text><xsl:value-of select="local-name()"/>
		<xsl:for-each select="@*">
			<xsl:if test="position() = 1"><xsl:text> </xsl:text></xsl:if>
			<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/><xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:text disable-output-escaping="yes">&gt;--&gt;</xsl:text>
		<xsl:text disable-output-escaping="yes"></xsl:text>
		
		<xsl:apply-templates />
		
		<!-- copy closing tag -->
		<xsl:text disable-output-escaping="yes">&lt;!--STS: &lt;/</xsl:text><xsl:value-of select="local-name()"/><xsl:text disable-output-escaping="yes">&gt;--&gt;</xsl:text>
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

	
</xsl:stylesheet>