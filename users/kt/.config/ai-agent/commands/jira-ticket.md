---
description: Create a JIRA ticket with structured content
allowed-tools: AskUserQuestion, mcp__atlassian__createJiraIssue, mcp__atlassian__getJiraIssueTypeMetaWithFields, Bash(git:*), Bash(basename:*), Bash(dirname:*)
---

# Create JIRA Ticket

Create a JIRA ticket on the swissgeoplatform Atlassian instance.

Cloud ID: `b35bec68-c9fe-43d3-9cfb-f078fe699eb9`

## Step 1: Gather ticket information from the user

The user may have provided a description of what the ticket should be about: $ARGUMENTS

If the user provided enough context in $ARGUMENTS, extract the information below from it. Otherwise, ask the user for the missing details.

You need to determine:

1. **Summary** (ticket title) - a concise title
2. **Project** - which project this belongs to
3. **Issue type** - what kind of issue this is
4. **Component(s)** - at least one component must be set (see below)
5. **Acceptance criteria** - what should exist after the ticket is closed
6. **Notes** (optional) - additional context for implementation
7. **Technical todo** (optional) - steps for implementation

## Step 2: Determine project and component

### Auto-inference from working directory

Infer the project and component from the current working directory path. The directory structure follows the pattern: `.../<org>/<repo-name>/...`

- If the parent directory (two levels up from the repo root, i.e. the org-level directory) is **swissgeo** -> project is **GPS**
- If the parent directory is **geoadmin** -> project is **PB**

The **repo name** (the directory name of the git repo root) maps directly to a JIRA **component** name. Use it as the component.

If the inferred component matches a known component for that project (see lists below), use it automatically. If it doesn't match any known component, still use the repo name but inform the user.

If the working directory doesn't match either org, or is not inside a git repo, fall back to asking the user.

### Available projects

- **GPS** - Swissgeo (platform infrastructure and services)
- **PB** - PP BGDI (map viewer and geoadmin services)
- **GEOCATOD** - geocat / opendata.swiss
- **MGEO_SB** - Geocat development
- **METADATA_SB** - Metadaten Management

### Components by project

**GPS** components: .github, arch, argocd, authN/Z, aws-swisstopo-swissgeo, aws-swisstopo-swissgeo-builder, aws-swisstopo-swissgeo-dev, cms, doc-guidelines, infra-e2e-tests, infra-kubernetes, infra-kubernetes-internal, infra-performance-tests, infra-terraform, k8s-cluster, observability, service-alti, service-control, service-datajobs, service-drawings, service-icons, service-kml, service-oa-records, service-portal-state, service-print, service-qrcode, service-shortlink, web-control, web-portal

**PB** components: .github, 3d-tiles, aerialimages, argocd, automata, aws-swisstopo-bgdi, aws-swisstopo-bgdi-builder, aws-swisstopo-bgdi-business-metrics, aws-swisstopo-bgdi-dev, aws-swisstopo-bgdi-observability, bgdi-scripts, cognito, config-wms-mapfiles, deploy, doc-api-specs, doc-guidelines, doc-tech, elastic, github-geoadmin, infra-ansible-bgdi, infra-ansible-bgdi-collection, infra-ansible-bgdi-dev, infra-e2e-tests, infra-elastic-integrations, infra-gopass-bgdi, infra-kubernetes, infra-kubernetes-internal, infra-performance-tests, infra-terraform-bgdi, infra-vhost, lib-esrijson, lib-gatilegrid, lib-py-logging-utilities, metrics, mf-chsdi3, mf-geoadmin3, observability, service-alti, service-atom-inspire, service-auth, service-bod, service-control, service-feedback, service-icons, service-kml, service-print, service-print-headless, service-print3, service-proxy, service-qrcode, service-redirect, service-search-sphinx, service-search-wsgi, service-shortlink, service-stac, service-template, service-wms, service-wmts, stac-browser, terrain, tool-aws, tool-golang-bgdi, vectortiles, web-geoadmin-help, web-mapviewer

**GEOCATOD, MGEO_SB, METADATA_SB**: These projects have no predefined components. Ask the user for a component name.

At least one component MUST be set. If auto-inference fails or the user overrides, use AskUserQuestion.

## Step 3: Determine issue type

Available issue types (for software projects): Task, Story, Bug, New Feature, Improvement

If not clear from context, ask the user.

## Step 4: Build the description

Format the description in markdown with these H2 sections:

```
## Acceptance criteria

- [criterion 1]
- [criterion 2]
- ...

## Notes

[Additional context, if provided]

## Technical todo

- [ ] [step 1]
- [ ] [step 2]
- ...
```

Rules:
- **Acceptance criteria** is always included (required section)
- **Notes** is only included if there is additional context to provide
- **Technical todo** is only included if there are implementation steps to list
- Keep acceptance criteria as short bullet points describing the end state
- Technical todo items should be actionable steps

## Step 5: Show preview and confirm

Before creating, show the user a preview of the ticket:
- Project + Issue type
- Summary
- Component(s)
- Full description

Ask for confirmation before creating.

## Step 6: Create the ticket

Use `mcp__atlassian__createJiraIssue` with:
- cloudId: `b35bec68-c9fe-43d3-9cfb-f078fe699eb9`
- projectKey: the selected project key
- issueTypeName: the selected issue type
- summary: the ticket title
- description: the formatted description
- contentFormat: `markdown`
- additional_fields: `{"components": [{"name": "component-name"}]}`

After creation, show the user the ticket key and link.
