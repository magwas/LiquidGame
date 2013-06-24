<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
  xmlns:archimate="http://www.bolton.ac.uk/archimate"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>


  <xsl:variable name="objmap" select="document('objmap.xml')"/>


  <xsl:template match="*">
  <xsl:message select="concat('foo=',name(),$objmap//map[@to=name(current())]/@from)"/>
    <xsl:choose>
      <xsl:when test="$objmap//map[@to=name(current())]">
        <element xsi:type="{$objmap//map[@to=name(current())]/@from}">
          <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
