# HRT RPG (`hrt-rpg`)

Мод для **Factorio 2.0 / Space Age**: ролевая прокачка поверх обычной фабрики.  
Игрок выбирает класс, идёт по личному roadmap, берёт подкласс, участвует в мировых ивентах и крафтит классовое снаряжение mid-game.

Версия: **0.2.7**

## Статус (честно для игроков)

**Уже есть:** классы, roadmap Early/Mid/Late, Mid+Late подклассы, ночные рейды / улей / прочие ивенты, локальный account level, классовый гир, soft-respawn (рандом в чанке спавна + неуязвимость).

**Ещё в работе:** персистентный аккаунт между вайпами сейвов, free-батлпасс, автосезоны/ротация планет, полный paragon-цикл конца сезона, полировка баланса.

## Баланс

Числовые ручки (ивенты, XP, киты, бонусы классов/подклассов, оружие/хил, respawn) — в [`scripts/balance.lua`](scripts/balance.lua).  
Квесты (targets/xp/rewards) — в [`scripts/roadmap_trees.lua`](scripts/roadmap_trees.lua).

`Balance.respawn`: `randomize` (телепорт в чанк спавна) и `invuln_seconds` (неуязвимость после смерти).

## Целевая модель сервера (сезоны)

Сервер задуман как **сессионный / сезонный**:

- каждый сезон — отдельный забег на карте (вайп сейва в конце);
- **старт каждого сезона — на другой планете** (ротация Nauvis / Vulcanus / Gleba / Fulgora / Aquilo и т.д.);
- **награды и разблокировки переносятся на аккаунт** между сезонами;
- **батлпасс** и задания сезона — общий трек поверх личного roadmap;
- **широкие roadmap’ы** классов: **Early / Mid / Late** (~9 квестов на фазу);
- билд: **1 класс + 1 общий подкласс (Mid) + 1 специализированный (Late)**.

### Столпы сезона (MineralZ-вайб)

1. **Ночные рейды** — после заката (игровое `darkness`) усиленная волна кусак; раз за ночь + шанс в ротации ивентов.
2. **Paragon / наследие** — перк с прошлого сезона на аккаунте (`survivor` / `scout` / `artisan`); переживает вайп карты.
3. **Сезонный босс-улей** — усиленное гнездо; полная награда только если рядом ≥3 разных классов (не соло-мегабаза).
4. **Разблокировки по уровню аккаунта** — стартовые классы свободны; Explorer с Lv.3; Astronaut Lv.2; личные Explorer-подклассы Lv.3.

В **0.2.0**: полные 3-фазные roadmap’ы, dual-подклассы, ночные рейды, босс-улей, локальный аккаунт.  
Внешний аккаунт между физическими сейвами и полный батлпасс — следующие этапы.

> **Миграция с 0.1.x:** старый короткий roadmap сбрасывается (`roadmap_v2`). Нужен `/hrt-reset-class` или новый персонаж.

## Зачем он

Ванильный SA + (опционально) Bob's Classes и RPG System не дают ровно нашу схему:

1. четыре специализации со стартовым китом и бонусами;
2. персональные миниквесты с наградами;
3. подкласс после roadmap;
4. внезапные ивенты (кусаки / временная жила);
5. отдельная классовая броня/оружие.

`hrt-rpg` — это «клей» и собственный контент поверх soft-зависимостей.

## Зависимости

| Мод | Обязателен? | Роль |
|---|---|---|
| base / Space Age | желательно SA | игра |
| bobclasses (+ boblibrary) | нет (`?`) | альтернативные тела на старте; Support всё равно из нашего мода |
| RPGsystem | нет (`?`) | XP/скиллы; награды roadmap зовут его API |
| flib | нет (`?`) | запас под GUI |

Без RPGsystem XP всё равно начисляется локально (сообщение в чат).  
Без bobclasses классы выбираются только через GUI `hrt-rpg`.

## Как играть

### 1. Выбор класса

При первом входе открывается окно специализации. Выбор **один раз** (сброс — `/hrt-reset-class` у админа).

