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
    `You are generating words for the family party game "Spy Hunt", distributed on the App Store.\n` +
    `Topic: "${topic.trim()}".\n` +
    `Language code: "${safeLanguage}".\n\n` +
    `Content policy (strict):\n` +
    `- Do NOT generate any sexual, pornographic, or romantically explicit words.\n` +
    `- Do NOT generate words referring to violence, weapons, gore, suicide, self-harm, or abuse.\n` +
    `- Do NOT generate words referring to illegal drugs, illegal activities, or hate speech.\n` +
    `- Do NOT generate slurs, insults, or profanity in any language.\n` +
    `- If the topic itself violates this policy or you cannot generate a safe list, return an empty JSON array: [].\n\n` +
    `Format rules:\n` +
    `- Exactly 40 distinct items (or an empty array if the topic is unsafe).\n` +
    `- Each item is a single noun in the nominative singular (no verbs, adjectives, or adverbs).\n` +
    `- No duplicates and no different inflected forms of the same word.\n` +
    `- Avoid multi-word phrases. Single common compounds (like "ice cream") are allowed only if there is no shorter equivalent.\n` +
    `- Every item must be a concept an average adult in the target language would recognise instantly.\n` +
    `- Each item should have several obvious associations so a player can hint at it without saying it.\n\n` +
    `Return ONLY a JSON array of strings. No surrounding text, no numbering, no explanations, no markdown.`;

  try {
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.6
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
