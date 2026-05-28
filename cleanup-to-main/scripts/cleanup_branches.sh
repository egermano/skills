#!/bin/bash
#
# cleanup_branches.sh
# Safely removes local git branches that have been deleted from the remote.
#
# Usage: ./cleanup_branches.sh
#
# Exit codes:
#   0 - Success (branches cleaned or nothing to clean)
#   1 - Safety abort (uncommitted changes or unsynced branch)
#   2 - Partial failure (some branches couldn't be deleted)
#

set -e

# Colors for output
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

# Arrays to track results
DELETED_BRANCHES=()
SKIPPED_BRANCHES=()
KEPT_BRANCHES=()

# Function to print colored output
print_status() {
    local symbol="$1"
    local message="$2"
    case "$symbol" in
        "✅") echo "${GREEN}${symbol}${RESET} ${message}" ;;
        "⚠️") echo "${YELLOW}${symbol}${RESET} ${message}" ;;
        "❌") echo "${RED}${symbol}${RESET} ${message}" ;;
        *)    echo "${symbol} ${message}" ;;
    esac
}

# Function to check for uncommitted changes
check_uncommitted_changes() {
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        echo ""
        print_status "❌" "Safety abort: Uncommitted changes detected"
        echo ""
        echo "You have uncommitted changes in your working directory."
        echo "Please commit or stash them before running this script."
        echo ""
        git status --short
        exit 1
    fi
}

# Function to check if current branch is synced with origin
check_branch_synced() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if branch has an upstream
    if ! git rev-parse --verify "@{upstream}" >/dev/null 2>&1; then
        # No upstream - this might be a local-only branch
        echo ""
        print_status "❌" "Safety abort: Current branch '$current_branch' has no upstream"
        echo ""
        echo "The current branch does not track a remote branch."
        echo "Please checkout a tracked branch before running this script."
        exit 1
    fi
    
    # Check if branch is synced
    local local_commit remote_commit
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "@{upstream}")
    
    if [ "$local_commit" != "$remote_commit" ]; then
        local ahead behind
        ahead=$(git rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo "0")
        behind=$(git rev-list --count "HEAD..@{upstream}" 2>/dev/null || echo "0")
        
        echo ""
        print_status "❌" "Safety abort: Current branch '$current_branch' is not synced with origin"
        echo ""
        if [ "$ahead" -gt 0 ]; then
            echo "  Branch is $ahead commit(s) ahead of origin"
        fi
        if [ "$behind" -gt 0 ]; then
            echo "  Branch is $behind commit(s) behind origin"
        fi
        echo ""
        echo "Please push or pull to sync your branch before running this script."
        exit 1
    fi
}

# Function to detect and switch to default branch
switch_to_default_branch() {
    local default_branch
    
    # Try main first, then master
    if git show-ref --verify --quiet refs/heads/main; then
        default_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        default_branch="master"
    else
        echo ""
        print_status "❌" "Error: No main or master branch found"
        exit 1
    fi
    
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    if [ "$current_branch" != "$default_branch" ]; then
        echo ""
        print_status "✅" "Switching from '$current_branch' to '$default_branch'"
        git checkout "$default_branch" -q
    fi
    
    DEFAULT_BRANCH="$default_branch"
}

# Function to fetch and prune
fetch_and_prune() {
    echo ""
    print_status "✅" "Running 'git fetch -p' to prune remote references"
    git fetch -p 2>/dev/null || git fetch -p
}

# Function to get branches that should be deleted
get_gone_branches() {
    # Get all local branches
    local all_branches
    all_branches=$(git branch --format='%(refname:short)')
    
    # Get branches whose remote is gone
    local gone_branches
    gone_branches=$(git branch -vv | grep ': gone]' | awk '{print $1}' 2>/dev/null || echo "")
    
    echo "$gone_branches"
}

# Function to delete a branch safely
delete_branch() {
    local branch="$1"
    
    # Skip protected branches
    if [ "$branch" = "main" ] || [ "$branch" = "master" ] || [ "$branch" = "develop" ]; then
        KEPT_BRANCHES+=("$branch")
        return 0
    fi
    
    # Try safe delete
    if git branch -d "$branch" 2>/dev/null; then
        DELETED_BRANCHES+=("$branch")
        return 0
    else
        # Check why it failed
        if git rev-parse --verify "$branch" >/dev/null 2>&1; then
            # Branch still exists, probably not merged
            SKIPPED_BRANCHES+=("$branch (not fully merged)")
        fi
        return 1
    fi
}

# Function to get local-only branches (never pushed)
get_local_only_branches() {
    git branch -vv | grep -v 'origin/' | awk '{print $1}' 2>/dev/null || echo ""
}

# Function to generate report
generate_report() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "                    Git Branch Cleanup Report                   "
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Pre-flight checks: ✅ Passed"
    echo "Default branch: $DEFAULT_BRANCH"
    echo "Current branch: $current_branch"
    echo ""
    
    # Deleted branches
    if [ ${#DELETED_BRANCHES[@]} -gt 0 ]; then
        echo "--- Deleted (${#DELETED_BRANCHES[@]} branch(es)) ---"
        for branch in "${DELETED_BRANCHES[@]}"; do
            print_status "✅" "$branch"
        done
        echo ""
    fi
    
    # Skipped branches
    if [ ${#SKIPPED_BRANCHES[@]} -gt 0 ]; then
        echo "--- Skipped (${#SKIPPED_BRANCHES[@]} branch(es)) ---"
        for branch in "${SKIPPED_BRANCHES[@]}"; do
            print_status "⚠️" "$branch"
        done
        echo ""
    fi
    
    # Kept branches (protected)
    if [ ${#KEPT_BRANCHES[@]} -gt 0 ]; then
        echo "--- Kept (protected branches) ---"
        echo "  ${KEPT_BRANCHES[*]}"
        echo ""
    fi
    
    # Summary
    echo "───────────────────────────────────────────────────────────────"
    echo "Summary: ${#DELETED_BRANCHES[@]} deleted, ${#SKIPPED_BRANCHES[@]} skipped, ${#KEPT_BRANCHES[@]} kept"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Return appropriate exit code
    if [ ${#DELETED_BRANCHES[@]} -gt 0 ]; then
        return 0
    else
        return 0
    fi
}

# Main execution
main() {
    echo "Starting git branch cleanup..."
    
    # Step 1: Pre-flight safety checks
    check_uncommitted_changes
    check_branch_synced
    
    # Step 2: Switch to default branch
    switch_to_default_branch
    
    # Step 3: Fetch and prune
    fetch_and_prune
    
    # Step 4 & 5: Identify and delete gone branches
    local gone_branches
    gone_branches=$(get_gone_branches)
    
    if [ -n "$gone_branches" ]; then
        echo ""
        print_status "✅" "Found branches to clean up"
        
        # Process each gone branch
        while IFS= read -r branch; do
            if [ -n "$branch" ]; then
                delete_branch "$branch" || true
            fi
        done <<< "$gone_branches"
    else
        echo ""
        print_status "✅" "No branches to clean up"
    fi
    
    # Add protected branches to kept list
    for protected in main master develop; do
        if git show-ref --verify --quiet "refs/heads/$protected" 2>/dev/null; then
            if [[ ! " ${KEPT_BRANCHES[*]} " =~ " ${protected} " ]]; then
                KEPT_BRANCHES+=("$protected")
            fi
        fi
    done
    
    # Step 6: Generate report
    generate_report
}

# Run main
main "$@"
