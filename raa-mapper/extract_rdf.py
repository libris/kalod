#!/usr/bin/env python
from lxml.etree import iterparse, tostring

RDF_URI = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
RDF = "{%s}" % RDF_URI
PMH = "{http://www.openarchives.org/OAI/2.0/}"

def find_records(source, ignore=()):
    context = iterparse(source, events=("start", "end"))
    root = context.next()[1]
    for event, elem in context:
        if event != 'end':
            continue
        if elem.tag in ignore:
            elem.clear()
        if elem.tag == PMH+"record":
            yield elem
        root.clear()

if __name__ == '__main__':
    import sys
    sourcepath = sys.argv[1]
    if sourcepath.endswith('.gz'):
        import gzip
        source = gzip.open(sourcepath, 'rb')
    else:
        source = open(sourcepath)
    ignore = ignore=["{http://kulturarvsdata.se/ksamsok#}presentation"]
    print '<RDF xmlns="%s">' % RDF_URI
    try:
        for record in find_records(source, ignore):
            data = record.find(PMH+"metadata")
            rdf = data.find(RDF+'RDF')
            if rdf is None:
                rdf = data
            print tostring(rdf[0])
        print '</RDF>'
    finally:
        source.close()

