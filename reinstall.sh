#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-${HOME}/Applications}"
NO_LAUNCH="${NO_LAUNCH:-0}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"
APP_NAME="ScreenDark.app"
LEGACY_APP_NAME="ThanosLight.app"
BUNDLE_ID="com.liuzhuang.thanoslight"

export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-${SCRIPT_DIR}/.build/clang-module-cache}"
export SWIFTPM_MODULECACHE_OVERRIDE="${SWIFTPM_MODULECACHE_OVERRIDE:-${SCRIPT_DIR}/.build/swiftpm-module-cache}"
/bin/mkdir -p "${CLANG_MODULE_CACHE_PATH}" "${SWIFTPM_MODULECACHE_OVERRIDE}"

case "${INSTALL_DIR}" in
    /*) ;;
    *)
        echo "INSTALL_DIR 必须是绝对路径：${INSTALL_DIR}" >&2
        exit 2
        ;;
esac

if [[ "${INSTALL_DIR}" == "/" ]]; then
    echo "拒绝安装到根目录" >&2
    exit 2
fi

TARGET_APP="${INSTALL_DIR}/${APP_NAME}"
LEGACY_APP="${INSTALL_DIR}/${LEGACY_APP_NAME}"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/screen-dark-install.XXXXXX")"
STAGED_APP="${TMP_ROOT}/${APP_NAME}"
TARGET_BACKUP_APP="${TMP_ROOT}/previous-${APP_NAME}"
LEGACY_BACKUP_APP="${TMP_ROOT}/previous-${LEGACY_APP_NAME}"
HELPER_APP="${STAGED_APP}/Contents/Helpers/ThanosLightRecovery.app"
HELPER_EXECUTABLE_PATH="${HELPER_APP}/Contents/MacOS/ThanosLightRecovery"
TARGET_BACKED_UP=0
LEGACY_BACKED_UP=0
TARGET_REPLACEMENT_STARTED=0

cleanup() {
    local status=$?
    local recovery_failed=0
    trap - EXIT
    set +e
    if [[ ${status} -ne 0 ]]; then
        if [[ ${TARGET_REPLACEMENT_STARTED} -eq 1 ]]; then
            /bin/rm -rf -- "${TARGET_APP}"
        fi
        if [[ ${TARGET_BACKED_UP} -eq 1 && -e "${TARGET_BACKUP_APP}" ]]; then
            /bin/mv -- "${TARGET_BACKUP_APP}" "${TARGET_APP}" || recovery_failed=1
        fi
        if [[ ${LEGACY_BACKED_UP} -eq 1 && -e "${LEGACY_BACKUP_APP}" ]]; then
            /bin/mv -- "${LEGACY_BACKUP_APP}" "${LEGACY_APP}" || recovery_failed=1
        fi
    fi
    if [[ ${recovery_failed} -ne 0 ]]; then
        echo "自动恢复失败；原应用备份保留在：${TMP_ROOT}" >&2
    else
        /bin/rm -rf -- "${TMP_ROOT}"
    fi
    exit "${status}"
}
trap cleanup EXIT

echo "[1/4] 构建 Release"
/usr/bin/swift build --package-path "${SCRIPT_DIR}" -c release
BIN_DIR="$(/usr/bin/swift build --package-path "${SCRIPT_DIR}" -c release --show-bin-path)"
EXECUTABLE="${BIN_DIR}/ThanosLight"
RECOVERY_EXECUTABLE="${BIN_DIR}/ThanosLightRecovery"
RESOURCE_BUNDLE_NAME="ThanosLight_ThanosLight.bundle"
RESOURCE_BUNDLE="${BIN_DIR}/${RESOURCE_BUNDLE_NAME}"
test -x "${EXECUTABLE}"
test -x "${RECOVERY_EXECUTABLE}"
test -d "${RESOURCE_BUNDLE}"

echo "[2/4] 组装并签名应用"
/bin/mkdir -p \
    "${STAGED_APP}/Contents/MacOS" \
    "${STAGED_APP}/Contents/Resources" \
    "${HELPER_APP}/Contents/MacOS"
/usr/bin/install -m 755 "${EXECUTABLE}" "${STAGED_APP}/Contents/MacOS/ThanosLight"
/usr/bin/install -m 755 \
    "${RECOVERY_EXECUTABLE}" \
    "${HELPER_EXECUTABLE_PATH}"
/usr/bin/install -m 644 "${SCRIPT_DIR}/Info.plist" "${STAGED_APP}/Contents/Info.plist"
/usr/bin/install -m 644 "${SCRIPT_DIR}/RecoveryInfo.plist" "${HELPER_APP}/Contents/Info.plist"
/usr/bin/ditto \
    "${RESOURCE_BUNDLE}" \
    "${STAGED_APP}/Contents/Resources/${RESOURCE_BUNDLE_NAME}"
/usr/bin/plutil -lint "${STAGED_APP}/Contents/Info.plist" >/dev/null
/usr/bin/plutil -lint "${HELPER_APP}/Contents/Info.plist" >/dev/null
/usr/bin/codesign \
    --force \
    --sign "${SIGNING_IDENTITY}" \
    "${HELPER_EXECUTABLE_PATH}"
/usr/bin/codesign --force --sign "${SIGNING_IDENTITY}" "${HELPER_APP}"
/usr/bin/codesign --force --sign "${SIGNING_IDENTITY}" "${STAGED_APP}"
/usr/bin/codesign --verify --strict "${HELPER_APP}"
/usr/bin/codesign --verify --deep --strict "${STAGED_APP}"

echo "[3/4] 安装到 ${TARGET_APP}"
/bin/mkdir -p "${INSTALL_DIR}"
bundle_id_for_app() {
    /usr/bin/plutil -extract CFBundleIdentifier raw -o - \
        "$1/Contents/Info.plist" 2>/dev/null || true
}

if [[ -e "${TARGET_APP}" ]]; then
    EXISTING_BUNDLE_ID="$(bundle_id_for_app "${TARGET_APP}")"
    if [[ "${EXISTING_BUNDLE_ID}" != "${BUNDLE_ID}" ]]; then
        echo "拒绝覆盖 Bundle ID 不匹配的同名应用：${EXISTING_BUNDLE_ID:-未知}" >&2
        exit 1
    fi
fi
MIGRATE_LEGACY_APP=0
if [[ -e "${LEGACY_APP}" ]]; then
    LEGACY_BUNDLE_ID="$(bundle_id_for_app "${LEGACY_APP}")"
    if [[ "${LEGACY_BUNDLE_ID}" == "${BUNDLE_ID}" ]]; then
        MIGRATE_LEGACY_APP=1
    else
        echo "保留 Bundle ID 不匹配的旧应用：${LEGACY_BUNDLE_ID:-未知}" >&2
    fi
fi
main_running() {
    /usr/bin/pgrep -x ThanosLight >/dev/null 2>&1
}

helper_running() {
    /usr/bin/pgrep -f '/ThanosLightRecovery([[:space:]]|$)' >/dev/null 2>&1
}

if main_running; then
    /usr/bin/osascript -e "tell application id \"${BUNDLE_ID}\" to quit" >/dev/null 2>&1 || true
fi
for _ in {1..20}; do
    if ! main_running && ! helper_running; then
        break
    fi
    /bin/sleep 0.1
done
if main_running || helper_running; then
    echo "ScreenDark 或恢复助手未能正常退出；为避免留下黑色 Gamma 状态，已中止重装" >&2
    exit 1
fi
if [[ -e "${TARGET_APP}" ]]; then
    /bin/mv -- "${TARGET_APP}" "${TARGET_BACKUP_APP}"
    TARGET_BACKED_UP=1
fi
if [[ ${MIGRATE_LEGACY_APP} -eq 1 ]]; then
    /bin/mv -- "${LEGACY_APP}" "${LEGACY_BACKUP_APP}"
    LEGACY_BACKED_UP=1
fi
TARGET_REPLACEMENT_STARTED=1
/usr/bin/ditto "${STAGED_APP}" "${TARGET_APP}"
test -x "${TARGET_APP}/Contents/MacOS/ThanosLight"
test -x \
    "${TARGET_APP}/Contents/Helpers/ThanosLightRecovery.app/Contents/MacOS/ThanosLightRecovery"
test -d \
    "${TARGET_APP}/Contents/Resources/${RESOURCE_BUNDLE_NAME}"
test "$(bundle_id_for_app "${TARGET_APP}")" = "${BUNDLE_ID}"
if [[ ${MIGRATE_LEGACY_APP} -eq 1 && -e "${LEGACY_APP}" ]]; then
    echo "旧应用迁移后仍然存在：${LEGACY_APP}" >&2
    exit 1
fi

echo "[4/4] 安装完成"
if [[ "${NO_LAUNCH}" != "1" ]]; then
    /usr/bin/open "${TARGET_APP}"
fi

echo "${TARGET_APP}"
