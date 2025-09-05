
#!/bin/bash

# === CONFIGURATION ===
TARGET_DIR="."                          # Scan current directory
AGE_DAYS=30                             # Files older than 30 days
SIZE_LIMIT="+50M"                       # Files larger than 50 MB
REPORT_FILE="file_report_$(date +%F_%H-%M-%S).txt"
INCLUDE_SUBDIRS=true                    # Set to false to scan only top-level

# === VALIDATION ===
if [ ! -d "$TARGET_DIR" ]; then
    echo "[ERROR] Directory does not exist: $TARGET_DIR"
    exit 1
fi

echo "[INFO] Scanning directory: $TARGET_DIR"
echo "[INFO] Finding files older than $AGE_DAYS days OR larger than $SIZE_LIMIT"
echo "[INFO] Report file: $REPORT_FILE"

echo "File Age & Size Report" > "$REPORT_FILE"
echo "Scan Time: $(date)" >> "$REPORT_FILE"
echo "Directory: $TARGET_DIR" >> "$REPORT_FILE"
echo "----------------------------------------------------" >> "$REPORT_FILE"

# === RUN FIND ===
if [ "$INCLUDE_SUBDIRS" = true ]; then
    find "$TARGET_DIR" -type f \( -mtime +$AGE_DAYS -o -size $SIZE_LIMIT \) -printf '%TY-%Tm-%Td %TH:%TM  %s bytes  %p\n' >> "$REPORT_FILE"
else
    find "$TARGET_DIR" -maxdepth 1 -type f \( -mtime +$AGE_DAYS -o -size $SIZE_LIMIT \) -printf '%TY-%Tm-%Td %TH:%TM  %s bytes  %p\n' >> "$REPORT_FILE"
fi

echo "[DONE] Report saved to: $REPORT_FILE"

