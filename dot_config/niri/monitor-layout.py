"""Keep the connected external monitor left of the laptop, including on hotplug."""

import json
import subprocess
import time


def outputs():
    try:
        data = subprocess.check_output(
            ["niri", "msg", "-j", "outputs"], stderr=subprocess.DEVNULL
        )
        return json.loads(data)
    except (OSError, subprocess.CalledProcessError, ValueError):
        return {}


def arrange():
    connected = outputs()
    laptop = connected.get("eDP-1", {}).get("logical")
    if laptop is None:
        return

    externals = sorted(
        (name for name, info in connected.items() if name != "eDP-1" and info.get("logical")),
        key=lambda name: name != "DP-3",  # Prefer the Huawei if multiple monitors are present.
    )
    if not externals:
        if (laptop["x"], laptop["y"]) != (0, 0):
            subprocess.run(["niri", "msg", "output", "eDP-1", "position", "set", "0", "0"])
        return

    external = externals[0]
    width = connected[external]["logical"]["width"]
    if (laptop["x"], laptop["y"]) != (width, 0):
        subprocess.run(
            ["niri", "msg", "output", "eDP-1", "position", "set", str(width), "0"]
        )
    if (connected[external]["logical"]["x"], connected[external]["logical"]["y"]) != (0, 0):
        subprocess.run(["niri", "msg", "output", external, "position", "set", "0", "0"])


def main():
    while True:
        try:
            with subprocess.Popen(
                ["niri", "msg", "-j", "event-stream"], stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL, text=True,
            ) as stream:
                for line in stream.stdout:
                    event = json.loads(line)
                    if "OutputsChanged" in event or "ConfigLoaded" in event:
                        arrange()
        except (OSError, ValueError):
            pass
        time.sleep(1)


if __name__ == "__main__":
    main()
