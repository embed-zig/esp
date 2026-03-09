#!/usr/bin/env python3

import os
import signal
import subprocess
import sys


def run_direct(cmd: list[str]) -> int:
    return subprocess.call(cmd)


def run_direct_timeout(cmd: list[str], timeout: int) -> int:
    proc = subprocess.Popen(cmd)
    try:
        return proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
        return 0


def run_with_pty(cmd: list[str]) -> int:
    import pty

    status = pty.spawn(cmd)
    if hasattr(os, "waitstatus_to_exitcode"):
        return os.waitstatus_to_exitcode(status)
    if os.WIFEXITED(status):
        return os.WEXITSTATUS(status)
    if os.WIFSIGNALED(status):
        return 128 + os.WTERMSIG(status)
    return 1


def run_with_pty_timeout(cmd: list[str], timeout: int) -> int:
    import pty

    class _Timeout(Exception):
        pass

    def _alarm(_signum, _frame):
        raise _Timeout()

    old = signal.signal(signal.SIGALRM, _alarm)
    signal.alarm(timeout)
    try:
        status = pty.spawn(cmd)
        signal.alarm(0)
        signal.signal(signal.SIGALRM, old)
        if hasattr(os, "waitstatus_to_exitcode"):
            return os.waitstatus_to_exitcode(status)
        if os.WIFEXITED(status):
            return os.WEXITSTATUS(status)
        if os.WIFSIGNALED(status):
            return 128 + os.WTERMSIG(status)
        return 1
    except _Timeout:
        return 0


def main() -> int:
    timeout = None
    args_start = 1

    if len(sys.argv) > 1 and sys.argv[1].startswith("--timeout="):
        timeout = int(sys.argv[1].split("=", 1)[1])
        args_start = 2

    if len(sys.argv) < args_start + 1:
        print("usage: pty_monitor.py [--timeout=N] <cmd...>", file=sys.stderr)
        return 2

    cmd = sys.argv[args_start:]

    # 非交互上下文下，为 idf_monitor 分配一个 pseudo-tty，避免 stdin 非 tty 直接退出。
    if not sys.stdin.isatty() and os.name == "posix":
        if timeout:
            return run_with_pty_timeout(cmd, timeout)
        return run_with_pty(cmd)

    if timeout:
        return run_direct_timeout(cmd, timeout)
    return run_direct(cmd)


if __name__ == "__main__":
    raise SystemExit(main())
