# !/usr/bin/env bash

# Status.
STATUS=(0 0 0 0 0 0 0 0 0 0)

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

# Editors, defaults to vim.
if [[ -e /usr/bin/vim ]]; then
  EDITOR='vim'
elif [[ -e /usr/bin/nano ]]; then
  EDITOR='nano'
fi

# Desktop Environments.
BUDGIE=0
CINNAMON=0
GNOME=0
KDE=0
MATE=0

# Keyboard Layout.
KEYBOARD_LAYOUT="US"

# Log functions.
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

log_checkbox() {
  if [[ $1 -eq 1 ]]; then
      log_info "${BOLD_WHITE}[X]${RESET}"
  else
      log_info "${BOLD_WHITE}[ ]${RESET}"
  fi
}

log_menu_item() {
  if [[ $1 == 1 ]]; then
      log_info "$(log_checkbox "$1") ${BOLD_GREEN}$2${RESET} \t\t $3"
  else
      log_info "$(log_checkbox "$1") ${BOLD_RED}$2${RESET} \t\t $3"
  fi
}

# Utility functions.
contains_element() {
  for i in "${@:2}"; do [[ $i == $1 ]] && break; done; 
}

package_install() {
  for PACKAGE in "${1}"; do
    if ! is_package_installed "${PACKAGE}"; then
        pacman -S --noconfirm --needed "${PACKAGE}"
    else
        log_info "Package ${PACKAGE} already exists"
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

check_connection() {
  # Returns 1 (Error) if connection not found.
  connection_test() {
    ping -q -w 1 -c 1 $(ip r | grep default | awk '{print $3}') &> /dev/null &&
    return 0 || return 1
  }
  if [[ ! connection_test ]]; then
    log_warning 'ERROR! Connection not found.'
  fi
}
