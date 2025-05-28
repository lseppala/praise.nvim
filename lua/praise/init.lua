local M = {}

-- Extract owner and repo from git remote URL
local function get_repo_info()
  local handle = io.popen("git remote get-url origin 2>/dev/null")
  if not handle then
    return nil, nil
  end

  local url = handle:read("*a")
  handle:close()

  if not url or url == "" then
    return nil, nil
  end

    -- Trim whitespace first
  url = url:gsub("^%s+", ""):gsub("%s+$", "")

  -- Match GitHub URLs (both HTTPS and SSH)
  -- https://github.com/owner/repo.git
  -- git@github.com:owner/repo.git
  local owner, repo = url:match("github%.com[:/]([^/:]+)/(.+)")

  if not owner or not repo then
    return nil, nil
  end

  return owner, repo
end

-- Get commit SHA for current line using git blame
local function get_commit_sha()
  local line = vim.fn.line('.')
  local file = vim.fn.expand('%:p')

  local cmd = string.format("git blame -L %d,%d --porcelain %s 2>/dev/null | head -n 1",
    line, line, vim.fn.shellescape(file))

  local handle = io.popen(cmd)
  if not handle then
    return nil
  end

  local output = handle:read("*a")
  handle:close()

  -- First line of porcelain output is the commit SHA
  local sha = output:match("^([a-f0-9]+)")

  -- Check if it's the uncommitted changes SHA
  if sha == "0000000000000000000000000000000000000000" then
    return nil
  end

  return sha
end

-- Execute GraphQL query using gh CLI
local function execute_graphql_query(owner, repo, sha)
  local query = [[
query FindPullRequestForCommit($owner: String!, $repo: String!, $sha: GitObjectID!) {
  repository(owner: $owner, name: $repo) {
    object(oid: $sha) {
      ... on Commit {
        associatedPullRequests(first: 1) {
          nodes {
            number
            title
            url
            state
            author {
              login
            }
            createdAt
            mergedAt
          }
        }
      }
    }
  }
}
]]

  -- Execute gh api graphql command
  local cmd = string.format("gh api graphql -F 'owner=%s' -F 'repo=%s' -F 'sha=%s' -f query='%s' -f variables='%s' 2>&1",
    owner, repo, sha, query:gsub("'", "'\"'\"'"), variables)

  local handle = io.popen(cmd)
  if not handle then
    return nil
  end

  local output = handle:read("*a")
  local success = handle:close()

  if not success then
    return nil
  end

  return vim.fn.json_decode(output)
end

-- Open URL in browser (macOS)
local function open_url(url)
  -- Copy URL to clipboard
  vim.fn.system(string.format("echo %s | pbcopy", vim.fn.shellescape(url)))

  -- Open in browser
  vim.fn.system(string.format("open %s", vim.fn.shellescape(url)))
end

-- Main function to find and open PR
function M.find_pr()
  -- Get repository info
  local owner, repo = get_repo_info()
  if not owner or not repo then
    vim.notify("Could not determine repository owner and name from git origin", vim.log.levels.ERROR)
    return
  end

  -- Get commit SHA for current line
  local sha = get_commit_sha()
  if not sha then
    vim.notify("Could not get commit SHA for current line (uncommitted changes?)", vim.log.levels.ERROR)
    return
  end

  vim.notify(string.format("Finding PR for commit %s in %s/%s...", sha:sub(1, 7), owner, repo))

  -- Execute GraphQL query
  local result = execute_graphql_query(owner, repo, sha)
  if not result then
    vim.notify("Failed to execute GraphQL query. Make sure 'gh' CLI is installed and authenticated.", vim.log.levels.ERROR)
    return
  end

  -- Check for errors in response
  if result.errors then
    vim.notify("GraphQL query error: " .. vim.inspect(result.errors), vim.log.levels.ERROR)
    return
  end

  -- Extract PR info
  local pr_nodes = vim.tbl_get(result, "data", "repository", "object", "associatedPullRequests", "nodes")

  if not pr_nodes or #pr_nodes == 0 then
    vim.notify(string.format("No pull request found for commit %s", sha:sub(1, 7)), vim.log.levels.WARN)
    return
  end

  local pr = pr_nodes[1]

  -- Show PR info and open in browser
  vim.notify(string.format("Found PR #%d: %s", pr.number, pr.title))
  open_url(pr.url)
end

-- Setup function to create commands and keymaps
function M.setup(opts)
  opts = opts or {}

  -- Create command
  vim.api.nvim_create_user_command('Praise', function()
    M.find_pr()
  end, { desc = 'Find and open PR the PR that introduced or changed code on the current line' })

  -- Optional: Set up a keymap if provided in opts
  if opts.keymap then
    vim.keymap.set('n', opts.keymap, M.find_pr, {
      desc = 'Find and open PR the PR that introduced or changed code on the current line',
      silent = true
    })
  end
end

return M
