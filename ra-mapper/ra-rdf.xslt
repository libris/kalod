<!DOCTYPE xsl:stylesheet SYSTEM "ra_xsl.dtd">
<xsl:stylesheet>

  <xsl:param name="link-base" select="'http://id.riksarkivet.se'"/>
  <xsl:param name="lang" select="'sv'"/>
  <xsl:param name="publisher" select="'http://id.riksarkivet.se/ra'"/>

  <xsl:template match="/">
    <rdf:RDF xml:lang="{$lang}">
      <xsl:apply-templates/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template name="get-guid">
    <xsl:value-of select="normalize-space(substring-before(substring-after(ra:url, 'http://nad.riksarkivet.se/?postid=Arkis'), '&amp;s=Balder'))"/>
  </xsl:template>

</xsl:stylesheet>
