# Agentic Pipeline - Technical Documentation

## Overview

This document provides comprehensive technical details about the agentic pipeline implementation added to the JARVIS chatbot.

## What is an Agentic Pipeline?

An agentic pipeline is a system where an AI agent can:
1. Receive user requests
2. Determine if external tools/functions are needed
3. Call those tools with appropriate parameters
4. Process and interpret the results
5. Use the results to answer the user's question
6. Iterate if necessary for multi-step tasks

This is more sophisticated than simple API calls because the agent makes intelligent decisions about when and how to use tools.

## Architecture

### Data Flow

```
┌─────────────────┐
│  User Message   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  sendCompletion()                   │
│  (existing chat handler)            │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  callOpenAI()                       │
│  (now with agent loop)              │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Agent Loop                         │
│  while (iterations < MAX)           │
└────────┬────────────────────────────┘
         │
         ├─► Send request WITH tools to OpenAI
         │
         ├─► Receive response
         │
         ├─► Check: tool_calls needed?
         │   │
         │   ├─ YES ─► Execute tools
         │   │         Show results in UI
         │   │         Add to conversation
         │   │         Loop back
         │   │
         │   └─ NO  ─► Generate final response
         │
         ▼
┌─────────────────────────────────────┐
│  Display Response & Tool Actions    │
│  Update Tokens & Cost               │
└─────────────────────────────────────┘
```

## Component Details

### 1. Tool Definitions: `AGENT_TOOLS`

```javascript
const AGENT_TOOLS = [
  {
    name: "tool_name",
    description: "What this tool does",
    parameters: {
      type: "object",
      properties: {
        param_name: {
          type: "string",
          description: "Parameter description"
        }
      },
      required: ["param_name"]
    }
  },
  // ... more tools
]
```

**Purpose**: Defines tools available to the agent in OpenAI's function calling format.

**Current Tools**:
1. `get_current_time` - No parameters, returns current datetime
2. `calculator` - Takes `expression` parameter, evaluates math
3. `web_search_simulator` - Takes `query` parameter, returns relevant info
4. `weather_simulator` - Takes `location` parameter, returns weather data

### 2. Tool Executor: `executeTool(toolName, args)`

```javascript
function executeTool(toolName, args) {
  switch (toolName) {
    case "tool_name":
      // Execute tool logic
      return result;
  }
}
```

**Purpose**: Executes tools based on name and parameters.

**Safety Features**:
- Try-catch blocks for error handling
- Safe math evaluation using Function constructor
- Graceful fallbacks for unknown tools
- Error messages returned on failure

**Adding New Tools**:
```javascript
case "my_tool":
  // Execute logic
  return myToolFunction(args);
```

### 3. UI Renderer: `addToolAction(toolName, args, result)`

```javascript
function addToolAction(toolName, args, result) {
  // Create DOM elements
  // Display: Tool name, arguments, result
  // Insert into chat
  // Scroll to view
}
```

**Purpose**: Displays tool execution details in the chat UI.

**Output Format**:
```
🔧 Tool Call: [tool_name]
Args: [JSON parameters]
Result: [execution result]
```

**Styling**: Darker background with accent colors for visibility.

### 4. Agent Loop Control Variables

```javascript
let agentLoopEnabled = true;              // Master toggle
let agentLoopIterations = 0;              // Current iteration
const MAX_AGENT_ITERATIONS = 5;           // Safety limit
```

**Purpose**: 
- `agentLoopEnabled`: Can disable agent without removing code
- `agentLoopIterations`: Tracks current loop iteration
- `MAX_AGENT_ITERATIONS`: Prevents infinite loops

### 5. Enhanced `callOpenAI()` Function

The main function now implements the agent loop logic:

