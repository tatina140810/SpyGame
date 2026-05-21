# SpyGame backend (OpenAI proxy)

Тонкая прокси-функция между iOS-приложением и OpenAI. Нужна потому, что
держать ключ OpenAI в клиентском коде нельзя — каждый, кто скачает .ipa,
вытащит его через `strings`.

## Что внутри

- `api/generate-words.js` — Vercel serverless function. Принимает
  `{ topic, language }`, дергает OpenAI Chat Completions с ключом из
  переменной окружения, отдаёт обратно JSON со списком из 40 слов.

## Деплой (Vercel, бесплатно)

1. Зарегистрируйтесь на [vercel.com](https://vercel.com) (через GitHub —
   проще всего).
2. Установите CLI: `npm i -g vercel`.
3. Из этой папки запустите `vercel` и пройдите по подсказкам:
   - **Set up and deploy?** Y
   - **Which scope?** ваш аккаунт
   - **Link to existing project?** N
   - **What's your project's name?** `spygame-backend` (любое)
   - **In which directory is your code located?** `./`
4. Добавьте секрет в дашборде Vercel:
   `Settings → Environment Variables → OPENAI_API_KEY = sk-...`
   (значение возьмите из OpenAI Dashboard, **сначала отозвав старый
   скомпрометированный ключ**).
5. Перезапустите деплой: `vercel --prod`.
6. Скопируйте URL вида
   `https://spygame-backend.vercel.app/api/generate-words` и вставьте его
   в `SpyGame/Views/OwnDictionary/AddTopicModel.swift` как значение
   `backendURL` (заменить `nil`).

После этого в приложении кнопка «Запрос» снова заработает.

## Эндпоинт

```
POST /api/generate-words
Content-Type: application/json

{ "topic": "космос", "language": "ru" }
```

Ответ при успехе:

```json
{ "words": ["звезда", "ракета", ...] }
```

При ошибке: `{ "error": "..." }` с подходящим HTTP-кодом.

## Тарификация

OpenAI берёт деньги за токены. `gpt-3.5-turbo` стоит копейки за запрос
(40 слов = ~$0.0002). 5 запросов в день на пользователя — лимит сейчас
зашит в клиенте (`AddTopicModel.maxRequests`). Если нужен жёсткий лимит
с серверной стороны — добавьте rate-limiting на Vercel/в функции.

## Альтернативы Vercel

- **Cloudflare Workers** — бесплатный лимит больше, чуть другой синтаксис
  (`addEventListener('fetch', ...)`).
- **AWS Lambda + API Gateway** — больше шагов, но больше контроля.

Файл `api/generate-words.js` устроен так, что его легко портировать на
любой из этих вариантов.
