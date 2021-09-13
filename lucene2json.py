#!/usr/bin/env python

import argparse
import json
import lucene


def main():
    parser = argparse.ArgumentParser(description='Dump a Lucene index to JSON')
    parser.add_argument('directory', help='A directory containing a lucene index')
    options = parser.parse_args()

    lucene.initVM()
    fs_dir = lucene.SimpleFSDirectory(lucene.File(options.directory))
    reader = lucene.IndexReader.open(fs_dir)

    docs = []
    for doc_id in range(reader.maxDoc()):
        lucene_doc = reader.document(doc_id)
        doc = {}
        for field in lucene_doc.getFields():
            if field.isStored():
                doc[field.name()] = field.stringValue()
        docs.append(doc)

    print(json.dumps(docs, sort_keys=True, indent=2))


if __name__ == '__main__':
    main()
