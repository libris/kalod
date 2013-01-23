#!/usr/bin/env python
from lxml.etree import iterparse, tostring

PMH = "{http://www.openarchives.org/OAI/2.0/}"

def find_records(source):
    context = iterparse(source, events=("start", "end"))
    root = context.next()[1]
    for event, elem in context:
        if event != 'end':
            continue
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
    print '<RDF xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#">'
    with source:
        for record in find_records(source):
            rdf = record.find(PMH+"metadata")[0]
            print tostring(rdf[0])
        print '</RDF>'

