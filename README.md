<h1 align="center">Tizen studio</h1>
A Docker container for Tizen Studio 5.0 with CLI

# Build tizen studio from remote
this install tizen studio from link
```sh
docker build --build-arg INSTALL_FROM=remote -t tizenstudio:webcli-5.0 .
```

# Build tizen studio from local
This install tizen studio from "web-cli_Tizen_Studio_5.0_ubuntu-64.bin" that need to be at the current directory
```sh
docker build --build-arg INSTALL_FROM=local -t tizenstudio:webcli-5.0 .
```

# Create tizen studio from compose
to make it easy docker compose is fast for managing container
```sh
docker-compose up -d
```

### Backup generated certificate for later use


### Build WGT

> Make sure you select the appropriate Certificate Profile in Tizen Certificate Manager. This determines which devices you can install the widget on.

```sh
tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock"
tizen package -t wgt -o . -- .buildResult
```

## Deployment

### Deploy to Emulator

1. Run emulator.
2. Install package.
   ```sh
   tizen install -n App.wgt -t T-samsung-5.5-x86
   ```
   > Specify target with `-t` option. Use `sdb devices` to list them.

### Deploy to TV

1. Run TV.
2. Activate Developer Mode on TV (<a href="https://developer.samsung.com/tv/develop/getting-started/using-sdk/tv-device">https://developer.samsung.com/tv/develop/getting-started/using-sdk/tv-device</a>).
3. Connect to TV with Device Manager from Tizen Studio. Or with sdb.
   ```sh
   sdb connect YOUR_TV_IP
   ```
4. If you are using a Samsung certificate, `Permit to install applications` on your TV using Device Manager from Tizen Studio. Or with sdb.
   > TODO: Find a command
5. Install package.
   ```sh
   tizen install -n App.wgt -t UE65NU7400
   ```
   > Specify target with `-t` option. Use `sdb devices` to list them.


Reference:
https://www.reddit.com/r/jellyfin/comments/s0438d/build_and_deploy_jellyfin_app_to_samsung_tizen/