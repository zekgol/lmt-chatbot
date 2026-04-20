# LLM Assistant — practice repo

A minimal OpenAI chatbot as a single HTML file. Hosted on GitHub Pages, calls the OpenAI API from your browser. No framework, no backend, no build step.

Use this as a starter: fork it, change the system prompt, restyle it, publish your own version at your own URL.

## Try the live demo

[klodzikowski.github.io/lmt-chatbot](https://klodzikowski.github.io/lmt-chatbot/)

Open the drawer (menu icon, top-left), paste an OpenAI API key, send a message. The key lives in your browser session only — not stored anywhere else, not committed, not synced.

## Goal: build your own chatbot

Takes about ten minutes. You end up with your own chatbot, at your own URL, doing whatever you want it to do.

### 1. Fork this repo

Click **Fork** at the top right of this page. GitHub makes you a copy at `https://github.com/<your-username>/lmt-chatbot`.

### 2. Turn on GitHub Pages on your fork

On your fork, go to **Settings → Pages**. Under "Build and deployment":

- Source: **Deploy from a branch**
- Branch: **main**, folder: **`/ (root)`**

Save. Wait 30 to 60 seconds. Your chatbot is live at `https://<your-username>.github.io/lmt-chatbot/`.

### 3. Open the code in an IDE

Three options — pick whichever suits you.

**a. In your browser, no install.** On your fork's main page, press `.` (the period key). GitHub opens a full VS Code in the browser at `github.dev/<your-username>/lmt-chatbot`. Commit from the Source Control panel in the left sidebar.

**b. Locally in VS Code.** `git clone` your fork, open it in VS Code. For instant "save = refresh" feedback, install the **Live Server** extension, then right-click `index.html` → Open with Live Server.

**c. Locally in another IDE.** DataSpell, PyCharm, Sublime, WebStorm, whatever. Any editor that can edit HTML works. Same clone → edit → commit → push flow.

If you have GitHub Copilot set up (free for students via [GitHub Education](https://education.github.com/)), let it handle the boring edits: "change the system prompt to a Socratic tutor", "swap the colour palette to warm yellows", "rename the title to X".

### 4. Make it yours

The defaults give you a plain, helpful assistant. Change it to whatever you want.

The interesting edits in `index.html`:

- `DEFAULT_SYSTEM` — the system prompt. The invisible first message that steers every reply. Rewrite this and the assistant becomes something else: a thesis coach, a Polish→English translator, a Socratic tutor, a grumpy film critic, a dad telling dry British dad jokes, anything.
- `<h1>Personal Assistant</h1>` and the hero tagline below it.
- The `:root` CSS variables at the top of the `<style>` block (colours, spacing).
- The `<option>` list inside `<select id="model">` (swap models in and out).
- Default slider values for temperature, top-p, max tokens.

**Example: turn this into a dad-jokes bot.** Open the drawer, paste this into the system prompt, send a message:

```
You are a dad with dry British humour. Every reply is a relevant dad joke about what the user just said. Short, groan-worthy, deadpan. Emojis allowed but sparingly — as punchlines, not confetti. Family friendly. British English.
```

### 5. Republish

Commit. Push. GitHub Pages rebuilds automatically in 30 to 60 seconds. Refresh your URL. Share the link.

## What the drawer gives you

Click the menu icon top-left:

- OpenAI API key input (stored in browser `sessionStorage`, never committed)
- Model picker, newest first (gpt-5-mini → gpt-3.5-turbo)
- Editable system prompt with Reset
- Temperature, top-p, max-tokens sliders, each with a one-line explainer tooltip
- Download the whole conversation as JSON (messages, system prompt, sampling settings, token totals, estimated cost)
- Clear chat
- Reset all

## Run locally without pushing

Sometimes you just want to poke at the file without committing. Open `index.html` directly in a browser, or for hot reload:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000`.

## Notes on models

The default is **gpt-5-mini**. Newer reasoning-tuned models only accept the default temperature and top-p (1.0), so the sampling sliders are effectively locked when that model is selected — pick an older model (e.g. `gpt-4o-mini`) to experiment with sampling.

Estimated cost shown in the UI is a rough teaching figure based on published per-token rates. Check [platform.openai.com/pricing](https://platform.openai.com/pricing) for the live numbers before you rely on them.
