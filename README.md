<img src=https://github.com/nikosias/tarantool_exmple/workflows/CI/badge.svg?branch-master>

# Key/Value api on tarantool

реализовать kv-хранилище доступное по http

# Данный пример написан не на максимальную производительность а скорее показать знания в lua

## Установка

    ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime &&\
        echo Europe/Moscow > /etc/timezone &&\
        apt update && \
        apt install -y curl python3 python3-pip &&\
        pip3 install pytest

    curl -L https://tarantool.io/pOUCGKc/release/2.8/installer.sh | bash
    apt install -y tarantool
    tarantoolctl rocks install http 
    tarantoolctl rocks install luatest
    tarantoolctl rocks install luacov

## Настройка
в файле src/config.lua

    logFile = 'tarantool.log', -- файл логов если nil то на стандартный вывод 
    port    = 80,              -- порт веб сервера
    addr    = '*',             -- адрес интерфейса
    rps = 20,                  -- ограничение RPS
    maxDelay = 0.01,           -- максимальная задержка для /randomtime используется при тестировании
    maxWindowRequest = 7,      -- максимальное количество запросов в 0.1 мс при работе по алгоритму window
    algoritm = 'simple',       -- алгоритм ограничения RPS 
                                --  simple
                                -- если у с начала текущей секунды отправлено сообщений меньше чем  config.rateLimiting.rps
                                -- то разрешаем обработку сообщения 
                                --  window
                                -- берем интервалы в 100 мс и не позваляем в этомпериоде превышать config.rateLimiting.maxWindowRequest 
                                -- и сумарно config.rateLimiting.rps за 10 интервалов(секунду).
    
    
## Запуск
    cd ./src
    tarantool ./init.lua

после запуска можно вживую посмотреть как это работает через http://ADDRESS:PORT

## Тестирование
### Unit & Coverage
    ./.rocks/bin/luatest --coverage ./unitTest/test_*
    ./.rocks/bin/luacov 

В результат  файле luacov.report.out - покрытие тестами запросов

### Интеграционное
    pytest --url=http://ADDRESS:PORT ./integrationTest/test_first.py 

### Нагрузочное
    python3 ./loadTest/test.py --url=http://ADDRESS:PORT  --treadcount=5
