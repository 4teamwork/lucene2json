# lucene2json

Dump a Lucene index into JSON

Uses PyLucene to read the Lucene index, which provides an API wrapper for JAVA
Lucene.

We currently require to read a rather ancient Lucene index of version 3.x.
Therefore the whole stack is built with pretty old, already end-of-life versions:

- Debian Linux 8 (Jessie)
- OpenJDK 7
- Lucene 3.6.2
- Python 2.7

## Building

To build the Docker image, simply run:

```
docker-compose build
```

## Usage

Copy the Lucene index into the data directory.

Then run lucene2json.py with docker-compose:

```
docker-compose run --rm pylucene lucene2json.py /data/LuceneIndex >dump.json
```
