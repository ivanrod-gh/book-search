# BookSearch

Приложение по поиску книг с расширенным фильтром поискового запроса

В данный момент оперирует открытой информацией с litres.ru

# Описание приложения

Приложение парсит (анализирует и забирает) книжную информацию из "партнерских" БД (находятся в открытом доступе, делятся на "простые" и "детализированные") и с отдельных интернет страниц

Т.к. одни и те же вещи (например, жанр) могут называться во всех источниках по-разному, то, для получения полноценной информации об одной книге, нужно предварительно извлечь книжную информацию из обеих "партнерских" БД (сначала из "простой", потом из "детализированной") и, используя ссылку на книгу, совершить парсинг удаленной страницы и докачать недостающую информацию

Ввиду того, то сайт litres агрессивно себя защищает от роботов при помощи ddos-guard, приложение недостающую информацию по оценкам, количеству страниц и комментариев просто генерирует

По этой причине приложение штатно разворачивается с ограниченным количеством книг

Приложение не хранит у себя сами книги (fb2, txt и т.п.) или их описания

# Устройство приложения

Для парсинга данных (локального и удаленного) написан сервис Worker

При разворачивании приложения он отвечает за начальную загрузку данных в БД из скачиваемых "партнерских" БД, а, при ег использовании в качестве удаленного парсера, обрабатывает не более 1 задачи (интернет страницы) одновременно не чаще 1 раза в секунду

Незарегистрированному пользователю доступна функция поиска книг

Книги можно искать или по фильтру(ам) (жанр, год издания, дата добавления на сайт и т.д.), в этом случае результаты поиска будут выведены постранично с паджинацией и разбивкой по дням добавления на сайт, или можно искать конкретную книгу или автора, в этом случае будет осуществлен полнотекстовый поиск (Sphinx) и выведено ограниченное количество результатов на одну страницу

Регистрация (аутентификация - Devise) осуществляется или через указание электронной почты, на которую потом придет письмо с подтверждением, или при помощи аккаунта GitHub, у которого будет запрошен актуальный адрес электронной почты

Зарегистрированный пользователь (авторизация - Cancancan) может:
- сохранить информацию о книге на свою книжную полку
- сбросить сохраненные книги и их авторов на почту (списком)
- воспользоваться параметрами сделанного ранее поиска, чтобы совершить новый поиск
- совершать операции со своим аккаунтом (изменение, удаление)

Письма рассылаются через почту Gmail (SMTP)

Данные, касающиеся книг и авторов, пробрасываются на фронт как JSON и далее обрабатываются при помощи JS/Jquery и шаблонов Handlebars

Модели, контроллеры, сервисы и пользовательский интерфейс покрыты тестами (RSpec)

В качестве CSS-фреймворка подключен Bootstrap

# Технические данные

Написано на Ruby 3.0.5, Rails 6.1.7.4

# Разворачивание приложения

Для начального разворачивания приложения написан LimitedWorkerJob, который формирует задачи (WorkerTask) для сервиса Worker и запускает его на выполнение

В окружении development:
- bundle exec bin/rails runner -e development LimitedWorkerJob.perform_now
В окружении production:
- bundle exec bin/rails runner -e production LimitedWorkerJob.perform_now

После вызова сервис Worker скачает, пропарсит и удалит "партнерские" БД (размер одной скачанной и распакованной "партнерской" БД может быть более 3.5 ГБ), недостающие данные будут сгенерированы

Для полноценной работы приложения также должна быть настроена БД, в credentials указаны необходимые данные для Gmail, GitHub и запущены Sphinx, Redis, Sidekiq

# Планы

В приложение планируется добавить:
- API, покрывающий поиск с фильтрами и полнотекстовой поиск
- мониторинг через Monit
- кеширование части данных
- тип пользователя "админ" и добавить функции администратора: разворачивание приложение, мониторинг состояния БД (количество записей в таблицах, общее количество книг и количество книг, на которые имеются полноценные данные и т.д.)
- возможности по работе со старыми поисками - запрос на сохранение, редактирование параметров старых поисков, ввести обозначения/имена
