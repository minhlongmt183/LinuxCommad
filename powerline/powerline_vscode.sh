#!/bin.bash
git clone https://github.com/abertsch/Menlo-for-Powerline.git
cd Menlo-for-Powerline/
sudo mv "Menlo for Powerline.ttf" /usr/share/fonts/
sudo fc-cache -vf /usr/share/fonts/

echo "------------------------------------------------"
echo "Go to your UI Settings: CTRL + SHIFT + P > UI Settings"
echo "Search for Terminal Font and set the new font:"
echo "more details: https://blog.zhaytam.com/2019/04/19/powerline-and-zshs-agnoster-theme-in-vs-code/"