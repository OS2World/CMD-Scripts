<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="windows-1251" indent="yes"/>

<xsl:template match="/">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
  <style type="text/css">
    table	{ background-color: #C0D5E0; }
    td {
      color: #202020;
      font: normal 8pt sans-serif;
      padding-right: 0.5em;
      background-color: #E7F5FD;
    }
    th		{ font: bold 7pt sans-serif; background-color: #E7F5FD;
		  padding-left: 0.5em; padding-right: 0.5em; }
    td.lc1	{ background-color: #FCCCA2; }
    td.lc2	{ background-color: #FFE3E7; }
    td.lc3	{ background-color: #FFE7EF; }
    td.lc4	{ background-color: #FFEBEF; }
    td.lc5	{ background-color: #FFEFEF; }
    td.lc6	{ background-color: #FFEFF7; }
    td.lc7	{ background-color: #FFF3F7; }
    td.lc8	{ background-color: #FFF7F7; }
    td.lc9	{ background-color: #FFFBFF; }
    td.lc10	{ background-color: #FFFFFF; }
    h1		{ font: bold 8pt sans-serif; text-align: center; }
  </style>
</head>
<body>
  <h1>LameStream playlist history</h1>
  <table align="center" cellspacing="1" cellpadding="2">
  <tr>
    <th>N</th>
    <th>Time</th>
    <th>File</th>
    <th>Artist</th>
    <th>Album / Title</th>
    <th>Year</th>
  </tr>

  <xsl:for-each select="lameStream/item">
    <tr>
    <td>
    <xsl:attribute name="class">lc<xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:value-of select="./@id"/>.
    </td>
    <td align="right">
    <xsl:attribute name="class">lc<xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:value-of select="./@time"/>
    </td>
    <td>
    <xsl:attribute name="class">lc<xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:value-of select="file"/>
    </td>
    <td>
    <xsl:attribute name="class">lc<xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:value-of select="artist"/>
    </td>
    <td>
    <xsl:attribute name="class">lc<xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:value-of select="album"/>
      / 
      <xsl:value-of select="title"/>
    </td>
    <td align="center">
    <xsl:attribute name="class">lc<xsl:value-of select="./@id"/></xsl:attribute>
      <xsl:value-of select="year"/>
    </td>
    </tr>
  </xsl:for-each>

  </table>
</body>
</xsl:template>

</xsl:stylesheet>
