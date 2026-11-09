#!/usr/bin/env bash
# setup.sh — virtue-cleaning-solution
# Flask landing page in Docker. Verified from the repo: app.py serves on
# port 80, the Dockerfile EXPOSEs 80, and the README runs it as -p 8080:80.
# There is NO docker-compose.yml and NO requirements.txt in this repo —
# the Dockerfile installs Flask itself (pip install flask).
set -e

REPO_NAME="virtue-cleaning-solution"
REPO="virtue-cleaning-solution"
OWNER="UncleD0886475978"
REPO_URL="https://github.com/UncleD0886475978/${REPO_NAME}.git"
IMAGE_NAME="virtue-cleaning-solution"
CONTAINER_NAME="virtue-cleaning"
HOST_PORT="8080"
RUN_ONELINE="curl -fsSL https://raw.githubusercontent.com/${OWNER}/${REPO}/main/setup.sh | bash"

echo "==> Step 1/6: Platform check + base bootstrap (git, curl)"
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "ERROR: this script needs root or sudo to install packages."
    exit 1
  fi
fi
APT=0
if [ "$(uname -s)" = "Linux" ] && command -v apt-get >/dev/null 2>&1; then APT=1; fi
INSTALLED=""
APT_UPDATED=""
note_installed() { INSTALLED="${INSTALLED} $1"; }
apt_update_once() {
  if [ -z "${APT_UPDATED}" ]; then $SUDO apt-get update -y; APT_UPDATED=1; fi
}
apt_install() {
  apt_update_once
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y "$@"
}
if [ "${APT}" -eq 1 ]; then
  BASE_PKGS=""
  command -v git >/dev/null 2>&1 || BASE_PKGS="${BASE_PKGS} git"
  command -v curl >/dev/null 2>&1 || BASE_PKGS="${BASE_PKGS} curl"
  [ -f /etc/ssl/certs/ca-certificates.crt ] || BASE_PKGS="${BASE_PKGS} ca-certificates"
  command -v gpg >/dev/null 2>&1 || BASE_PKGS="${BASE_PKGS} gnupg"
  if [ -n "${BASE_PKGS}" ]; then
    echo "    Installing base tools:${BASE_PKGS}"
    # shellcheck disable=SC2086
    apt_install ${BASE_PKGS}
    note_installed "${BASE_PKGS}"
  else
    echo "    Base tools already present (git, curl, ca-certificates, gnupg)."
  fi
else
  echo "    Non-apt platform detected — bootstrap will only CHECK tools and print install guidance."
fi

echo "==> Step 2/6: Locate the repo"
if [ -f "$0" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
  SCRIPT_DIR="$PWD"
fi
if [ -f "app.py" ] && [ -f "Dockerfile" ]; then
  REPO_DIR="$PWD"
  echo "    Already inside the repo checkout: $REPO_DIR"
else
  REPO_DIR="$HOME/repos/$REPO_NAME"
  if [ -d "$REPO_DIR/.git" ]; then
    echo "    Existing checkout found — pulling latest..."
    git -C "$REPO_DIR" pull --ff-only || true
  else
    if ! command -v git >/dev/null 2>&1; then
      echo "    ERROR: git not found. Install git first: https://git-scm.com/downloads"
      exit 1
    fi
    echo "    Cloning $REPO_URL into $REPO_DIR ..."
    mkdir -p "$HOME/repos"
    git clone "$REPO_URL" "$REPO_DIR"
  fi
fi
cd "$REPO_DIR"

echo "==> Step 3/6: Bootstrap Docker"
DOCKER="docker"
install_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "    docker: already present ($(docker --version))"
  elif [ "${APT}" -eq 1 ]; then
    echo "    Installing Docker Engine via the official get.docker.com script..."
    curl -fsSL https://get.docker.com | $SUDO sh
    note_installed "docker"
  else
    return 1
  fi
  if ! docker info >/dev/null 2>&1 && ! $SUDO docker info >/dev/null 2>&1; then
    echo "    Starting the Docker daemon..."
    $SUDO systemctl enable --now docker 2>/dev/null || $SUDO service docker start 2>/dev/null || true
    for _i in $(seq 1 15); do
      if docker info >/dev/null 2>&1 || $SUDO docker info >/dev/null 2>&1; then break; fi
      sleep 2
    done
  fi
  if docker info >/dev/null 2>&1; then
    DOCKER="docker"
  elif $SUDO docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
    if [ "$(id -u)" -ne 0 ]; then
      $SUDO usermod -aG docker "$USER" 2>/dev/null || true
      echo "    NOTE: you were added to the 'docker' group (applies at next login); this run uses 'sudo docker'."
    fi
  else
    echo "ERROR: Docker is installed but the daemon could not be started."
    echo "       On a VM:  sudo systemctl start docker   |   In a container/WSL without systemd, Docker cannot run here."
    exit 1
  fi
  echo "    docker daemon OK (using: ${DOCKER})"
}
MISSING_LIST=""
install_docker || MISSING_LIST="${MISSING_LIST} docker(https://docs.docker.com/get-docker/)"
if [ -n "${MISSING_LIST}" ]; then
  echo "ERROR: could not auto-install on this platform. Missing:${MISSING_LIST}"
  echo "Install the tool(s) manually, then re-run this script."
  exit 1
