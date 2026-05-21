# SpyGame — Claude Code Project Notes

iOS-приложение «Шпион»: компанейская игра «один шпион среди невинных».
Поддерживает пасс-зе-фоун (одно устройство) и локальный мультиплеер
(WiFi/Bluetooth через MultipeerConnectivity, без бэкенда).

## Стек

- Swift 5.9+ / iOS 15+ / Xcode 16+
- UIKit (НЕ SwiftUI), MVP-паттерн (View + Presenter + Protocol)
- StoreKit 2 для премиума (`wordgen_premium`, Non-Consumable, $1.99)
- MultipeerConnectivity для мультиплеера, без бэкенда
- OpenAI API для генерации тем по запросу (премиум-фича; ключ временно
  лежит в клиенте, см. ниже)
- Локализация: en / ru / ky-KG через `.lproj/Localizable.strings`

## Xcode 16 synchronized folders

В `project.pbxproj` группа `SpyGame` определена как
`PBXFileSystemSynchronizedRootGroup`. Это значит **любой `.swift` файл,
положенный в папку `SpyGame/`, автоматически попадает в таргет** — не надо
руками добавлять через Xcode, не надо править pbxproj. Достаточно положить
файл на диск, открыть Xcode заново (или дождаться авто-сканирования).

## Структура (`SpyGame/`)

- `Applications/` — `AppDelegate`, `SceneDelegate`. AppDelegate стартует
  `PremiumIAP.startTransactionListener()` и первичную `refreshUnlockedState()`.
- `Models/` — `GameModel.swift` (UserDefaults-расширения, ключи доступа),
  `Theme.swift` (встроенные темы + custom theme storage).
- `Helpers/` — `LanguageManager`, `GradientExtension` (neon-градиент карточек),
  `LocalizedExtension` (`String.localized`), `UserDefaultsExtension`.
- `Views/` — синглплеер VC + Presenter:
  - `MainView/` — главный экран (кнопки «Новая игра», «Играть вместе», «Язык», «Правила»)
  - `PlayersSettings/` — настройка партии (3-15 игроков, 1-3 шпионов, темы, время)
  - `Themes/` — выбор тем + точка входа «Добавить свою тему» (премиум)
  - `StartGameView/` — карточный экран синглплеера (передаём телефон)
  - `TimerView/` — таймер с `CircularTimerView` + бип на 11-й секунде
  - `LanguageView/` — выбор языка с пересозданием root VC
  - `OwnDictionary/` — генерация тем через OpenAI (премиум)
  - `PaywallViewController.swift` — экран покупки
  - `PrivacyPolicyViewController.swift`, `RulesViewController.swift`
  - `StoreKit.swift` — namespace `PremiumIAP` (см. ниже)
- `Multiplayer/` — мультиплеер-режим (см. отдельный раздел ниже)
- `Resourсes/` — Assets.xcassets, `zvuk.wav` (звук бипа).
  ⚠️ Папка названа с **кириллической «с»** — не переименовывать, это сломает
  ссылки в pbxproj.
- `Info.plist` — содержит `NSLocalNetworkUsageDescription` +
  `NSBonjourServices` (для MultipeerConnectivity).

## Локализация

- Рабочие `.strings` лежат в **корне проекта**: `en.lproj/Localizable.strings`,
  `ru.lproj/Localizable.strings`, `ky-KG.lproj/Localizable.strings`.
- Папки `SpyGame/Resourсes/*.lproj/` сейчас пустые (служебные, на них смотрит
  pbxproj-группа, но файлы внутри отсутствуют).
- Доступ через `"key".localized` (см. `Helpers/LocalizedExtension.swift`) или
  `"key".localized(with: arg1, arg2)` для форматных строк (см.
  `AddTopicViewController.swift`).
- `LanguageManager.shared.currentLanguage` хранит выбор языка в UserDefaults.
  Переключение языка → пересоздание root view controller.