| Класс | Фокус | Бонусы (сейчас) | Стартовый кит (кратко) |
|---|---|---|---|
| **Боец** | бой у базы | +100 HP, +10% скорости | ПП бойца, патроны, лёгкая броня, турели, стены |
| **Шахтёр** | добыча | +35% mining, +20 слотов | буры, уголь, ленты, инсертеры, печи, железо |
| **Инженер** | стройка/автоматизация | +40% craft, +30 слотов, **+8 build / +6 reach** | сборочные, инсертеры, ленты, схемы |
| **Поддержка** | дроны/лечение | +50 HP, +15% скорости, +5 robots | капсулы, ремкомплекты, аптечки, робопорт |
| **Исследователь** | разведка/наука | +25% бег, +pickup/loot reach | колбы, лабы, радары, лампа, машина |

**Аптечка (`hrt-medkit`)** — хил себя и союзников в небольшом радиусе (скриптовый, в ванили такого нет).

### 2. Roadmap (Early / Mid / Late)

Кнопка **Roadmap** или `/hrt-roadmap`. У каждого класса **~27 квестов** в трёх фазах:

| Фаза | Фокус | Разблокировка |
|---|---|---|
| **Early** | онбординг роли | общий подкласс (Logistics / Demolitionist / Astronaut / Medic) |
| **Mid** | mid-game роль | специализированный подкласс класса |
| **Late** | сила роли / prep к улью и ракете | финал roadmap + account XP |

Типы заданий: kill / build (+ роботы) / craft / mine / research / distance / chart / deliver (сундуки рядом).

### 3. Подклассы

Два слота, оба заполняются по мере roadmap:

| Слот | Когда | Примеры |
|---|---|---|
| **Общий (Mid)** | конец Early | Логистика, Подрывник, Космонавт, Медик |
| **Спец. (Late)** | конец Mid | Боец→Авангард, Шахтёр→Геолог, Инженер→Архитектор, Поддержка→Наблюдатель, Исследователь→Картограф / Полевой учёный |

### 4. Мировые ивенты

Периодически (~20+ минут, пока есть онлайн-игроки):

- **волна кусак** рядом с игроками, или  
- **временная богатая жила** + сундук с мелочью.

Админ: `/hrt-force-event`.

### 5. Mid-game снаряжение

Технология **«Классовое снаряжение»** (`hrt-class-gear`, после modular-armor):

- броня: `hrt-armor-fighter` / `miner` / `engineer` / `support`
- оружие: `hrt-fighter-smg`, `hrt-class-cannon`
- аптечка крафтится с начала: repair-pack + fish

## Команды

| Команда | Кто | Что делает |
|---|---|---|
| `/hrt-roadmap` | все | окно roadmap |
| `/hrt-status [игрок]` | admin / RCON | статус класса/roadmap/character |
| `/hrt-set-class [игрок] <class> [kit]` | admin / RCON | назначить класс |
| `/hrt-set-subclass [игрок] <id> [tier]` | admin / RCON | назначить подкласс |
| `/hrt-set-roadmap [игрок] <index>` | admin / RCON | прыжок по roadmap |
| `/hrt-complete-quest [игрок]` | admin / RCON | завершить текущий квест |
| `/hrt-reapply [игрок]` | admin / RCON | переложить бонусы |
| `/hrt-account` | все | уровень аккаунта / XP |
| `/hrt-paragon` | все | список наследий |
| `/hrt-reset-class [игрок]` | admin / RCON | сброс класса/прогресса |
| `/hrt-force-event [night\|hive]` | admin / RCON | форс ивента |
| `/hrt-account set <игрок> <lvl>` | admin | выставить уровень аккаунта |
| `/hrt-paragon give <игрок> <id>` | admin | выдать наследие (`survivor`/`scout`/`artisan`) |

С хоста разработки: `factorio/scripts/hrt-rcon.sh 'hrt-status'` · `PLAYER=Name ./scripts/hrt-rcon-smoke.sh` (игрок online).

