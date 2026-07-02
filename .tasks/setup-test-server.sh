#!/bin/sh

TESTDIR="Tests"

# If we don't have cloned Satori, need to clone it 
if [ ! -d "$TESTDIR/satori" ]; then
  git clone git@github.com:heroiclabs/satori.git "$TESTDIR/satori"
fi

# If we don't have cloned dashboards, need to clone it 
if [ ! -d "$TESTDIR/dashboards" ]; then
  git clone git@github.com:heroiclabs/dashboards.git "$TESTDIR/dashboards"
fi

docker compose -f "$TESTDIR/server/docker-compose.yml" down -v # Cleanup in case we have a leftover instance
docker compose -f "$TESTDIR/server/docker-compose.yml" up -d --build --wait

