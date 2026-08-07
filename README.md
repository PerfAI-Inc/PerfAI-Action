# Perfai Security — GitHub Action

Run an autonomous [**Perfai Security**](https://docs.perfai.ai) scan from your CI/CD
pipeline. Perfai maps your application's workflows, API endpoints, and user roles, then
systematically tests them for **broken access control** — BOLA, cross-tenant and
cross-role access, RBAC gaps, privilege escalation, SSRF, token-handling flaws, and more.

Learn more at **[docs.perfai.ai](https://docs.perfai.ai)** · [perfai.ai](https://perfai.ai)

## What it does

On each run, this composite Action:

1. **Authenticates** to the Perfai API with your account credentials.
2. **Triggers a security scan** against your app catalog — a `sensitive_data` scan covering
   ~30 access-control and data-exposure checks (Authorization missing/invalid/expired, RBAC,
   BOLA / cross-tenant / cross-role, SSRF, privilege escalation, token signature and
   revocation, broken logout, data-access anomalies, and more).
3. **Waits for completion** (optional) and prints a summary to the Actions log: total,
   critical, high, and medium/low issue counts, plus estimated bug-bounty savings.

## Usage

```yaml
name: Perfai Security Scan
on:
  workflow_dispatch:

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Run Perfai Security
        uses: PerfAI-Inc/Perfai-Security@v1.5
        with:
          username: ${{ secrets.PERFAI_USERNAME }}
          password: ${{ secrets.PERFAI_PASSWORD }}
          orgId: ${{ secrets.PERFAI_ORG_ID }}
          catalogId: <your-app-catalog-id>
          appId: <your-app-id>
          wait-for-completion: "true"
```

> **Keep credentials in secrets.** Store `username`, `password`, and `orgId` as
> [encrypted GitHub secrets](https://docs.github.com/actions/security-guides/using-secrets-in-github-actions)
> — never inline them in the workflow. The Action masks the access token it obtains so it
> never appears in the logs.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `username` | yes | — | Perfai account email. Provide via a secret. |
| `password` | yes | — | Perfai account password. Provide via a secret. |
| `orgId` | yes | — | Your Perfai organization ID (sent as the `x-org-id` header). |
| `catalogId` | yes | — | ID of the app catalog to scan. |
| `appId` | yes | — | Your Perfai app ID. |
| `wait-for-completion` | no | `"true"` | Block until the scan finishes and print the issue summary. Set to `"false"` to trigger the scan and return immediately. |
| `fail-on-new-leaks` | no | `"false"` | Reserved. Not yet enforced — the build currently fails on scan errors (see **Build status**), not on the number or severity of findings. |

Find your `orgId`, `catalogId`, and `appId` in the Perfai dashboard at
[cloud.perfai.ai](https://cloud.perfai.ai). See the [documentation](https://docs.perfai.ai)
for details.

## Build status

The Action gates your pipeline by **exit code**:

- **Fails the build** (non-zero exit) on authentication failure, a scan that cannot be
  triggered, a `FAILED` scan, an unexpected terminal status, or repeated invalid API
  responses.
- **Passes** on a completed scan — or, with `wait-for-completion: "false"`, as soon as the
  scan is triggered.

It does **not** currently fail based on the number or severity of findings; those are
reported to the Actions log for review.

## Requirements

Runs on a Linux runner (e.g. `ubuntu-latest`) with `curl` and `jq` available (both are
present by default on GitHub-hosted runners).

---

[Terms of Use](https://www.perfai.ai/terms-of-use) · [Privacy Policy](https://www.perfai.ai/privacy-policy)
