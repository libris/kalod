<!DOCTYPE xsl:stylesheet SYSTEM "ra_xsl.dtd">
<xsl:stylesheet>
  <xsl:include href="ra-rdf.xslt"/>

  <xsl:template match="ra:ra_container">
    <xsl:variable name="guid"><xsl:call-template name="get-guid"/></xsl:variable>
    <xsl:variable name="typeid" select="ra:type/@id"/>
    <!-- see complete list "Posttyp_auktoritet.txt" -->
    <xsl:choose>
      <xsl:when test="$typeid = '11' or $typeid = '12'">
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
        <xsl:if test="$typeid = '901'">
          <xsl:message>
            <xsl:text>Warning: typed as</xsl:text>
            <xsl:value-of select="$typeid"/>
          </xsl:message>
        </xsl:if>
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
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="uri" select="$uri"/>
      </xsl:apply-templates>
      <foaf:isPrimaryTopicOf>
        <foaf:Document rdf:about="{ra:url}">
          <foaf:primaryTopic rdf:resource="{$uri}"/>
          <dct:identifier xml:lang=""><xsl:value-of select="$guid"/></dct:identifier>
          <dct:identifier xml:lang=""><xsl:value-of select="ra:referenceCode"/></dct:identifier>
          <dct:publisher rdf:resource="{$publisher}"/>
          <!-- dct:isPartOf dataset -->
        </foaf:Document>
      </foaf:isPrimaryTopicOf>
    </xsl:element>
    <xsl:apply-templates mode="top-level">
      <xsl:with-param name="uri" select="$uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="ra:name[text()]">
    <foaf:name><xsl:value-of select="."/></foaf:name>
  </xsl:template>

  <!-- TODO: generate Class, Concept and Property definitions from definition
       lists instead. Only link to them from here.  -->

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
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = 'foaf:Person'">
        <dbpowl:birthYear rdf:datatype="&xsd;gYear"><xsl:value-of select="."/></dbpowl:birthYear>
      </xsl:when>
      <xsl:otherwise>
        <dbpowl:activeYearsStartYear rdf:datatype="&xsd;gYear"><xsl:value-of select="."/></dbpowl:activeYearsStartYear>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ra:endDate">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = 'foaf:Person'">
        <dbpowl:deathYear rdf:datatype="&xsd;gYear"><xsl:value-of select="."/></dbpowl:deathYear>
      </xsl:when>
      <xsl:otherwise>
        <dbpowl:activeYearsEndYear rdf:datatype="&xsd;gYear"><xsl:value-of select="."/></dbpowl:activeYearsEndYear>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ra:alternativeName[@typeName='Auktoriserad namnform' and text()]">
    <skos:prefLabel><xsl:value-of select="."/></skos:prefLabel>
  </xsl:template>

  <xsl:template match="ra:alternativeName[text()]">
    <skos:altLabel><xsl:value-of select="."/></skos:altLabel>
  </xsl:template>

  <!--
  <xsl:template match="ra:archive">
    <xsl:element name="rark:archiveRelation-{@relationCode}">
      <rdf:Description rdf:about="{$link-base}/archive/{@id}"/>
    </xsl:element>
  </xsl:template>
  -->
  <xsl:template match="ra:archive" mode="top-level">
    <xsl:param name="uri"/>
    <rdf:Description rdf:about="{$link-base}/archive/{@id}">
      <!-- TODO: evaluate relation applicability -->
      <xsl:choose>
        <xsl:when test="@relationCode = '1' or @relationCode = '3'">
          <dct:creator rdf:resource="{$uri}"/>
        </xsl:when>
        <xsl:when test="@relationCode = '2' or @relationCode = '7'">
          <dct:contributor rdf:resource="{$uri}"/>
        </xsl:when>
        <xsl:when test="@relationCode = '4'">
          <dct:subject rdf:resource="{$uri}"/>
        </xsl:when>
        <xsl:when test="@relationCode = '5'">
          <dbpowl:curator rdf:resource="{$uri}"/>
        </xsl:when>
        <xsl:when test="@relationCode = '6' or @relationCode = '8'">
          <dbpowl:maintainedBy rdf:resource="{$uri}"/>
        </xsl:when>
      </xsl:choose>
    </rdf:Description>
    <!--
    <rdf:Property rdf:about="&rark;archiveRelation-{@relationCode}">
      <rdfs:label><xsl:value-of select="@relation"/></rdfs:label>
    </rdf:Property>
    -->
  </xsl:template>

  <xsl:template match="ra:place">
    <xsl:variable name="relation">
      <xsl:choose>
        <!-- 1: Verksamhetsort; 2: Sätesort; 5: Verksamhet -->
        <xsl:when test="@relationTypeId = '1' or
                  relationTypeId = '2' or
                  relationTypeId = '5'
                  ">foaf:based_near<!--schema:location--></xsl:when>
        <xsl:when test="@relationTypeId = '3'">dbpowl:birthPlace</xsl:when>
        <xsl:when test="@relationTypeId = '4'">dbpowl:deathPlace</xsl:when>
        <xsl:otherwise>dct:relation</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$relation}">
      <!-- TODO:
           - link to identified place;
           - generate place data in ra-terms-rdf.xslt;
           - put class def in controlled set -->
      <dbpowl:Place>
        <dct:identifier xml:lang=""><xsl:value-of select="@code"/></dct:identifier>
        <rdf:type>
          <rdfs:Class rdf:about="&rark;Place-{@typeId}">
            <rdfs:label><xsl:value-of select="@type"/></rdfs:label>
          </rdfs:Class>
        </rdf:type>
      </dbpowl:Place>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="top-level"/>

</xsl:stylesheet>
