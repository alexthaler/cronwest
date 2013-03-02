#!/bin/bash

if command -v foreman > /dev/null; then
  echo "yay foreman!"
  foreman start
else 
  echo "you should really install foreman, included in the heroku toolkit"
  rackup -p 5000 config.ru 
fi
