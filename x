#!/bin/bash
here="$(readlink -m $(dirname ${BASH_SOURCE[0]}))"
workspace=$(dirname ${here})
project_name=$(basename ${workspace})
image="${DEV_IMAGE:-archlinux:latest}"
dev_name="${DEV_NAME:-${project_name}-dev}"
user_id="${DEV_USER_ID:-$(id -ru)}"
user_name="${DEV_USER_NAME:-$(id -run)}"
group_id="${DEV_GROUP_ID:-$(id -rg)}"
group_name="${DEV_GROUP_NAME:-$(id -rgn)}"
app_dir="${APP_DIR:-/var/app}"

if [ "${DEBUG}" = "true" ]; then
  set -x
  set -e
fi

function build_container()
{
  podman build \
    --rm \
    -t ${dev_name} \
    --build-arg APP_DIR="${app_dir}" \
    --build-arg USER_ID="${user_id}" \
    --build-arg USER_NAME="${user_name}" \
    --build-arg GROUP_ID="${group_id}" \
    --build-arg GROUP_NAME="${group_name}" \
    --build-arg SHELL="${SHELL}" \
    --build-arg PS1_HEAD="[${dev_name}]" \
    ${here}
}

function run_container()
{
  podman run \
    --tty \
    --interactive \
    --userns=keep-id \
    --volume="${workspace}":"${app_dir}"\
    --user="${user_name}" \
    --name="${dev_name}" \
    "${dev_name}" \
    bash
}

function create_container()
{
  podman create \
    --userns=keep-id \
    --volume="${workspace}":"${app_dir}"\
    --user="${user_name}" \
    --name="${dev_name}" \
    "${dev_name}" \
    bash
}

function enter_container()
{
  podman start ${dev_name}
  podman exec \
    --tty \
    --interactive \
    --detach-keys= \
    "${dev_name}" \
    bash
}

function kill_container()
{
  podman stop "${dev_name}" > /dev/null
  podman rm "${dev_name}" > /dev/null
}

function rmi()
{
  podman rmi ${dev_name} > /dev/null
}

function rebuild_image()
{
  kill_container
  rmi
  build_container
}

cmd=$1
shift
case "${cmd}" in
  build) build_container;;
  run) run_container;;
  create) create_container;;
  enter) enter_container;;
  rerun)
    kill_container
    run_container
    ;;
  kill|destroy) kill_container;;
  cleanup) rmi;;
  rebuild) rebuild_image;;
  reboot)
    rebuild_image
    run_container
    ;;
  *)
    exit 0
    ;;
esac
