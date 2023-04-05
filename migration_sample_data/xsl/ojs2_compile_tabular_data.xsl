<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:METS="http://www.loc.gov/METS/"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/TR/xlink"
    exclude-result-prefixes="xs" version="2.0">
    <!-- This stylesheet serves to create a tabular data text file to use in post-import QA for the OSU OJS2 to OJS3 migration.
        
        The source file for this stylesheet is the arbitrary XML output from the ojs2_compile_METS.xsl stylesheet,
        which contains metadata extracted from the exported METS files from OJS2.
        The output from this stylesheet is one row per issue and per article, containing delimited data as 
        enumerated in header row.
    -->
    
    <xsl:output method="text" indent="yes"/>
    
    <xsl:variable name="delim" select="'&#9;'"/>
    <xsl:variable name="newline" select="'&#10;'"/>
    
    <xsl:template match="/">
        <!-- create header row -->
        <xsl:text>document_type</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>journal_title</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>volume_number</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>issue_number</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>year</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>section_abbrev</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>section_name</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>internal_id</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>item_id</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>item_title</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>item_url</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>article_count</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>html_galley</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>html_media_files</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>pdf_galley</xsl:text>
        <xsl:value-of select="$delim"/>
        <xsl:text>supplementary_files</xsl:text>
        <xsl:value-of select="$delim"/>
        
        <!-- create a data row per issue, matching headers above -->
        <xsl:for-each select="mets_data/issue">
            <xsl:value-of select="$newline"/>
            <xsl:text>Issue</xsl:text>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="journal_title"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="volume"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="number"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="year"/>
            <xsl:value-of select="$delim"/>
            <!-- skip section abbrev -->
            <xsl:value-of select="$delim"/>
            <!-- skip section name -->
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="@id"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="public_id"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="concat('&quot;',normalize-space(issue_title), '&quot;')"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="issue_url"/>
            <xsl:value-of select="$delim"/>
            <xsl:value-of select="count(articles/article)"/>
            <xsl:value-of select="$delim"/>
            <!-- skip html_galley -->
            <xsl:value-of select="$delim"/>
            <!-- skip html_media_files -->
            <xsl:value-of select="$delim"/>
            <!-- skip pdf_galley -->
            <xsl:value-of select="$delim"/>
            <!-- skip supplementary_files -->
            <xsl:value-of select="$delim"/>
            
            <xsl:for-each select="articles/article">
                <xsl:value-of select="$newline"/>
                <xsl:text>Article</xsl:text>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="ancestor::issue/journal_title"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="ancestor::issue/volume"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="ancestor::issue/number"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="ancestor::issue/year"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="section/@abbrev"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="section"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="@id"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="public_id"/>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="concat('&quot;', normalize-space(title), '&quot;')"/>
                <xsl:value-of select="$delim"/>
                <!-- compose expected URL -->
                <xsl:variable name="volnum" select="ancestor::issue/volume"/>
                <xsl:variable name="journal_id" select="substring-before(@id,$volnum)"/>
                <xsl:value-of select="concat('http://journals.oregondigital.org/index.php/',substring($journal_id,1,string-length($journal_id)-1),'/article/view/',public_id)"/>
                <xsl:value-of select="$delim"/>
                <!-- skip article count -->
                <xsl:value-of select="$delim"/>
                <xsl:choose>
                    <xsl:when test="files/file[@type = 'text/html']">
                        <xsl:text>TRUE</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>FALSE</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="count(files/file[not(@type = 'text/html' or @type = 'application/pdf')])"/>
                <xsl:value-of select="$delim"/>
                <xsl:choose>
                    <xsl:when test="files/file[@type = 'application/pdf']">
                        <xsl:text>TRUE</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>FALSE</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$delim"/>
                <xsl:value-of select="count(files/supp_file)"/>
                <xsl:value-of select="$delim"/>
            </xsl:for-each>
            
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>