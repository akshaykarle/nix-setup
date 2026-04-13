#!/usr/bin/env fish

# Read JSON input from stdin
set input (cat)

# Extract data from JSON
set cwd (echo $input | jq -r '.workspace.current_dir')
set model (echo $input | jq -r '.model.display_name')
set used_pct (echo $input | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
set total_cost (echo $input | jq -r '.cost.total_cost_usd // 0')
set duration_ms (echo $input | jq -r '.cost.total_duration_ms // 0')
set ctx_size (echo $input | jq -r '.context_window.context_window_size // 200000')
set input_tokens (echo $input | jq -r '.context_window.current_usage.input_tokens // 0')
set cache_create (echo $input | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
set cache_read (echo $input | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Color definitions
set normal '\033[0m'
set dim '\033[2m'
set cyan '\033[36m'
set green '\033[32m'
set blue '\033[34m'
set red '\033[31m'
set yellow '\033[33m'

# --- Line 1: [Model] dir | branch ---

# Shorten the path to just the folder name
set dir_name (basename "$cwd")

# Git branch
set git_info ""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1
    set -l branch (git -C "$cwd" -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
    if test -z "$branch"
        set branch (git -C "$cwd" -c core.useBuiltinFSMonitor=false rev-parse --short HEAD 2>/dev/null)
    end
    if test -n "$branch"
        if not git -C "$cwd" -c core.useBuiltinFSMonitor=false diff --quiet 2>/dev/null
            or not git -C "$cwd" -c core.useBuiltinFSMonitor=false diff --cached --quiet 2>/dev/null
            set git_info " | $branch*"
        else
            set git_info " | $branch"
        end
    end
end

set line1 (printf "$cyan")"[$model]"(printf "$normal")" $dir_name"
if test -n "$git_info"
    set line1 "$line1"(printf "$green")"$git_info"(printf "$normal")
end

# --- Line 2: progress_bar pct% (cache: X%) | $cost | duration ---

# Pick bar color based on context usage
if test "$used_pct" -ge 90
    set bar_color "$red"
else if test "$used_pct" -ge 70
    set bar_color "$yellow"
else
    set bar_color "$green"
end

# Build progress bar (10 chars wide)
set bar_width 10
set filled (math "floor($used_pct * $bar_width / 100)")
set empty (math "$bar_width - $filled")

set bar ""
set i 0
while test $i -lt $filled
    set bar "$bar""█"
    set i (math "$i + 1")
end
set i 0
while test $i -lt $empty
    set bar "$bar""░"
    set i (math "$i + 1")
end

# Calculate MCP/cache percentage of context
set cache_tokens (math "$cache_create + $cache_read")
set total_input (math "$input_tokens + $cache_tokens")
set cache_info ""
if test "$total_input" -gt 0
    set cache_pct (math "floor($cache_tokens * 100 / $total_input)")
    set cache_info (printf "$dim")" (mcp: $cache_pct%)"(printf "$normal")
end

# Format cost
set cost_fmt (printf '$%.2f' "$total_cost")

# Format duration
set duration_sec (math "floor($duration_ms / 1000)")
set mins (math "floor($duration_sec / 60)")
set secs (math "$duration_sec % 60")

set line2 (printf "$bar_color")"$bar"(printf "$normal")" $used_pct%$cache_info | "(printf "$yellow")"$cost_fmt"(printf "$normal")" | "$mins"m "$secs"s"

# Output both lines
echo -e "$line1"
echo -e "$line2"
