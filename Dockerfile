FROM debian:jessie-slim as builder

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y \
       default-jdk \
       ant \
       python-dev \
       python-setuptools \
       gcc \
       g++ \
       make \
       wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://archive.apache.org/dist/lucene/pylucene/pylucene-3.6.2-1-src.tar.gz \
    && tar xzvf pylucene-3.6.2-1-src.tar.gz \
    && cd /pylucene-3.6.2-1/jcc \
    && JCC_JDK=/usr/lib/jvm/default-java python setup.py install \
    # Fetch required jars manually because Java 7 doesn't support the required SSL version
    && mkdir -p /root/.ant/lib \
    && wget -P /root/.ant/lib/ https://repo1.maven.org/maven2/org/apache/ivy/ivy/2.2.0/ivy-2.2.0.jar \
    && mkdir -p /root/.ivy2/local/jakarta-regexp/jakarta-regexp/1.4/jars \
    && wget -P /root/.ivy2/local/jakarta-regexp/jakarta-regexp/1.4/jars/ https://repo1.maven.org/maven2/jakarta-regexp/jakarta-regexp/1.4/jakarta-regexp-1.4.jar \
    && mv /root/.ivy2/local/jakarta-regexp/jakarta-regexp/1.4/jars/jakarta-regexp-1.4.jar /root/.ivy2/local/jakarta-regexp/jakarta-regexp/1.4/jars/jakarta-regexp.jar \
    && cd /pylucene-3.6.2-1 \
    && make all install JCC='python -m jcc --shared' ANT=ant PYTHON=python NUM_FILES=8


FROM debian:jessie-slim

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends \
       python \
       libpython2.7 \
       default-jre-headless \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python2.7/dist-packages /usr/local/lib/python2.7/dist-packages
COPY lucene2json.py /usr/local/bin/

CMD ["/bin/bash"]