```javascript
async function callOpenAI({ apiKey, model, systemPrompt, messages, temperature, top_p, max_tokens, wantLogprobs, onDelta }) {
  // Initialize
  let currentMessages = [...];
  let agentLoopIterations = 0;
  
  // Main loop
  while (agentLoopIterations < MAX_AGENT_ITERATIONS) {
    agentLoopIterations++;
    
    // Build payload WITH tools if agent enabled
    const payload = {
      model,
      messages: currentMessages,
      stream: true,
      stream_options: { include_usage: true }
    };
    
    if (agentLoopEnabled) {
      payload.tools = AGENT_TOOLS.map(tool => ({
        type: "function",
        function: tool
      }));
      payload.tool_choice = "auto";  // Let model decide
    }
    
    // Send request to OpenAI
    const response = await fetch("https://api.openai.com/v1/chat/completions", {...});
    
    // Process streaming response
    while (reading stream...) {
      // Parse SSE chunks
      // Extract content and tool_calls
    }
    
    // Check if tools were called
    if (toolCalls.length > 0 && finishReason === "tool_calls") {
      // Add assistant message with tool_calls to history
      currentMessages.push({
        role: "assistant",
        content: replyText || null,
        tool_calls: toolCalls
      });
      
      // Execute each tool
      for (const toolCall of toolCalls) {
        const args = JSON.parse(toolCall.function.arguments);
        const result = executeTool(toolCall.function.name, args);
        
        // Show in UI
        addToolAction(toolCall.function.name, args, result);
        
        // Add result to messages
        currentMessages.push({
          role: "user",
          content: `Tool result: ${result}`
        });
      }
      
      // Continue loop for final response
      continue;
    }
    
    // No more tool calls - we have final response
    finalReply = replyText;
    break;
  }
  
  // Return response object
  return { reply, usage, finish_reason, ... };
}
```

**Key Features**:
1. **Streaming Integration**: Processes SSE chunks with tool call support
2. **Message History**: Maintains conversation context across iterations
3. **Tool Detection**: Recognizes when model wants to call tools
4. **Iteration Control**: Loops until no more tool calls or max iterations
5. **Error Handling**: Catches and reports errors gracefully

## Data Structures

### Tool Call Object
```javascript
{
  index: 0,                      // Position in tool_calls array
  id: "call_abc123",            // Unique call ID
  function: {
    name: "calculator",         // Tool name
    arguments: '{"expression":"2+2"}'  // JSON string
  }
}
```

### Message History Entry with Tool Call
```javascript
{
  role: "assistant",
  content: "Let me calculate that",  // Optional text response
  tool_calls: [
    {
      id: "call_xyz789",
      type: "function",
      function: {
        name: "calculator",
        arguments: '{"expression":"2+2"}'
      }
    }
  ]
}
```

### Tool Result Message
```javascript
{
  role: "user",  // From tool result perspective
  content: "Tool result for calculator: 4"
}
```

## OpenAI API Integration

### Request Payload with Tools

```json
{
  "model": "gpt-4o-mini",
  "messages": [
    { "role": "system", "content": "..." },
    { "role": "user", "content": "..." }
  ],
  "stream": true,
  "stream_options": { "include_usage": true },
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "calculator",
        "description": "...",
        "parameters": {...}
      }
    }
  ],
  "tool_choice": "auto",
  "temperature": 0.8,
  "top_p": 1.0,
  "max_completion_tokens": 1024
}
```

### Response Format (Streaming)

When tool is needed:
```json
{
  "choices": [{
    "delta": {
      "tool_calls": [{
        "index": 0,
        "id": "call_123",
        "function": {
          "name": "calculator",
          "arguments": "{\"expression\":\"2+2\"}"
        }
      }]
    },
    "finish_reason": "tool_calls"
  }]
}
```

When final response:
```json
{
  "choices": [{
    "delta": { "content": "The result is 4." },
    "finish_reason": "stop"
  }]
}
```

## Error Handling

### Tool Execution Errors
```javascript
try {
  const result = executeTool(toolName, args);
  // Success
} catch (e) {
  // Add error message to conversation
  currentMessages.push({
    role: "user",
    content: `Error calling ${toolName}: ${e.message}`
  });
}
```

### Network Errors
```javascript
catch {
  throw new Error("Network error while contacting OpenAI.");
}
```

### JSON Parsing Errors
```javascript
try { 
  const args = JSON.parse(toolCall.function.arguments);
} catch (e) {
  // Handle invalid JSON
}
```

## Performance Considerations

### Token Usage
- Tool calls don't incur separate API costs
- Tool results added to conversation increase tokens
- Streaming optimizes real-time display

### Iteration Cost
- Each iteration = 1 API call
- MAX_AGENT_ITERATIONS = 5 means up to 5 API calls per request
- Set lower for cost-sensitive applications

### Example Costs
```
Single tool use:      2 API calls (request + final)
Multiple tools:       3-5 API calls depending on quantity
No tools used:        1 API call (standard chat)
```

## Integration with Existing Features

### Compatibility Matrix

| Feature | Compatible | Notes |
|---------|-----------|-------|
| Skills/Instructions | ✅ | System prompt still applied |
| RAG | ✅ | Context retrieved and included |
| Streaming | ✅ | Works with tool calls |
| Token Tracking | ✅ | Tracks all iterations |
| Voice I/O | ✅ | Tool results incorporated |
| Memory Persistence | ✅ | History includes tool calls |
| Export | ✅ | JSON includes tool calls |
| Multiple Models | ✅ | Any OpenAI model supported |

