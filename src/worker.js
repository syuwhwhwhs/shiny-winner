const BOT_TOKEN = "8989785487:AAGxlS6KCbxzRg4Pl_SDRgYaQXF_aIQXzF8";
const CUSTOM_EMOJI_ID = "5438162971719141307";

export default {
  async fetch(request) {
    if (request.method === "GET") {
      return new Response("Telegram bot is running.");
    }

    if (request.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    const update = await request.json().catch(() => null);
    const chatId = update?.message?.chat?.id;
    if (!chatId) return new Response("OK");

    const text =
      `سلام! <tg-emoji emoji-id="${CUSTOM_EMOJI_ID}">✨</tg-emoji>`;

    await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        chat_id: chatId,
        text,
        parse_mode: "HTML"
      })
    });

    return new Response("OK");
  }
};
