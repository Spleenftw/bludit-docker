# bludit-docker

An unofficial Docker image for [Bludit](https://www.bludit.com), the flat-file CMS, built on the official `php:8.3-apache` image.

I built it because the Bludit image I was using stopped getting rebuilt with PHP security fixes. This one is rebuilt from scratch every week, so PHP and Debian patches reach my blog without me lifting a finger.

## Quick start

```bash
docker run -d --name bludit \
  -p 127.0.0.1:8001:80 \
  -v ./content:/var/www/html/bl-content \
  -v ./plugins:/var/www/html/bl-plugins \
  -v ./themes:/var/www/html/bl-themes \
  ghcr.io/spleenftw/bludit:latest
```

Open `http://127.0.0.1:8001` and follow the Bludit installer. The admin panel lives at `/admin`.

Or with Compose:

```yaml
services:
  bludit:
    image: ghcr.io/spleenftw/bludit:latest
    container_name: bludit
    restart: unless-stopped
    ports:
      - "127.0.0.1:8001:80"
    volumes:
      - ./content:/var/www/html/bl-content
      - ./plugins:/var/www/html/bl-plugins
      - ./themes:/var/www/html/bl-themes
```

The container speaks plain HTTP on port 80. Put a reverse proxy in front of it for TLS.

## Tags

| Tag | What it is |
|---|---|
| `latest` | Most recent build |
| `3.22.0` | Latest build for that Bludit version |
| `3.22.0-YYYYMMDD` | Immutable snapshot of a given build date, handy for rollbacks |

## Volumes

| Path in the container | Content |
|---|---|
| `/var/www/html/bl-content` | Pages, uploads, databases and settings |
| `/var/www/html/bl-plugins` | Plugins |
| `/var/www/html/bl-themes` | Themes |

If a mounted folder is empty on startup, the entrypoint fills it with Bludit's defaults. Folders that already contain data are never touched.

## Permissions

`www-data` runs as uid/gid **82** in this image, the same as the Alpine-based `bludit/docker` image. Your mounted folders must be writable by that uid:

```bash
sudo chown -R 82:82 content plugins themes
```

## Migrating from bludit/docker

Only the mount paths change, your data stays as it is:

| bludit/docker | This image |
|---|---|
| `/usr/share/nginx/html/bl-content` | `/var/www/html/bl-content` |
| `/usr/share/nginx/html/bl-plugins` | `/var/www/html/bl-plugins` |
| `/usr/share/nginx/html/bl-themes` | `/var/www/html/bl-themes` |

## Updating

```bash
docker compose pull && docker compose up -d
```

A populated `bl-plugins` or `bl-themes` volume hides the plugins and themes shipped inside the image. After a Bludit upgrade, if the admin panel throws errors, refresh the bundled ones from the new image (your own plugins stay untouched):

```bash
docker run --rm ghcr.io/spleenftw/bludit:latest \
  tar -C /var/www/html/bl-plugins -cf - . | tar -C plugins -xf -
```

## How it is built

- GitHub Actions builds and pushes to `ghcr.io/spleenftw/bludit` on every push to `main`, on demand, and every Monday at 04:00 UTC.
- The scheduled run uses `--no-cache` and pulls the base image fresh, which is how PHP and Debian fixes get in.
- The Bludit version is set by `BLUDIT_VERSION` in `.github/workflows/build.yml`.

To build it yourself:

```bash
docker build --build-arg BLUDIT_VERSION=3.22.0 -t bludit .
```

## What is in the image

- PHP 8.3 with Apache, `mod_rewrite` and `mod_headers` enabled, `AllowOverride All` for Bludit's `.htaccess`
- The `gd` extension for image processing
- The Bludit release archive from the upstream GitHub repository

## Good to know

- This is an unofficial build, not affiliated with the Bludit project.
- Weekly rebuilds keep PHP and the OS patched. They do not patch Bludit itself, which follows upstream releases.
- Bludit is MIT licensed.
