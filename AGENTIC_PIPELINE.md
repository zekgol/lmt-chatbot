# Agentic Pipeline Integration

## Overview
This document describes the agentic pipeline that has been added to the JARVIS chatbot interface.

## What is an Agentic Pipeline?
An agentic pipeline is a system where an AI agent can:
1. Recognize when a task requires external tools/functions
2. Call those tools with appropriate parameters
3. Receive and process the tool results
4. Incorporate the results into its response
5. Iterate if needed to accomplish complex tasks

## Implementation

### Available Tools

The agent pipeline now includes the following tools:

#### 1. **get_current_time**
- **Description**: Get the current date and time
- **Parameters**: None required
- **Example Response**: "5/19/2026, 2:30:45 PM"

#### 2. **calculator**
- **Description**: Perform mathematical calculations
- **Parameters**: `expression` (string) - Mathematical expression
- **Example**: expression = "2 + 2 * 10" → Result = "22"

#### 3. **web_search_simulator**
- **Description**: Simulate a web search to retrieve information
- **Parameters**: `query` (string) - Search query
- **Example Keywords**: javascript, python, ai, machine learning
- **Example Response**: "JavaScript is a versatile programming language used for web development and scripting."

#### 4. **weather_simulator**
- **Description**: Get simulated weather information for a location
- **Parameters**: `location` (string) - City name or location
- **Example Locations**: london, new york, tokyo, paris
- **Example Response**: "London: 15°C, Partly cloudy"

### How It Works

#### Agent Loop Flow:
```
1. User sends a message
   ↓
2. System sends to OpenAI with tools attached
   ↓
3. Model determines if tools are needed
   ↓
4. If tool calls are generated:
   a. Display the tool call in the chat (with args and result)
   b. Execute the tool
   c. Add result to conversation history
   d. Loop back to step 2
   ↓
5. If no more tool calls needed:
   Model generates final response
   ↓
6. Display final response to user
```

### Example Usage

**User**: "What's the weather in London and can you calculate 15 * 7?"

**Agent Actions**:
1. Calls `weather_simulator` with location="London"
   - Result: "London: 15°C, Partly cloudy"
2. Calls `calculator` with expression="15 * 7"
   - Result: "105"
3. Generates response: "The weather in London is 15°C and partly cloudy. 15 multiplied by 7 equals 105."

## Code Integration

### Key Components Added:

1. **AGENT_TOOLS** - Array of tool definitions with OpenAI function calling format
2. **executeTool()** - Function that executes tools based on tool name
3. **addToolAction()** - Renders tool execution information in the chat UI
4. **runAgentLoop()** - Main agent loop that:
   - Sends requests to OpenAI with tools
   - Processes tool calls
   - Manages iterations
   - Returns final response
5. **agentLoopEnabled** - Boolean flag to enable/disable agent functionality
6. **MAX_AGENT_ITERATIONS** - Safety limit to prevent infinite loops (default: 5)

### Modified Functions:

- **callOpenAI()** - Now uses runAgentLoop() to support function calling
  - Processes streaming tool calls
  - Maintains conversation context across tool uses
  - Handles tool results properly

## UI Changes

### Tool Action Display:
When the agent calls a tool, it displays:
- 🔧 Tool Call: [tool name]
- Args: [JSON parameters]
- Result: [execution result]

These are shown as special assistant messages in the chat with distinctive styling (darker background, green result text).

## Features

- ✅ Automatic tool selection by the AI model
- ✅ Support for up to 5 sequential tool calls (configurable)
- ✅ Visual feedback for tool execution
- ✅ Proper error handling and reporting
- ✅ Maintains conversation history
- ✅ Works with streaming responses
- ✅ Compatible with existing chatbot features (RAG, skills, etc.)

## Enabling/Disabling

To disable the agentic pipeline:
```javascript
agentLoopEnabled = false;  // Model won't use tools
agentLoopEnabled = true;   // Model can use tools (default)
```

To change maximum iterations:
```javascript
MAX_AGENT_ITERATIONS = 10;  // Allow up to 10 tool calls
```

## Future Enhancements

Potential tools to add:
- Real weather API integration
- Web search API integration
- File operations (read/write)
- Database queries
- Custom business logic functions
- External API calls
- Code execution

## Testing

Try these prompts to test the agent:

1. "What time is it right now?"
2. "Can you calculate 123 * 456?"
3. "Tell me about Python"
4. "What's the weather in Paris?"
5. "Calculate 100 / 2 and tell me about JavaScript"
6. "Give me the current time and check the weather in Tokyo"

The agent will automatically recognize when tools are needed and execute them appropriately.
