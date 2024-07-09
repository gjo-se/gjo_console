# Reload Bash
source ~/.zsh

source ~/.bashrc
nano ~/.bashrc
if [ -f /var/www/html/packages/gjo_console/Bash/shell/.bash/.bash_profile ]; then
    . /var/www/html/packages/gjo_console/Bash/shell/.bash/.bash_profile
fi

# Typo3 Console
https://docs.typo3.org/p/helhum/typo3-console/8.1/en-us/CommandReference/Index.html#available-commands
https://docs.typo3.org/m/typo3/guide-installation/10.4/en-us/ExtensionInstallation/Index.html#install-an-extension-with-composer


# WIN Symlink
cd C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\Projects\tiger.de\packages
# Softlink
sudo mklink /d gjo_console C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\localRepositories\ext\gjo\gjo_console
# Hardlink
sudo mklink /j gjo_console C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\localRepositories\ext\gjo\gjo_console


# WIN Powershell Symlink (funktioniert nicht für Composer)
sudo New-Item -ItemType SymbolicLink -Path  C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\Projects\tiger.de\packages\gjo_console -Target C:\Users\gjo\Dropbox\5-Berufsleben\gjoSe\Development\localRepositories\ext\gjo\gjo_console