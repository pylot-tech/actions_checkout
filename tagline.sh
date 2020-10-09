#!/bin/bash
 
git tag -d v1 && git push --delete origin v1 && git tag -a v1 -m "default version" && git push origin v1
