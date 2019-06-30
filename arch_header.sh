# !/usr/bin/env bash

# Status.
# Each element is an installation step.
# (check_deps, verify_boot_mode, verify_internet, set_editor
# set_keyboard_layout, update_system_clock, partition_disks
STATUS=(0 0 0 0 0 0 0 0 0 0)

# Boot mode, default UEFI.
BOOT_MODE='UEFI'

# Connected to internet.
CONNECTION='false'

# Editors, defaults to vim or nano.
if [[ -e /usr/bin/vim ]]; then
  EDITOR='vim'
elif [[ -e /usr/bin/nano ]]; then
  EDITOR='nano'
fi

# Keyboard Layout, defaults to us.
KEYBOARD_LAYOUT='us'

SYSTEM_CLOCK_UPDATED='false'

# Output styles.
BOLD=$(tput bold)
UNDERLINE=$(tput sgr 0 1)
RESET=$(tput sgr0)

# Regular output colors.
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Bold output colors.
BOLD_RED=${BOLD}${RED}
BOLD_GREEN=${BOLD}${GREEN}
BOLD_YELLOW=${BOLD}${YELLOW}
BOLD_BLUE=${BOLD}${BLUE}
BOLD_PURPLE=${BOLD}${PURPLE}
BOLD_CYAN=${BOLD}${CYAN}
BOLD_WHITE=${BOLD}${WHITE}

# Desktop Environments.
BUDGIE=0
CINNAMON=0
GNOME=0
KDE=0
MATE=0

# Log functions.
# There are 3 levels of logs: Info, Warning and Error. Each purpose is pretty
# much self explanatory. You can recover from Warning but not from Error.
log_error() {
    local terminal_width
    terminal_width=$(tput cols)
    >&2 echo "${RED}$@${RESET}" | fold -sw $(( $terminal_width -1 ))
}

log_warning() {
  local terminal_width
  terminal_width=$(tput cols)
  echo "${RED}$@${RESET}" | fold -sw $(( $terminal_width - 1 ))
}

log_info() {
  local terminal_width
  terminal_width=$(tput cols)
  echo "$@" | fold -sw $(( $terminal_width - 1 ))
}

# Print formatters.
# Prettifies log outputs.
main_menu_checkbox() {
  if [[ $1 -eq 1 ]]; then
      log_info "${BOLD_WHITE}[X]${RESET}"
  else
      log_info "${BOLD_WHITE}[ ]${RESET}"
  fi
}

main_menu_item() {
  if [[ $1 == 1 ]]; then
      log_info "$(main_menu_checkbox "$1") ${BOLD_GREEN}$2${RESET} \t\t $3"
  else
      log_info "$(main_menu_checkbox "$1") ${BOLD_RED}$2${RESET} \t\t $3"
  fi
}

# Utility functions.
# Helper functions to reduce duplicity.
contains_element() {
  for i in "${@:2}"; do [[ $i == $1 ]] && return 0; done; return 1; 
}

# Pacman functions.
package_install() {
  for PACKAGE in "${1}"; do
    if ! is_package_installed "${PACKAGE}"; then
        pacman -S --noconfirm --needed "${PACKAGE}"
    else
        log_info "Package ${PACKAGE} already installed."
    fi
  done
}

is_package_installed() {
  for PACKAGE in "${1}"; do
      # pacman -Q returns 1 if not found.
    pacman -Q "${PACKAGE}" &> /dev/null && return 0;
  done
  return 1
}

# System functions.
system_update() {
  pacman -Sy
}

check_connection() {
  # Returns 1 (Error) if connection not found.
  connection_test() {
    ping -q -w 1 -c 1 $(ip r | grep default | awk '{print $3}') &> /dev/null && return 0 || return 1
  }
  if ! connection_test; then
    log_warning 'ERROR! Connection not found.'
    return 1
  else
    return 0
  fi
}

update_system_clock() {
  timedatectl set-ntp true
}
