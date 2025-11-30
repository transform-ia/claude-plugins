#!/usr/bin/env python3
"""
Detect which plugin command initiated a tool call by walking the transcript parent chain.

Usage: detect-caller.py <transcript_path> <tool_use_id>

Returns (to stdout):
  - Plugin command (e.g., "/helm:cmd-lint", "/go:cmd-build") if found
  - Empty string if not from a plugin command

Exit codes:
  0 = Success (found or not found)
  1 = Error (missing args, file not found, etc.)
"""

import sys
import json
import re

def find_caller(transcript_path: str, tool_use_id: str) -> str:
    """Walk parent chain to find originating plugin command."""

    # Load transcript into a dict keyed by uuid for fast lookup
    messages = {}
    try:
        with open(transcript_path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    msg = json.loads(line)
                    uuid = msg.get('uuid')
                    if uuid:
                        messages[uuid] = msg
                except json.JSONDecodeError:
                    continue
    except FileNotFoundError:
        print("ERROR: Transcript file not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    # Find the assistant message containing this tool_use_id
    current_uuid = None
    for uuid, msg in messages.items():
        content = msg.get('message', {}).get('content', [])
        if isinstance(content, list):
            for item in content:
                if isinstance(item, dict) and item.get('id') == tool_use_id:
                    current_uuid = msg.get('parentUuid')
                    break
        if current_uuid:
            break

    if not current_uuid:
        # Tool use not found in transcript - might be too new
        return ""

    # Walk parent chain looking for plugin commands or skills
    # Pattern 1: Slash commands like <command-name>/helm:cmd-lint</command-name>
    command_pattern = re.compile(r'<command-name>(/[a-zA-Z0-9_-]+:[a-zA-Z0-9_-]+)</command-name>')
    # Pattern 2: Skills - look for "Base directory for this skill:" followed by <command-name>skillname</command-name>
    skill_base_pattern = re.compile(r'Base directory for this skill:\s*/[^\s]*/claude-plugins/([a-zA-Z0-9_-]+)/skills/([a-zA-Z0-9_-]+)')
    skill_name_pattern = re.compile(r'<command-name>([a-zA-Z0-9_-]+)</command-name>')
    max_depth = 20  # Prevent infinite loops

    for _ in range(max_depth):
        if current_uuid not in messages:
            break

        msg = messages[current_uuid]
        content = msg.get('message', {}).get('content', '')

        # Content might be a string or list
        if isinstance(content, list):
            content = ' '.join(
                item.get('text', '') if isinstance(item, dict) else str(item)
                for item in content
            )

        # Look for slash command pattern first (e.g., /helm:cmd-lint)
        match = command_pattern.search(content)
        if match:
            return match.group(1)

        # Look for skill pattern: "Base directory for this skill:" with plugin/skill info
        skill_base_match = skill_base_pattern.search(content)
        if skill_base_match:
            plugin_name = skill_base_match.group(1)
            skill_name = skill_base_match.group(2)
            # Return in format /plugin:skill so existing checks like /github:* still work
            return f"/{plugin_name}:{skill_name}"

        # Move to parent
        current_uuid = msg.get('parentUuid')
        if not current_uuid:
            break

    return ""


def main():
    if len(sys.argv) != 3:
        print("Usage: detect-caller.py <transcript_path> <tool_use_id>", file=sys.stderr)
        sys.exit(1)

    transcript_path = sys.argv[1]
    tool_use_id = sys.argv[2]

    caller = find_caller(transcript_path, tool_use_id)
    print(caller)
    sys.exit(0)


if __name__ == '__main__':
    main()
