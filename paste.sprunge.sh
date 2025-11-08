#!/usr/bin/env bash
curl -F 'sprunge=<-' http://sprunge.us >> ~/.sprunges.history 2>>~/.sprunges.errata
echo ff "`tail -n1 ~/.sprunges.history`"
