#!/bin/bash

sudo ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime &&\
    echo Europe/Moscow > /etc/timezone &&\
    apt update && \
    apt install -y curl python3 python3-pip &&\
    pip3 install pytest

sudo curl -L https://tarantool.io/pOUCGKc/release/2.8/installer.sh | bash

sudo apt install -y tarantool

sudo tarantoolctl rocks install http &&\
    sudo tarantoolctl rocks install luatest &&\
    sudo tarantoolctl rocks install luacov &&\

