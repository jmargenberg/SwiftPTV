!/usr/bin/env bash

# Decrypt and setup deploy key to allow Travis to push to GitHub
openssl aes-256-cbc -k "$travis_key_password" -md sha256 -d -a -in travis_key.enc -out ./travis_key
echo "Host github.com" > ~/.ssh/config
echo "  IdentityFile  $(pwd)/travis_key" >> ~/.ssh/config
chmod 400 ./travis_key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLG0vWhKrOFowvjCRTU18hhPetkMCn+r4/ZrMHbCu5B5NytPGcuao+8XtlzM9R+BelzjEc79oLkeFdzumFzEaYvJsX8AlMVStS3FjLb7XMBTosAk/vFgak2dZq+VC2U2J1yxJ+CWT/A7+aUH6YRXMRQQnzlNnLGz7Ura8RW/fVy3qLY6DLrc2YWnf2nklZwhUiisf0iE9Kr4gci62z+k/sErhmlZiKyDmB9dKL+LPfhkBuP/Jf+cuq/1zZMa+Ffi/9iWtz81ollLPYoWRwb7KeOTk8sqX6iur0vaTO7B+fCdnykUQMzsv45bNH4C7TiVbLWxfuqXLJNyI9DGyJ6viBm6Q9f9vh1HtGvxExzRqFO31scUL9tp7kOvlq2GOSnp9Xxa3+c1yhBeVKbJipP9d9NlHUiZLOZO4zr/PsoZ5Jf7/BicvJzVCamBgjk7MrLfbiu440WnoJOdnq3990Zq+MwcjWRsP3YISZPx7jq+A0isjCdH8h3zeDKZ++uEq4BT6vPFq0EyZeuxwr0iYkM82TTb+C+YK2TH4YwpbiOJ8QOT6XwuN7TNw5zi6nBq0IaIuTT5gc1hEDyg/gl5072vdxOI5VatEoVro5MJHiA6vIfJI+iH2w/r8wuQYEyiUool8XNSYmpgkghBlrklHWZrjDXIBXD2a4gzK5oIUa+cowaw==" > ~/.ssh/known_hosts
git remote set-url origin git@github.com:jmargenberg/SwiftPTV.git
if ! git push -v ; then
  _err "git push error"
fi

# Run cocoapods deployment with Fastlane
bundle exec fastlane release
