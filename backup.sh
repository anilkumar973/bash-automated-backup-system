#!/bin/bash
# ==========================================
# Automated Backup System
# ==========================================

CONFIG_FILE="./backup.config"
LOG_FILE="./backup.log"
LOCK_FILE="/tmp/backup.lock"

# ------------------------------------------
# Load Config File
# ------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found ($CONFIG_FILE)"
    exit 1
fi

source "$CONFIG_FILE"

# ------------------------------------------
# Logging Function
# ------------------------------------------
log() {
    local LEVEL=$1
    local MESSAGE=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $LEVEL: $MESSAGE" | tee -a "$LOG_FILE"
}

# ------------------------------------------
# Prevent Multiple Runs
# ------------------------------------------
if [ -f "$LOCK_FILE" ]; then
    log "ERROR" "Backup already running! Lock file exists."
    exit 1
fi
touch "$LOCK_FILE"

# ------------------------------------------
# Handle Exit and Cleanup
# ------------------------------------------
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# ------------------------------------------
# Handle Dry Run Mode
# ------------------------------------------
if [[ "$1" == "--dry-run" ]]; then
    SOURCE_DIR="$2"
    log "INFO" "Dry run mode enabled"
    log "INFO" "Would backup folder: $SOURCE_DIR"
    log "INFO" "Would save backup to: $BACKUP_DESTINATION"
    log "INFO" "Would skip patterns: $EXCLUDE_PATTERNS"
    exit 0
fi

# ------------------------------------------
# Validate Source Folder
# ------------------------------------------
SOURCE_DIR="$1"
if [ -z "$SOURCE_DIR" ]; then
    log "ERROR" "No source directory specified!"
    echo "Usage: ./backup.sh <source_folder>"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR" "Source folder not found: $SOURCE_DIR"
    exit 1
fi

# ------------------------------------------
# Create Backup Destination
# ------------------------------------------
mkdir -p "$BACKUP_DESTINATION"

# ------------------------------------------
# Timestamp and Backup Name
# ------------------------------------------
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_FILE="backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_FILE"
CHECKSUM_FILE="$BACKUP_PATH.md5"

# ------------------------------------------
# Build Exclude Arguments
# ------------------------------------------
IFS=',' read -r -a EXCLUDES <<< "$EXCLUDE_PATTERNS"
EXCLUDE_ARGS=()
for pattern in "${EXCLUDES[@]}"; do
    EXCLUDE_ARGS+=("--exclude=$pattern")
done

# ------------------------------------------
# Create Backup
# ------------------------------------------
log "INFO" "Starting backup of $SOURCE_DIR"
tar -czf "$BACKUP_PATH" "${EXCLUDE_ARGS[@]}" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>>"$LOG_FILE"

if [ $? -ne 0 ]; then
    log "ERROR" "Failed to create backup archive."
    exit 1
fi
log "SUCCESS" "Backup created: $BACKUP_PATH"

# ------------------------------------------
# Generate and Verify Checksum
# ------------------------------------------
md5sum "$BACKUP_PATH" > "$CHECKSUM_FILE"
if [ $? -ne 0 ]; then
    log "ERROR" "Checksum generation failed."
    exit 1
fi
log "INFO" "Checksum saved: $CHECKSUM_FILE"

# Verify Checksum
md5sum -c "$CHECKSUM_FILE" &>/dev/null
if [ $? -eq 0 ]; then
    log "SUCCESS" "Checksum verified successfully."
else
    log "ERROR" "Checksum verification failed!"
    exit 1
fi

# ------------------------------------------
# Backup Rotation: Delete Old Backups
# ------------------------------------------
log "INFO" "Applying backup rotation policy..."

# Keep only the configured number of backups
cd "$BACKUP_DESTINATION"
ALL_BACKUPS=($(ls -1tr backup-*.tar.gz 2>/dev/null))
TOTAL=${#ALL_BACKUPS[@]}
KEEP=$((DAILY_KEEP + WEEKLY_KEEP + MONTHLY_KEEP))

if (( TOTAL > KEEP )); then
    DELETE_COUNT=$((TOTAL - KEEP))
    for ((i=0; i<DELETE_COUNT; i++)); do
        OLD_BACKUP="${ALL_BACKUPS[$i]}"
        rm -f "$OLD_BACKUP" "$OLD_BACKUP.md5"
        log "INFO" "Deleted old backup: $OLD_BACKUP"
    done
else
    log "INFO" "No old backups to delete."
fi

# ------------------------------------------
# Verify Backup Extraction Test
# ------------------------------------------
log "INFO" "Testing backup integrity..."
tar -tzf "$BACKUP_PATH" >/dev/null 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    log "SUCCESS" "Backup verified and ready!"
else
    log "ERROR" "Backup archive may be corrupted!"
    exit 1
fi

# ------------------------------------------
# Finish
# ------------------------------------------
log "SUCCESS" "Backup completed successfully for $SOURCE_DIR"
exit 0