### System Prompt Preservation
Tool calls and results are added to conversation AFTER system prompt, so instructions still apply.

### RAG Integration
```
1. User message retrieved with RAG
2. System prompt + RAG context sent to OpenAI WITH tools
3. If tool called, it has access to context indirectly through conversation
4. Tool result added to conversation
```

## Configuration

### Quick Configuration

```javascript
// Disable agent for one session
agentLoopEnabled = false;

// Allow more iterations
MAX_AGENT_ITERATIONS = 10;

// Check current state
console.log({
  agentEnabled: agentLoopEnabled,
  maxIterations: MAX_AGENT_ITERATIONS,
  currentIteration: agentLoopIterations
});
```

### Permanent Configuration

Edit in `index.html` to change defaults:

```javascript
let agentLoopEnabled = false;  // Change to false to disable by default
const MAX_AGENT_ITERATIONS = 5; // Change iterations limit
```

## Testing Strategy

### Unit Tests

Test each tool independently:
```javascript
// Test calculator
executeTool("calculator", { expression: "2+2" })
// Expected: "4"

// Test weather
executeTool("weather_simulator", { location: "london" })
// Expected: "London: 15°C, Partly cloudy"
```

### Integration Tests

Test full loop:
1. Send message requiring tool
2. Verify tool call appears in UI
3. Verify result displayed
4. Verify final response incorporates result

### Edge Cases

```
- Empty expression: calculator("")
- Invalid location: weather_simulator({location: "XYZ"})
- Unknown tool: executeTool("unknown", {})
- Null args: executeTool("calculator", null)
```

## Debugging

### Browser Console Commands

```javascript
// Check agent status
console.log(agentLoopEnabled);

// Check loop count
console.log(agentLoopIterations);

// Monitor API calls
// (Check Network tab in DevTools)

// Manually execute tool
executeTool("calculator", {expression: "100*50"});

// See conversation history
console.log(history);
```

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| No tool calls | Model doesn't think tools needed | Be more explicit |
| Stuck in loop | MAX_AGENT_ITERATIONS too high | Lower the limit |
| Tool not found | Typo in tool name | Check AGENT_TOOLS array |
| JSON parse error | Invalid arguments | Check tool implementation |
| Slow response | Multiple iterations | Reduce MAX_AGENT_ITERATIONS |

## Security Considerations

### Current Implementation

- **Tool Validation**: All tools return strings only
- **Input Sanitization**: Math expressions validated
- **No External Calls**: Simulator tools don't call real APIs
- **Error Boundaries**: All failures caught and reported

### When Adding Real Tools

- Validate all inputs
- Implement rate limiting
- Use secure authentication
- Sanitize outputs
- Log all calls for auditing
- Implement timeout handling

## Future Enhancements

### Planned Features

1. **Parallel Tool Execution**: Call multiple tools simultaneously
2. **Tool Dependencies**: Tool A uses output of Tool B
3. **Conditional Tool Use**: If-then logic for tool selection
4. **Tool History**: Log and replay tool calls
5. **Tool Analytics**: Track which tools are used most

### Extensibility Points

```javascript
// Add pre-tool-call hook
function preToolExecution(toolName, args) { }

// Add post-tool-call hook
function postToolExecution(toolName, result) { }

// Add tool validation
function validateToolCall(toolName, args) { }

// Add custom iteration logic
function shouldContinueLoop(iteration, toolCalls) { }
```

## Best Practices

### For Users
1. Be specific about what you want
2. Ask tool-friendly questions
3. Check the tool call results
4. Monitor token usage

### For Developers
1. Keep tools focused and single-purpose
2. Provide clear error messages
3. Validate all inputs
4. Test edge cases
5. Document tool behavior
6. Monitor performance
7. Implement proper logging

## Conclusion

The agentic pipeline implementation transforms the JARVIS chatbot into a capable agent system that can intelligently use tools to accomplish complex tasks. The system is:

- ✅ **Robust**: Error handling at all levels
- ✅ **Efficient**: Streaming and iteration optimization  
- ✅ **Compatible**: Works with existing features
- ✅ **Extensible**: Easy to add new tools
- ✅ **Debuggable**: Console logging and inspection
- ✅ **Safe**: Iteration limits and error boundaries

For questions or improvements, refer to the accompanying documentation files:
- `IMPLEMENTATION_SUMMARY.md` - Overview and features
- `QUICK_START.md` - Testing and usage guide
- `AGENTIC_PIPELINE.md` - Feature documentation
