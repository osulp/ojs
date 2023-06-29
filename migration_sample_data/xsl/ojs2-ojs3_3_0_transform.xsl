<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <!-- This stylesheet is a main component of OSU Library Information Technology's project
        to migrate journals from Open Journal Systems (OJS) version 2 to version 3.3.0. 
        
        It takes as input the XML exported from OJS2 using the 'Articles & Issues XML Plugin.'
        
        It uses a secondary source to fetch Public Identifiers and Galley Identifiers.
        This secondary source is the output of the XSL stylesheet 'ojs2_compile_METS.xsl' which 
        is generated from XML exported from OJS2 using the 'METS XML Export Plugin.'
        
        It produces as output one file per issue, regardless of whether the source file 
        contained a single issue or multiple issues.
        
        To use this stylesheet without having to make edits, the exported Articles & Issues 
        XML files should be: 
        - saved in a directory called 'ojs2_exports/' 
        - named using the format 'journalID_export.xml' 
        - if multiple export files are required for a single journal, differentiate between their 
            filenames after 'export', e.g. 'journalID_export-1.xml' and 'journalID_export-2.xml'
        
        Be advised: This transform does not handle every element and attribute of the OJS2 or OJS3 schemas, 
        but only those data found in the Oregon Digital instance of each. Some edits or additions may 
        be needed for reuse. 
    -->

    <xsl:output method="xml" exclude-result-prefixes="#all" indent="yes"/>
    <xsl:variable name="mets_data" select="doc('ojs2_mets_data.xml')"/>

    <xsl:template match="/">
        <xsl:for-each select="collection('ojs2_exports/?select=*.xml')">
            <!-- derive journal id from input filename -->
            <xsl:variable name="journal_id"
                select="substring-before(substring-after(document-uri(), 'ojs2_exports/'), '_export')"/>
            <xsl:for-each select="//issue">

                <!-- construct vol_iss id for multiple uses -->
                <xsl:variable name="vol_iss" select="concat(volume, '_', number)"/>
                <!-- construct internal id to use for filename and to match METS data -->
                
                
                <xsl:variable name="issue_internal_id" select="concat($journal_id, '_', $vol_iss)"/>
                <!-- point to the 'issue' record in the mets_data document -->
                <xsl:variable name="issue_mets_record"
                    select="$mets_data/mets_data/issue[@id = $issue_internal_id]"/>
                <!-- pull public identifier from export file, or METS as alternate -->
                
                
                <!-- if the issue has a custom id, set a variable to use for URL Path -->
                <xsl:variable name="issue_custom_id">
                    <xsl:if test="@public_id">
                        <xsl:value-of select="@public_id"/>
                    </xsl:if>
                </xsl:variable>
                
                <!-- create one file per issue, using file id for filename -->
                <xsl:result-document href="ojs3_imports/{$issue_internal_id}_import.xml">

                    <!-- create issue root element with required attributes -->
                    <issue xmlns="http://pkp.sfu.ca"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                        xsi:schemaLocation="http://pkp.sfu.ca native.xsd">
                        <xsl:attribute name="published">
                            <xsl:choose>
                                <xsl:when test="@published = 'true'">
                                    <xsl:value-of select="1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="0"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="current">
                            <xsl:choose>
                                <xsl:when test="@current = 'true'">
                                    <xsl:value-of select="1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="0"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="access_status" select="'1'"/>
                        
                        <!-- set url_path only if explicitly declared in OJS2, otherwise omit -->
                        <xsl:if test="@public_id != ''">
                            <xsl:attribute name="url_path" select="@public_id"/>
                        </xsl:if>
                        
                        <!-- add internal id for QA purposes -->
                        <id type="internal" advice="ignore">
                            <xsl:value-of select="$issue_internal_id"/>
                        </id>
                        <!-- copy issue doi, if present -->
                        <xsl:if test="id[@type = 'doi']">
                            <id type="doi" advice="update">
                                <xsl:value-of select="id[@type = 'doi']"/>
                            </id>
                        </xsl:if>

                        <xsl:if test="description[text()] or cover/caption[text()]">
                            <description>
                                <!-- replicate description element, adding CDATA tag if source description contains markup -->
                                <xsl:for-each select="description">
                                    <xsl:if test="@locale">
                                        <xsl:attribute name="locale" select="@locale"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="contains(., '&lt;')">
                                            <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                                            <xsl:value-of
                                                select="normalize-space(replace(., '&#13;', '&lt;br&gt;'))"
                                                disable-output-escaping="yes"/>
                                            <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                </xsl:for-each>
                                <xsl:for-each select="cover/caption[text()]">
                                    <xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;p&gt;&lt;br&gt;&lt;strong&gt;Cover:&lt;/strong&gt; </xsl:text>
                                    <xsl:value-of
                                        select="normalize-space(replace(., '&#13;', '&lt;br&gt;'))"
                                        disable-output-escaping="yes"/>
                                    <xsl:text disable-output-escaping="yes">&lt;/p&gt;]]&gt;</xsl:text>
                                </xsl:for-each>
                            </description>
                        </xsl:if>

                        <!-- add issue_identification container element and nest subelements inside -->
                        <issue_identification xmlns="http://pkp.sfu.ca">
                            <volume>
                                <xsl:value-of select="volume"/>
                            </volume>
                            <number>
                                <xsl:value-of select="number"/>
                            </number>
                            <year>
                                <xsl:value-of select="year"/>
                            </year>
                            <xsl:for-each select="title">
                                <title>
                                    <xsl:if test="@locale">
                                        <xsl:attribute name="locale" select="@locale"/>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                </title>
                            </xsl:for-each>
                        </issue_identification>

                        <!-- copy date_published -->
                        <xsl:if test="date_published/text()">
                            <date_published>
                                <xsl:value-of select="date_published"/>
                            </date_published>
                        </xsl:if>

                        <!-- copy open_access to open_access_date, if present -->
                        <xsl:for-each select="open_access[text()]">
                            <open_access_date>
                                <xsl:value-of select="."/>
                            </open_access_date>
                        </xsl:for-each>

                        <!-- replicate section information with updated structure -->
                        <sections>
                            <xsl:for-each select="section">
                                <section>
                                    <xsl:attribute name="ref">
                                        <xsl:value-of select="abbrev"/>
                                    </xsl:attribute>
                                    <!-- TESTING: Additional attributes (seq + policy ones) are present in export, not included here -->
                                    <id type="internal" advice="ignore">0</id>
                                    <abbrev>
                                        <xsl:attribute name="locale" select="abbrev/@locale"/>
                                        <xsl:value-of select="abbrev"/>
                                    </abbrev>
                                    <title>
                                        <xsl:attribute name="locale" select="title/@locale"/>
                                        <xsl:value-of select="normalize-space(title)"/>
                                    </title>
                                </section>
                            </xsl:for-each>
                        </sections>
                        
                        <!-- TESTING: Check against a sample with a cover file -->
                        <!-- replicate cover information with updated structure and element names -->
                        <xsl:if test="cover">
                            <covers>
                                <xsl:for-each select="cover">
                                    <cover>
                                        <xsl:if test="@locale">
                                            <xsl:attribute name="locale" select="@locale"/>
                                        </xsl:if>
                                        <cover_image>
                                            <xsl:value-of select="image/embed/@filename"/>
                                        </cover_image>
                                        <cover_image_alt_text>
                                            <xsl:text>Issue Cover Art</xsl:text>
                                        </cover_image_alt_text>
                                        <embed encoding="base64">
                                            <xsl:value-of select="image/embed"/>
                                        </embed>
                                    </cover>
                                </xsl:for-each>
                            </covers>
                        </xsl:if>

                        <!-- Issue Galleys would be here but are not included in OJS 2 export and will be added manually --> 
                        <issue_galleys/>
                        
                        <!-- create articles container and replicate article metadata within -->
                        <articles>
                            
                            <xsl:for-each select="section/article">
                                
                                <!-- construct internal id and use to match METS data -->
                                <xsl:variable name="article_internal_id"
                                    select="concat($issue_internal_id, '_', format-number(position(), '00'))"/>
                                
                                <xsl:variable name="article_mets_record"
                                    select="$issue_mets_record/articles/article[@id = $article_internal_id]"/>

                                <article>

                                    <!-- add required attributes -->
                                    <xsl:attribute name="status" select="'3'"/>
                                    <xsl:attribute name="submission_progress" select="'0'"/>
                                    <xsl:attribute name="current_publication_id" select="'0'"/>

                                    <!-- set stage attribute based on issue publication status -->
                                    <xsl:attribute name="stage">
                                        <xsl:choose>
                                            <xsl:when test="ancestor::issue/@published = 'true'">
                                                <xsl:value-of select="'production'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'submission'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>

                                    <!-- add internal id for QA purposes -->
                                    <id type="internal" advice="ignore">
                                        <xsl:value-of select="$article_internal_id"/>
                                    </id>

                                    <!-- construct OJS3 submission file information from OJS2 galley information -->
                                    <!-- TEST: Import with no files -->
                                   
                                    <!--<xsl:for-each
                                        select="*[contains(name(), 'galley')][file/*[text()]]">
                                        <xsl:variable name="galley_filetype"
                                            select="file/embed/@mime_type"/>
                                        <xsl:variable name="galley_mets_record"
                                            select="$article_mets_record/files/file[@type = $galley_filetype]"/>
                                        <xsl:call-template name="submission_file">
                                            <xsl:with-param name="element_name"
                                                select="'submission_file'"/>
                                            <xsl:with-param name="genre" select="'Article Text'"/>
                                            <xsl:with-param name="file_name"
                                                select="file/embed/@filename"/>
                                            <xsl:with-param name="file_type">
                                                <xsl:choose>
                                                  <xsl:when test="$galley_filetype = 'text/htm'">
                                                  <xsl:value-of select="'text/html'"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="$galley_filetype"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:with-param>
                                            <xsl:with-param name="extension">
                                                <xsl:choose>
                                                  <xsl:when test="$galley_filetype = 'text/htm'">
                                                  <xsl:value-of select="'html'"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="substring-after($galley_filetype, '/')"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:with-param>
                                            <xsl:with-param name="file_size"
                                                select="$galley_mets_record/file_size"/>
                                            <!-\- TEST: set galley file @public_id to 0 -\->
                                            <!-\-<xsl:with-param name="public_id"
                                                select="$galley_mets_record/public_id"/>-\->
                                            <xsl:with-param name="public_id" select="$galley_mets_record/public_id"/>
                                            <xsl:with-param name="stage" select="'proof'"/>
                                        </xsl:call-template>
                                    </xsl:for-each>-->

                                    <!-- supplementary file information
                                        NOT WORKING; SKIPPING FOR EXPEDITED MIGRATION and will add manually  -->
                                    <!--<xsl:for-each select="supplemental_file[file/embed/text()]">
                                        <!-\- get supplementary file information from METS -\->
                                        <xsl:variable name="supp_internal_id"
                                            select="concat($article_internal_id, '_s', format-number(position(), '00'))"/>
                                        <xsl:variable name="supp_file_mets"
                                            select="$article_mets_record/files/supp_file[@id = $supp_internal_id]"/>
                                        <xsl:call-template name="submission_file">
                                            <xsl:with-param name="element_name"
                                                select="'supplementary_file'"/>
                                            <xsl:with-param name="public_id"
                                                select="$supp_file_mets/supp_id"/>
                                            <xsl:with-param name="stage" select="'proof'"/>
                                            <xsl:with-param name="genre">
                                                <xsl:choose>
                                                  <xsl:when test="@type = 'source_text'">
                                                  <xsl:value-of select="'Source Texts'"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:for-each select="tokenize(@type, '_')">
                                                  <xsl:value-of
                                                  select="concat(upper-case(substring(., 1, 1)), substring(., 2))"/>
                                                  <xsl:if test="position() != last()">
                                                  <xsl:text> </xsl:text>
                                                  </xsl:if>
                                                  </xsl:for-each>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:with-param>
                                            <xsl:with-param name="file_name"
                                                select="file/embed/@filename"/>
                                            <xsl:with-param name="file_size"
                                                select="$supp_file_mets/supp_filesize"/>
                                            <xsl:with-param name="file_type"
                                                select="$supp_file_mets/supp_type"/>
                                        </xsl:call-template>
                                    </xsl:for-each>-->


                                    <!-- handle image and media files within htmlgalley as artwork_file -->
                                    <!-- TEST: Import with no files -->
                                    <!--<xsl:for-each-group select="htmlgalley/image"
                                        group-by="embed/@mime_type">
                                        <xsl:variable name="media_type" select="embed/@mime_type"/>
                                        <xsl:variable name="mets_group"
                                            select="$article_mets_record/files/file[@type = $media_type]"/>
                                        <xsl:for-each select="current-group()">
                                            <xsl:variable name="order" select="position()"/>
                                            <xsl:variable name="media_mets_record"
                                                select="$mets_group[position() = $order]"/>
                                            <xsl:call-template name="submission_file">
                                                <xsl:with-param name="element_name"
                                                  select="'artwork_file'"/>
                                                <xsl:with-param name="genre">
                                                  <xsl:choose>
                                                  <xsl:when test="contains($media_type, 'image')">
                                                  <xsl:value-of select="'Image'"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="'Multimedia'"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:with-param>
                                                <xsl:with-param name="file_name"
                                                  select="embed/@filename"/>
                                                <xsl:with-param name="file_type"
                                                  select="$media_type"/>
                                                <xsl:with-param name="file_size"
                                                  select="$media_mets_record/file_size"/>
                                                <xsl:with-param name="public_id"
                                                  select="substring-after($media_mets_record/public_id, '/')"/>
                                                <xsl:with-param name="submission_file_ref"
                                                  select="substring-before($media_mets_record/public_id, '/')"/>
                                                <xsl:with-param name="stage" select="'dependent'"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </xsl:for-each-group>-->

                                    <!-- add publication container element -->
                                    <publication>
                                        <xsl:if test="@locale">
                                            <xsl:attribute name="locale" select="@locale"/>
                                        </xsl:if>
                                        <xsl:attribute name="version" select="'1'"/>
                                        <xsl:attribute name="status" select="'3'"/>
                                        <xsl:if test="@public_id">
                                            <xsl:attribute name="url_path" select="@public_id"/>
                                        </xsl:if>
                                        <xsl:attribute name="seq" select="'0'"/>
                                        <xsl:attribute name="date_published">
                                            <xsl:choose>
                                                <xsl:when test="date_published[text()]">
                                                    <xsl:value-of select="date_published"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="ancestor::issue/date_published"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>                                        <!-- set section_ref attribute using containing section abbreviation -->
                                        <xsl:attribute name="section_ref"
                                            select="parent::section/abbrev"/>
                                        <xsl:attribute name="access_status" select="'0'"/>
                                        <xsl:if test="@language">
                                            <xsl:attribute name="language" select="@language"/>
                                        </xsl:if>

                                        <!-- create publication IDs -->
                                        <!-- add required internal id and set as zero -->
                                        <id type="internal" advice="ignore">
                                            <xsl:value-of select="'0'"/>
                                        </id>

                                        <!-- add Public Identifier for the article -->
                                        <id type="public" advice="update">
                                            <xsl:value-of select="@public_id"/>
                                        </id>

                                        <!-- copy DOI if present -->
                                        <xsl:if test="id[@type = 'doi']">
                                            <id type="doi" advice="update">
                                                <xsl:value-of select="id[@type = 'doi']"/>
                                            </id>
                                        </xsl:if>

                                        <!-- copy title, wrapping in CDATA tags if markup is present -->
                                        <xsl:for-each select="title[text()]">
                                            <title>
                                                <xsl:if test="@locale">
                                                  <xsl:attribute name="locale" select="@locale"/>
                                                </xsl:if>
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="contains(., 'class=&quot;tocSectionTitle&quot;&gt;')">
                                                  <xsl:value-of
                                                  select="normalize-space(substring-before(substring-after(., 'tocSectionTitle&quot;&gt;'), '&lt;/strong'))"
                                                  />
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:choose>
                                                  <xsl:when test="contains(., '&lt;')">
                                                  <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(replace(., '&#13;', '&lt;br /&gt;'))"
                                                  disable-output-escaping="yes"/>
                                                  <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </title>
                                        </xsl:for-each>

                                        <!-- copy abstract, wrapping in CDATA tags if markup is present -->
                                        <xsl:for-each select="abstract[text()]">
                                            <abstract>
                                                <xsl:if test="@locale">
                                                  <xsl:attribute name="locale" select="@locale"/>
                                                </xsl:if>
                                                <xsl:choose>
                                                  <xsl:when test="contains(., '&lt;')">
                                                  <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(replace(., '&#13;', '&lt;br /&gt;'))"
                                                  disable-output-escaping="yes"/>
                                                  <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </abstract>
                                        </xsl:for-each>

                                        <!-- copy the contents of each OJS2 indexing/coverage subelement into an OJS3 coverage element  -->
                                        <xsl:for-each select="indexing/coverage/*">
                                            <coverage>
                                                <xsl:if test="@locale">
                                                  <xsl:attribute name="locale" select="@locale"/>
                                                </xsl:if>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </coverage>
                                        </xsl:for-each>

                                        <!-- copy the contents of each OJS2 indexing/type subelement into an OJS3 type element  -->
                                        <xsl:for-each select="indexing/type">
                                            <type>
                                                <xsl:call-template name="locale"/>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </type>
                                        </xsl:for-each>

                                        <!-- replicate license/rights information without permissions container element,
                                    reformatting element names per OJS3 schema -->
                                        <xsl:for-each select="permissions/*[text()]">
                                            <xsl:variable name="permissions_label">
                                                <xsl:if test="name() = 'license_url'">
                                                  <xsl:value-of select="'licenseUrl'"/>
                                                </xsl:if>
                                                <xsl:if test="name() = 'copyright_holder'">
                                                  <xsl:value-of select="'copyrightHolder'"/>
                                                </xsl:if>
                                                <xsl:if test="name() = 'copyright_year'">
                                                  <xsl:value-of select="'copyrightYear'"/>
                                                </xsl:if>
                                            </xsl:variable>
                                            <xsl:element name="{$permissions_label}">
                                                <xsl:call-template name="locale"/>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </xsl:element>
                                        </xsl:for-each>
                                        <xsl:if test="not(permissions/copyright_year)">
                                            <copyrightYear>
                                                <xsl:value-of select="ancestor::issue/year"/>
                                            </copyrightYear>
                                        </xsl:if>

                                        <xsl:if
                                            test="indexing/discipline[text()] or indexing/subject[text()]">
                                            <keywords>
                                                <xsl:for-each
                                                  select="indexing/*[name() = 'discipline' or contains(name(), 'subject')]">
                                                  <xsl:variable name="index_contents">
                                                  <xsl:call-template name="fix_delimiters"/>
                                                  </xsl:variable>
                                                  <xsl:call-template name="tokenize_to_subelements">
                                                  <xsl:with-param name="delimited_string"
                                                  select="$index_contents"/>
                                                  <xsl:with-param name="subelement_name"
                                                  select="'keyword'"/>
                                                  </xsl:call-template>
                                                </xsl:for-each>
                                            </keywords>
                                        </xsl:if>

                                        <!-- place 'discipline' contents into valid OJS3 structure -->
                                        <xsl:if test="indexing/discipline[text()]">

                                            <xsl:for-each select="indexing/discipline[text()]">
                                                <disciplines>
                                                  <xsl:if test="@locale">
                                                  <xsl:attribute name="locale" select="@locale"/>
                                                  </xsl:if>
                                                  <xsl:variable name="index_contents"
                                                  select="replace(replace(., '\p{P}$', ''), ',', ';')"/>
                                                  <xsl:for-each
                                                  select="tokenize($index_contents, ';')">
                                                  <discipline>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </discipline>
                                                  </xsl:for-each>
                                                </disciplines>
                                            </xsl:for-each>

                                        </xsl:if>

                                        <!-- place 'subject' and 'subject_class' contents into valid OJS3 structure -->
                                        <xsl:if
                                            test="indexing/*[contains(name(), 'subject')]/text()">
                                            <subjects>
                                                <xsl:if
                                                  test="indexing/*[contains(name(), 'subject')]/@locale">
                                                  <xsl:attribute name="locale" select="@locale"/>
                                                </xsl:if>
                                                <xsl:for-each
                                                  select="indexing/*[contains(name(), 'subject')]">
                                                  <xsl:variable name="index_contents"
                                                  select="replace(replace(., '\p{P}$', ''), ',', ';')"/>
                                                  <xsl:for-each
                                                  select="tokenize($index_contents, ';')">
                                                  <subject>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </subject>
                                                  </xsl:for-each>
                                                </xsl:for-each>
                                            </subjects>
                                        </xsl:if>

                                        <!-- replicate author info within authors container element -->
                                        <authors>
                                            <xsl:choose>
                                                <!-- copy author info for each author, when present -->
                                                <xsl:when test="author/*[text()]">
                                                  <xsl:for-each select="author">
                                                  <author>
                                                  <!-- construct OJS3 required attributes -->
                                                  <xsl:attribute name="include_in_browse"
                                                  select="'true'"/>
                                                  <xsl:attribute name="user_group_ref"
                                                  select="'Author'"/>
                                                  <xsl:attribute name="seq" select="'0'"/>
                                                  <xsl:attribute name="id" select="'0'"/>
                                                  <!-- copy / update author subelements -->
                                                  <givenname>
                                                      <xsl:attribute name="locale">
                                                          <xsl:choose>
                                                              <xsl:when test="firstname/@locale">
                                                                  <xsl:value-of select="firstname/@locale"/>
                                                              </xsl:when>
                                                              <xsl:otherwise>
                                                                  <xsl:value-of select="'en_US'"/>
                                                              </xsl:otherwise>
                                                          </xsl:choose>
                                                      </xsl:attribute>
                                                  <xsl:value-of select="firstname"/>
                                                  <xsl:if test="middlename[text()]">
                                                  <xsl:text> </xsl:text>
                                                  <xsl:value-of select="middlename"/>
                                                  </xsl:if>
                                                  </givenname>
                                                  <familyname>
                                                      <xsl:attribute name="locale">
                                                          <xsl:choose>
                                                              <xsl:when test="lastname/@locale">
                                                                  <xsl:value-of select="lastname/@locale"/>
                                                              </xsl:when>
                                                              <xsl:otherwise>
                                                                  <xsl:value-of select="'en_US'"/>
                                                              </xsl:otherwise>
                                                          </xsl:choose>
                                                      </xsl:attribute>
                                                  <xsl:value-of select="lastname"/>
                                                  </familyname>
                                                  <xsl:for-each select="affiliation">
                                                  <affiliation>
                                                  <xsl:if test="@locale">
                                                  <xsl:attribute name="locale" select="@locale"/>
                                                  </xsl:if>
                                                  <xsl:value-of select="."/>
                                                  </affiliation>
                                                  </xsl:for-each>
                                                  <xsl:for-each select="country">
                                                  <country>
                                                  <xsl:value-of select="."/>
                                                  </country>
                                                  </xsl:for-each>
                                                  <email>
                                                  <xsl:value-of select="email"/>
                                                  </email>
                                                  <xsl:for-each select="url">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(., 'orcid.org')">
                                                  <orcid>
                                                  <xsl:value-of select="."/>
                                                  </orcid>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <url>
                                                  <xsl:value-of select="."/>
                                                  </url>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:for-each>
                                                  <xsl:for-each select="biography">
                                                  <biography>
                                                      <xsl:attribute name="locale">
                                                          <xsl:choose>
                                                              <xsl:when test="@locale">
                                                                  <xsl:value-of select="@locale"/>
                                                              </xsl:when>
                                                              <xsl:otherwise>
                                                                  <xsl:value-of select="'en_US'"/>
                                                              </xsl:otherwise>
                                                          </xsl:choose>
                                                      </xsl:attribute>
                                                     
                                                  <xsl:choose>
                                                  <xsl:when test="contains(., '&lt;')">
                                                  <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                                                  <xsl:value-of
                                                  select="normalize-space(replace(., '&#13;', '&lt;br /&gt;'))"
                                                  disable-output-escaping="yes"/>
                                                  <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </biography>
                                                  </xsl:for-each>
                                                  </author>
                                                  </xsl:for-each>
                                                </xsl:when>
                                                <!-- add default author information if no authors are listed, to meet validation requirements -->
                                                <xsl:otherwise>
                                                  <author include_in_browse="true"
                                                  user_group_ref="Author">
                                                  <givenname locale='en_US'>Editorial</givenname>
                                                      <familyname locale='en_US'>Team</familyname>
                                                  <affiliation>
                                                  <xsl:value-of
                                                  select="ancestor::issue/$issue_mets_record/journal_title"
                                                  />
                                                  </affiliation>
                                                  <email/>
                                                  </author>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </authors>

                                        <!-- construct OJS3 article galley sections from OJS2 galley information-->
                                        <!--
                                        <xsl:for-each select="galley[file/*[text()]]">
                                            <xsl:variable name="galley_mets_record"
                                                select="$article_mets_record/files/file[@type = 'application/pdf']"/>
                                            <xsl:call-template name="article_galley">
                                                <!-\-<xsl:with-param name="galley_type" select="'pdfarticlegalleyplugin'"/>-\->
                                                <xsl:with-param name="public_id"
                                                  select="$galley_mets_record/public_id"/>
                                                <xsl:with-param name="galley_name" select="label"/>
                                            </xsl:call-template>
                                        </xsl:for-each>-->

                                        <!--<xsl:for-each select="htmlgalley[file/*[text()]]">
                                            <xsl:variable name="galley_mets_record"
                                                select="$article_mets_record/files/file[@type = 'text/html']"/>
                                            <xsl:call-template name="article_galley">
                                                <!-\-<xsl:with-param name="galley_type" select="'htmlarticlegalleyplugin'"/>-\->
                                                <xsl:with-param name="public_id"
                                                  select="$galley_mets_record/public_id"/>
                                                <xsl:with-param name="galley_name" select="label"/>
                                            </xsl:call-template>
                                        </xsl:for-each>

                                        <xsl:for-each select="supplemental_file[file/embed/text()]">
                                            <xsl:variable name="supp_internal_id"
                                                select="concat($article_internal_id, '_s', format-number(position(), '00'))"/>
                                            <xsl:variable name="supp_file_mets"
                                                select="$article_mets_record/files/supp_file[@id = $supp_internal_id]"/>
                                            <xsl:call-template name="article_galley">
                                                <!-\-<xsl:with-param name="galley_type"></xsl:with-param> -\->
                                                <xsl:with-param name="public_id"
                                                  select="$supp_file_mets/supp_id"/>
                                                <xsl:with-param name="galley_name"
                                                  select="normalize-space(title)"/>
                                                <xsl:with-param name="seq" select="position()"/>
                                            </xsl:call-template>
                                        </xsl:for-each>-->

                                        <!-- copy page numbers -->
                                        <xsl:for-each select="pages">
                                            <pages>
                                                <xsl:value-of select="."/>
                                            </pages>
                                        </xsl:for-each>
                                    </publication>
                                </article>
                            </xsl:for-each>
                        </articles>
                    </issue>
                </xsl:result-document>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="submission_file">
        <xsl:param name="element_name"/>
        <xsl:param name="genre"/>
        <xsl:param name="public_id"/>
        <xsl:param name="file_name"/>
        <xsl:param name="file_size"/>
        <xsl:param name="file_type"/>
        <xsl:param name="extension"/>
        <xsl:param name="submission_file_ref"/>
        <xsl:param name="stage"/>
        <xsl:element name="{$element_name}" xmlns="http://pkp.sfu.ca">
            <xsl:attribute name="id" select="$public_id"/>
            <xsl:attribute name="file_id" select="'0'"/>
            <xsl:attribute name="stage" select="$stage"/>
            <xsl:attribute name="viewable" select="'false'"/>
            <xsl:attribute name="genre" select="$genre"/>
            
            <name>
                <xsl:value-of select="$file_name"/>
            </name>
            <xsl:element name="file">
                <xsl:attribute name="id" select="'0'"/>
                <xsl:attribute name="filesize" select="$file_size"/>
                <xsl:attribute name="extension" select="$extension"/>

                <xsl:if test="$submission_file_ref != ''">
                    <submission_file_ref>
                        <xsl:attribute name="id" select="$submission_file_ref"/>
                        <xsl:attribute name="revision" select="'1'"/>
                    </submission_file_ref>
                </xsl:if>
                <embed>
                    <xsl:attribute name="encoding" select="'base64'"/>
                    <xsl:choose>
                        <xsl:when test="file">
                            <xsl:value-of select="file/embed"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="embed"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </embed>
            </xsl:element>
            <xsl:if test="$element_name = 'supplementary_file'">
                <xsl:for-each
                    select="*[not(name() = 'title' or name() = 'file' or name() = 'type_other')]">
                    <xsl:element name="{name()}">
                        <xsl:for-each select="@*">
                            <xsl:attribute name="{name()}" select="."/>
                        </xsl:for-each>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:element>url
                </xsl:for-each>
                <xsl:if test="@language">
                    <language>
                        <xsl:value-of select="@language"/>
                    </language>
                </xsl:if>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="article_galley">
        <!--<xsl:param name="galley_type"/>-->
        <xsl:param name="public_id"/>
        <xsl:param name="galley_name"/>
        <xsl:param name="seq" select="'0'"/>
        <article_galley xmlns="http://pkp.sfu.ca">
            
            <xsl:if test="contains($public_id, 'pdf')">
                <xsl:attribute name="url_path" select="$public_id"/>
            </xsl:if>
            <xsl:attribute name="approved" select="'true'"/>
<!--            <xsl:if test="$galley_type != ''">
                <xsl:attribute name="galley_type" select="$galley_type"/>
            </xsl:if>-->
            <id type="internal" advice="ignore">0</id>
            <id type="public" advice="update">
                <xsl:value-of select="$public_id"/>
            </id>
            <name>
                <xsl:value-of select="$galley_name"/>
            </name>
            <seq>
                <xsl:value-of select="$seq"/>
            </seq>
            <submission_file_ref id="{$public_id}"/>
        </article_galley>
    </xsl:template>
    
    <xsl:template name="locale">
        <xsl:if test="@locale">
            <xsl:attribute name="locale" select="@locale"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="fix_delimiters">
        <xsl:value-of select="replace(replace(., '\p{P}$', ''), ',', ';')"/>
    </xsl:template>
    
    <xsl:template name="tokenize_to_subelements">
        <xsl:param name="subelement_name" select="''"/>
        <xsl:param name="delimited_string" select="''"/>
        <xsl:for-each select="tokenize($delimited_string, ';')">
            <xsl:element name="{$subelement_name}" xmlns="http://pkp.sfu.ca">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>

    </xsl:template>
</xsl:stylesheet>
