"""Open a terminal and Firefox on the external display, Teams on the laptop."""

import json
import subprocess
import time


def windows(app_id):
    try:
        output = subprocess.check_output(
            ["niri", "msg", "-j", "windows"], stderr=subprocess.DEVNULL
        )
        return {
            window["id"]
            for window in json.loads(output)
            if window.get("app_id") == app_id
        }
    except (OSError, subprocess.CalledProcessError, ValueError):
        return set()


def external_output(timeout=5):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            output = subprocess.check_output(
                ["niri", "msg", "-j", "outputs"], stderr=subprocess.DEVNULL
            )
            connected = json.loads(output)
            externals = sorted(
                (
                    name
                    for name, info in connected.items()
                    if name != "eDP-1" and info.get("logical")
                ),
                key=lambda name: name != "DP-3",
            )
            if externals:
                return externals[0]
        except (OSError, subprocess.CalledProcessError, ValueError):
            pass
        time.sleep(0.25)
    return "eDP-1"  # No external monitor: launch everything on the laptop.


def wait_for_new_window(app_id, existing, timeout=60):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        new_windows = windows(app_id) - existing
        if new_windows:
            return min(new_windows)
        time.sleep(0.25)
    return None


def move(window_id, output):
    if window_id is not None:
        subprocess.run(
            [
                "niri",
                "msg",
                "action",
                "move-window-to-monitor",
                "--id",
                str(window_id),
                output,
            ],
            check=False,
        )


external = external_output()

before = windows("Alacritty")
subprocess.Popen(["alacritty"])
move(wait_for_new_window("Alacritty", before), external)

before = windows("firefox")
subprocess.Popen(["firefox", "--new-window", "https://github.com/trending"])
move(wait_for_new_window("firefox", before), external)

before = windows("firefox")
subprocess.Popen(["firefox", "--new-window", "https://teams.microsoft.com/v2/"])
move(wait_for_new_window("firefox", before), "eDP-1")
