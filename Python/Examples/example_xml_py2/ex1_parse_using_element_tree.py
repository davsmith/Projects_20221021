""" Example of parsing XML using ElementTree
From https://docs.python.org/3/library/xml.etree.elementtree.html

- The ElementTree module has been deprecated in Python 3
- Seems like common nomenclature is to import as ET

"""


import xml.etree.ElementTree as ET

tree = ET.parse(
    "D:\\Local\\OneDrive\\Settings\\GIMP\\2.10\\myXml\\commander\\combinedCommander.xml"
)
root = tree.getroot()
print(root.tag)
print(root.attrib)
print(type(root))

for wumba in root:
    print(wumba.tag, wumba.attrib)
