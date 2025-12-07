# gh CLI Minimal Output Guidelines

**CRITICAL: Use `--json` with specific fields and `--jq` to reduce context.**

## Required Patterns

| Pattern         | Purpose                  | Example                      |
| --------------- | ------------------------ | ---------------------------- |
| `--json FIELDS` | Fetch only needed fields | `--json number,title,author` |
| `--jq EXPR`     | Transform/filter output  | `--jq '.[].name'`            |
| `--limit N`     | Control result count     | `--limit 20`                 |
| `--state STATE` | Filter by state          | `--state open`               |

## Common Commands

### Pull Requests

```bash
# List open PRs - minimal
gh pr list --repo OWNER/REPO --state open --limit 20 \
  --json number,title,author,headRefName \
  --jq '.[] | "\(.number): \(.title) (@\(.author.login))"'

# Check PR status
gh pr checks PR_NUMBER --repo OWNER/REPO

# View PR details
gh pr view PR_NUMBER --repo OWNER/REPO \
  --json title,state,statusCheckRollup \
  --jq '{title, state, checks: [.statusCheckRollup[] | {name, conclusion}]}'
```

### Repositories

```bash
# List org repos
gh repo list ORG --limit 50 --json nameWithOwner --jq '.[].nameWithOwner'

# Get default branch
gh repo view OWNER/REPO --json defaultBranchRef --jq '.defaultBranchRef.name'
```

### Branches

```bash
# List branches (names only)
gh api repos/OWNER/REPO/branches --paginate --jq '.[].name'
```

### Workflow Runs

```bash
# List runs - minimal
gh run list --repo OWNER/REPO --limit 5 \
  --json databaseId,status,conclusion,headBranch \
  --jq '.[] | "\(.databaseId): \(.status)/\(.conclusion) (\(.headBranch))"'

# Check latest run status
gh run list --repo OWNER/REPO --limit 1 \
  --json status,conclusion --jq '.[0] | "\(.status)/\(.conclusion)"'
```

### Search

```bash
# Search code - minimal
gh search code "QUERY" --limit 20 \
  --json path,repository --jq '.[] | "\(.repository.nameWithOwner):\(.path)"'

# Search repos
gh search repos "QUERY" --limit 20 \
  --json nameWithOwner --jq '.[].nameWithOwner'
```

## Anti-Patterns (Never Do)

- `gh pr list` without `--json` - returns verbose default format
- `gh repo list` without `--json` - returns full repo details
- `--limit 100` - too many results, use 20-50 max
- Omitting `--state` on PR/issue lists - fetches all states
- Using `gh api` without `--jq` - returns full API response

## Field Reference

### PR Fields (commonly needed)

- `number` - PR number
- `title` - PR title
- `author` - Author object (use `.author.login`)
- `headRefName` - Source branch name
- `state` - open/closed/merged
- `statusCheckRollup` - CI status array

### Repo Fields (commonly needed)

- `nameWithOwner` - Full repo name (owner/repo)
- `defaultBranchRef` - Default branch object
- `description` - Repo description
