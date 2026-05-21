// Vercel serverless function — proxy between the iOS app and OpenAI.
//
// Deployment:
//   1. Sign up at https://vercel.com (free tier is enough for low traffic).
//   2. Install the CLI: `npm i -g vercel`.
//   3. From this `backend/` directory run `vercel` and follow the prompts.
//   4. Add the secret in the Vercel dashboard:
//        Settings -> Environment Variables -> OPENAI_API_KEY = sk-...
//   5. Re-deploy: `vercel --prod`.
//   6. Copy the resulting URL (looks like https://<project>.vercel.app/api/generate-words)
//      into `SpyGame/Views/OwnDictionary/AddTopicModel.swift` as `backendURL`.
//
// Endpoint:
//   POST /api/generate-words
//   Body (JSON): { "topic": "string", "language": "en" | "ru" | "ky-KG" }
//   Response (JSON): { "words": ["..."] }   // 40 strings on success
//                    or { "error": "..." }
//
// The OpenAI key never leaves this server — the iOS binary stays clean.

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { topic, language } = req.body || {};
  if (typeof topic !== 'string' || topic.trim().length === 0) {
    return res.status(400).json({ error: 'topic is required' });
  }
  const safeLanguage = typeof language === 'string' && language.length <= 8 ? language : 'en';

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'OPENAI_API_KEY env var is not set' });
  }

  const prompt =
    `Generate exactly 40 single-concept words on the topic "${topic.trim()}" ` +
    `in language code "${safeLanguage}". Return only a JSON array of strings, ` +
    `no surrounding text, no numbering, no explanations.`;

  try {
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7
      })
    });

    if (!openaiResponse.ok) {
      const text = await openaiResponse.text();
      return res.status(openaiResponse.status).json({ error: text });
    }

    const data = await openaiResponse.json();
    const content = data?.choices?.[0]?.message?.content ?? '';

    let words;
    try {
      words = JSON.parse(content);
    } catch {
      return res.status(502).json({ error: 'OpenAI did not return valid JSON' });
    }
    if (!Array.isArray(words) || !words.every(w => typeof w === 'string')) {
      return res.status(502).json({ error: 'Unexpected payload shape' });
    }

    return res.status(200).json({ words });
  } catch (err) {
    return res.status(500).json({ error: String(err && err.message || err) });
  }
}
