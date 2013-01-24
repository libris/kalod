<!DOCTYPE xsl:stylesheet SYSTEM "ra_xsl.dtd">
<xsl:stylesheet>
  <xsl:include href="ra-rdf.xslt"/>

  <xsl:template match="ra:ra_container">
    <xsl:variable name="guid" select="ra:hierarchy/ra:this/@id"/>
    <xsl:variable name="desc">
      <dct:identifier xml:lang=""><xsl:value-of select="$guid"/></dct:identifier>
      <rdfs:label><xsl:value-of select="ra:hierarchy/ra:this"/></rdfs:label>
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="typeid" select="ra:type/@id"/>
    <xsl:choose>
      <xsl:when test="$typeid = '1' or
                $typeid = '2' or
                $typeid = '3' or
                $typeid = '5' or
                $typeid = '17' or
                $typeid = '999'">
        <dctype:Collection rdf:about="{$link-base}/archive/{$guid}">
          <xsl:copy-of select="$desc"/>
        </dctype:Collection>
      </xsl:when>
      <!-- TODO: specific object types
           "$typeid = '4' or
           $typeid = '6' or
           $typeid = '7' or
           $typeid = '8' or
           $typeid = '9' or
           $typeid = '10' or
           $typeid = '11' or
           $typeid = '12' or
           $typeid = '13' or
           $typeid = '14' or
           $typeid = '15' or
           $typeid = '16' -->
      <xsl:otherwise>
        <foaf:Document rdf:about="{$link-base}/archive/{$guid}">
          <xsl:copy-of select="$desc"/>
        </foaf:Document>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="ra:hierarchy/ra:parent">
      <rdf:Description rdf:about="{$link-base}/archive/{preceding-sibling::ra:*[1]/@id}">
        <dct:isPartOf rdf:resource="{$link-base}/archive/{@id}"/>
      </rdf:Description>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ra:type">
    <rdf:type>
      <rdfs:Class rdf:about="&rark;{ra:label[@lang='eng']}">
        <xsl:for-each select="ra:label">
          <rdfs:label>
            <xsl:if test="@lang='eng'">
              <xsl:attribute name="xml:lang">en</xsl:attribute>
          </xsl:if>
            <xsl:value-of select="."/>
          </rdfs:label>
        </xsl:for-each>
      </rdfs:Class>
    </rdf:type>
  </xsl:template>

  <xsl:template match="ra:description">
    <dct:description><xsl:value-of select="."/></dct:description>
  </xsl:template>

  <xsl:template match="ra:date">
    <dces:date xml:lang=""><xsl:value-of select="."/></dces:date>
  </xsl:template>

  <xsl:template match="ra:scanned">
    <foaf:depiction rdf:parseType="Resource">
      <foaf:isPrimaryTopicOf rdf:resource="{.}"/>
    </foaf:depiction>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:stylesheet>
