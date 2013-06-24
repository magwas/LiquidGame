<?xml version="1.1" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
  xmlns:archimate="http://www.bolton.ac.uk/archimate"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:my="http://demokracia.rulez.org/LiquidGame"
  exclude-result-prefixes="archimate xsi my">
	<xsl:output method="xml" version="1.1" encoding="utf-8" indent="yes"/>

  <xsl:variable name="objmap">
    <objmap>
      <map from="archimate:BusinessCollaboration" to="group" foldered="yes" relation="no"/>
      <map from="archimate:BusinessActor" to="user" foldered="yes" relation="no"/>
      <map from="archimate:BusinessObject" to="resource" foldered="no" relation="no"/>
      <map from="archimate:Value" to="statement" foldered="no" relation="no"/>
    </objmap>
  </xsl:variable>

  <xsl:variable name="document" select="/"/>

  <xsl:function name="my:parents">
    <xsl:param name="this"/>
      <parents>
        <xsl:for-each select="$document//element[@xsi:type='archimate:AssociationRelationship' and @target=$this/@id]">
          <xsl:sort select="@name"/>
          <xsl:copy-of select="$document//element[@id=current()/@source]"/>
        </xsl:for-each>
      </parents>
  </xsl:function>

  <xsl:template name="createlinks">
    <xsl:param name="this"/>
    <xsl:message select="concat('links for ',$this/@name)"/>
    <xsl:variable name="parents" select="my:parents($this)"/>
    <xsl:message select="count($parents//element)"/>
    <xsl:if test="count($parents//element) >1">
      <xsl:for-each select="$parents//element[position()>1]">
        <xsl:message select="concat('link ',@name, my:path(.,concat(@name,'/',$this/@name,'.link')))"/>
        <xsl:result-document href="{my:path(.,concat(@name,'/',$this/@name,'.link'))}" omit-xml-declaration="yes">
          <link>
            <xsl:attribute name="ref" select="my:path($this)"/>
          </link>
        </xsl:result-document>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:function name="my:path">
    <xsl:param name="this"/>
    <xsl:variable name="paths">
      <xsl:element name="paths">
        <xsl:choose>
          <xsl:when test="$objmap//map[@from=$this/@xsi:type]/@foldered = 'yes'">
           <xsl:attribute name="path" select="concat($this/@name,'/',$this/@name)"/>
          </xsl:when>
          <xsl:otherwise>
           <xsl:attribute name="path" select="$this/@name"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:variable>
    <xsl:variable name="parents" select="my:parents($this)"/>
    <xsl:copy-of select="my:path($this,$paths//@path)"/>
  </xsl:function>

  <xsl:function name="my:path">
    <xsl:param name="this"/>
    <xsl:param name="pathend"/>
    <xsl:variable name="parents" select="my:parents($this)"/>
    <xsl:choose>
      <xsl:when test="$objmap//map[@from=($parents//element)[1]/@xsi:type]/@foldered = 'yes'">
        <xsl:value-of select="my:path(($parents//element)[1],concat(($parents//element)[1]/@name,'/',$pathend))"/>
      </xsl:when>
      <xsl:when test="$parents//element">
        <xsl:value-of select="my:path($parents//element,$pathend)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$this/@xsi:type='archimate:BusinessCollaboration' and $this/@name='world'">
            <xsl:value-of select="concat('./',$pathend)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="folder">
    <xsl:param name="parent"/>
    <xsl:param name="this"/>
    <xsl:variable name="paths">
      <xsl:element name="paths">
        <xsl:choose>
          <xsl:when test="$objmap//map[@from=$this/@xsi:type]/@foldered = 'yes'">
           <xsl:attribute name="path" select="concat($parent,'/',$this/@name)"/>
           <xsl:attribute name="objpath" select="concat($parent,'/',$this/@name,'/',$this/@name)"/>
          </xsl:when>
          <xsl:otherwise>
           <xsl:attribute name="path" select="concat($parent,'/',$this/@name)"/>
           <xsl:attribute name="objpath" select="concat($parent,'/',$this/@name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:variable>
    <xsl:variable name="thepath" select="my:path($this)"/>
    <xsl:if test="$thepath">
      <xsl:result-document href="{$thepath}" omit-xml-declaration="yes">
        <xsl:variable name="etype">
          <xsl:choose>
            <xsl:when test="$objmap//map[@from=$this/@xsi:type]/@to">
              <xsl:value-of select="$objmap//map[@from=$this/@xsi:type]/@to"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$this/@xsi:type"/>
            </xsl:otherwise>
          </xsl:choose>
       </xsl:variable>
        <xsl:element name="{$etype}">
          <xsl:copy-of select="//child[@archimateElement= $this/@id]/bounds" copy-namespaces="no"/>
          <xsl:copy-of select="property|documentation" copy-namespaces="no"/>
        </xsl:element>
      </xsl:result-document>
    </xsl:if>
    <xsl:call-template name="createlinks">
      <xsl:with-param name="this" select="$this"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="/">
    <xsl:for-each select="//element">
      <xsl:call-template name="folder">
          <xsl:with-param name="parent" select="string('.')"/>
          <xsl:with-param name="this" select="."/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="//element[@xsi:type='archimate:CompositionRelationship']">
      <xsl:message select="'composition'"/>
      <xsl:message select="concat('from:',//element[@id=current()/@source]/@name)"/>
      <xsl:message select="concat('frompath:',my:path(//element[@id=current()/@source]))"/>
      <xsl:message select="concat('to:',//element[@id=current()/@target]/@name)"/>
      <xsl:message select="concat('topath:',my:path(//element[@id=current()/@target]))"/>
      <xsl:result-document href="{concat('resourcehierarchy/',//element[@id=current()/@source]/@name, ' contains ', //element[@id=current()/@target]/@name)}" omit-xml-declaration="yes">
        <contains>
          <xsl:attribute name="container" select="my:path(//element[@id=current()/@source])"/>
          <xsl:attribute name="contained" select="my:path(//element[@id=current()/@target])"/>
        </contains>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

