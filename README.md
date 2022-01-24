<img src=https://github.com/nikosias/tarantool_exmple/workflows/CI/badge.svg?branch-master>

# Key/Value api on tarantool

1) скачать/собрать тарантул
2) запустить на нем 'hello world'
3) реализовать kv-хранилище доступное по http
4) выложить на гитхаб
5) задеплоить где-нибудь в публичном облаке, чтобы мы смогли проверить работоспособность (или любым другим способом)

API:
- POST /kv body: {key: "test", "value": {SOME ARBITRARY JSON}}
- PUT kv/{id} body: {"value": {SOME ARBITRARY JSON}}
- GET kv/{id}
- DELETE kv/{id}

- POST возвращает 409 если ключ уже существует,
- POST, PUT возвращают 400 если боди некорректное
- PUT, GET, DELETE возвращает 404 если такого ключа нет
- все операции логируются
- в случае, если число запросов в секунду в http api превышает заданый интервал, возвращать 429 ошибку.

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
    port    = 2020,            -- порт веб сервера
    addr    = '*',             -- адрес интерфейса
    rps = 200,                 -- ограничение RPS
    maxDelay = 0.01,           -- максимальная задержка для /randomtime используется при тестировании
    maxWindowRequest = 40,     -- максимальное количество запросов в 0.1 мс при работе по алгоритму window
    algoritm = 'window',       -- алгоритм ограничения RPS 
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
