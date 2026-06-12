# Coding Agents — Initial Considerations

This document captures the baseline considerations for teams at TCS that adopt AI-powered coding agents, with a focus on **GitHub Copilot** and **Google Gemini Code Assist**. It is intended as a living reference and will be updated as the tooling and our internal guidance evolve.

---

## 1. What Are Coding Agents?

Coding agents are AI-assisted tools that can generate, explain, review, and refactor code directly inside a developer's IDE or CI pipeline. They differ from simple autocomplete in that they can reason across files, follow natural-language instructions, and take multi-step actions (e.g. create a PR, run tests, fix a failing check).

| Tool | Vendor | Primary interface |
|------|--------|-------------------|
| GitHub Copilot (incl. Copilot Coding Agent) | Microsoft / GitHub | VS Code, JetBrains, GitHub.com, CLI |
| Gemini Code Assist | Google | VS Code, JetBrains, Cloud Shell |

---

## 2. Data Privacy and Confidentiality

### 2.1 What data leaves the device?

Both tools send code context (open files, selected snippets, repository metadata) to vendor-hosted models. Before enabling either tool, teams **must** confirm:

- The subscription tier in use and its data-handling commitments (e.g. GitHub Copilot Business/Enterprise disables training on customer code by default).
- Whether any client data, PII, secrets, or regulated data (GDPR, PCI-DSS, HIPAA) could appear in prompts.
- That `.gitignore` and editor settings exclude sensitive configuration files from the context window.

### 2.2 Enterprise vs. individual licences

Use **enterprise or business licences** wherever possible. These provide:

- Contractual data-residency and retention terms.
- Telemetry opt-out controls.
- Audit logs for administrator review.

### 2.3 Secret and credential hygiene

Coding agents can inadvertently reproduce secrets from context. Enforce:

- Pre-commit secret scanning (e.g. `gitleaks`, `truffleHog`, GitHub secret scanning).
- Environment variables via a secrets manager (AWS Secrets Manager, HashiCorp Vault) — never hardcoded.
- A repository `.gitattributes` or `.copilotignore` / `.geminiignore` to exclude files that must not be sent as context.

---

## 3. Code Quality and Review

### 3.1 AI-generated code is a starting point, not a finished product

All code produced by a coding agent must go through the same review process as hand-written code:

- Pull request with at least one human reviewer.
- CI checks (lint, unit tests, security scans) must pass.
- Reviewers should explicitly look for logic errors, edge cases, and security issues that the model may have missed.

### 3.2 Test coverage

Agents are capable of generating test stubs, but may produce tests that pass trivially or do not cover failure paths. Require:

- Minimum branch/line coverage thresholds enforced in CI.
- Mutation testing (e.g. `pitest`, `stryker`) for critical business logic.

### 3.3 Dependency and licence risk

Auto-generated code may introduce:

- Unlicensed or GPL-licensed libraries that conflict with TCS/client licence policies.
- Packages with known CVEs at the time of suggestion.

Use SBOM generation and licence scanning (e.g. FOSSA, Snyk, `trivy`) in the CI pipeline for every PR.

---

## 4. Security Considerations

### 4.1 Common vulnerability patterns introduced by LLMs

| Pattern | Mitigation |
|---------|-----------|
| SQL / NoSQL injection | Parameterised queries enforced by linter rule or ORM policy |
| Hardcoded credentials | Secret scanning in pre-commit and CI |
| Insecure deserialization | Static analysis (CodeQL, Semgrep) |
| Outdated / vulnerable dependencies | `dependabot`, `renovate`, or equivalent |
| Excessive permissions in IAM / RBAC | Policy-as-code review (OPA, Kyverno) |

### 4.2 Agentic / multi-step actions

When using agentic modes (e.g. Copilot Coding Agent, Gemini's multi-file edit), additional safeguards are needed:

- Restrict agent access to repository scopes it genuinely needs (principle of least privilege).
- Require human approval before the agent opens a PR or triggers a deployment.
- Review all files touched by an agent action, not just the diff summary.
- Never allow an agent to merge its own pull request.

---

## 5. Governance and Acceptable Use

### 5.1 Licence and IP

- Generated code may be similar to training data. Avoid enabling Copilot's "public code" duplication filter being turned off.
- Gemini Code Assist Enterprise includes an indemnification commitment from Google; verify equivalent coverage for other subscription types.
- All generated code committed to a TCS or client repository is subject to the same IP ownership terms as any other code authored under that engagement.

### 5.2 Human accountability

AI tools do not reduce the accountability of the developer who commits the code. The committing engineer is responsible for correctness, security, and compliance of all changes, regardless of how they were generated.

### 5.3 Disclosure

When delivering to clients, disclose the use of AI coding tools as part of the project's toolchain documentation. This applies to:

- Architecture decision records (ADRs).
- SBOM / software transparency artefacts.
- Engagement contracts where relevant.

---

## 6. Tool-Specific Notes

### 6.1 GitHub Copilot

- **Copilot Chat** (in-IDE and on GitHub.com) can answer questions about codebases; ensure sensitive architecture information is not inadvertently exposed through chat prompts.
- **Copilot Coding Agent** operates as a GitHub App. Review the permissions granted to the installation (typically: read/write contents, read metadata, read pull requests). Restrict to repositories that require it.
- **Copilot for CLI** (`gh copilot suggest` / `explain`) operates on the local shell context; be cautious about pasting output from sensitive terminals.
- Audit logs are available in the GitHub organisation's audit log stream.

### 6.2 Google Gemini Code Assist

- Gemini Code Assist integrates with Google Cloud identity. Use **Cloud Identity** / **Workspace** federation to control who can activate the plugin.
- **Duet AI for Developers** (now Gemini Code Assist) respects Google Cloud Organisation Policies — use `constraints/cloudaicompanion.*` to restrict features at the org or project level.
- Context is scoped per file by default in the IDE plugin; the full-codebase indexing feature (Enterprise) requires explicit enablement and stores an index in a GCP project you control.
- Review **Data Access Transparency** logs in Cloud Audit Logs for any enterprise usage.

---

## 7. Getting Started Checklist

Before enabling a coding agent for a team or project:

- [ ] Confirm the appropriate licence tier (Business/Enterprise) is in place.
- [ ] Review and agree data handling commitments with the client or security team.
- [ ] Enable secret scanning and dependency scanning in the repository.
- [ ] Add a `.copilotignore` or equivalent to exclude sensitive files from agent context.
- [ ] Update the team's PR review checklist to include AI-generated code review guidance.
- [ ] Record the adoption in the project's ADR or toolchain documentation.
- [ ] Schedule a retrospective touchpoint 4–6 weeks after rollout to assess quality and security impact.

---

## 8. References

- [GitHub Copilot Trust Center](https://resources.github.com/copilot-trust-center/)
- [Google Gemini Code Assist documentation](https://cloud.google.com/gemini/docs/codeassist/overview)
- [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [NCSC Guidance: AI Coding Assistants](https://www.ncsc.gov.uk/)
- Internal: [GitOps Guide](./gitops-guide.md)
