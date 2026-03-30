---
name: cwi-research
description: Researches the current directory by reading all source code files deeply and updating the research.md file
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
effort: max
argument-hint: "[focus-area]"
---

Research the codebase following these steps:

1. Use Glob to get a complete file listing of all source code files (exclude node_modules, dist, build, .git, vendor, __pycache__)
2. If there are more than 50 source files, ask the user what to focus on. Otherwise proceed.
3. Read all source files systematically — group by directory/module
4. If a research.md already exists, read it and validate its contents against current code. Remove any outdated information.
5. If the user has given specific instructions, use WebSearch to verify technical assumptions before including them.

When research is complete, write research.md using the structure from [research-template.md](research-template.md).

If the user specified a focus area, prioritize researching: $ARGUMENTS
