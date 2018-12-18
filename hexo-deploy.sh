#!/usr/bin/env sh
hexo clean
export HEXO_ALGOLIA_INDEXING_KEY=4f366251eaef4451880e103804172d4e
hexo algolia
hexo deploy

