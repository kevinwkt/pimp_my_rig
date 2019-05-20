# !/usr/bin/env bash
# Style Guide: https://google.github.io/styleguide/shell.xml.

# Menu.
menu_options_display() {
    printf "\n1) $(log_menu_item "${STATUS[1]}" 'Check Script Deps' 'Done')"
    printf "\n2) $(log_menu_item "${STATUS[2]}" 'Set Editor\t' "$EDITOR")"
    printf "\n3) $(log_menu_item "${STATUS[3]}" 'Set Keyboard Layout' "$KEYBOARD_LAYOUT")"
    printf "\n4) $(log_menu_item "${STATUS[4]}" 'Set Keyboard Layout' "$KEYBOARD_LAYOUT")"
    printf "\n5) $(log_menu_item "${STATUS[5]}" 'Set Keyboard Layout' "$KEYBOARD_LAYOUT")"
    printf "\n6) $(log_menu_item "${STATUS[6]}" 'Set Keyboard Layout' "$KEYBOARD_LAYOUT")"
    printf "\n7) $(log_menu_item "${STATUS[7]}" 'Set Keyboard Layout' "$KEYBOARD_LAYOUT")"
    printf "\n8) $(log_menu_item "${STATUS[8]}" 'Set Keyboard Layout' "$KEYBOARD_LAYOUT")"
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
  supported_keyboards=(yes maybe)
  select KEYMAP in "${supported_keyboards[@]}"; do
    if contains_element "$KEYMAP" "${supported_keyboards[@]}"; then
        loadkeys "$KEYMAP";
        break
    else
        log_warning "Warning: Invalid option"
    fi
  done
}

# Set editor.
set_editor() {
  supported_editors=(nano vim emacs vimm)
  select EDITOR in "${supported_editors[@]}"; do
    if contains_element "$EDITOR" "${supported_editors[@]}"; then
      package_install "$EDITOR" 
      break
    else
      log_warning "Warning: Invalid option"
    fi
  done
}

verify_boot_mode() {
  if [[ ! -e /sys/firmware/efi/efivars ]]; then
    log_error "Error! System may be booted in BIOS or CSM mode." \
              "Refer to your motherboard's manual for details."
    exit 1
  fi
}

connect_to_internet() {
 print "yes" 
}

update_system_clock() {
  timedatectl set-ntp true
}

stop_run() {
  echo "${BOLD_GREEN}INSTALL COMPLETED${RESET}"
  exit 0
}

run() {
  # Imports dependencies before starting. 
  check_deps
  STATUS[1]=1

  log_info "Starting installation..."
  while true; do
    menu_options_display
    read OPTION
    case "$OPTION" in
      1)
        echo "Dependency has been checked."
        ;;
      2)
        set_editor
        STATUS[2]=1
        ;;
      3)
        set_keyboard_layout
        STATUS[3]=1
        ;;
      10)
        stop_run 
        ;;
      *)
        echo "Invalid option"
        ;;
      esac
  done
}

run
