#/bin/sh
# Update TheSDK entities to v1.1 syntax
# Run this in Entities directory of your project

#Logging
sed -i "s/\(self\.print_log(\)\([{]'type' *: *\)\('.*,\)\( *'msg' *: *\)\(.*\)\(})\)/\1type=\3 msg=\5)/g" `grep -lr self.print_log\(\{\* | grep py | grep -v pyc | grep -v swp`

#IOs
sed -i "s/\(\.Value\)/.Data/g" `grep -lr .Value | grep py | grep -v .pyc | grep -v swp`
sed -n "s/\(\refptr\)/IO/p" `grep -lr .Value | grep py | grep -v .pyc | grep -v swp`


