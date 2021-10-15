#!/usr/bin/env python

import argparse
import json
import lucene
import sys

class StreamArray(list):
    """
    Converts a generator into a list object that can be json serialisable
    while still retaining the iterative nature of a generator.

    IE. It converts it to a list without having to exhaust the generator
    and keep it's contents in memory.
    """
    def __init__(self, generator):
        self.generator = generator
        self._len = 1

    def __iter__(self):
        self._len = 0
        for item in self.generator:
            yield item
            self._len += 1

    def __len__(self):
        """
        Json parser looks for this method to confirm whether or not it can
        be parsed
        """
        return self._len

def main():
    parser = argparse.ArgumentParser(description='Dump a Lucene index to JSON')
    parser.add_argument('directory', help='A directory containing a lucene index')
    options = parser.parse_args()

    lucene.initVM()
    fs_dir = lucene.SimpleFSDirectory(lucene.File(options.directory))
    reader = lucene.IndexReader.open(fs_dir)

    stream_array = StreamArray(lucene_docs(reader))
    for chunk in json.JSONEncoder().iterencode(stream_array):
        sys.stdout.write(chunk)

def lucene_docs(reader):
    for doc_id in range(reader.maxDoc()):
        lucene_doc = reader.document(doc_id)
        doc = {}
        for field in lucene_doc.getFields():
            if field.isStored():
                doc[field.name()] = field.stringValue()
        yield doc    

if __name__ == '__main__':
    main()
