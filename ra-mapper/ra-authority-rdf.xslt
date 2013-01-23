<!DOCTYPE xsl:stylesheet [
  <!ENTITY xsd 'http://www.w3.org/2001/XMLSchema#'>
  <!ENTITY rark 'http://data.ra.se/vocab/archive#'>
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:ra="http://libris.kb.se/vocab/ra"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:void="http://rdfs.org/ns/void#"
    xmlns:schema="http://schema.org/"
    xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dbpowl="http://dbpedia.org/ontology/"
    xmlns:rark="&rark;">

  <xsl:param name="link-base" select="'http://id.riksarkivet.se'"/>
  <xsl:param name="lang" select="'sv'"/>
  <xsl:param name="publisher" select="'http://id.riksarkivet.se/ra'"/>

  <xsl:template match="/">
    <rdf:RDF xml:lang="{$lang}">
      <xsl:apply-templates/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template match="ra:ra_container">
    <xsl:variable name="guid" select="substring-before(substring-after(ra:url, 'http://nad.riksarkivet.se/?postid=Arkis'), '&amp;s=Balder')"/>
    <xsl:variable name="typeid" select="ra:type/@id"/>
    <!-- TODO: complete list
        $ cat downloads/ra-authority-dump.xml | grep '<type id=' | sort | uniq
    -->
    <xsl:choose>
      <xsl:when test="$typeid = '11'">
        <xsl:call-template name="desc">
          <xsl:with-param name="type">foaf:Person</xsl:with-param>
          <xsl:with-param name="segment">person</xsl:with-param>
          <xsl:with-param name="guid" select="$guid"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$typeid = '13'">
        <xsl:call-template name="desc">
          <xsl:with-param name="type">foaf:Group</xsl:with-param>
          <xsl:with-param name="segment">family</xsl:with-param>
          <xsl:with-param name="guid" select="$guid"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="desc">
          <xsl:with-param name="type">foaf:Organization</xsl:with-param>
          <xsl:with-param name="segment">org</xsl:with-param>
          <xsl:with-param name="guid" select="$guid"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="desc">
    <xsl:param name="type"/>
    <xsl:param name="segment"/>
    <xsl:param name="guid"/>
    <xsl:variable name="uri" select="concat($link-base, '/', $segment, '/', $guid)"/>
    <xsl:element name="{$type}">
      <xsl:attribute name="rdf:about"><xsl:value-of select="$uri"/></xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="uri" select="$uri"/>
      </xsl:apply-templates>
      <foaf:primaryTopicOf>
        <foaf:Document rdf:about="{ra:url}">
          <foaf:primaryTopic rdf:resource="{$uri}"/>
          <dct:identifier xml:lang=""><xsl:value-of select="$guid"/></dct:identifier>
          <dct:identifier xml:lang=""><xsl:value-of select="ra:referenceCode"/></dct:identifier>
          <dct:publisher rdf:resource="{$publisher}"/>
          <!-- dct:isPartOf dataset -->
        </foaf:Document>
      </foaf:primaryTopicOf>
    </xsl:element>
    <xsl:apply-templates mode="top-level">
      <xsl:with-param name="uri" select="$uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="ra:name[text()]">
    <foaf:name><xsl:value-of select="."/></foaf:name>
  </xsl:template>

  <xsl:template match="ra:type">
    <rdf:type>
      <rdfs:Class rdf:about="&rark;Agent-{@id}">
        <rdfs:label><xsl:value-of select="."/></rdfs:label>
      </rdfs:Class>
    </rdf:type>
  </xsl:template>

  <xsl:template match="ra:category">
    <dct:subject>
      <skos:Concept rdf:about="{$link-base}/category/{@id}">
        <rdfs:label><xsl:value-of select="."/></rdfs:label>
      </skos:Concept>
    </dct:subject>
  </xsl:template>

  <xsl:template match="ra:sector">
    <dct:subject>
      <skos:Concept rdf:about="{$link-base}/sector/{@id}">
        <rdfs:label><xsl:value-of select="."/></rdfs:label>
      </skos:Concept>
    </dct:subject>
  </xsl:template>

  <xsl:template match="ra:organisationLevel[@id != 0]">
    <dct:subject>
      <skos:Concept rdf:about="{$link-base}/orgLevel/{@id}">
        <rdfs:label><xsl:value-of select="."/></rdfs:label>
      </skos:Concept>
    </dct:subject>
  </xsl:template>

  <xsl:template match="ra:startDate">
    <dbpowl:activeYearsStartYear rdf:datatype="&xsd;gYear"><xsl:value-of select="."/></dbpowl:activeYearsStartYear>
  </xsl:template>

  <xsl:template match="ra:endDate">
    <dbpowl:activeYearsEndYear rdf:datatype="&xsd;gYear"><xsl:value-of select="."/></dbpowl:activeYearsEndYear>
  </xsl:template>

  <xsl:template match="ra:alternativeName[@typeName='Auktoriserad namnform' and text()]">
    <skos:prefLabel><xsl:value-of select="."/></skos:prefLabel>
  </xsl:template>

  <xsl:template match="ra:alternativeName[text()]">
    <skos:altLabel><xsl:value-of select="."/></skos:altLabel>
  </xsl:template>

  <!-- ra:archive -->
  <xsl:template match="ra:archive">
    <xsl:param name="uri"/>
    <xsl:element name="rark:archiveRelation-{@relationCode}">
      <rdf:Description rdf:about="{$link-base}/archive/{@id}"/>
      <!--
      <dctype:Collection rdf:about="{$link-base}/archive/{@id}">
        <dct:identifier xml:lang=""><xsl:value-of select="@id"/></dct:identifier>
        <!- -<dct:contributor rdf:resource="{$uri}"/> - ->
      </dctype:Collection>
      -->
    </xsl:element>
  </xsl:template>
  <xsl:template match="ra:archive" mode="top-level">
    <rdf:Property rdf:about="&rark;archiveRelation-{@relationCode}">
      <rdfs:label><xsl:value-of select="@relation"/></rdfs:label>
    </rdf:Property>
  </xsl:template>

  <!-- ra:place -->
  <xsl:template match="ra:place">
    <!-- TODO: @relationTypeId a rdf:Property; rdfs:label @relationType -->
    <foaf:based_near>
      <dbpowl:Place>
        <dct:identifier xml:lang=""><xsl:value-of select="@code"/></dct:identifier>
        <rdf:type>
          <rdfs:Class rdf:about="&rark;Place-{@typeId}">
            <rdfs:label><xsl:value-of select="@type"/></rdfs:label>
          </rdfs:Class>
        </rdf:type>
      </dbpowl:Place>
    </foaf:based_near>
  </xsl:template>

</xsl:stylesheet>
