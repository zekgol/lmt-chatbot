# PowerShell script to update callOpenAI function with agent loop logic

$filePath = "index.html"
$content = Get-Content $filePath -Raw

# Find the position of the callOpenAI function
$callOpenAIStart = $content.IndexOf("      async function callOpenAI({ apiKey, model, systemPrompt, messages, temperature, top_p, max_tokens, wantLogprobs, onDelta }) {")

if ($callOpenAIStart -eq -1) {
    Write-Output "ERROR: callOpenAI function not found!"
    exit 1
}

# Find the next function definition after callOpenAI to determine where the function ends
$nextFunctionStart = $content.IndexOf("      function addMessage(role, text) {", $callOpenAIStart)

if ($nextFunctionStart -eq -1) {
    Write-Output "ERROR: addMessage function not found!"
    exit 1
}

# Extract the old callOpenAI function
$oldFunction = $content.Substring($callOpenAIStart, $nextFunctionStart - $callOpenAIStart).TrimEnd()

Write-Output "Found old callOpenAI function"
Write-Output "Old function length: $($oldFunction.Length) characters"

# Create the new callOpenAI function with agent loop
$newFunction = @'
      async function callOpenAI({ apiKey, model, systemPrompt, messages, temperature, top_p, max_tokens, wantLogprobs, onDelta }) {
        // Agent loop implementation with function calling
        let currentMessages = [
          { role: "system", content: systemPrompt },
          ...messages.map(({ role, content }) => ({ role, content }))
        ];
        let finalReply = "";
        let totalUsage = null;
        let finishReason = null;
        let modelSnapshot = null;
        let responseId = null;
        let logprobsContent = [];
        agentLoopIterations = 0;

        // Main agent loop - continues until no more tool calls or max iterations
        while (agentLoopIterations < MAX_AGENT_ITERATIONS) {
          agentLoopIterations++;
          
          const payload = {
            model,
            messages: currentMessages,
            stream: true,
            stream_options: { include_usage: true },
          };

          // Add tools if agent loop is enabled
          if (agentLoopEnabled) {
            payload.tools = AGENT_TOOLS.map(tool => ({
              type: "function",
              function: tool
            }));
            payload.tool_choice = "auto";
          }

          if (!SAMPLING_LOCKED(model)) {
            payload.temperature = temperature;
            payload.top_p = top_p;
            if (wantLogprobs) {
              payload.logprobs = true;
              payload.top_logprobs = 5;
            }
            if (temperature === 0) payload.seed = 42;
          }

          if (model.startsWith("gpt-3.5")) {
            payload.max_tokens = max_tokens;
          } else {
            payload.max_completion_tokens = max_tokens;
          }

          let response;
          try {
            response = await fetch("https://api.openai.com/v1/chat/completions", {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${apiKey}`,
              },
              body: JSON.stringify(payload),
            });
          } catch {
            throw new Error("Network error while contacting OpenAI.");
          }

          if (!response.ok) {
            const body = await response.json().catch(() => ({}));
            const msg = body?.error?.message ?? `HTTP ${response.status}`;
            throw new Error(msg);
          }

          // Process streaming response
          const reader = response.body.getReader();
          const decoder = new TextDecoder();
          let buffer = "";
          let replyText = "";
          let toolCalls = [];

          const processSseLine = (rawLine) => {
            const line = rawLine.trim();
            if (!line.startsWith("data:")) return;
            const data = line.slice(5).trim();
            if (!data || data === "[DONE]") return;
            let chunk;
            try { chunk = JSON.parse(data); } catch { return; }
            if (chunk.error) throw new Error(chunk.error.message || "Streaming error");
            if (chunk.model) modelSnapshot = chunk.model;
            if (chunk.id) responseId = chunk.id;
            if (chunk.usage) totalUsage = chunk.usage;

            const choice = chunk.choices?.[0];
            if (!choice) return;
            if (choice.finish_reason) finishReason = choice.finish_reason;

            const delta = choice.delta;
            if (!delta) return;

            // Handle content streaming (only on first iteration)
            if (delta.content && agentLoopIterations === 1) {
              replyText += delta.content;
              if (onDelta) onDelta(delta.content);
            }

            // Handle tool calls
            if (delta.tool_calls) {
              for (const toolCall of delta.tool_calls) {
                if (toolCall.index !== undefined) {
                  if (toolCall.index >= toolCalls.length) {
                    toolCalls.push({ index: toolCall.index, id: "", function: { name: "", arguments: "" } });
                  }
                  if (toolCall.id) toolCalls[toolCall.index].id = toolCall.id;
                  if (toolCall.function?.name) toolCalls[toolCall.index].function.name = toolCall.function.name;
                  if (toolCall.function?.arguments) toolCalls[toolCall.index].function.arguments += toolCall.function.arguments;
                }
              }
            }

            const lpDelta = delta.logprobs?.content;
            if (Array.isArray(lpDelta)) logprobsContent.push(...lpDelta);
          };

          streamLoop: while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            buffer += decoder.decode(value, { stream: true });
            const lines = buffer.split("\n");
            buffer = lines.pop() || "";
            for (const rawLine of lines) {
              if (rawLine.trim() === "data: [DONE]") break streamLoop;
              processSseLine(rawLine);
            }
          }
          buffer += decoder.decode();
          if (buffer.trim()) processSseLine(buffer);

          // Check if we need to process tool calls
          if (toolCalls.length > 0 && finishReason === "tool_calls") {
            currentMessages.push({
              role: "assistant",
              content: replyText || null,
              tool_calls: toolCalls.map(tc => ({
                id: tc.id,
                type: "function",
                function: {
                  name: tc.function.name,
                  arguments: tc.function.arguments
                }
              }))
            });

            // Process each tool call
            for (const toolCall of toolCalls) {
              try {
                const args = JSON.parse(toolCall.function.arguments);
                const result = executeTool(toolCall.function.name, args);
                addToolAction(toolCall.function.name, args, result);
                currentMessages.push({
                  role: "user",
                  content: `Tool result for ${toolCall.function.name}: ${result}`
                });
              } catch (e) {
                currentMessages.push({
                  role: "user",
                  content: `Error calling ${toolCall.function.name}: ${e.message}`
                });
              }
            }
            replyText = "";
            toolCalls = [];
            finishReason = null;
            continue;
          }

          finalReply = replyText;
          break;
        }

        return {
          reply: finalReply,
          usage: totalUsage,
          finish_reason: finishReason,
          model_snapshot: modelSnapshot,
          id: responseId,
          logprobs: logprobsContent.length ? logprobsContent : null,
        };
      }

'@

# Replace the old function with the new one
$newContent = $content.Substring(0, $callOpenAIStart) + $newFunction + $content.Substring($nextFunctionStart)

# Backup the original file
Copy-Item -Path $filePath -Destination "$filePath.backup" -Force
Write-Output "Backup created: $filePath.backup"

# Write the updated content
Set-Content -Path $filePath -Value $newContent -Encoding UTF8
Write-Output "Updated index.html with agent loop implementation"

# Verify the update
$updatedContent = Get-Content $filePath -Raw
if ($updatedContent -like "*// Agent loop implementation with function calling*") {
    Write-Output "SUCCESS: Agent loop implementation added to callOpenAI function!"
} else {
    Write-Output "WARNING: Verification failed"
}