fi
echo "    docker: $(docker --version)"

echo "==> Step 4/6: Build the image"
echo "    (No docker-compose.yml in this repo, so this uses plain docker build.)"
# shellcheck disable=SC2086
${DOCKER} build -t "$IMAGE_NAME" .

echo "==> Step 5/6: Run the container (host port $HOST_PORT -> container port 80)"
# shellcheck disable=SC2086
if ${DOCKER} ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  echo "    Removing existing container '$CONTAINER_NAME'..."
  # shellcheck disable=SC2086
  ${DOCKER} rm -f "$CONTAINER_NAME" >/dev/null
fi
# shellcheck disable=SC2086
${DOCKER} run -d -p "${HOST_PORT}:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

echo "==> Step 6/6: Wait for the app to answer on http://localhost:${HOST_PORT}"
APP_URL="http://localhost:${HOST_PORT}"
READY=0
for i in $(seq 1 30); do
  if command -v curl >/dev/null 2>&1; then
    if curl -fsS -o /dev/null "$APP_URL"; then READY=1; break; fi
  elif command -v wget >/dev/null 2>&1; then
    if wget -q -O /dev/null "$APP_URL"; then READY=1; break; fi
  else
    sleep 2; READY=1; break
  fi
  sleep 1
done
if [ "$READY" = "1" ]; then
  echo "    App is responding."
else
  echo "    WARNING: app did not respond within ~30s. Check the logs (command below)."
fi

cat <<EOF

=================== BOOTSTRAP SUMMARY ===================
Installed during this run:${INSTALLED:- (nothing — all tools were already present)}
Working copy: ${REPO_DIR}
Next time, set up from scratch on any fresh Ubuntu VM with one line:
  ${RUN_ONELINE}
=========================================================
EOF

echo ""
echo "============================================================"
echo "Done. Virtue Cleaning Solution is running at: $APP_URL"
echo "Note: schema.sql (PostgreSQL: departments/employees/supplies) ships in"
echo "      the repo for the internal database — it is not started by the"
echo "      Dockerfile; the container above serves the Flask landing page."
echo ""
echo "Next commands:"
echo "  Run/use:  open $APP_URL   (rebuild/restart: re-run this setup.sh)"
echo "  Stop:     ${DOCKER} stop $CONTAINER_NAME"
echo "  Start:    ${DOCKER} start $CONTAINER_NAME"
echo "  Remove:   ${DOCKER} rm -f $CONTAINER_NAME"
echo "  Logs:     ${DOCKER} logs -f $CONTAINER_NAME"
echo "============================================================"
