# SpyGame — Claude Code Project Notes

iOS-приложение «Шпион»: компанейская игра «один шпион среди невинных».
Поддерживает пасс-зе-фоун (одно устройство) и локальный мультиплеер
(WiFi/Bluetooth через MultipeerConnectivity, без бэкенда для самой игры).

## Стек

- Swift 5.9+ / iOS 15+ / Xcode 16+
- UIKit (НЕ SwiftUI), MVP-паттерн (View + Presenter + Protocol)
- StoreKit 2 для премиума (`wordgen_premium`, Non-Consumable, $1.99)
- MultipeerConnectivity для мультиплеера, без бэкенда
- OpenAI API для генерации тем — через **свой бэкенд-прокси**
  (`backend/api/generate-words.js`), ключ держится в env-переменной
  на сервере. Подробности — раздел «Бэкенд» ниже.
- Локализация: en / ru / ky-KG через `.lproj/Localizable.strings`
  и `.lproj/InfoPlist.strings` (для системных строк типа Local Network).

## Где работаем

Активная рабочая копия — `~/Projects/SpyGame`.
Старая копия лежит в iCloud Drive (`~/Library/Mobile Documents/com~apple~CloudDocs/SpyGame`)
— **не использовать**, iCloud любит терять файлы (особенно ассеты).
Все правки и сборки идут из `~/Projects/SpyGame`.

## Xcode 16 synchronized folders

В `project.pbxproj` группа `SpyGame` определена как
`PBXFileSystemSynchronizedRootGroup`. Это значит **любой `.swift` файл,
положенный в папку `SpyGame/`, автоматически попадает в таргет** — не надо
руками добавлять через Xcode, не надо править pbxproj. Достаточно положить
файл на диск, открыть Xcode заново (или дождаться авто-сканирования).

## Структура (`SpyGame/`)

- `Applications/` — `AppDelegate`, `SceneDelegate`. AppDelegate стартует
  `PremiumIAP.startTransactionListener()` и первичную `refreshUnlockedState()`.
- `Models/` — `GameModel.swift` (UserDefaults-расширения),
  `Theme.swift` (12 встроенных тем + custom theme storage).
- `Helpers/` — `LanguageManager`, `GradientExtension` (neon-градиент карточек),
  `LocalizedExtension` (`String.localized`), `UserDefaultsExtension`.
- `Views/` — синглплеер VC + Presenter:
  - `MainView/` — главный экран (кнопки «Новая игра», «Играть вместе»,
    «Язык», «Правила»)
  - `PlayersSettings/` — настройка партии (3-15 игроков, 1-3 шпионов, темы,
    время). В свойстве `allThemes` зашит список ключей всех 11 тем — должен
    оставаться синхронным с `Theme.allThemes`.
  - `Themes/` — выбор тем. Кнопки тем создаются **динамически** из
    `allThemeKeys` и положены в `UIScrollView` внутри cardView. Чтобы
    добавить новую тему — достаточно прописать её ключ в `allThemeKeys`
    + перевод в `.strings`. Никаких хардкод `lazy var` кнопок.
  - `StartGameView/` — карточный экран синглплеера (передаём телефон)
  - `TimerView/` — таймер с `CircularTimerView` + бип на 11-й секунде.
    Один источник тиков — `CircularTimerView` (старый дубль-счётчик в
    `TimerPresenter` был удалён).
  - `LanguageView/` — выбор языка с пересозданием root VC
  - `OwnDictionary/` — генерация тем через бэкенд-прокси (премиум).
    `AddTopicModel.backendURL` сейчас `nil` — фича отвечает понятным
    алертом `backend_not_configured` пока URL не подставлен.
  - `PaywallViewController.swift` — экран покупки. Кнопка с реальной
    ценой (`product.displayPrice`), блокировка на время операции,
    закрытие через `dismiss` (модально).
  - `StoreKit.swift` — namespace `PremiumIAP` (см. ниже)
