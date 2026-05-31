#!/bin/sh
set -u

REPO_ROOT=$(dirname "$0")
case "$REPO_ROOT" in
    /*) ;;
    *) REPO_ROOT="$PWD/$REPO_ROOT" ;;
esac

ITEMS_FILE="/tmp/sync-items-$$"
STATUS_FILE="/tmp/sync-status-$$"
SELECTION_FILE="/tmp/sync-sel-$$"

trap 'rm -f "$ITEMS_FILE" "$STATUS_FILE" "$SELECTION_FILE"' EXIT INT TERM

SUDO_ITEMS="sddm"

cat > "$ITEMS_FILE" <<- 'ITEMS'
	fish|~/.config/fish/|config/fish/
	helix|~/.config/helix/|config/helix/
	mako|~/.config/mako/|config/mako/
	rofi|~/.config/rofi/|config/rofi/
	sway|~/.config/sway/|config/sway/
	systemd/user|~/.config/systemd/user/|config/systemd/user/
	waybar|~/.config/waybar/|config/waybar/
	yazi|~/.config/yazi/|config/yazi/
	mimeapps.list|~/.config/mimeapps.list|config/mimeapps.list
	scripts|~/.scripts/|scripts/
	sddm|/etc/sddm.conf|etc/sddm/sddm.conf
ITEMS

usage() {
    cat <<- 'USAGE'
	Usage: sync-config.sh [sync|deploy] [--dry-run] [--sanitize] [--check]

	Commands:
	  sync              Copy live ~/.config/ -> config/ in repo (default)
	  deploy            Copy config/ in repo -> ~/.config/
	  --check           Scan tracked files for sensitive data
	  --sanitize        Apply secrets.sed redactions during sync
	  --dry-run         Preview only, no files copied
	  -h, --help        Show this help
	USAGE
    exit 0
}

MODE="sync"
DRY_RUN="false"
SANITIZE="false"

for arg in "$@"; do
    case "$arg" in
        sync) MODE="sync" ;;
        deploy) MODE="deploy" ;;
        --check) MODE="check" ;;
        --sanitize) SANITIZE="true" ;;
        --dry-run) DRY_RUN="true" ;;
        -h|--help) usage ;;
    esac
done

err() { printf '%s\n' "$*" >&2; }

expand_path() {
    path="$1"
    tilde="~"
    case "$path" in
        "${tilde}/"*) path="${HOME}/${path#\~/}" ;;
    esac
    printf '%s' "$path"
}

ensure_dir() {
    dir="$1"
    if [ ! -e "$dir" ]; then
        mkdir -p "$dir"
    fi
}

get_sudo_prefix() {
    item="$1"
    for s in $SUDO_ITEMS; do
        if [ "$s" = "$item" ]; then
            printf 'sudo '
            return
        fi
    done
    printf ''
}

apply_sanitize() {
    dest="$1"
    san_file="$REPO_ROOT/secrets.sed"
    if [ ! -f "$san_file" ]; then
        err "Warning: --sanitize requested but secrets.sed not found"
        return
    fi
    if [ -f "$dest" ]; then
        sed -f "$san_file" "$dest" > "$dest.tmp" && mv "$dest.tmp" "$dest"
    elif [ -d "$dest" ]; then
        find "$dest" -type f | while read -r f; do
            sed -f "$san_file" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        done
    fi
}

detect_changes() {
    direction="$1"
    : > "$STATUS_FILE"
    while IFS='|' read -r item live_path repo_path <&3; do
        case "$item" in ''|'#'*) continue ;; esac
        live_path=$(expand_path "$live_path")
        repo_path="$REPO_ROOT/$repo_path"

        if [ "$direction" = "deploy" ]; then
            src="$repo_path"
            dest="$live_path"
        else
            src="$live_path"
            dest="$repo_path"
        fi

        sp=$(get_sudo_prefix "$item")

        if [ -z "$sp" ]; then
            if [ ! -e "$src" ]; then
                printf '%s|missing_source\n' "$item" >> "$STATUS_FILE"
                continue
            fi
            if [ -d "$src" ] && [ -d "$dest" ]; then
                if diff -rq "$src" "$dest" > /dev/null 2>&1; then
                    printf '%s|identical\n' "$item" >> "$STATUS_FILE"
                else
                    printf '%s|changed\n' "$item" >> "$STATUS_FILE"
                fi
            elif [ -f "$src" ] && [ -f "$dest" ]; then
                if diff -q "$src" "$dest" > /dev/null 2>&1; then
                    printf '%s|identical\n' "$item" >> "$STATUS_FILE"
                else
                    printf '%s|changed\n' "$item" >> "$STATUS_FILE"
                fi
            elif [ -e "$src" ] && [ ! -e "$dest" ]; then
                printf '%s|new\n' "$item" >> "$STATUS_FILE"
            else
                printf '%s|changed\n' "$item" >> "$STATUS_FILE"
            fi
        else
            if ! ${sp}test -e "$src" 2>/dev/null; then
                printf '%s|missing_source\n' "$item" >> "$STATUS_FILE"
                continue
            fi
            if [ -f "$dest" ]; then
                if ${sp}cat "$src" | diff -q - "$dest" > /dev/null 2>&1; then
                    printf '%s|identical\n' "$item" >> "$STATUS_FILE"
                else
                    printf '%s|changed\n' "$item" >> "$STATUS_FILE"
                fi
            else
                printf '%s|new\n' "$item" >> "$STATUS_FILE"
            fi
        fi
    done 3< "$ITEMS_FILE"
}

strip_prefix() {
    full="$1"
    prefix="$2"
    case "$full" in
        "${prefix}"*) printf '%s' "${full#"$prefix"}" ;;
        *) printf '%s' "$full" ;;
    esac
}

show_tree_preview() {
    direction="$1"

    if [ "$direction" = "deploy" ]; then
        arrow="repo -> ~/.config/"
    else
        arrow="~/.config/ -> repo"
    fi

    echo ""
    echo "Changes preview for $direction ($arrow):"
    echo "---------------------------------------------"
    echo ""

    changed_count=0
    total=0

    while IFS='|' read -r item live_path repo_path <&3; do
        case "$item" in ''|'#'*) continue ;; esac
        status=$(grep "^$item|" "$STATUS_FILE" | cut -d'|' -f2)
        total=$((total + 1))

        case "$status" in
            changed|new)
                changed_count=$((changed_count + 1))
                live_path=$(expand_path "$live_path")
                repo_path="$REPO_ROOT/$repo_path"

                if [ "$direction" = "deploy" ]; then
                    src="$repo_path"
                    dst="$live_path"
                else
                    src="$live_path"
                    dst="$repo_path"
                fi

                echo "$item/"

                src_clean="${src%/}"
                dst_clean="${dst%/}"
                sp=$(get_sudo_prefix "$item")

                if [ -d "$src" ] && [ -d "$dst" ]; then
                    diff -rq "$src_clean" "$dst_clean" 2>/dev/null | while read -r line; do
                        case "$line" in
                            "Files "*" differ")
                                f=$(printf '%s\n' "$line" | sed 's/^Files \(.*\) and .* differ$/\1/')
                                r=$(strip_prefix "$f" "$src_clean")
                                r="${r#/}"
                                if [ -z "$r" ]; then
                                    echo "  $(basename "$f")  (modified)"
                                else
                                    echo "  $r  (modified)"
                                fi
                                ;;
                            "Only in $src_clean"*)
                                d=$(printf '%s\n' "$line" | sed 's/^Only in \(.*\): .*$/\1/')
                                fn=$(printf '%s\n' "$line" | sed 's/^Only in .*: \(.*\)$/\1/')
                                r=$(strip_prefix "$d" "$src_clean")
                                r="${r#/}"
                                if [ -z "$r" ]; then
                                    echo "  $fn  (new)"
                                else
                                    echo "  $r/$fn  (new)"
                                fi
                                ;;
                            "Only in $dst_clean"*)
                                d=$(printf '%s\n' "$line" | sed 's/^Only in \(.*\): .*$/\1/')
                                fn=$(printf '%s\n' "$line" | sed 's/^Only in .*: \(.*\)$/\1/')
                                r=$(strip_prefix "$d" "$dst_clean")
                                r="${r#/}"
                                if [ -z "$r" ]; then
                                    echo "  $fn  (exists only in dest)"
                                else
                                    echo "  $r/$fn  (exists only in dest)"
                                fi
                                ;;
                        esac
                    done
                elif [ -z "$sp" ] && [ -f "$src" ] && [ -f "$dst" ]; then
                    echo "  (modified)"
                elif [ -n "$sp" ] && [ -f "$dst" ] && ${sp}test -f "$src" 2>/dev/null; then
                    echo "  (modified)"
                else
                    echo "  (new)"
                fi
                ;;
        esac
    done 3< "$ITEMS_FILE"

    echo ""
    echo "$changed_count of $total items have changes"
    echo "---------------------------------------------"

    [ "$changed_count" -eq 0 ] && return 1
    return 0
}

select_items_fzf() {
    direction="$1"
    fzf_input="/tmp/sync-fzf-in-$$"
    : > "$fzf_input"

    while IFS='|' read -r item status <&3; do
        case "$item" in ''|'#'*) continue ;; esac
        case "$status" in
            changed)   printf '%s  (changed)\n' "$item" >> "$fzf_input" ;;
            new)       printf '%s  (new)\n' "$item" >> "$fzf_input" ;;
            identical) printf '%s  (up to date)\n' "$item" >> "$fzf_input" ;;
            missing_source) printf '%s  (source missing)\n' "$item" >> "$fzf_input" ;;
        esac
    done 3< "$STATUS_FILE"

    selected=$(fzf --multi --prompt="Select items to $direction (Tab=multi, Enter=confirm): " < "$fzf_input")
    rm -f "$fzf_input"

    if [ -z "$selected" ]; then
        return 1
    fi

    printf '%s\n' "$selected" | sed 's/  (.*)//' > "$SELECTION_FILE"
}

select_items_manual() {
    direction="$1"
    echo ""
    echo "Select items to $direction:"
    echo ""

    index=0
    while IFS='|' read -r item status <&3; do
        case "$item" in ''|'#'*) continue ;; esac
        index=$((index + 1))
        echo "  $index) $item  [$status]"
    done 3< "$STATUS_FILE"

    echo ""
    printf 'Enter numbers (e.g. "1 3"), "all", or "none": '
    read -r selection

    case "$selection" in
        all|ALL)
            while IFS='|' read -r item _ <&3; do
                case "$item" in ''|'#'*) continue ;; esac
                echo "$item" >> "$SELECTION_FILE"
            done 3< "$STATUS_FILE"
            ;;
        none|NONE|"")
            return 1
            ;;
        *)
            for num in $selection; do
                idx=0
                while IFS='|' read -r item _ <&3; do
                    case "$item" in ''|'#'*) continue ;; esac
                    idx=$((idx + 1))
                    if [ "$idx" -eq "$num" ] 2>/dev/null; then
                        echo "$item" >> "$SELECTION_FILE"
                    fi
                done 3< "$STATUS_FILE"
            done
            ;;
    esac
}

select_items() {
    direction="$1"
    : > "$SELECTION_FILE"
    if command -v fzf > /dev/null 2>&1; then
        select_items_fzf "$direction"
    else
        select_items_manual "$direction"
    fi
    [ -s "$SELECTION_FILE" ]
}

copy_item() {
    item="$1"
    src="$2"
    dest="$3"

    if [ "$DRY_RUN" = "true" ]; then
        echo "  [DRY RUN] would copy: $src -> $dest"
        return
    fi

    ensure_dir "$(dirname "$dest")"
    sp=$(get_sudo_prefix "$item")
    if [ -n "$sp" ]; then
        ${sp}cat "$src" > "$dest"
    elif [ -d "$src" ]; then
        rsync -a "$src/" "$dest/"
    elif [ -f "$src" ]; then
        rsync -a "$src" "$dest"
    fi
}

process_items() {
    direction="$1"

    if [ ! -s "$SELECTION_FILE" ]; then
        echo "No items selected."
        return
    fi

    applied=0
    skipped=0

    while read -r item <&4; do
        [ -z "$item" ] && continue

        line=$(grep "^$item|" "$ITEMS_FILE")
        live_path=$(printf '%s' "$line" | cut -d'|' -f2)
        repo_path=$(printf '%s' "$line" | cut -d'|' -f3)
        live_path=$(expand_path "$live_path")
        repo_path="$REPO_ROOT/$repo_path"

        if [ "$direction" = "deploy" ]; then
            src="$repo_path"
            dest="$live_path"
        else
            src="$live_path"
            dest="$repo_path"
        fi

        status=$(grep "^$item|" "$STATUS_FILE" | cut -d'|' -f2)

        sp=$(get_sudo_prefix "$item")

        if [ "$status" = "identical" ] || [ "$status" = "missing_source" ]; then
            copy_item "$item" "$src" "$dest"
            if [ "$status" = "identical" ]; then
                echo "  copied $item (up to date)"
            else
                echo "  skipped $item (source not found)"
            fi
            applied=$((applied + 1))
            continue
        fi

        echo ""
        echo "---------------------------------------------"
        echo "=== $item/ ==="
        echo "---------------------------------------------"

        if [ -n "$sp" ]; then
            if ${sp}test -f "$src" 2>/dev/null && [ -f "$dest" ]; then
                ${sp}diff -ruN "$dest" "$src" 2>/dev/null | less -R
            else
                echo "(New item -- no diff available)"
            fi
        elif [ -d "$dest" ] && [ -d "$src" ]; then
            diff -ruN "$dest" "$src" 2>/dev/null | less -R
        elif [ -f "$src" ] && [ -f "$dest" ]; then
            diff -ruN "$dest" "$src" 2>/dev/null | less -R
        else
            echo "(New item -- no diff available)"
        fi

        printf '\nApply changes for %s/? [y/N] ' "$item"
        read -r confirm
        case "$confirm" in
            y|Y|yes|Yes)
                copy_item "$item" "$src" "$dest"
                if [ "$direction" = "sync" ] && [ "$SANITIZE" = "true" ]; then
                    apply_sanitize "$dest"
                fi
                echo "  applied $item"
                applied=$((applied + 1))
                ;;
            *)
                echo "  skipped $item"
                skipped=$((skipped + 1))
                ;;
        esac
    done 4< "$SELECTION_FILE"

    echo ""
    echo "Done. Sync complete."
    echo "  Applied: $applied"
    [ "$skipped" -gt 0 ] && echo "  Skipped: $skipped"
}

check_targets() {
    targets=""
    for d in "$REPO_ROOT/config" "$REPO_ROOT/scripts" "$REPO_ROOT/etc"; do
        [ -d "$d" ] && targets="$targets $d"
    done
    [ -f "$REPO_ROOT/config/mimeapps.list" ] && targets="$targets $REPO_ROOT/config/mimeapps.list"
    printf '%s' "$targets"
}

check_pattern() {
    label="$1"
    pattern="$2"
    shift 2
    first=true
    found=false
    for target in "$@"; do
        if [ -f "$target" ]; then
            matches=$(grep -nE -e "$pattern" "$target") || true
            if [ -n "$matches" ]; then
                if $first; then
                    echo ""
                    echo "=== $label ==="
                    first=false
                fi
                printf '%s\n' "$matches" | while read -r m; do
                    echo "  $target:$m"
                done
                found=true
            fi
        elif [ -d "$target" ]; then
            for f in $(find "$target" -type f); do
                matches=$(grep -nE -e "$pattern" "$f") || true
                if [ -n "$matches" ]; then
                    if $first; then
                        echo ""
                        echo "=== $label ==="
                        first=false
                    fi
                    printf '%s\n' "$matches" | while read -r m; do
                        echo "  $f:$m"
                    done
                    found=true
                fi
            done
        fi
    done
    $found
}

do_check() {
    targets=$(check_targets)
    if [ -z "$targets" ]; then
        echo "Nothing to check -- no config/ or scripts/ directory found."
        exit 0
    fi

    echo "Scanning tracked files for sensitive data..."
    echo "Targets: config/ scripts/"
    echo ""

    any=false

    if check_pattern "GPS coordinates" '^[[:space:]]*(lat|lon|latitude|longitude)[[:space:]]*=[^=]' $targets; then
        any=true
    fi

    if check_pattern "Home directory paths" '/home/[^/]' $targets; then
        any=true
    fi

    if check_pattern "Tokens" '[Tt]oken[[:space:]]*=' $targets; then
        any=true
    fi

    if check_pattern "Secrets and API keys" '[Ss]ecret[[:space:]]*=' $targets; then
        any=true
    fi

    if check_pattern "Secrets and API keys" '[Aa][Pp][Ii]_[Kk][Ee][Yy]' $targets; then
        any=true
    fi

    if check_pattern "Private keys" '-----BEGIN[[:space:]]+.*PRIVATE[[:space:]]+KEY-----' $targets; then
        any=true
    fi

    if check_pattern "URLs with credentials" 'https?://[^/[:space:]]*@' $targets; then
        any=true
    fi

    if check_pattern "Email addresses" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' $targets; then
        any=true
    fi

    echo ""
    if $any; then
        echo "Potential issues found above. Review before committing."
        exit 1
    else
        echo "No sensitive data detected."
        exit 0
    fi
}

do_sync_or_deploy() {
    direction="$1"

    detect_changes "$direction"

    if ! show_tree_preview "$direction"; then
        echo ""
        echo "All up to date. Nothing to do."
        exit 0
    fi

    echo ""
    printf 'Proceed to item selection? [y/N] '
    read -r proceed
    case "$proceed" in y|Y|yes|Yes) ;; *)
        echo "Aborted."
        exit 0
    esac

    if ! select_items "$direction"; then
        echo "No items selected. Aborted."
        exit 0
    fi

    process_items "$direction"
}

case "$MODE" in
    check) do_check ;;
    sync) do_sync_or_deploy "sync" ;;
    deploy) do_sync_or_deploy "deploy" ;;
esac
