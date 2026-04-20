# Your personal LLM assistant

A minimal LLM chatbot as a single HTML file, hosted on GitHub Pages. Fork it, make it yours, publish your own version at your own URL.

## 1. Try the live demo

[klodzikowski.github.io/lmt-chatbot](https://klodzikowski.github.io/lmt-chatbot/)

This is the skeleton we'll build on today. Everything you need to get started is in the app itself — open the drawer, follow the cues.

## 2. Fork the repository

Click **Fork** at the top right of this page. GitHub makes you a copy at `https://github.com/<your-username>/lmt-chatbot`.

## 3. Turn on GitHub Pages

On your fork, go to **Settings → Pages**:

- Source: **Deploy from a branch**
- Branch: **main**, folder: **`/ (root)`**

Save. Wait 30–60 seconds. Your fork is live at `https://<your-username>.github.io/lmt-chatbot/`.

## 4. Open the code

Three ways — pick whichever suits you.

**a. In your browser.** On your fork's main page, press `.` (the period key). GitHub opens a full VS Code in the browser at `github.dev/<your-username>/lmt-chatbot`.

**b. Locally in VS Code.** `git clone` your fork, open it in VS Code. Install the **Live Server** extension for instant reload on save.

**c. Locally in another IDE.** DataSpell, PyCharm, Sublime, WebStorm — any editor that can edit HTML works.

If you have GitHub Copilot ([free for students](https://education.github.com/)), let it handle the boring edits.

## 5. Make it yours

The interesting edits in `index.html`:

- `DEFAULT_SYSTEM` — the system prompt. Rewrite this and the assistant becomes something else: a thesis coach, a Polish→English translator, a Socratic tutor.
- `PRESETS` — add your own named starter prompts to the drawer dropdown.
- `<h1>Personal Assistant</h1>` and the hero tagline below it.
- The `:root` CSS variables at the top of the `<style>` block (colours, spacing).
- The `<option>` list inside `<select id="model">` (swap models in and out).

Commit, push, wait 30–60 seconds. Your changes are live at your URL.