- `Multiplayer/` — мультиплеер (см. отдельный раздел ниже)
- `Resourсes/` — Assets.xcassets, `zvuk.wav` (звук бипа), пустые `*.lproj/`.
  ВНИМАНИЕ: папка названа с **кириллической «с»** — не переименовывать,
  это сломает ссылки в pbxproj.
- `Info.plist` — `NSLocalNetworkUsageDescription` (английский дефолт),
  `NSBonjourServices`. Локализованные тексты разрешения —
  в корневых `*.lproj/InfoPlist.strings`.

## Локализация

- Игровые `.strings` — в корне проекта: `en.lproj/Localizable.strings`,
  `ru.lproj/Localizable.strings`, `ky-KG.lproj/Localizable.strings`.
- Системные тексты (NSLocalNetworkUsageDescription, и т.п.) — в
  `<lang>.lproj/InfoPlist.strings`. Эти файлы автоматически подхватываются
  iOS для локализации диалогов разрешений.
- Папки `SpyGame/Resourсes/*.lproj/` сейчас пустые — рабочие `.strings`
  в корне.
- Доступ через `"key".localized` (см. `Helpers/LocalizedExtension.swift`)
  или `"key".localized(with: arg1, arg2)` для форматных строк.

## Премиум (StoreKit 2)

Весь API — в `SpyGame/Views/StoreKit.swift`, namespace `PremiumIAP`.

- `PremiumIAP.isUnlocked()` — синхронный fast-path через UserDefaults кеш.
- `PremiumIAP.refreshUnlockedState()` — async, синхронизирует кеш со StoreKit.
- `PremiumIAP.hasVerifiedEntitlement()` — async, прямой запрос к StoreKit.
- `PremiumIAP.startTransactionListener()` — пожизненный Task, ловит
  Ask-to-Buy approvals, refunds, revocations, покупки с других устройств.
  Стартует в `AppDelegate.didFinishLaunchingWithOptions`.
- Один источник истины — UserDefaults флаг `fullVersionUnlocked`. Пишется
  в listener'е и в `PaywallViewController.unlockPremium()`.

Премиум открывает: генерацию своих тем через бэкенд, мультиплеер с 5+
игроками (см. `MultiplayerSession.maxAllowedPeers`).

## Мультиплеер

Файлы в `SpyGame/Multiplayer/`:

- `MultiplayerSession.swift` — singleton-обёртка над `MCSession + Advertiser
  + Browser`. Делегат-протокол `MultiplayerSessionDelegate` (НЕ Combine, НЕ
  ObservableObject — стиль проекта). Service type: `spyhunt-v1`. 4-значный
  room code в `discoveryInfo`. Хост-проверка через `hostingRoomCode != nil`
  (НЕ через `connectionState`). `disconnect()` идемпотентен (флаг
  `isDisconnecting`), шлёт `.hostLeft` всем гостям и через 0.3 сек делает
  teardown.
- `RoomSetupViewController` — хаб с двумя баннерами «Создать» / «Войти».
- `HostRoomViewController` — экран хоста с кодом, списком игроков,
  настройками (spy count, timer), кнопкой Start и навбар-кнопкой
  «Покинуть комнату» (красная). `restartGame()` — публичный метод для
  TimerVC.
- `GuestRoomViewController` — ввод кода, поиск хоста, состояние ожидания.
- `MultiplayerCardViewController` — карточный экран (визуально как
  синглплеерный StartGameViewController). Хост и гости используют один и
  тот же VC, отличаются обработкой Ready: хост считает локально, гости
  шлют `.playerReady`. Экран не гаснет (`isIdleTimerDisabled`).
- `MultiplayerTimerViewController` — таймер (визуально как синглплеерный
  TimerViewController). Кнопки **только у хоста**:
  - «Новая игра» — зовёт `HostRoomViewController.restartGame()`, сессия
    остаётся живой, всем разлетается новый `gameStart` + замена стека
    через `multiplayerResetStack(to:)`.
  - «Покинуть комнату» — `session.disconnect()` + `popToRoot`, гости
    получают `.hostLeft` алерт и тоже возвращаются на главную.