## Премиум (StoreKit 2)

Весь API — в `SpyGame/Views/StoreKit.swift`, namespace `PremiumIAP`.

- `PremiumIAP.isUnlocked()` — **синхронный** fast-path через UserDefaults кеш.
  Используется для UI-гейтинга (быстро решает «показывать пейволл или нет»).
- `PremiumIAP.refreshUnlockedState()` — async, синхронизирует кеш со StoreKit.
  Зовётся на старте + после каждой Transaction.update.
- `PremiumIAP.hasVerifiedEntitlement()` — async, прямой запрос к StoreKit.
- `PremiumIAP.startTransactionListener()` — пожизненный Task, ловит
  Ask-to-Buy approvals, refunds, revocations, покупки с других устройств.
  Стартует в `AppDelegate.didFinishLaunchingWithOptions`.
- Один источник истины — UserDefaults флаг `fullVersionUnlocked`. Пишется в
  двух местах: в listener'е и в `PaywallViewController.unlockPremium()`.

Премиум открывает: добавление собственных тем (через OpenAI), мультиплеер с
5+ игроками (см. `MultiplayerSession.maxAllowedPeers`).

## Мультиплеер

Файлы в `SpyGame/Multiplayer/`:

- `MultiplayerSession.swift` — singleton-обёртка над `MCSession + Advertiser
  + Browser`. Делегат-протокол `MultiplayerSessionDelegate` (НЕ Combine, НЕ
  ObservableObject — стиль проекта). Service type: `spyhunt-v1`. 4-значный
  room code в `discoveryInfo`. Хост-проверка через `hostingRoomCode != nil`
  (НЕ через `connectionState` — он меняется на `.connected` при первом
  коннекте). `disconnect()` шлёт `.hostLeft` всем гостям и через 0.3 сек
  делает teardown (чтобы пакет успел уйти).
- `RoomSetupViewController` — хаб с двумя баннерами «Создать» / «Войти».
- `HostRoomViewController` — экран хоста с кодом, списком игроков,
  настройками (spy count, timer), кнопкой Start и rightBarButtonItem
  «Покинуть комнату». `restartGame()` — публичный метод, используется
  TimerVC для запуска следующего раунда без рестарта сессии.
- `GuestRoomViewController` — ввод кода, поиск хоста, состояние ожидания.
- `MultiplayerCardViewController` — карточный экран (визуально как
  одиночный StartGameViewController). Хост и гости используют один и тот
  же VC, отличаются только обработкой Ready: хост считает локально, гости
  шлют `.playerReady`.
- `MultiplayerTimerViewController` — таймер (визуально как одиночный
  TimerViewController). Кнопка «Новая игра» только у хоста — зовёт
  `HostRoomViewController.restartGame()`, **сессия остаётся живой**.

Сообщения (`MessageType`):
- `gameStart` (host → каждому индивидуально): `GameStartPayload` = роль + конфиг.
- `playerReady` (гость → host).
- `allReadyStartTimer` (host → всем).
- `hostLeft` (host → всем при выходе).

Премиум-лимит: бесплатно — до 4 игроков (host + 3 гостя), премиум — до 15.
Реализован через `session.maxAllowedPeers`, проверяется в
`MCNearbyServiceAdvertiserDelegate.didReceiveInvitation`.

Делегирование: `MultiplayerSession.shared.delegate = self` ставится в
`viewDidLoad` / `viewWillAppear` активного VC. Delegate — weak, перехват
автоматический при push'е следующего экрана.

Управление стеком на смене раунда — `UIViewController.multiplayerResetStack(
to:animated:)` в `MultiplayerSession.swift`. Обрезает стек до `self` и
приклеивает указанный хвост — позволяет рестартить раунд, оставляя лобби
в основании стека.

## Команды

Никакого CLI — все через Xcode.

