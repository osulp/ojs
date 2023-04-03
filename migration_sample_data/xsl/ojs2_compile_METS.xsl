<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:METS="http://www.loc.gov/METS/"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/TR/xlink"
    exclude-result-prefixes="xs" version="2.0">
    <!-- This stylesheet serves to create a "lookup list" to facilitate the OSU OJS2 to OJS3 migration.
        This lookup list compiles the Public and Galley Identifiers for the existing OJS2 items.
        
        The primary source data for this stylesheet are the XML exports produced by the OJS2 METS XML Export Plugin.
        The ID attributes used within the METS document provide the Public IDs for issues and articles. 
        The Galley IDs are derived from the URLs for the full text files.
        This stylesheet combines the relevant data from the total of all METS XML export files into a single document. 
          - The METS XML export files should be located in the same directory as this stylesheet, inside a directory named 'mets/'.
        The output format is arbitrary XML with human readable element names, which is used by the 'ojs2_ojs3_transform.xsl' 
        stylesheet to generate import files that include the original Public and Galley IDs.
    -->

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:result-document href="ojs2_mets_data.xml">
            <mets_data>
                <!-- root element -->
                <xsl:for-each select="collection('mets/')">
                    <!-- for each document in 'mets/' folder -->
                    <xsl:variable name="journal_title"
                        select="METS:mets//mods:mods[mods:genre = 'journal']/*/mods:title"/>
                    <!-- set journal title for all issues in this document -->
                    <xsl:for-each select="METS:mets//mods:mods[mods:genre = 'issue']">
                        <!-- for each issue in the document -->
                        <!-- assign variables for identifying information -->
                        <xsl:variable name="journal_id"
                            select="substring-after(mods:relatedItem/mods:identifier, 'index.php/')"/>
                        <xsl:variable name="volume_no"
                            select="mods:relatedItem/mods:part/mods:detail[@type = 'volume']/mods:number"/>
                        <xsl:variable name="issue_no"
                            select="mods:relatedItem/mods:part/mods:detail[@type = 'issue']/mods:number"/>
                        <xsl:variable name="issue_date"
                            select="mods:relatedItem/mods:part/mods:date"/>
                        <!-- get ID from dmdSec element and designate as Public ID -->
                        <xsl:variable name="issue_id" select="ancestor::METS:dmdSec/@ID"/>
                        <xsl:variable name="issue_public_id"
                            select="substring-after($issue_id, 'I-')"/>
                        <!-- construct a semantically meaningful issue identifier to key off of when combining data -->
                        <xsl:variable name="issue_internal_id"
                            select="concat($journal_id, '_', $volume_no, '_', $issue_no)"/>
                        <!-- create a human readable record -->
                        <issue id="{$issue_internal_id}">
                            <journal_title>
                                <xsl:value-of select="normalize-space($journal_title)"/>
                            </journal_title>
                            <volume>
                                <xsl:value-of select="$volume_no"/>
                            </volume>
                            <number>
                                <xsl:value-of select="$issue_no"/>
                            </number>
                            <year>
                                <xsl:value-of select="$issue_date"/>
                            </year>
                            <issue_title>
                                <xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/>
                            </issue_title>
                            <issue_url>
                                <xsl:value-of select="mods:identifier[@type = 'uri']"/>
                            </issue_url>
                            <public_id>
                                <xsl:value-of select="$issue_public_id"/>
                            </public_id>
                            <!-- list the contents of the issue -->
                            <articles>
                                <!-- refer to structMap section and locate articles within issues using issue_id -->
                                <xsl:for-each
                                    select="/METS:mets/METS:structMap//METS:div[@DMDID = $issue_id]">
                                    <xsl:for-each select=".//METS:div[@TYPE = 'article']">
                                        <!-- locate section metadata -->
                                        <xsl:variable name="section_id" select="parent::METS:div[@TYPE = 'section']/@DMDID"/>
                                        <xsl:variable name="section_metadata" select="//METS:dmdSec[@ID = $section_id][1]"/>
                                        <!-- get ID from DMDID attribute and designate as Public ID -->
                                        <xsl:variable name="article_id" select="@DMDID"/>
                                        <xsl:variable name="article_public_id"
                                            select="substring-after($article_id, 'A-')"/>
                                        <!-- locate corresponding descriptive metadata using article id -->
                                        <xsl:variable name="article_metadata"
                                            select="//METS:dmdSec[@ID = $article_id]//mods:mods"/>
                                        <!-- construct a semantically meaningful article identifier to key off of 
                                        when combining data, using sequence within issue -->
                                        <xsl:variable name="article_internal_id"
                                            select="concat($journal_id, '_', $volume_no, '_', $issue_no, '_', format-number(position(), '00'))"/>

                                        <article id="{$article_internal_id}">
                                            <section>
                                                <xsl:attribute name="abbrev" select="$section_metadata//mods:titleInfo[@type = 'abbreviated']/mods:title"/>
                                                <xsl:value-of select="$section_metadata//mods:titleInfo[not(@type = 'abbreviated')]/mods:title"/>
                                            </section>
                                            <title>
                                                <xsl:value-of select="normalize-space($article_metadata//mods:titleInfo[not(@type = 'alternative')]/mods:title)"
                                                />
                                            </title>
                                            <public_id>
                                                <xsl:value-of select="$article_public_id"/>
                                            </public_id>
                                            <!-- get galley_id and file size for corresponding full text items -->
                                            <files>
                                                <xsl:for-each select="METS:fptr">
                                                  <!-- get file ids within articles and use to match to fileSec -->
                                                  <xsl:variable name="file_id" select="@FILEID"/>
                                                  <xsl:variable name="file"
                                                  select="//METS:file[@ID = $file_id]"/>
                                                  <!-- get mime type of file -->
                                                  <xsl:variable name="mimetype"
                                                  select="$file/@MIMETYPE"/>
                                                  <!-- get URL of file -->
                                                  <xsl:variable name="file_url"
                                                  select="$file/METS:FLocat/@xlink:href"/>
                                                  <!-- derive Galley ID from final portion of file URL -->
                                                  <xsl:variable name="galley_id"
                                                  select="substring-after($file_url, concat($article_public_id, '/'))"/>
                                                  <!-- get file size -->
                                                  <xsl:variable name="file_size"
                                                  select="$file/@SIZE"/>
                                                  <!-- include Galley IDs only for HTML and PDF files -->
                                                  <file type="{$mimetype}">
                                                  <public_id>
                                                  <xsl:value-of select="$galley_id"/>
                                                  </public_id>
                                                  <file_size>
                                                  <xsl:value-of select="$file_size"/>
                                                  </file_size>
                                                  <file_url>
                                                  <xsl:value-of select="$file_url"/>
                                                  </file_url>
                                                  </file>
                                                </xsl:for-each>

                                                <!-- get supplementary file information -->
                                                <xsl:for-each
                                                  select="METS:div[@TYPE = 'additional_material']">
                                                  <!-- get identifying information -->
                                                  <xsl:variable name="supp_dmdid" select="@DMDID"/>
                                                  <xsl:variable name="supp_internal_id"
                                                  select="concat($article_internal_id, '_s', format-number(position(), '00'))"/>
                                                  <xsl:variable name="supp_metadata"
                                                  select="//METS:dmdSec[@ID = $supp_dmdid]//mods:mods"/>
                                                  <!-- get file ids within articles and use to match to fileSec -->
                                                  <xsl:variable name="supp_file_id"
                                                  select="METS:fptr/@FILEID"/>
                                                  <xsl:variable name="supp_file"
                                                  select="//METS:file[@ID = $supp_file_id]"/>
                                                  <!-- get mime type of file -->
                                                  <xsl:variable name="supp_mimetype"
                                                  select="$supp_file/@MIMETYPE"/>
                                                  <!-- get file name -->
                                                  <xsl:variable name="supp_file_name"
                                                  select="$supp_file/@OWNERID"/>
                                                  <!-- get URL of file -->
                                                  <xsl:variable name="supp_file_url"
                                                  select="$supp_file/METS:FLocat/@xlink:href"/>
                                                  <!-- derive Public ID from final portion of file URL -->
                                                  <xsl:variable name="supp_public_id"
                                                  select="replace(substring-after($supp_file_url, $article_public_id), '/', '')"/>
                                                  <!-- get file size -->
                                                  <xsl:variable name="supp_file_size"
                                                  select="$supp_file/@SIZE"/>

                                                  <!-- create record for supplementary files -->
                                                  <supp_file id="{$supp_internal_id}">
                                                  <xsl:for-each select="$supp_metadata//mods:title">

                                                  <supp_title>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </supp_title>
                                                  </xsl:for-each>
                                                  <supp_file_name>
                                                  <xsl:value-of select="$supp_file_name"/>
                                                  </supp_file_name>
                                                  <supp_id>
                                                  <xsl:value-of select="$supp_public_id"/>
                                                  </supp_id>
                                                  <supp_type>
                                                  <xsl:value-of select="$supp_mimetype"/>
                                                  </supp_type>
                                                  <supp_filesize>
                                                  <xsl:value-of select="$supp_file_size"/>
                                                  </supp_filesize>
                                                  <supp_file_url>
                                                  <xsl:value-of select="$supp_file_url"/>
                                                  </supp_file_url>
                                                  </supp_file>
                                                </xsl:for-each>
                                            </files>
                                        </article>
                                    </xsl:for-each>
                                </xsl:for-each>
                            </articles>
                        </issue>
                    </xsl:for-each>
                </xsl:for-each>
            </mets_data>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>