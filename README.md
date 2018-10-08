# Moteradi downloader
Download [moteradi](https://moteradi.com/) mp3 files if new files are uploaded.

## How to use

    ruby moteradi_downloader.rb

## Settings
Override these parameters if you need.

### Where to download mp3 files.
    $cf[:download_dir] = "./mp3"

### Start downloading from which episode.
    $cf[:episode_start] = 880
