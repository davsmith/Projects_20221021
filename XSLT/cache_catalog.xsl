<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
  <h2>Caches I've found</h2>
  <table border="1">
    <tr bgcolor="#9acd32">
      <th>Cache Name</th>
    </tr>
    <xsl:for-each select="gpx/wpt">
    <tr>
      <td><xsl:value-of select="name"/></td>
    </tr>
    </xsl:for-each>
  </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>