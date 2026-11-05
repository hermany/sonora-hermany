# sonora-hermany

Fork local de Sonora que solo usa mi servidor de música (Navidrome sobre `~/Music`, API Subsonic).

## Qué cambia respecto al original
- `crates/sonora/src/main.rs`: la lista de proveedores queda solo con `SubsonicProvider`
  (se quitan Spotify, Apple, YouTube, Deezer, TIDAL) y las letras solo vienen de archivos locales y del servidor Subsonic.

## Servidor (Navidrome)
- Instalado con `brew install navidrome`; config en `~/.config/navidrome/navidrome.toml`
  (`MusicFolder = ~/Music`, puerto 4533, solo `127.0.0.1` hasta crear el admin).
- Arranque manual: `navidrome --configfile ~/.config/navidrome/navidrome.toml`
- Primera vez: abrir http://127.0.0.1:4533 y crear el usuario admin.
- Para usarlo desde otros equipos: cambiar `Address` a `0.0.0.0` (o servirlo con `tailscale serve`) DESPUÉS de crear el admin.

## Compilar (pendiente de ejecutar)
```sh
cd ~/projects/sonora-hermany
cargo check -p sonora      # verifica el cambio
cargo build --release -p sonora
```
Toolchain: `rust-toolchain.toml` pide 1.98.1 (ya instalado con rustup). La primera compilación es larga (GPUI).

## Conectar Sonora al servidor
En Sonora: proveedor `subsonic` → URL `http://127.0.0.1:4533`, usuario y contraseña del admin.
Control remoto desde Ayda Desk: CLI `sonora --json current|toggle|next|search …`.

## App con icono
`hermany/make-app.sh` arma `~/Applications/Sonora Hermany.app` (icono en `hermany/`, regenerable con `hermany/make-icon.swift`).
Comparte datos con Sonora original (`~/Library/Application Support/sonora`): no abrir las dos a la vez.
Estado: compila, y `sonora --json providers` solo lista `subsonic`.

## Streaming opcional
El lanzador de la app solo arranca Navidrome si existe `~/.config/sonora-hermany/streaming`
(`touch` para activar, `rm` para desactivar). Sin él, Sonora reproduce solo archivos locales y no gasta recursos en el servidor.
