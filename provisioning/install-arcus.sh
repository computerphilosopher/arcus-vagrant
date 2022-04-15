#!/bin/bash

ARCUS_USER=vagrant
ARCUS_REPOSITORY="https://github.com/naver/arcus"
ARCUS_DIR="/home/vagrant/arcus"
MEMC_DIR="$ARCUS_DIR/server"
ZOOKEEPER_DIR="$ARCUS_DIR/zookeeper"

# reset environment for idempotent
rm -rf $ARCUS_DIR

cd /home/vagrant
git clone $ARCUS_REPOSITORY; \
    cd $ARCUS_DIR; \
    git submodule update --init; \

#build dependency(zk c client, libevent)
cd $ZOOKEEPER_DIR; \
ant compile_jute; \
cd $ZOOKEEPER_DIR/zookeeper-client/zookeeper-client-c; \
autoreconf -if && ./configure --prefix=$ARCUS_DIR && make && make install; \
cd $ARCUS_DIR/deps/libevent; \
autoreconf -if && ./configure --prefix=$ARCUS_DIR && make && make install; \

#build arcus-memcached
cd $ARCUS_DIR/server; \
./config/autorun.sh && ./configure --with-libevent=$ARCUS_DIR --enable-zk-integration --with-zookeeper=$ARCUS_DIR && make; \
chown -R "$ARCUS_USER:$ARCUS_USER" "$ARCUS_DIR"

cd $ARCUS_DIR/zookeeper
mvn clean install -DskipTests=true 
