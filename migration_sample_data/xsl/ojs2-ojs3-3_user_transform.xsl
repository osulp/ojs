<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://pkp.sfu.ca" 
    exclude-result-prefixes="xs #default"
    version="2.0">

    <!-- 
        Created by Cara M. Key, August 2023.
        
        This stylesheet is a component of OSU Library Information Technology's project
        to migrate journals from Open Journal Systems (OJS) version 2 to version 3, specifically
        used for transferring user accounts.
        
        It takes as input an XML file containing a list of user account information, exported 
        from the OJS 2 Users XML Plugin. The input file is expected to be named using the syntax 
        "(identifyingInformation)_users.xml" (e.g. MyJournal_users.xml or authors_users.xml), and
        located in a directory named "ojs2_users/".  
        
        It produces as output one XML file containing a list of user account information, which
        can be imported to OJS 3.3.
        
        This transform attempts to remove a majority of spam user accounts by skipping accounts 
        in the input XML that advertise a website in the signature or biography field. It looks for
        strings such as "website", "click here", "blog", etc. See below for the full list. 
        
        It also replaces any password hashes that are not 60 characters long with a dummy password
        and sets a requirement for the user to change the password at next login. This is to avoid the 
        system sending emails when the password type is not acceptable for OJS version 3. 
        
    -->

    <xsl:output method="xml" xpath-default-namespace="http://pkp.sfu.ca" exclude-result-prefixes="#all" indent="yes" />
    
    <xsl:variable name="journal_id"
        select="substring-before(substring-after(document-uri(), 'ojs2_users/'), '_users')"/>
    
    <xsl:variable name="user_roles">
        <user_roles>
            <user_role ojs2="manager" ojs3="Journal manager"/>
            <user_role ojs2="editor" ojs3="Journal editor"/>
            <user_role ojs2="sectionEditor" ojs3="Section editor"/>
            <user_role ojs2="layoutEditor" ojs3="Layout Editor"/>
            <user_role ojs2="reviewer" ojs3="Reviewer"/>
            <user_role ojs2="copyeditor" ojs3="Copyeditor"/>
            <user_role ojs2="proofreader" ojs3="Proofreader"/>
            <user_role ojs2="author" ojs3="Author"/>
            <user_role ojs2="reader" ojs3="Reader"/>
            <user_role ojs2="subscriptionManager" ojs3="Subscription Manager"/>
        </user_roles>
    </xsl:variable>
    
    <xsl:key name="role_map" match="*[local-name() = 'user_role']" use="@ojs2"/>
    
    <xsl:template match="users">
        <xsl:result-document href="ojs3_users/{$journal_id}_users.xml">
            <users xmlns="http://pkp.sfu.ca" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://pkp.sfu.ca pkp-users.xsd">
                <xsl:for-each
                    select="
                        user
                        [not(username = 'admin')]
                        [not(contains(normalize-space(biography[1]), 'a href'))]
                        [not(contains(normalize-space(signature[1]), 'a href'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'blog'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'blog'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'website'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'website'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'web site'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'web site'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'web-site'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'web-site'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'web page'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'web page'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'webpage'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'webpage'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'homepage'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'homepage'))]
                        [not(contains(normalize-space(lower-case(biography[1])), 'click here'))]
                        [not(contains(normalize-space(lower-case(signature[1])), 'click here'))]">
                    <user xmlns="http://pkp.sfu.ca">
                        <xsl:apply-templates select="first_name"/>
                        <xsl:apply-templates select="last_name"/>
                        <xsl:apply-templates select="affiliation"/>
                        <xsl:apply-templates select="country"/>
                        <xsl:apply-templates select="email"/>
                        <xsl:apply-templates select="url"/>
                        <xsl:apply-templates select="biography"/>
                        <xsl:apply-templates select="username"/>
                        <xsl:apply-templates select="signature"/>
                        <xsl:apply-templates select="password"/>
                        <xsl:apply-templates select="phone"/>
                        <xsl:apply-templates select="mailing_address"/>
                        <xsl:apply-templates select="role"/>
                        <xsl:apply-templates select="interests[1]"/>
                    </user>
                </xsl:for-each>

            </users>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="first_name">
        <givenname>
            <xsl:if test="@locale">
                <xsl:attribute name="locale" select="@locale"/>
            </xsl:if>
            <xsl:value-of select="."/>
            <xsl:if test="../middle_name">
                <xsl:text> </xsl:text>
                <xsl:value-of select="../middle_name"/>
            </xsl:if>
        </givenname>
    </xsl:template>
    
    <xsl:template match="last_name">
        <familyname>
            <xsl:if test="@locale">
                <xsl:attribute name="locale" select="@locale"/>
            </xsl:if>
            <xsl:value-of select="."/>
        </familyname>
    </xsl:template>
    
    <xsl:template match="affiliation|email|username|phone">
        <xsl:element name="{local-name(.)}">
            <xsl:if test="@locale">
                <xsl:attribute name="locale" select="@locale"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="biography|signature|mailing_address">
        <xsl:element name="{local-name(.)}">
            <xsl:if test="@locale">
                <xsl:attribute name="locale" select="@locale"/>
            </xsl:if>
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[&lt;p&gt;</xsl:text>
            <xsl:value-of
                select="normalize-space(replace(., '&#13;', '&lt;br/&gt;'))"
                disable-output-escaping="yes"/>
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;]]&gt;</xsl:text>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="country">
        <country>
            <xsl:choose>
                <xsl:when test=".">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>United States</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </country>
    </xsl:template>
    
    <xsl:template match="url">
        <xsl:choose>
            <xsl:when test="matches(., 'orcid.org/')">
                <orcid>
                    <xsl:value-of select="substring-after(., 'orcid.org/')"/>
                </orcid>
            </xsl:when>
            <xsl:otherwise>
                <url>
                    <xsl:value-of select="."/>
                </url>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="password">
        <xsl:choose>
            <xsl:when test="string-length(.) = 60">
                <password is_disabled="false" must_change="false" encryption="{@encrypted}">
                    <value>
                        <xsl:value-of select="."/>
                    </value>
                </password>
            </xsl:when>
            <xsl:otherwise>
                <password is_disabled="false" must_change="true" encryption="md5">
                    <value>$2y$10$.x.RT5Sox5HdSxO96RQKk.YhpNuwAofLCCOh.ziyFWAaIaJDYtY6G</value>
                </password>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="role">
        <xsl:variable name="ojs2_role" select="@type"/>
        <user_group_ref>
            <xsl:value-of select="$user_roles/key('role_map', $ojs2_role)/@ojs3"/>
        </user_group_ref>
    </xsl:template>
    
    <xsl:template match="interests">
        <review_interests>
            <xsl:for-each select="../interests">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </review_interests>
    </xsl:template>
    

</xsl:stylesheet>