Сообщения (`MessageType`):
- `gameStart` (host → каждому индивидуально): `GameStartPayload` = роль + конфиг.
- `playerReady` (гость → host).
- `allReadyStartTimer` (host → всем).
- `hostLeft` (host → всем при выходе).

Премиум-лимит: бесплатно — до 4 игроков (host + 3 гостя), премиум — до 15.
Реализован через `session.maxAllowedPeers`, проверяется в
`MCNearbyServiceAdvertiserDelegate.didReceiveInvitation`.

Управление стеком на смене раунда — `UIViewController.multiplayerResetStack(
to:animated:)` (extension в `MultiplayerSession.swift`). Обрезает стек до
`self` и приклеивает хвост — позволяет рестартить раунд, оставляя лобби в
основании стека.

## Бэкенд (генерация тем)

Папка `backend/` в корне репозитория.

- `backend/api/generate-words.js` — Vercel serverless function. Принимает
  `POST { topic, language }`, дёргает OpenAI с ключом из env-переменной
  `OPENAI_API_KEY`, возвращает `{ words: [...] }`.
- `backend/README.md` — пошаговая инструкция деплоя на Vercel.

Клиент дёргает бэкенд через `AddTopicModel.swift`, переменная
`backendURL` (приватная константа в файле). Сейчас `nil` — пока вы не
задеплоили функцию и не вписали URL, фича «Добавь свою тему» показывает
алерт `backend_not_configured` вместо запроса. Никаких сломанных 401-ответов.

OpenAI ключ из клиента полностью удалён.

## Команды

- Открыть в Xcode: `~/Projects/SpyGame/SpyGame.xcodeproj`.
- Сборка через CLI (используется в этой сессии):
  ```bash
  cd ~/Projects/SpyGame
  xcodebuild -project SpyGame.xcodeproj -scheme SpyGame \
    -destination 'platform=iOS Simulator,id=<UDID>' \
    -derivedDataPath /tmp/SpyGameBuild build
  xcrun simctl install <UDID> /tmp/SpyGameBuild/Build/Products/Debug-iphonesimulator/SpyGame.app
  xcrun simctl launch <UDID> kg.tatina.SpyFinder
  ```
  iPhone 17 Pro UDID, который использовали в этой сессии:
  `712AB4D1-94AA-478D-933A-C7C24E7A79C7`. Список симов:
  `xcrun simctl list devices available | grep iPhone`.
- Bundle ID: `kg.tatina.SpyFinder`.
- Для теста мультиплеера — 2-3 симулятора одновременно (boot + install +
  launch на каждом).

## Известные подводные камни

1. **iCloud Drive копия проекта** существует, но **не использовать**. Она
   когда-то теряла Assets.xcassets целиком. Активная копия —
   `~/Projects/SpyGame/`.
2. **`Resourсes/` с кириллической «с»** — НЕ исправлять (сломает pbxproj).
3. **`SpyGame/Resourсes/*.lproj/` пустые** — рабочие `.strings` в корне.
4. **`Pods/` папка удалена.** Проект не использовал CocoaPods (нулевые
   импорты), папка была мусором.
5. **`UserDefaults` для премиум-флага не-секретно**. Если пользователь
   сбросит UserDefaults — премиум потеряется, но `Transaction listener`
   восстановит при следующем запуске приложения.
6. **Симуляторы и DTLS-шум**. При работе 2+ симуляторов на одном Mac MC
   ругается в логах на `Failed to send a DTLS packet, No route to host`.
   Это шум симулятора через локальный бридж, на реальных устройствах
   не воспроизводится.
7. **CHHapticPattern errors в симуляторе** — у симуляторов нет haptic
   engine, эти ошибки можно игнорировать.
8. **`popToRootViewController` НЕ гарантирует `viewWillDisappear` на
   промежуточных VC.** Если нужен disconnect/cleanup при выходе с
   несколько VC выше в стеке — вызывать явно ДО pop, не полагаться на
   lifecycle. Подвох исправлен в Multiplayer, но если будут новые
   мульти-стек выходы — помните.
