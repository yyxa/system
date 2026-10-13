# system

Личные скрипты и конфиги для быстрой настройки ОС: Linux Mint, Windows и загрузочная флешка Ventoy.

## Структура

```
system/
├── mint/                     # Linux Mint 22 Cinnamon
│   ├── install/hello.sh      # bootstrap-скрипт: пакеты, zsh, docker, rust, snap-пакеты и т.д.
│   ├── makefile              # удалённое управление ПК: WoL, ssh, shutdown, vpn, proxy
│   └── example.env           # пример переменных для makefile
├── windows/                  # Windows 11 Pro
│   ├── autounattend_128.xml  # автоустановка, раздел Windows 128 ГБ
│   ├── autounattend_1000.xml # автоустановка, раздел Windows ~1000 ГБ
│   ├── install_apps.ps1      # winget import + установка Murglar с GitHub releases
│   └── key.ps1               # активация
├── flash-drive/              # файлы для Ventoy-флешки
│   ├── ventoy/ventoy.json    # auto_install: windows11.iso -> scripts/autounattend.xml
│   └── scripts/
│       ├── autounattend.xml # автоустановка
│       └── $OEM$/$$/Setup/Scripts/packages.json  # winget-пакеты
├── misc/wallpapers/          # обои
├── nixos/                    # задел под NixOS (пусто)
└── .gitignore                # .env, логи, AppImage, ovpn и т.д.
```

## Быстрый старт

### Mint

```bash
cp mint/example.env mint/.env
# заполнить IP, MAC, USER, PASSWORD, VPS_* в mint/.env

chmod +x mint/install/hello.sh
./mint/install/hello.sh
# с авторебутом в конце:
# ./mint/install/hello.sh --reboot
```

Полезное из `mint/makefile`:

```bash
make -C mint ssh       # ssh USER@IP
make -C mint up        # Wake-on-LAN
make -C mint down      # shutdown -h now
make -C mint sleep     # systemctl suspend
make -C mint reboot
make -C mint ping
make -C mint ping-port
make -C mint vps       # ssh на VPS
make -C mint vpn       # openvpn --config maxim.ovpn
make -C mint ls-proxy
```

Что ставит `hello.sh`: base-пакеты, dotnet-sdk-8.0, snapd, git-credential-libsecret, oh-my-zsh, JetBrainsMono Nerd Font, starship, fastfetch, btop (из исходников), rust + yazi, docker + compose, yandex-browser, plantuml, flameshot, code, obsidian, telegram, vlc, obs-studio, discord, teams-for-linux, postman, stellarium, bitwarden, zoom-client, libreoffice, ktorrent, usb-creator-kde, hiddify AppImage, alacritty (из исходников).

### Windows

1. Выбрать нужный `autounattend`: `autounattend_128.xml` или `autounattend_1000.xml`.
   Сгенерированы через [schneegans.de/windows/unattend-generator](https://schneegans.de/windows/unattend-generator/):
   ru-RU, GPT, Windows 11 Pro, пользователи `Admin` / `yyxa`, удаление лишних UWP-приложений.
2. `key.ps1` и `install_apps.ps1` вшиты в autounattend.xml.

### Flash-drive (Ventoy)

1. Установить Ventoy на флешку, скопировать `windows11.iso` в корень.
2. Скопировать на флешку:
   - `flash-drive/ventoy` -> корень флешки
   - `flash-drive/scripts/` -> корень флешки
3. При загрузке Ventoy покажет меню выбора с `autounattend.xml`.
