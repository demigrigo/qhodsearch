<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Template for escaping JSON strings -->
    <xsl:template name="escape-json">
        <xsl:param name="text"/>
        <xsl:variable name="escaped">
            <xsl:call-template name="replace-string">
                <xsl:with-param name="text">
                    <xsl:call-template name="replace-string">
                        <xsl:with-param name="text">
                            <xsl:call-template name="replace-string">
                                <xsl:with-param name="text">
                                    <xsl:call-template name="replace-string">
                                        <xsl:with-param name="text">
                                            <xsl:call-template name="replace-string">
                                                <xsl:with-param name="text" select="$text"/>
                                                <xsl:with-param name="replace">\</xsl:with-param>
                                                <xsl:with-param name="with">\\</xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                        <xsl:with-param name="replace">"</xsl:with-param>
                                        <xsl:with-param name="with">\"</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="replace">\n</xsl:with-param>
                                <xsl:with-param name="with"> </xsl:with-param>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="replace">\r</xsl:with-param>
                        <xsl:with-param name="with"> </xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="replace">\t</xsl:with-param>
                <xsl:with-param name="with"> </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$escaped"/>
    </xsl:template>
    
    <!-- Template for replacing strings -->
    <xsl:template name="replace-string">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text, $replace)"/>
                <xsl:value-of select="$with"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="substring-after($text, $replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="with" select="$with"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Main template to process the entire document -->
    <xsl:template match="/">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="//tei:person | //tei:place ">
            <xsl:choose>
                <xsl:when test="self::tei:person">
                    <xsl:call-template name="processPerson"/>
                </xsl:when>
                <xsl:when test="self::tei:place">
                    <xsl:call-template name="processPlace"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    
    <!-- Template for processing person elements -->
    <xsl:template name="processPerson" match="tei:person">
        <xsl:text>{</xsl:text>
        <xsl:text>"type": "person",</xsl:text>
        <xsl:text>"name": "</xsl:text>
        <xsl:for-each select="./tei:persName">
            <xsl:value-of select="normalize-space(concat(tei:forename, ' ', tei:surname))"/>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>",</xsl:text>
        
        <xsl:text>"additional names": [</xsl:text>
        <xsl:for-each select="./tei:persName/tei:addName[@subtype][@xml:lang]">
            <xsl:text>{</xsl:text>
            <xsl:text>"name": "</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>", "lang": "</xsl:text>
            <xsl:value-of select="@xml:lang"/>
            <xsl:text>", "collection": "</xsl:text>
            <xsl:value-of select="@subtype"/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        
        <xsl:if test="./tei:link">
            <xsl:text>,"links": [</xsl:text>
            <xsl:for-each select="./tei:link[@subtype='vrancic' or @subtype='kuse' or @subtype='graviz' or @subtype='Dolmetscher' or @subtype='QHOD']">
                <xsl:text>{</xsl:text>
                <xsl:text>"link": "</xsl:text>
                <xsl:value-of select="@subtype"/>
                <xsl:text>"}</xsl:text>
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>]</xsl:text>
        </xsl:if>
        
        <xsl:text>,"id": [</xsl:text>
        <xsl:for-each select="./tei:idno[@type='apis_id']">
            <xsl:text>{</xsl:text>
            <xsl:text>"id": "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        
        <!-- Add authoritative_ids for GND links in persons -->
        <xsl:text>,"authoritative_ids": [</xsl:text>
        <xsl:for-each select="./tei:idno[@type='GND']">
            <xsl:text>{</xsl:text>
            <xsl:text>"GND": "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        
        <xsl:text>, "when": [</xsl:text>
        <xsl:for-each select=".//comment()[contains(., '202')][1]">
            <xsl:text>{</xsl:text>
            <xsl:text>"when": "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template name="processPlace" match="tei:place">
        <xsl:text>{</xsl:text>
        <xsl:text>"type": "place",</xsl:text>
        <xsl:text>"name": "</xsl:text>
        <xsl:for-each select="./tei:placeName[not(@type)]">
            <xsl:call-template name="escape-json">
                <xsl:with-param name="text" select="normalize-space(.)"/>
            </xsl:call-template>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>",</xsl:text>
        
        <xsl:text>"additional names": [</xsl:text>
        <xsl:for-each select="tei:placeName[@subtype][@xml:lang]">
            <xsl:text>{</xsl:text>
            <xsl:text>"name": "</xsl:text>
            <xsl:call-template name="escape-json">
                <xsl:with-param name="text" select="normalize-space(.)"/>
            </xsl:call-template>
            <xsl:text>", "lang": "</xsl:text>
            <xsl:value-of select="@xml:lang"/>
            <xsl:text>", "collection": "</xsl:text>
            <xsl:value-of select="@subtype"/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        
        <xsl:if test=".//tei:link">
            <xsl:text>,"links": [</xsl:text>
            <xsl:for-each select=".//tei:link[@subtype='vrancic' or @subtype='kuse' or @subtype='graviz' or @subtype='Dolmetscher' or @subtype='QHOD']">
                <xsl:text>{</xsl:text>
                <xsl:text>"link": "</xsl:text>
                <xsl:value-of select="@subtype"/>
                <xsl:text>"}</xsl:text>
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>]</xsl:text>
        </xsl:if>
        
        <xsl:text>,"id": [</xsl:text>
        <xsl:for-each select=".//tei:idno[@type='apis_id']">
            <xsl:text>{</xsl:text>
            <xsl:text>"id": "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        
        <xsl:text>,"authoritative_ids": [</xsl:text>
        <xsl:for-each select=".//tei:idno[@type='GND' or 'GeoNames']">
            <xsl:text>{</xsl:text>
            <xsl:text>"type": "</xsl:text>
            <xsl:value-of select="@type"/>
            <xsl:text>",</xsl:text>
            <xsl:text>"url": "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"</xsl:text>
            <xsl:text>}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        
        <xsl:text>, "when": [</xsl:text>
        <xsl:for-each select=".//comment()[contains(., '202')][1]">
            <xsl:text>{</xsl:text>
            <xsl:text>"when": "</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
</xsl:stylesheet>
