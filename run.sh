#!/bin/bash
# ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime &&\
#     echo Europe/Moscow > /etc/timezone &&\
#     apt update && \
#     apt install -y curl python3 python3-pip &&\
#     pip3 install pytest

# curl -L https://tarantool.io/pOUCGKc/release/2.8/installer.sh | bash
# apt install -y tarantool
tarantoolctl rocks install http 
tarantoolctl rocks install luatest
tarantoolctl rocks install luacov

