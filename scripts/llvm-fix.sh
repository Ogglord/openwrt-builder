#!/usr/bin/env bash
# OpenWrt Build Environment Fix Script
# Applies automatic adjustments to use LLVM toolchain on Host

# Strict error handling
set -euo pipefail

# Logging and verbosity control
VERBOSE=true
LOG_FILE="/tmp/openwrt-fixes.log"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quiet)
            VERBOSE=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Always log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Conditionally print to console based on verbosity
    if [[ "$VERBOSE" == "true" ]] || [[ "$level" == "ERROR" ]]; then
        echo "[$level] $message" >&2
    fi
}

# Cleanup function to ensure proper directory restoration
cleanup() {
    local exit_code=$?
    
    # Attempt to return to original directory if we changed directories
    if [ -n "${ORIGINAL_DIR:-}" ]; then
        cd "$ORIGINAL_DIR"
    fi
    
    log "INFO" "Script exiting with status $exit_code"
    exit $exit_code
}

# Trap signals to ensure cleanup
trap cleanup EXIT INT TERM

# Store original directory
ORIGINAL_DIR=$(pwd)

# Main script
log "INFO" "========================================================="
log "INFO" "Applying automatic adjustments for OpenWrt environment..."
log "INFO" "========================================================="

# Check for broken symlinks in staging directory
check_staging_symlinks() {
    local staging_dir="./staging_dir/host/bin"
    
    if [ ! -d "$staging_dir" ]; then
        log "WARN" "Staging directory does not exist: $staging_dir"
        return 0
    fi
    
    cd "$staging_dir"
    
    # Find and report broken symlinks
    local broken_links
    if ! broken_links=$(find . -xtype l -print); then
        log "ERROR" "Failed to search for symlinks"
        return 1
    fi
    
    if [ -n "$broken_links" ]; then
        log "ERROR" "Broken symlinks detected:"
        echo "$broken_links" | while read -r link; do
            log "ERROR" "Broken symlink: $link"
        done
        return 1
    else
        log "INFO" "No broken symlinks found in staging directory"
    fi
}

# Configure LLVM toolchain settings
configure_llvm_toolchain() {
    # Validate LLVM_HOST_PATH
    if [ -z "${LLVM_HOST_PATH:-}" ]; then
        log "ERROR" "LLVM_HOST_PATH is not set or is empty"
        return 1
    fi
    
    local config_file="$ORIGINAL_DIR/.config"
    if [ ! -e "$config_file" ]; then
        log "WARN" "Configuration file missing: $config_file"
        return 0
    fi
    
    # Unset BPF toolchain build flag
    if grep -q "CONFIG_BPF_TOOLCHAIN_BUILD_LLVM=y" "$config_file"; then
        log "INFO" "Unsetting CONFIG_BPF_TOOLCHAIN_BUILD_LLVM"
        sed -i -e 's|CONFIG_BPF_TOOLCHAIN_BUILD_LLVM=y|# CONFIG_BPF_TOOLCHAIN_BUILD_LLVM is not set|' "$config_file"
    fi
    
    # Handle LLVM host path configuration
    if grep -q "CONFIG_BPF_TOOLCHAIN_HOST_PATH" "$config_file"; then
        log "INFO" "Updating existing LLVM host path"
        sed -i -e 's|CONFIG_BPF_TOOLCHAIN_HOST_PATH=.*|CONFIG_BPF_TOOLCHAIN_HOST_PATH="'"$LLVM_HOST_PATH"'"|' "$config_file"
    else
        log "INFO" "Adding LLVM host path configuration"
        {
            echo 'CONFIG_BPF_TOOLCHAIN_HOST_PATH="'"$LLVM_HOST_PATH"'"'
            echo 'CONFIG_BPF_TOOLCHAIN_HOST=y'
            echo 'CONFIG_USE_LLVM_HOST=y'
        } >> "$config_file"
    fi
}

# Execute main functions
main() {
    check_staging_symlinks
    configure_llvm_toolchain
    
    log "INFO" "OpenWrt fixes applied successfully"
}

# Run main script
main