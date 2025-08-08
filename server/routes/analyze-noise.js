import express from 'express';
import { Configuration, OpenAIApi } from 'openai';

const router = express.Router();

const openai = new OpenAIApi(new Configuration({
  apiKey: process.env.OPENAI_API_KEY, // 🔒 환경변수에서 API 키 가져오기
}));

// 🔥 POST /analyze-noise
router.post('/analyze-noise', async (req, res) => {
  try {
    const { averageDb, peakDb, timestamp } = req.body;

    if (!averageDb || !peakDb) {
      return res.status(400).json({ error: 'averageDb and peakDb are required.' });
    }

    const prompt = buildPrompt(averageDb, peakDb, timestamp);

    const completion = await openai.createChatCompletion({
      model: 'gpt-4',
      messages: [
        { role: 'system', content: '너는 층간소음 분석 전문가야. 법적 기준과 생활소음 규정을 잘 알아.' },
        { role: 'user', content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 800,
    });

    const reply = completion.data.choices[0]?.message?.content ?? 'AI 응답을 받을 수 없습니다.';
    return res.json({ reply });

  } catch (error) {
    console.error('AI 분석 오류:', error);
    return res.status(500).json({ error: '서버 오류 또는 GPT 응답 실패' });
  }
});

function buildPrompt(averageDb, peakDb, timestampStr) {
  const time = timestampStr ? new Date(timestampStr) : new Date();
  const hours = time.getHours();

  let timeContext = '주간';
  if (hours >= 23 || hours < 6) {
    timeContext = '야간 (조용해야 할 시간)';
  } else if (hours >= 18) {
    timeContext = '저녁 (생활 소음이 제한되는 시간)';
  }

  const formatted = time.toLocaleString('ko-KR', { hour12: false });

  return `${formatted} 기준, ${timeContext} 시간대에 측정한 층간 소음 데이터입니다.
- 평균 소음: ${averageDb.toFixed(2)} dB
- 최고 소음: ${peakDb.toFixed(2)} dB

이 수치들이 생활 소음 기준에 비춰 문제가 되는 수준인지,
법적 기준, 일반적인 피해 인정 사례 등을 참고해 분석해 주세요.
또한, 어떤 조치를 취하는 것이 적절할지도 알려주세요.`;
}

export default router;
