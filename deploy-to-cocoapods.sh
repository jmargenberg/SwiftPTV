!/usr/bin/env bash

# Decrypt and setup deploy key to allow Travis to push to GitHub
openssl aes-256-cbc -k "$travis_key_password" -md sha256 -d -a -in travis_key.enc -out ./travis_key
chmod 400 ./travis_key  
git remote set-url origin git@github.com:jmargenberg/SwiftPTV.git

# Run cocoapods deployment with Fastlane
bundle exec fastlane release
