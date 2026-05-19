# Quick Start Guide - Testing the Agentic Pipeline

## 🚀 Getting Started

### Prerequisites
1. OpenAI API Key (required to be pasted in Settings)
2. Web browser (Chrome, Firefox, Safari, Edge)
3. Internet connection

### Step 1: Open the Application
- Open `index.html` in your browser

### Step 2: Add Your API Key
- Click the ☰ (menu) button in the top-left
- Paste your OpenAI API key in the "OpenAI API key" field
- Close the menu

### Step 3: Test the Agent

---

## 🧪 Test Scenarios

### Test 1: Time Query (Simple)
**User Input**: "What time is it?"

**Expected Behavior**:
- Chat shows a tool call box with "🔧 Tool Call: get_current_time"
- Shows execution result with current time
- Assistant responds naturally incorporating the time

**Example Response**: "According to the current time, it is [timestamp]. Sir, what else may I assist you with?"

---

### Test 2: Calculator (Math)
**User Input**: "Calculate 123 multiplied by 456 for me"

**Expected Behavior**:
- Tool call box appears: "🔧 Tool Call: calculator"
- Args shown: `{ "expression": "123 * 456" }`
- Result displayed: "56088"
- Assistant provides the answer

**Example Response**: "The calculation yields 56,088. A straightforward multiplication, sir."

---

### Test 3: Weather Query
**User Input**: "What's the weather like in Tokyo?"

**Expected Behavior**:
- Tool call: "🔧 Tool Call: weather_simulator"
- Args: `{ "location": "Tokyo" }`
- Result: "Tokyo: 18°C, Rainy"
- Assistant incorporates into response

**Example Response**: "Tokyo is currently experiencing rain at 18 degrees Celsius, sir. Quite typical for the season."

---

### Test 4: Search Query
**User Input**: "Tell me about artificial intelligence"

**Expected Behavior**:
- Tool call: "🔧 Tool Call: web_search_simulator"
- Args: `{ "query": "artificial intelligence" }`
- Result: "Artificial Intelligence (AI) is the simulation of human intelligence by computer systems."
- Assistant elaborates on the result

---

### Test 5: Multi-Tool (Complex)
**User Input**: "What time is it, calculate 10 plus 5, and check the weather in London"

**Expected Behavior**:
- Multiple tool calls appear in sequence
- Tool 1: get_current_time
- Tool 2: calculator with expression "10 + 5"
- Tool 3: weather_simulator for London
- Final response synthesizes all three results

**Example Response**: "Sir, it is currently [time]. Ten plus five equals fifteen. London is presently at 15°C with partly cloudy skies. How else may I serve?"

---

## 🎮 Interactive Testing

### Test Format:
Each test follows this pattern:

```
┌─ USER INPUT ─────────────────────────────┐
│ "[Your question requiring a tool]"      │
├──────────────────────────────────────────┤
│ 🔧 Tool Call: [tool_name]               │
│ Args: [parameters shown]                │
│ Result: [execution result shown]        │
├──────────────────────────────────────────┤
│ JARVIS: "[Natural response]"            │
└──────────────────────────────────────────┘
```

### What to Look For:
1. Tool execution displayed in chat
2. Tool arguments shown as JSON
3. Tool result visible
4. Final response incorporates tool result naturally
5. No errors or duplicate messages

---

## 🔍 Verification Checklist

After running each test, verify:

- [ ] Tool call appears as a message in the chat
- [ ] Tool name is displayed with 🔧 emoji
- [ ] Parameters (Args) are shown in JSON format
- [ ] Result is displayed and visible
- [ ] No JavaScript errors in browser console
- [ ] Final response is coherent and uses the tool result
- [ ] Token counter updates correctly
- [ ] Chat is scrollable and readable

---

## 🛠️ Troubleshooting

### Issue: "Tool call not appearing"
**Solution**: 
- Verify API key is valid
- Check browser console for errors (F12)
- Ensure internet connection is active
- Try a simpler query first