- Открыть `SpyGame.xcodeproj` в Xcode 16+
- Cmd+B — собрать
- Cmd+R — запустить
- Cmd+Shift+K — clean build folder (нужен при пропаже ассетов / странных
  кешах)
- Для теста мультиплеера — 2-3 симулятора одновременно через
  «Window → Devices and Simulators → +» или схема с несколькими таргетами.
  При первом запуске система спросит разрешение Local Network — нужно
  разрешить, иначе peer'ы не найдутся.

## Известные подводные камни

1. **Проект в iCloud Drive** (`~/Library/Mobile Documents/com~apple~CloudDocs/SpyGame/`).
   iCloud имеет привычку «выгружать» файлы и иногда теряет их полностью.
   Особенно страдает `Assets.xcassets/`. Если приложение перестаёт находить
   иконки или цвета — сначала проверить, на месте ли ассеты на диске.
   Рекомендуется перенести проект в обычную папку (например `~/Projects/`).
2. **OpenAI API key**. На момент написания лежит в открытом виде в
   `SpyGame/Views/OwnDictionary/AddTopicModel.swift:15`. Это **критическая
   утечка**: каждый, кто скачает .ipa, может вытащить ключ через `strings`.
   Правильное решение — бэкенд-прокси (Cloud Function / Vercel / etc.),
   ключ держится там, клиент шлёт топики. Лимит 5 запросов/день тоже
   переезжает на бэкенд (сейчас он в Keychain → стирается при сбросе
   устройства).
3. **`Resourсes/` с кириллической «с»** — не исправлять.
4. **`SpyGame/Resourсes/*.lproj/` пустые** — рабочие `.strings` в корне.
5. **Двойной таймер**. В `TimerPresenter` была параллельная логика к
   `CircularTimerView` — удалена. Один источник тиков теперь — CircularTimerView.
6. **`UserDefaults` для премиум-флага и Multiplayer не-секретно**. Если
   пользователь сбросит UserDefaults — премиум потеряется (но `Transaction
   listener` сразу восстановит при следующем запуске).
7. **Симуляторы и DTLS**. При работе двух+ симуляторов на одном Mac MC
   может ругаться в логах на `Failed to send a DTLS packet, No route to host`.
   Это нормальный шум симуляторов через локальный бридж, на реальных
   устройствах не воспроизводится.
8. **CHHapticPattern errors в симуляторе** — у симуляторов нет haptic
   engine, эти ошибки можно игнорировать.

## Стиль кода / договорённости

- Русские объяснения и общение с пользователем (Russian everything).
- Комментарии в коде — английский, лаконичные. Без многострочных docstrings.
- Перед каждым изменением показывать «было» и «станет».
- НЕ плодить мёртвый код. Если функция/метод не вызывается — удалять.
- Следовать существующим паттернам: delegate-протоколы, completion
  handlers. Async/await — только там, где уже используется (StoreKit 2,
  тесты MultipeerConnectivity).
- Никаких `ObservableObject` / `@Published` — проект не на Combine.
- NSLocalNetwork разрешение: сейчас текст только на английском в
  Info.plist. Локализация в InfoPlist.strings — задача на потом.

## Полезные точки входа для нового агента

- Понять премиум-флоу — начни с `SpyGame/Views/StoreKit.swift`, далее
  `AppDelegate.didFinishLaunchingWithOptions`, потом
  `PaywallViewController` и `ThemesViewController.addYourTopicButtonTapped`.
- Понять мультиплеер — начни с `MultiplayerSession.swift`, потом
  `HostRoomViewController.startRound` (генерация ролей) и
  `MultiplayerCardViewController.handleCardTap/handleReady` (флоу раунда).
- Понять одиночную игру — `MainViewController → PlayersSetupViewController
  → StartGameViewController + StartGamePresenter → TimerViewController`.
- Локализация — `Helpers/LocalizedExtension.swift` + три `.strings` в корне.
