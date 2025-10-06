#!/bin/bash

# Couleur
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logs
log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Variables

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" # Remonte au /app

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker non trouvé"
    exit 1
  fi
}