9. **StoreKit await в обработчиках UI зависает в симуляторе под
   `simctl launch`.** `Transaction.currentEntitlements` /
   `Product.products(for:)` / `product.purchase()` могут висеть много
   секунд, если симулятор запущен НЕ через Xcode Run и нет ни StoreKit
   Testing config, ни sandbox-аккаунта. Решения:
   - Для UI-гейтинга (например, кнопка «Добавь свою тему») использовать
     **синхронный** `PremiumIAP.isUnlocked()` — он читает кеш в
     UserDefaults и возвращается мгновенно. Async-обновление делается
     один раз на старте в AppDelegate и через Transaction.updates
     listener.
   - Для теста реальной покупки в симуляторе — запускать через
     Xcode Run (Cmd+R), не через `simctl launch`. В схеме
     `SpyGame.xcscheme` прописан `StoreKitConfigurationFileReference` на
     `TestStoreKit.storekit`, который Xcode подхватывает при Run.

## Стиль кода / договорённости

- Русские объяснения и общение с пользователем.
- Комментарии в коде — английский, лаконичные. Без многострочных docstrings.
- **Никаких эмодзи в новом коде и комментариях.**
- Перед каждым изменением показывать «было» и «станет».
- НЕ плодить мёртвый код. Если функция/метод не вызывается — удалять.
- Следовать существующим паттернам: delegate-протоколы, completion
  handlers. Async/await — только там, где уже используется (StoreKit 2,
  тесты MultipeerConnectivity).
- Никаких `ObservableObject` / `@Published` — проект не на Combine.

## История правок (важные коммиты)

- `901a85c` — исходная база (StoreKit + IAP-стабилизация, до начала
  большой работы).
- `901fbf7` — мультиплеер шаги 1-3 (Multiplayer/, MainView кнопка, лобби,
  карточный экран, локализации).
- `3e6e335` — фикс Leave Room: idempotent disconnect, явный вызов из
  обоих handleLeaveRoom (см. подвох №8 выше).
- `b575cd7` — переписан словарь: 12 тем, 478 уникальных простых слов
  вместо compound-мусора типа `airport_terminal`. Темы Sports, Celebrities,
  Countries, TV Shows, Music — добавлены.
- `29d3017` — Themes UI: динамический список со скроллом (раньше было
  6 хардкод-кнопок).
- `59b22d8` — удаление OpenAI ключа из клиента, заготовка backend/,
  InfoPlist.strings × 3, удаление Pods/, обновление CLAUDE.md.
- `c13e6c6` — backendURL подставлен (Vercel deploy), prompt в backend
  чище (gpt-4o-mini).
- `f9309c7` — paywall переделан в стиль приложения, fix зависания
  кнопки «Добавь свою тему» (синхронный `PremiumIAP.isUnlocked()`
  вместо async).
- **Текущий коммит** — App Store submission prep:
  - `docs/privacy.md` + `docs/index.md` для GitHub Pages (публичный URL).
  - Промт backend ужесточён: запрет на adult/violent/illegal/hateful
    контент, при подозрительной теме возвращается пустой массив.
  - Фоновое изображение переименовано: `Screenshot 2025-04-09 at
    10.15.28 pm.png` → `background.png`, asset `.background`,
    все 15 ссылок в Swift обновлены.
  - `CURRENT_PROJECT_VERSION` 1 → 2.

## Полезные точки входа для нового агента

- Премиум-флоу: `SpyGame/Views/StoreKit.swift` →
  `AppDelegate.didFinishLaunchingWithOptions` → `PaywallViewController` →
  `ThemesViewController.addYourTopicButtonTapped`.
- Мультиплеер: `MultiplayerSession.swift` →
  `HostRoomViewController.startRound` (генерация ролей) →
  `MultiplayerCardViewController.handleCardTap/handleReady`.
- Одиночная игра: `MainViewController` → `PlayersSetupViewController` →
  `StartGameViewController + StartGamePresenter` → `TimerViewController`.
- Темы и слова: `Models/Theme.swift` + три `Localizable.strings` в корне.
- Бэкенд: `backend/api/generate-words.js` + `backend/README.md`.