### Issue: "Tool executes but no result shown"
**Solution**:
- Refresh the page
- Check that `agentLoopEnabled = true`
- Look in browser console for error messages

### Issue: "Model doesn't use tools when asked"
**Reason**: Model is deciding that tools aren't needed for this query
**Solution**: Be more explicit, e.g., "Use the calculator to compute 2+2"

### Issue: "Getting rate limit errors"
**Solution**: Wait a few seconds and try again (OpenAI API rate limits)

---

## 📊 Advanced Testing

### Check Agent State:
Open browser console (F12) and type:

```javascript
// Check if agent is enabled
agentLoopEnabled

// Check max iterations
MAX_AGENT_ITERATIONS

// Check current iteration count
agentLoopIterations

// Disable agent for one session
agentLoopEnabled = false

// Re-enable
agentLoopEnabled = true
```

### Monitor Performance:
```javascript
// Check total tokens used
console.log(`Tokens in: ${tokensIn}, Tokens out: ${tokensOut}`)

// Check cost
console.log(`Total cost: ${costTotal}`)
```

---

## 💡 Pro Tips

1. **Be Specific**: "Calculate 100 * 50" works better than "Do math"
2. **Use Natural Language**: "How's the weather in Paris?" is better than just "Paris weather"
3. **Chain Requests**: The agent can handle multiple tools in one message
4. **Check Results**: Tool results are always shown before the final response
5. **Monitor Iterations**: Look at the number of tool calls to understand reasoning

---

## 📝 Example Conversations

### Conversation 1: Simple Query
```
User: "What's the current time?"
↓
Tool Call: get_current_time
Result: 5/19/2026, 2:30:45 PM
↓
JARVIS: "The current time is 5/19/2026, 2:30:45 PM, sir."
```

### Conversation 2: Math Problem
```
User: "What's 50 times 8?"
↓
Tool Call: calculator
Args: { "expression": "50 * 8" }
Result: 400
↓
JARVIS: "50 times 8 equals 400, sir. A simple calculation."
```

### Conversation 3: Multi-Step
```
User: "Tell me what time it is and calculate 10 plus 10"
↓
Tool Call 1: get_current_time
Result: 5/19/2026, 2:35:00 PM
Tool Call 2: calculator
Args: { "expression": "10 + 10" }
Result: 20
↓
JARVIS: "It is presently 2:35 PM, sir. Additionally, ten plus ten equals twenty."
```

---

## 🎯 Next Steps After Testing

1. **Verify Functionality**: Confirm all tools work as expected
2. **Explore Combinations**: Try complex queries using multiple tools
3. **Test Edge Cases**: Try invalid inputs, very large numbers, etc.
4. **Monitor Performance**: Check token usage and costs
5. **Customize**: Add your own tools by editing the code
6. **Deploy**: Use in production with confidence

---

## 📚 Tool Reference

| Tool | Trigger Words | Example Input | Example Output |
|------|---------------|---------------|-----------------|
| `get_current_time` | time, now, current | "What time is it?" | `"5/19/2026, 2:30 PM"` |
| `calculator` | calculate, math, plus, times | "100 * 50" | `"5000"` |
| `web_search_simulator` | about, tell me, explain | "about JavaScript" | `"JavaScript is..."` |
| `weather_simulator` | weather, temperature, climate | "London weather" | `"London: 15°C"` |

---

## ✅ Success Criteria

Your agentic pipeline is working correctly when:

- ✅ Tool calls display in chat with full details
- ✅ Tool results are accurate
- ✅ Final responses incorporate tool results naturally
- ✅ Multiple tool calls work in single query
- ✅ No errors appear in console
- ✅ Token counter updates correctly
- ✅ Agent stops after getting results (no infinite loops)

---

**Happy Testing! 🎉**

The agentic pipeline transforms your chatbot into an intelligent agent capable of using tools to accomplish complex tasks. Explore its capabilities and build amazing applications on top of it!
