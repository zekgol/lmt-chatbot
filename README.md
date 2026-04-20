# LMT Chatbot — Class 19 fork

Lightly branded fork of the Streamlit Community Cloud chatbot template for the Class 19 warm-up. Students deploy this (or the vanilla template) via the deploy-from-template flow; no local work is required.

## Deploy

1. Push this folder to a new GitHub repo.
2. Go to `https://share.streamlit.io/new` and select the repo.
3. Point the main file to `streamlit_app.py`.
4. Deploy. Paste your OpenAI API key into the running app.

## What differs from the vanilla template

- Title and welcome copy aimed at the LMT cohort.
- Seeded academic-tutor system prompt, with an explicit note about hallucinated citations — this sets up the responsible-AI thread in Class 21 (Thesis Writer tab) and Class 22 (evaluation).
- Default model is `gpt-4o-mini` for cost and rate-limit headroom.

## What stayed the same

- Streamlit session-state message list (`st.session_state.messages`) — this is the "memory" students inspect in class.
- One file, no framework, one API key field.
