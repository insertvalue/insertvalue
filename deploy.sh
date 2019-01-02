#!/bin/bash
export HEXO_ALGOLIA_INDEXING_KEY=4f366251eaef4451880e103804172d4e
hexo clean
hexo algolia
hexo g
hexo d

