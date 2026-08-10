#!/usr/bin/env bash

set -uo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/$(basename -- "${BASH_SOURCE[0]}")"
LOG_DIR="${SCREEN_DARK_LOG_DIR:-${SCRIPT_DIR}}"
ARM_SECONDS="${SCREEN_DARK_ARM_SECONDS:-30}"
WAIT_SECONDS="${SCREEN_DARK_WAIT_SECONDS:-180}"

validate_seconds() {
    local name="$1"
    local value="$2"

    if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
        echo "${name} 必须是正整数秒数：${value}" >&2
        exit 2
    fi
}

section() {
    printf '\n===== %s =====\n' "$1"
}

capture() {
    local title="$1"
    shift

    section "${title}"
    "$@" || printf '[命令失败，退出码 %s]\n' "$?"
}

run_worker() {
    local log_file="$1"
    local test_start
    local test_end

    echo "ScreenDark idle system sleep verification"
    echo "日志文件：${log_file}"
    echo "脚本 PID：$$"
    echo "布置时间：${ARM_SECONDS} 秒"
    echo "静默测试：${WAIT_SECONDS} 秒"

    /bin/sleep "${ARM_SECONDS}"

    capture "PRE TIME" /bin/date '+%Y-%m-%d %H:%M:%S %z'
    capture "MACOS" /usr/bin/sw_vers
    capture "ARCH" /usr/bin/uname -m
    capture "RELEVANT PROCESSES" /usr/bin/pgrep -lf \
        'ThanosLight|ScreenDark|UURemote|ChatGPT|Electron|SoftwareUpdate'
    capture "POWER SETTINGS IN USE" /usr/bin/pmset -g
    capture "POWER SOURCE" /usr/bin/pmset -g batt
    capture "ALL POWER PROFILES" /usr/bin/pmset -g custom
    capture "SCHEDULED POWER EVENTS" /usr/bin/pmset -g sched
    capture "ASSERTIONS BEFORE WAIT" /usr/bin/pmset -g assertions

    test_start="$(/bin/date '+%Y-%m-%d %H:%M:%S')"
    section "MEASUREMENT START"
    echo "${test_start}"
    echo "接下来的 ${WAIT_SECONDS} 秒只执行一次 sleep，不轮询、不 ping。"

    /bin/sleep "${WAIT_SECONDS}"

    test_end="$(/bin/date '+%Y-%m-%d %H:%M:%S')"
    section "MEASUREMENT END"
    echo "${test_end}"

    capture "POST TIME" /bin/date '+%Y-%m-%d %H:%M:%S %z'
    capture "POWER SOURCE AFTER WAIT" /usr/bin/pmset -g batt
    capture "ASSERTIONS AFTER WAIT" /usr/bin/pmset -g assertions

    section "PMSET LOG DURING MEASUREMENT"
    /usr/bin/pmset -g log | /usr/bin/awk \
        -v start="${test_start}" \
        -v finish="${test_end}" '
        /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-/ {
            stamp = substr($0, 1, 19)
            keep = stamp >= start && stamp <= finish
        }
        keep { print }
    ' || printf '[pmset 日志提取失败，退出码 %s]\n' "$?"

    section "COLLECTION COMPLETE"
    /bin/date '+%Y-%m-%d %H:%M:%S %z'
    echo "请把这个日志文件发给我：${log_file}"
}

validate_seconds "SCREEN_DARK_ARM_SECONDS" "${ARM_SECONDS}"
validate_seconds "SCREEN_DARK_WAIT_SECONDS" "${WAIT_SECONDS}"

if [[ "${1:-}" == "--worker" ]]; then
    if [[ -z "${2:-}" ]]; then
        echo "缺少日志文件路径" >&2
        exit 2
    fi
    exec </dev/null >>"$2" 2>&1
    run_worker "$2"
    exit 0
fi

if ! /bin/mkdir -p -- "${LOG_DIR}"; then
    echo "无法创建日志目录：${LOG_DIR}" >&2
    exit 1
fi
LOG_FILE="${LOG_DIR}/ScreenDark-idle-system-sleep-$(/bin/date '+%Y%m%d-%H%M%S').log"

/usr/bin/nohup /usr/bin/env bash "${SCRIPT_PATH}" --worker "${LOG_FILE}" \
    </dev/null >/dev/null 2>&1 &
WORKER_PID=$!
/bin/sleep 0.2
if [[ ! -f "${LOG_FILE}" ]]; then
    echo "后台采集脚本启动失败" >&2
    exit 1
fi

echo "验证脚本已在后台启动，PID：${WORKER_PID}"
echo "日志将保存到：${LOG_FILE}"
echo
echo "现在请在 ${ARM_SECONDS} 秒内完成："
echo "1. 关闭 Terminal、ChatGPT、浏览器、播放器和远程控制软件。"
echo "2. 最后一个操作：把 ScreenDark 的任意一块屏幕设为 0%。"
echo "3. 此后 ${WAIT_SECONDS} 秒内不要碰键盘/鼠标，不要合盖或手动睡眠。"
echo
echo "建议用手机计时 4 分钟；之后按 ⌃⌥⌘B 点亮全部屏幕，再等 10 秒后发送日志。"
