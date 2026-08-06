# Agent Rules for Project Sentinel

## Conversation & Context Persistence Rule
1. **Always Record Progress & Questions**: Record every key user question, technical decision, architectural choice, and phase update in `CHAT_HISTORY.md` located at the root of the workspace.
2. **Session Restoration**: When starting a new session or if conversation history is cleared/not showing in the UI, read `CHAT_HISTORY.md` and recent Git logs to restore full context instantly.
3. **Commit Cleanly**: Ensure all completed features, engines, and tests are committed to git with descriptive messages.
