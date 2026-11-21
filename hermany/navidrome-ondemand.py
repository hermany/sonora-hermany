#!/usr/bin/env python3
"""Proxy bajo demanda: escucha en la IP de Tailscale y arranca Navidrome con la primera conexion remota.

Apaga Navidrome tras IDLE segundos sin conexiones, pero solo si lo arranco este proceso.
Navidrome sigue escuchando solo en 127.0.0.1:4533.
"""
import asyncio, os, subprocess, time

NAV = "/opt/homebrew/bin/navidrome"
CONF = os.path.expanduser("~/.config/navidrome/navidrome.toml")
LOG = os.path.expanduser("~/Library/Logs/navidrome.log")
BACK = ("127.0.0.1", 4533)
PORT = 4533
IDLE = 600

proc = None
active = 0
last = time.monotonic()
lock = asyncio.Lock()


def tailscale_ip():
    for exe in ("tailscale", "/Applications/Tailscale.app/Contents/MacOS/Tailscale"):
        try:
            return subprocess.check_output([exe, "ip", "-4"], text=True).split()[0]
        except (OSError, subprocess.CalledProcessError, IndexError):
            continue
    return None


async def backend_up():
    try:
        _, w = await asyncio.open_connection(*BACK)
        w.close()
        return True
    except OSError:
        return False


async def ensure_backend():
    global proc
    async with lock:
        if await backend_up():
            return True
        log = open(LOG, "ab")
        proc = subprocess.Popen([NAV, "--configfile", CONF], stdout=log, stderr=log)
        print("navidrome started", flush=True)
        for _ in range(60):
            if await backend_up():
                return True
            await asyncio.sleep(0.5)
        return False


async def pipe(r, w):
    global last
    try:
        while data := await r.read(65536):
            w.write(data)
            await w.drain()
            last = time.monotonic()
    except OSError:
        pass
    finally:
        w.close()


async def handle(cr, cw):
    global active, last
    active += 1
    last = time.monotonic()
    try:
        if not await ensure_backend():
            cw.close()
            return
        br, bw = await asyncio.open_connection(*BACK)
        await asyncio.gather(pipe(cr, bw), pipe(br, cw))
    except OSError:
        cw.close()
    finally:
        active -= 1
        last = time.monotonic()


async def reaper():
    global proc
    while True:
        await asyncio.sleep(30)
        if proc and active == 0 and time.monotonic() - last > IDLE:
            proc.terminate()
            proc.wait()
            proc = None
            print("navidrome stopped (idle)", flush=True)


async def main():
    ip = None
    while not ip:
        ip = tailscale_ip()
        if not ip:
            await asyncio.sleep(10)
    server = await asyncio.start_server(handle, ip, PORT)
    print(f"listening on {ip}:{PORT}", flush=True)
    asyncio.create_task(reaper())
    async with server:
        await server.serve_forever()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    finally:
        if proc:
            proc.terminate()
