"""LMT Chatbot — Class 19 warm-up.

Lightly branded fork of the Streamlit Community Cloud chatbot template.
Drops a seeded academic-tutor system prompt so the baseline is more
interesting to compare against Class 20 (Document QA) and Class 21
(Agent Lab). Deploys via the usual deploy-from-template flow.
"""

import streamlit as st
from openai import OpenAI

DEFAULT_MODEL = "gpt-4o-mini"

SYSTEM_PROMPT = (
    "You are an academic tutor for MA students in Language and Media "
    "Technology at Adam Mickiewicz University. You help with applied "
    "linguistics, NLP, agentic AI, and thesis writing. British English. "
    "Prefer short, concrete answers. When the student asks for sources, "
    "be explicit that you cannot verify citations and suggest they cross-"
    "check in Google Scholar before using anything in a thesis draft."
)

st.set_page_config(page_title="LMT Chatbot — Class 19", page_icon=None)
st.title("LMT Chatbot — Class 19 warm-up")
st.write(
    "This is the Level 1 baseline: an LLM plus a system prompt plus a message "
    "history. No tools, no retrieval, no memory across sessions. Follow the "
    "class handout to deploy your own fork. The system prompt is seeded as an "
    "academic tutor; edit `streamlit_app.py` in GitHub Codespaces to change it."
)

openai_api_key = st.text_input("OpenAI API key", type="password")
if not openai_api_key:
    st.info("Paste your OpenAI API key to start chatting. The key lives in "
            "the browser session only.")
    st.stop()

client = OpenAI(api_key=openai_api_key)

if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Ask about your thesis, a paper, or the class."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    stream = client.chat.completions.create(
        model=DEFAULT_MODEL,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            *({"role": m["role"], "content": m["content"]}
              for m in st.session_state.messages),
        ],
        stream=True,
    )

    with st.chat_message("assistant"):
        response = st.write_stream(stream)
    st.session_state.messages.append({"role": "assistant", "content": response})
