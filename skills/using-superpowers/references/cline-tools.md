# Cline Tool Mapping

This reference maps Superpowers' abstract tool references to **Cline's** native MCP and built-in tools. When using skills in Cline, the agent should interpret the abstract commands as follows:

| Abstract Tool | Cline Native Tool | Description |
| :--- | :--- | :--- |
| `Read` | `read_file` | Read content from a file. |
| `Write` | `write_to_file` | Create or overwrite a file. |
| `Edit` | `replace_in_file` | Targeted replacement within a file. |
| `Bash` | `execute_command` | Execute shell commands. |
| `Grep` | `search_files` | Search for patterns in files. |
| `Glob` | `list_files` | List files matching a pattern. |
| `Skill` | (Native) | Cline automatically discovers skills in `.cline/skills/`. |
| `TodoWrite` | `write_to_file` | Use standard markdown files for task tracking. |
| `Task` | (Built-in) | Cline manages task flow natively. |

## Guidance for Cline

Cline should always prefer its native tools while following the **Workflow** defined in the `SKILL.md` files. If a skill instructs to use a tool that Cline does not have, Cline should use its most relevant equivalent (e.g., `execute_command` for any custom script).