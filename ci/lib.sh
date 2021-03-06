#!/usr/bin/env bash

config_dir="$WORKSPACE/nix_configs"
cache_dir="$HOME/.cache/nix/jenkins-cache"
mkdir -p "${cache_dir}"

# nixpkgs-path overlays-path nixpkgs-pkgs-path
function nixpkgs-build-cache-result-path() {
    local nixpkgs_dir=$1
    local overlays_dir=$2
    local name=$3

    if [ -z "${BUILD_TAG}" ] ; then
        timestamp=$(date '+%s')
        basename="${name}-${timestamp}"
    else
        basename="${name}-${BUILD_TAG}"
    fi
    results_path="${cache_dir}/${basename}"

    if [ -z $nix ] ; then
        nix_bin=""
    else
        nix_bin="$nix/bin/"
    fi

    export NIX_PATH="nixpkgs-overlays=$overlays_dir"

    set -x
    store_path=$(${nix_bin}nix-build --show-trace "$nixpkgs_dir"/pkgs/top-level/impure.nix \
                           --arg config "{}" \
                           -o "${results_path}" \
                           -A "pkgs.${name}")
    set +x

    (
        if [ ! -z "${BUILD_TAG}" ] ; then
            for build_dep in $(nix-store -qR $(nix-store -qd $store_path)) ; do
                root="${cache_dir}/build-dep-$(basename $build_dep)"
                if [ ! -e "$root" ] ; then
                    ${nix_bin}nix-store --add-root "$root" --indirect -r $build_dep
                fi
            done
        fi
    ) > /dev/null

    echo $store_path
}

function nixos-test-cache-result-path() {
    local nixos_dir=$1
    local overlays_dir=$2
    local name=$3

    if [ -z "${BUILD_TAG}" ] ; then
        timestamp=$(date '+%s')
        basename="${name}-${timestamp}"
    else
        basename="${name}-${BUILD_TAG}"
    fi
    results_path="${cache_dir}/${basename}"

    if [ -z $nix ] ; then
        nix_bin=""
    else
        nix_bin="$nix/bin/"
    fi

    export NIX_PATH="nixpkgs-overlays=$overlays_dir"

    store_path=$(${nix_bin}nix-build --show-trace "$nixos_dir"/release.nix \
                           -o "${results_path}" \
                           -A "tests.${name}.x86_64-linux")

    (
        if [ ! -z "${BUILD_TAG}" ] ; then
            for build_dep in $(nix-store -qR $(nix-store -qd $store_path)) ; do
                root="${cache_dir}/build-dep-$(basename $build_dep)"
                if [ ! -e "$root" ] ; then
                    ${nix_bin}nix-store --add-root "$root" --indirect -r $build_dep
                fi
            done
        fi
    ) > /dev/null

    echo $store_path
}

function gc-cache-dir() {
    find "${cache_dir}" -mindepth 1 -maxdepth 1 -mtime +30 -print -delete || true
}