## Совместимость с другими модами пака

- **bobclasses** — можно выбрать тело Bob’а; специализация `hrt-rpg` всё равно своя. Смена «лишних тел» Bob’а не меняет зафиксированный класс HRT.
- **RPGsystem** — XP с квестов уходит в `remote.call("RPG", …)` при наличии мода.
- Не ставить параллельно тяжёлые RPG-overhaul (CEVO, второй XP-скиллтри вроде Ascendustry) без отдельного баланса.

## Структура исходников

```
hrt-rpg/
  info.json
  control.lua
  data.lua
  prototypes/
  scripts/
    account.lua
    classes.lua
    roadmap.lua        # движок квестов
    roadmap_trees.lua  # деревья Early/Mid/Late
    subclass.lua
    events.lua
    gui.lua
    player_state.lua
    rpg_bridge.lua
  locale/ru|en/
```

Состояние игрока в `storage.players[index]`: `class`, `subclass_common`, `subclass_spec`, `roadmap_index`, `quest_progress`, …  
Аккаунт в `storage.accounts[name]`: `level`, `xp`, `paragons`, `seasons_finished`.

Remote:

```lua
remote.call("hrt-rpg", "get_class", player_index)
remote.call("hrt-rpg", "give_xp", player_name, amount)
remote.call("hrt-rpg", "account_level", player_name)
remote.call("hrt-rpg", "grant_paragon", player_name, "survivor")
remote.call("hrt-rpg", "season_complete", player_name, "scout")
```

## Разработка

Исходники в воркспейсе: `factorio/mods/hrt-rpg/`.  
Сервер на ноуте: см. [`../../README.md`](../../README.md).

После правок — скопировать мод в `data/mods/hrt-rpg` на хосте и `docker compose restart factorio`.

## Исходники на GitHub

Публичный репозиторий (корень = содержимое мода): **https://github.com/Hertuno/hrt-rpg**

Сайт: [hrt-rpg.ru](https://hrt-rpg.ru) · портал: [mods.factorio.com/mod/hrt-rpg](https://mods.factorio.com/mod/hrt-rpg)

### Релизы через GitHub Actions

1. Секрет **`FACTORIO_MOD_API_KEY`** (Upload Mods).
2. Поднимите `version` в `info.json`, закоммитьте, запушьте тег `vX.Y.Z` (= версии).

Workflow соберёт zip → портал → GitHub Release.

#### Деплой на игровой сервер (.55)

GitHub-hosted runner **не видит** LAN `192.168.0.55`. Варианты:

**A) Self-hosted runner на `.55` (рекомендуется)**

1. На https://github.com/Hertuno/hrt-rpg/settings/actions/runners → **New self-hosted runner** (Linux x64).
2. На сервере от пользователя `y` (с доступом к docker):

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
# curl/tar по инструкции со страницы New runner
./config.sh --url https://github.com/Hertuno/hrt-rpg --token <TOKEN_С_СТРАНИЦЫ> \
  --name factorio-55 --labels hrt-factorio --work _work
sudo ./svc.sh install
sudo ./svc.sh start
```

3. Settings → Secrets and variables → Actions → **Variables** (не Secrets):
   - `ENABLE_SERVER_DEPLOY` = `true`
   - опционально `FACTORIO_STACK_DIR` = `/home/y/factorio`

После тега job **deploy-local** скопирует мод и сделает `docker compose restart factorio`.

**B) SSH с облака** — только если SSH доступен с интернета:

- Secrets: `FACTORIO_SSH_HOST`, `FACTORIO_SSH_USER`, `FACTORIO_SSH_KEY` (private key), опционально `FACTORIO_SSH_PORT`
- Variable: `ENABLE_SSH_DEPLOY` = `true`

Локально по-прежнему: `factorio/scripts/hrt-release.sh`.

Рабочая копия в monorepo: `factorio/mods/hrt-rpg/` в cursor_home; GitHub — отдельный репозиторий для `source_url` и CI.
