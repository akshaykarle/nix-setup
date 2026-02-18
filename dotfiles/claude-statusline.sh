#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
username=$(whoami)
hostname=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Color definitions (dimmed for status line)
normal='\033[0m'
cyan='\033[0;36m'
green='\033[0;32m'
blue='\033[0;34m'
red='\033[0;31m'
yellow='\033[0;33m'

# Get git information (skip optional locks for safety)
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        # Detached HEAD state
        branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false rev-parse --short HEAD 2>/dev/null)
    fi

    if [ -n "$branch" ]; then
        # Check for changes
        if ! git -C "$cwd" -c core.useBuiltinFSMonitor=false diff --quiet 2>/dev/null || \
           ! git -C "$cwd" -c core.useBuiltinFSMonitor=false diff --cached --quiet 2>/dev/null; then
            git_info=" (${branch}*)"
        else
            git_info=" (${branch})"
        fi
    fi
fi

# Shorten the path (similar to prompt_pwd in fish)
short_cwd="$cwd"
if [[ "$cwd" == "$HOME"* ]]; then
    short_cwd="~${cwd#$HOME}"
fi

# Build the prompt string
prompt_login="${username}@${hostname}"
prompt=""

# Add login info
prompt="${prompt}${prompt_login} "

# Add current directory (in cyan/blue color)
prompt="${prompt}$(printf "${cyan}")${short_cwd}$(printf "${normal}")"

# Add git info (in green)
if [ -n "$git_info" ]; then
    prompt="${prompt}$(printf "${green}")${git_info}$(printf "${normal}")"
fi

# Add context remaining if available
if [ -n "$context_remaining" ]; then
    # Color based on remaining percentage
    context_color="$green"
    if (( $(echo "$context_remaining < 30" | bc -l 2>/dev/null || echo 0) )); then
        context_color="$red"
    elif (( $(echo "$context_remaining < 60" | bc -l 2>/dev/null || echo 0) )); then
        context_color="$yellow"
    fi
    prompt="${prompt} $(printf "${context_color}")[ctx: ${context_remaining}%]$(printf "${normal}")"
fi

# Add model name
prompt="${prompt} $(printf "${blue}")[${model}]$(printf "${normal}")"

# Add prompt suffix
prompt="${prompt} >"

# Output the final prompt
echo -e "$prompt"
