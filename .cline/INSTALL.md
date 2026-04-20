# Superpowers for Cline (Installation & Guide)

This guide explains how to install and use the **Superpowers** skill system within the **Cline** (formerly Claude Dev) VSCode extension.

## 🚀 One-Click Installation

To port Superpowers to your current project, run the following command from your project root:

```bash
/root/code/superpowers/scripts/setup-cline.sh
```

*(Note: Replace the path with the absolute path to your `superpowers` repository if it's stored elsewhere.)*

---

## 🛠️ How it Works

Cline natively supports modular skills and project-level rules. This port leverages these features without duplicating any source markdown files:

1.  **Symlinking Skills:** The installer creates symbolic links from `superpowers/skills/*` to your project's `.cline/skills/`. This ensures that any updates to the `superpowers` repo are instantly available in your project.
2.  **Native Skill Discovery:** Cline automatically scans the `.cline/skills/` directory and discovers every available `SKILL.md`. It only "activates" the full content when it matches your task, saving tokens.
3.  **Bootstrap Rule:** The installer adds a bootstrapper to your `.clinerules` file, instructing Cline to always consult the Superpowers foundational guide (`using-superpowers`).

## 📋 Tool Mapping

Since Superpowers was originally designed for various agents, it uses abstract tool names. Cline is instructed to map these via `skills/using-superpowers/references/cline-tools.md`:

| Superpowers Tool | Cline Native Equivalent |
| :--- | :--- |
| `Read` | `read_file` |
| `Write` | `write_to_file` |
| `Edit` | `replace_in_file` |
| `Bash` | `execute_command` |
| `Grep` | `search_files` |
| `Glob` | `list_files` |

## 🌟 Benefits

-   **Consistency:** Use the same high-quality engineering workflows (TDD, Systematic Debugging, Brainstorming) across all your AI agents.
-   **Token Efficiency:** Skills are only loaded on-demand, keeping your main context window clean.
-   **Zero Maintenance:** Since the skills are symlinked, you only need to manage them in one place (the `superpowers` repo).

---

## 🛑 Troubleshooting

-   **Skills not showing up:** Ensure you have the "Enable Skills" feature toggled ON in your Cline settings (if available as an experimental flag).
-   **Rule ignored:** Try typing "refresh rules" or restarting the Cline task.
-   **Permission Denied:** Ensure the `setup-cline.sh` script is executable (`chmod +x`).