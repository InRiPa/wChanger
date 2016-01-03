
## About

This is a simple tool written in bash to automatically change the desktop background.
Because of extension scripts you don't need to have a big local wallpaper repository. 
Just use the remote URL which contains all wallpapers and choose the correct image grabber.

## Installation

1. clone / copy the content in a desired folder (e.g. /home/<user>/Tools/)
2. Setup you first initial script at the bottom end of wChanger.sh
  * set _imgPath_ variable (e.g. /home/<user>/Tools/wChanger)
  * set _imgSrc_ equal to the link from which the wallpaper should be retrieved from
  * choose image grab extenstion (e.g. _grabur.sh_)
  * call _downloadSource_ (not needed for local image repository)
  * finally call _setWallpaper_ which will replace the current wallpaper
  
3. Setup a crontab rule 
```bash
$> crontab -e
   e.g.: 59 * * * * /home/<user>/Tools/wChanger/wChanger.sh
```


## License
See LICENSE file for more information.

## Troubleshooting
  * possible permisson problems (crontab)
