# !/usr/bin/env bash
# Style Guide: https://google.github.io/styleguide/shell.xml.

# Menu.
main_menu_display() {
    printf "\n1) $(main_menu_item "${STATUS[0]}" 'Check Script Deps' '\t\tDone')"
    printf "\n2) $(main_menu_item "${STATUS[1]}" 'Verify Boot Mode' "\t\t$BOOT_MODE")"
    printf "\n3) $(main_menu_item "${STATUS[2]}" 'Verify Internet Connection' "\t$CONNECTION")"
    printf "\n4) $(main_menu_item "${STATUS[3]}" 'Set Editor\t' "\t\t$EDITOR")"
    printf "\n5) $(main_menu_item "${STATUS[4]}" 'Set Keyboard Layout' "\t\t$KEYBOARD_LAYOUT")"
    printf "\n6) $(main_menu_item "${STATUS[5]}" 'Update System Clock' "\t\t$SYSTEM_CLOCK_UPDATED")"
    printf "\n7) $(main_menu_item "${STATUS[6]}" 'Update System Clock' "\t\t$KEYBOARD_LAYOUT")"
    printf "\n8) $(main_menu_item "${STATUS[7]}" 'Set Keyboard Layout' "\t\t$KEYBOARD_LAYOUT")"
    printf "\n9) $(main_menu_item "${STATUS[8]}" 'Set Keyboard Layout' "\t\t$KEYBOARD_LAYOUT")"
    printf "\n10) Finish\n"
}

# Initial dependency checks.
check_deps() {
    if [[ -e `pwd`/arch_header.sh ]]; then
        source ./arch_header.sh
    else
        log_error "missing file: arch_header.sh"
        exit 1
    fi
}

# Set keyboard layout.
set_keyboard_layout() {
  supported_keyboards=(us es uk)
  select KEYMAP in "${supported_keyboards[@]}"; do
    if contains_element "$KEYMAP" "${supported_keyboards[@]}"; then
        loadkeys "$KEYMAP";
        KEYBOARD_LAYOUT="$KEYMAP"
        break
    else
        log_warning "Warning: Invalid option"
    fi
  done
}

# Set editor.
set_editor() {
  supported_editors=(nano vim emacs)
  select CHOICE in "${supported_editors[@]}"; do
    echo "$CHOICE"
    if contains_element "$CHOICE" "${supported_editors[@]}"; then
      package_install "$CHOICE" 
      EDITOR="$CHOICE"
      break
    else
      log_warning "Warning: Invalid option."
      log_warning "Will default to vim or nano."
    fi
  done
}

#=
verify_boot_mode() {
  if [[ ! -e /sys/firmware/efi/efivars ]]; then
    log_error "Error! System may be booted in BIOS or CSM mode." \
              "Refer to your motherboard's manual for details."
    BOOT_MODE="BIOS"
    exit 1
  fi
}

# Partition the disks.
partition_disks() {
  
}

# Finish.
stop_run() {
  echo "${BOLD_GREEN}INSTALL COMPLETED${RESET}"
  exit 0
}

run() {
  # Imports dependencies before starting. 
  check_deps
  STATUS[0]=1

  log_info "Starting installation..."
  while true; do
    main_menu_display
    read OPTION
    case "$OPTION" in
      1)
        echo "Dependency has been checked."
        ;;
      2)
        verify_boot_mode
        STATUS[1]=1
        ;;
      3)
        if check_connection; then
            log_info "Connection is established."
            STATUS[2]=1
            CONNECTION="true"
        else
            log_warning "Starting wifi-menu..."
            wifi-menu
        fi
        ;;
      4)
        set_editor
        STATUS[3]=1
        ;;
      5)
        set_keyboard_layout
        STATUS[4]=1
        ;;
      6)
        update_system_clock
        STATUS[5]=1
        SYSTEM_CLOCK_UPDATED='true'
        ;;
      10)
        stop_run 
        ;;
      *)
        log_error "Invalid option"
        ;;
      esac
  done
}

run
