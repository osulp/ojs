<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:METS="http://www.loc.gov/METS/"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/TR/xlink"
    exclude-result-prefixes="xs" version="2.0">
    <!-- 
        This stylesheet serves to create a tabular data text file representing issues, submissions, and content files 
        (galleys and supplements), focusing on IDs and URLs to help handle redirects for the OSU OJS2 to OJS3 migration.
        
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
        <!-- internal_id -->
        <xsl:value-of select="'internal_id',$delim"/>
        <!-- OJS2_id -->
        <xsl:value-of select="'OJS2_id',$delim"/>
        <!-- parent_issue_OJS2_id -->
        <xsl:value-of select="'parent_issue_OJS2_id',$delim"/>
        <!-- parent_submission_OJS2_id -->
        <xsl:value-of select="'parent_submission_OJS2_id',$delim"/>
        <!-- content_type -->
        <xsl:value-of select="'content_type',$delim"/>
        <!-- item_title -->
        <xsl:value-of select="'item_title',$delim"/>
        <!-- journal_abbrev -->
        <xsl:value-of select="'journal_abbrev',$delim"/>
        <!-- journal_title -->
        <xsl:value-of select="'journal_title',$delim"/>
        <!-- volume_number -->
        <xsl:value-of select="'volume_number',$delim"/>
        <!-- issue_number -->
        <xsl:value-of select="'issue_number',$delim"/>
        <!-- year -->
        <xsl:value-of select="'year',$delim"/>
        <!-- section_abbrev -->
        <xsl:value-of select="'section_abbrev',$delim"/>
        <!-- section_name -->
        <xsl:value-of select="'section_name',$delim"/>
        <!-- file_type -->
        <xsl:value-of select="'file_type',$delim"/>
        <!-- OJS2_url -->
        <xsl:value-of select="'OJS2_url',$delim"/>
        <!-- OJS3_id -->
        <xsl:value-of select="'OJS3_id',$delim"/>
        <!-- parent_issue_OJS3_id -->
        <xsl:value-of select="'parent_issue_OJS3_id',$delim"/>
        <!-- parent_submission_OJS3_id -->
        <xsl:value-of select="'parent_submission_OJS3_id',$delim"/>
        <!-- OJS3_url -->
        <xsl:value-of select="'OJS3_url',$delim"/>
        
        <!-- create a data row per issue, matching headers above -->
        <xsl:for-each select="mets_data/issue">
            <!-- save issue data for component rows -->
            <xsl:variable name="journal_abbrev" select="substring-before(substring-after(issue_url,'index.php/'),'/')"/>
            <xsl:variable name="issue_id" select="public_id"/>
            <xsl:variable name="journal_title" select="journal_title"/>
            <xsl:variable name="issue_volnum" select="volume"/>
            <xsl:variable name="issue_issnum" select="issue"/>
            <xsl:variable name="issue_year" select="year"/>
            
            <xsl:value-of select="$newline"/>
            <!-- internal_id -->
            <xsl:value-of select="@id,$delim"/>
            <!-- OJS2_id -->
            <xsl:value-of select="$issue_id,$delim"/>
            <!-- parent_issue_OJS2_id -->
            <xsl:value-of select="'n/a',$delim"/>
            <!-- parent_submission_OJS2_id -->
            <xsl:value-of select="'n/a',$delim"/>
            <!-- content_type -->
            <xsl:value-of select="'issue',$delim"/>
            <!-- item_title -->
            <xsl:value-of select="issue_title,$delim"/>
            <!-- journal_abbrev -->
            <xsl:value-of select="$journal_abbrev,$delim"/>
            <!-- journal_title -->
            <xsl:value-of select="$journal_title,$delim"/>
            <!-- volume_number -->
            <xsl:value-of select="$issue_volnum,$delim"/>
            <!-- issue_number -->
            <xsl:value-of select="$issue_issnum,$delim"/>
            <!-- year -->
            <xsl:value-of select="$issue_year,$delim"/>
            <!-- section_abbrev -->
            <xsl:value-of select="'n/a',$delim"/>
            <!-- section_name -->
            <xsl:value-of select="'n/a',$delim"/>
            <!-- file_type -->
            <xsl:value-of select="'n/a',$delim"/>
            <!-- OJS2_url -->
            <xsl:value-of select="issue_url,$delim"/>
            <!-- set up empty cells for OJS3 data -->
            <!-- OJS3_id -->
            <!-- parent_issue_OJS3_id -->
            <!-- parent_submission_OJS3_id -->
            <!-- OJS3_url -->
            <xsl:value-of select="$delim,$delim,$delim,$delim"/>
       
            <xsl:for-each select="articles/article">
                <!-- save article data for component rows -->
                <xsl:variable name="article_internal_id" select="@id"/>
                <xsl:variable name="article_id" select="public_id"/>
                <xsl:variable name="article_secabbrev" select="section/@abbrev"/>
                <xsl:variable name="article_secname" select="section"/>
                
                <xsl:value-of select="$newline"/>
                <!-- internal_id -->
                <xsl:value-of select="$article_internal_id,$delim"/>
                <!-- OJS2_id -->
                <xsl:value-of select="$article_id,$delim"/>
                <!-- parent_issue_OJS2_id -->
                <xsl:value-of select="$issue_id,$delim"/>
                <!-- parent_submission_OJS2_id -->
                <xsl:value-of select="'n/a',$delim"/>
                <!-- content_type -->
                <xsl:value-of select="'article',$delim"/>
                <!-- item_title -->
                <xsl:value-of select="title,$delim"/>
                <!-- journal_abbrev -->
                <xsl:value-of select="$journal_abbrev,$delim"/>
                <!-- journal_title -->
                <xsl:value-of select="$journal_title,$delim"/>
                <!-- volume_number -->
                <xsl:value-of select="$issue_volnum,$delim"/>
                <!-- issue_number -->
                <xsl:value-of select="$issue_issnum,$delim"/>
                <!-- year -->
                <xsl:value-of select="$issue_year,$delim"/>
                <!-- section_abbrev -->
                <xsl:value-of select="$article_secabbrev,$delim"/>
                <!-- section_name -->
                <xsl:value-of select="$article_secname,$delim"/>
                <!-- file_type -->
                <xsl:value-of select="'n/a',$delim"/>
                <!-- OJS2_url -->
                <xsl:value-of select="concat('http://journals.oregondigital.org/index.php/',$journal_abbrev,'/article/view/',$article_id),$delim"/>
                <!-- set up empty cells for OJS3 data -->
                <!-- OJS3_id -->
                <!-- parent_issue_OJS3_id -->
                <!-- parent_submission_OJS3_id -->
                <!-- OJS3_url -->
                <xsl:value-of select="$delim,$delim,$delim,$delim"/>
                
                <xsl:for-each select="files/file">
                    <xsl:value-of select="$newline"/>
                    <!-- internal_id -->
                    <xsl:value-of select="concat($article_internal_id,'_g',format-number(position(), '00')),$delim"/>
                    <!-- OJS2_id -->
                    <xsl:value-of select="public_id,$delim"/>
                    <!-- parent_issue_OJS2_id -->
                    <xsl:value-of select="$issue_id,$delim"/>
                    <!-- parent_submission_OJS2_id -->
                    <xsl:value-of select="$article_id,$delim"/>
                    <!-- content_type -->
                    <xsl:value-of select="'galley',$delim"/>
                    <!-- item_title -->
                    <xsl:value-of select="$delim"/>
                    <!-- journal_abbrev -->
                    <xsl:value-of select="$journal_abbrev,$delim"/>
                    <!-- journal_title -->
                    <xsl:value-of select="$journal_title,$delim"/>
                    <!-- volume_number -->
                    <xsl:value-of select="$issue_volnum,$delim"/>
                    <!-- issue_number -->
                    <xsl:value-of select="$issue_issnum,$delim"/>
                    <!-- year -->
                    <xsl:value-of select="$issue_year,$delim"/>
                    <!-- section_abbrev -->
                    <xsl:value-of select="$article_secabbrev,$delim"/>
                    <!-- section_name -->
                    <xsl:value-of select="$article_secname,$delim"/>
                    <!-- file_type -->
                    <xsl:value-of select="@type,$delim"/>
                    <!-- OJS2_url -->
                    <xsl:value-of select="file_url,$delim"/>
                    <!-- set up empty cells for OJS3 data -->
                    <!-- OJS3_id -->
                    <!-- parent_issue_OJS3_id -->
                    <!-- parent_submission_OJS3_id -->
                    <!-- OJS3_url -->
                    <xsl:value-of select="$delim,$delim,$delim,$delim"/>    
                </xsl:for-each>
                
                <xsl:for-each select="files/supp_file">
                    <xsl:value-of select="$newline"/>
                    <!-- internal_id -->
                    <xsl:value-of select="@id,$delim"/>
                    <!-- OJS2_id -->
                    <xsl:value-of select="supp_id,$delim"/>
                    <!-- parent_issue_OJS2_id -->
                    <xsl:value-of select="$issue_id,$delim"/>
                    <!-- parent_submission_OJS2_id -->
                    <xsl:value-of select="$article_id,$delim"/>
                    <!-- content_type -->
                    <xsl:value-of select="'supplement',$delim"/>
                    <!-- item_title -->
                    <xsl:for-each select="supp_title">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(position()=last())">
                            <xsl:text>||</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="$delim"/>
                    <!-- journal_abbrev -->
                    <xsl:value-of select="$journal_abbrev,$delim"/>
                    <!-- journal_title -->
                    <xsl:value-of select="$journal_title,$delim"/>
                    <!-- volume_number -->
                    <xsl:value-of select="$issue_volnum,$delim"/>
                    <!-- issue_number -->
                    <xsl:value-of select="$issue_issnum,$delim"/>
                    <!-- year -->
                    <xsl:value-of select="$issue_year,$delim"/>
                    <!-- section_abbrev -->
                    <xsl:value-of select="$article_secabbrev,$delim"/>
                    <!-- section_name -->
                    <xsl:value-of select="$article_secname,$delim"/>
                    <!-- file_type -->
                    <xsl:value-of select="supp_type,$delim"/>
                    <!-- OJS2_url -->
                    <xsl:value-of select="supp_file_url,$delim"/>
                    <!-- set up empty cells for OJS3 data -->
                    <!-- OJS3_id -->
                    <!-- parent_issue_OJS3_id -->
                    <!-- parent_submission_OJS3_id -->
                    <!-- OJS3_url -->
                    <xsl:value-of select="$delim,$delim,$delim,$delim"/>
                </xsl:for-each>
                
            </xsl:for-each>
            
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>