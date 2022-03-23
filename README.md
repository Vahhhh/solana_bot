# Solana-bot kerak_edition
Скрипт-бот для контроля ноды(нод) солана.

## Навигация
* [Описание](#Что-делает-бот)
* [Установка](#Тербования-к-установке-и-установка)
* [Как обновить ](#Обновление)

## Что делает бот

1. Бот разделен на два скрипта. 1й файл  kerak_edition.sh в котором находится основной код и 2й settings.sh  в нем все данные о бот-токен, пабкей, вотте, ип ноды, утсавке баланса и текст для вывода сообщений и.т.д. 

2. Скрипт kerak_edition.sh каждые 5минут (я рекомендую столько ставить в crontab)  проверяет наличие баланса больше 1 sol (это значение меняется в settings.sh ), пинг к серверу, где находится нода, делинк она или нет, и выводит в чат №1 сообщене(в этом чате включить оповещение), если все ок, то один раз в час выводит в чат №2 Info о ноде. (Скрипт при работае создает файлы, Не пугатся! $HOME/solana_bot/temp.txt и $HOME/solana_bot/mesto_top.txt, названия их меняются в зависимости от cluster)

3. Нюансы.
Возле пабкея выводится версия соланы.
Если скип меньше или  равен среднему по кластеру плюс уставка указанная в skip_dop (установил 15, можно менять), то возле skip будет зеленый кружок и процент скипа, если скип превысит этот параметр то  кружок станет карссным;
Когда текущей эпохе есть активация стэйка, то зеленый кружок  справа от суммы активации,
если есть деактивация стэйка то восклицательный знак. 
При выборе в кластере m (майнет) в info не выводится строка onboard,
если нода в тестнет и уже произошел апрув, то строка onboard не выводится.

4. **ВАЖНО!** 
в бота в настройках settings.sh можно добавить 1, 2,3 и более нод, но в одном скрипте должны быть или ноды тестнета или майнета!!! Инфо о эпохе выводитсчя отдельным сообщением и один раз!  Коментарии по заполнению в скрипте под символом #.

**В планах седлать так, чтобы можно было  одновременно контролировать и майнет и тестнет ноды** 

![alt text](https://github.com/kerak69/solana_bot/blob/master/bot.png?raw=true)

В v3.2.1 добавил расчет комиссии и поменял местами % по кредитам и onboard
`comission>[earn 0.001 sol]` означает что награды за сделанные блоки превысили траты на голосование (таколе бывает  в начале эпохи ;-))

## Тербования к установке и установка

**Нужна установленная солана!!! скрипт без нее не работает!!!**
Нужен отдельный сервер (самый дешёвый vps) (или там где у вас нода стоит), на котором будет по расписанию запускаться скрипт, который проверяет статус вашей ноды и инфо о ней.

1. Создаем своего бота в телеграм с помощью @BotFather
2. Создаем два чата. №1 для тревожных оповещений, когда нода уходит в делинк и.т.д, №2 "Инфо о ноде" в тестнет или майнет (я создаю еще  один скрипт и настройки для майнт ноды и отдельный чат для инфо о ней)  Во втором ( и третьем чате если сделали как я)  оповещения.
3. Добавляем своего бота во все чаты.
4. С помощью бота @username_to_id_bot  узнаем чат ID наших трех чатов. Пришлите ему ссылку на ваш чат и бот вернет вам чат ID. Не потеряйте дефис. 
5. Правим скрипт settings.sh  (Все параметрі начиная с Cluster)

**Установка**
!!! Команду вводим в папке root (если вход под рутом) (/root ) или в домашней дериктории если вход под пользователем ($HOME) !!!

```bash
sudo apt update \
&& sudo apt install bc jq -y \
&& git clone https://github.com/kerak69/solana_bot.git
```

7. добавляем в крон запуск скрипта  и чистку логов (если нужно)
```bash
crontab -e
```
в  crontab в самый низ добавить
```bash
*/5 * * * * $HOME/solana_bot/kerak_edition.sh >> $HOME/solana_bot/dog.log 2>&1
59 23 * * * rm $HOME/solana_bot/dog.log
```
эти строки означают
(запускать каждые 5 мин, лог сохранять в dog.log, удалять раз в сутки dog.log )

P.S. В телеграмме в настройки > настройки чатов > размер текста сообщений  поставить 14!!! (больше 15 не ставить, некоторый текст может не влезть в строку. )

## Обновление
```bash
cd $HOME/solana_bot && git pull
```


