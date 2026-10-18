---
description: Review a GitHub PR or branch and write findings to REVIEW_<PR>_<BRANCH>.md
allowed-tools: AskUserQuestion, Read, Grep, Glob, Write, Bash(git:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr list:*), Bash(gh repo view:*), Bash(sha256sum:*), Bash(printf:*), Bash(basename:*)
---

# Review PR / Branch

Review the changes of a GitHub pull request (or a plain branch) and write all findings to a markdown file. Do NOT post anything to GitHub.

## Step 1: Resolve the review target

The user may have provided a target: $ARGUMENTS

Accepted forms:
- PR number (e.g. `123`)
- PR URL (e.g. `https://github.com/<owner>/<repo>/pull/123`)
- Branch name (e.g. `feat/my-change`)
- Empty -> use the currently checked-out branch

Resolve it to a PR:

```
gh pr view <target> --json number,url,title,body,headRefName,headRefOid,baseRefName,headRepositoryOwner,headRepository
```

(With an empty target, run `gh pr view` without an argument to get the PR of the current branch.)

Also get the base repository:

```
gh repo view --json nameWithOwner,defaultBranchRef
```

If no PR exists for the branch, review the branch against the default branch instead (use `git merge-base`). In that case there is no PR number; use `nopr` in the filename and only use blob permalinks (see Step 4). Inform the user.

If the target is ambiguous or cannot be resolved, ask the user with AskUserQuestion.

Record:
- `PR` - PR number (or `nopr`)
- `BRANCH` - head branch name
- `HEAD_SHA` - head commit SHA (`headRefOid`, or `git rev-parse <branch>` for branches)
- `OWNER/REPO` - repository the PR targets

## Step 2: Get the changes

- PR: `gh pr diff <PR>` and `gh pr diff <PR> --name-only`
- Branch only: `git diff <base>...<branch>` and `git diff --name-only <base>...<branch>`

Make sure the head commit is available locally so you can read full files at the PR state (not the working tree):

```
git fetch origin pull/<PR>/head    # for PRs (also works for forks)
git fetch origin <BRANCH>          # for branches
```

Read changed files with `git show <HEAD_SHA>:<path>` when the PR is not checked out. Only use Read on the working tree if `git rev-parse HEAD` equals `HEAD_SHA`.

Read the PR title and description to understand the intent. Look at surrounding code (callers, related modules, tests, project conventions) where needed to judge the change - don't review the diff in isolation.

## Step 3: Review

Look for, in order of importance:

1. **Correctness** - logic errors, broken edge cases, wrong assumptions, regressions
2. **Security** - injection, secrets in code, missing authz/validation, unsafe defaults
3. **Reliability** - error handling, resource leaks, race conditions, failure modes
4. **Tests** - missing or insufficient tests for new behavior
5. **Maintainability** - unclear code, duplication, inconsistency with project conventions
6. **Performance** - unnecessary work, N+1 patterns, inefficient algorithms
7. **Docs** - outdated README/docs, missing comments on non-obvious logic

Rules:
- Only report findings in code changed or directly affected by this PR
- Verify each finding against the actual code before reporting; drop anything you cannot substantiate
- Be concrete: say what is wrong, why it matters, and how to fix it
- Mark uncertain findings as such instead of overstating them
- Don't pad the review with nitpicks; group trivial style remarks into one finding if at all

Assign each finding a severity:
- **Critical** - must fix before merge (bugs, security issues, data loss)
- **Major** - should fix before merge
- **Minor** - improvement, can be addressed later
- **Nit** - cosmetic / optional

## Step 4: Build links for each finding

Every finding needs: file path, line (or line range), and a link.

Line numbers refer to the file **at `HEAD_SHA`** (the new version). For findings on deleted code, use the line number in the base version and mark it as such.

### PR diff link (preferred, when a PR exists and the line is part of the diff)

GitHub anchors files in the PR "Files changed" tab by the SHA-256 hex of the file path:

```
printf '%s' '<path>' | sha256sum
```

Link format:

```
https://github.com/<OWNER>/<REPO>/pull/<PR>/files#diff-<sha256>R<line>
```

- `R<line>` = line in the new file, `L<line>` = line in the old file (deleted lines)
- Ranges: `R<start>-R<end>`

### Blob permalink (always include)

Diff anchors only work for lines inside a diff hunk, so always add a permalink pinned to the head commit:

```
https://github.com/<OWNER>/<REPO>/blob/<HEAD_SHA>/<path>#L<line>
https://github.com/<OWNER>/<REPO>/blob/<HEAD_SHA>/<path>#L<start>-L<end>
```

For PRs from forks, use the fork's owner/repo (`headRepositoryOwner` / `headRepository`) for blob permalinks, and the base repo for PR diff links.

## Step 5: Write the review file

Filename: `REVIEW_<PR>_<BRANCH>.md` in the repository root. Replace `/` and other characters that are not filename-safe in the branch name with `-` (e.g. `feat/foo` -> `REVIEW_123_feat-foo.md`). If the file already exists, ask the user whether to overwrite it.

Structure:

```
# Review: <PR title> (#<PR>)

- **PR:** <PR url>
- **Branch:** `<BRANCH>` -> `<base branch>`
- **Head commit:** `<HEAD_SHA>`
- **Reviewed:** <YYYY-MM-DD>

## Summary

<2-5 sentences: what the PR does, overall assessment, the most important issues.>

| Severity | Count |
|----------|-------|
| Critical | n |
| Major    | n |
| Minor    | n |
| Nit      | n |

## Findings

### 1. [Critical] <short title>

- **File:** `<path>`
- **Line:** <line or start-end>
- **PR link:** <PR diff link>
- **Permalink:** <blob permalink>

<What is wrong and why it matters.>

<Suggested fix, with a code snippet if helpful.>

### 2. [Major] <short title>

...

## Open questions

- <Things that are unclear and should be clarified with the author, if any.>
```

Rules:
- Order findings by severity (Critical first), then by file
- Number findings sequentially so they can be referenced
- Omit "Open questions" if there are none
- If there are no findings, say so in the summary and leave the Findings section with "No findings."

## Step 6: Report

Tell the user:
- The path of the review file
- The severity counts
- The titles of Critical/Major findings

Remind the user that the review file is untracked and should not be committed.
