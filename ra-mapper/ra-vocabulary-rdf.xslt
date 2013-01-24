<!DOCTYPE xsl:stylesheet SYSTEM "ra_xsl.dtd">
<xsl:stylesheet>
  <xsl:include href="ra-rdf.xslt"/>

  <xsl:template match="ra:ra_container">
    <xsl:variable name="guid"><xsl:call-template name="get-guid"/></xsl:variable>
    <skos:Concept rdf:about="{$link-base}/vocabulary/{$guid}">
      <skos:prefLabel><xsl:value-of select="ra:name"/></skos:prefLabel>
      <skos:notation xml:lang=""><xsl:value-of select="ra:code"/></skos:notation>
      <!-- TODO: ra:typeId -->
      <skos:inScheme>
        <skos:ConceptScheme rdf:about="{$link-base}/vocabulary/scheme/{ra:thesaurusId}">
          <skos:prefLabel><xsl:value-of select="ra:thesaurus"/></skos:prefLabel>
        </skos:ConceptScheme>
      </skos:inScheme>
    </skos:Concept>
  </xsl:template>

</xsl:stylesheet>
