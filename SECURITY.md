# Security Policy

## Scope

builder-ai is markdown files — there is no executable server, database, or network code in this repo itself. Security concerns relevant to this project are:

- **Prompt injection** — skills and agents that create attack surfaces in applications built with this pack
- **Supply chain** — the install scripts that clone and copy files into user projects
- **Secret exposure** — instructions that accidentally encourage hardcoding API keys or credentials

## Reporting a Vulnerability

**Do not open a public issue for security reports.**

Use [GitHub private vulnerability reporting](https://github.com/RBraga01/builder-ai/security/advisories/new):

1. Describe the vulnerability and the impact
2. Include reproduction steps if applicable
3. Suggest a fix if you have one

**Response SLA:**
- Acknowledgement: within 48 hours
- Assessment: within 7 days
- Fix (if confirmed): within 14 days

## Known Security Considerations for Users

### Prompt Injection

Skills and agents in this pack advise on how to defend against prompt injection — they do not introduce injection vectors themselves. However: AI coding assistants reading these skill files will follow the instructions in them. Review skill files before deploying to shared or multi-tenant environments.

### Install Scripts

`install.sh` and `install.ps1` perform a sparse git clone and copy files into the target directory. They do not execute code from this repo, install packages, or make network requests beyond the git clone. Review the scripts before running in sensitive environments.

### API Keys and Credentials

The cost audit, eval, and benchmarking skills involve LLM API calls. None of these skills should be interpreted as instructing you to hardcode API keys. Always use environment variables or a secrets manager.
