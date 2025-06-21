# Loaf Panel Installer

This script automates the installation of the Loaf Panel, Loaf Wings, and other required dependencies on a fresh Linux server.

## Requirements

- A server running a fresh installation of one of the following operating systems:
    - Ubuntu 22.04, 20.04
    - Debian 11, 10
    - Rocky Linux 8
    - AlmaLinux 8
- A valid domain name (or subdomain) pointed to your server's IP address if you wish to use Let's Encrypt for SSL.
- Root access to the server.

## How to Use

1.  **Connect to your server via SSH:**

    ```bash
    ssh root@your_server_ip
    ```

2.  **Download and run the installer script:**

    Copy and paste the following command into your terminal and press Enter. The script will guide you through the installation process.

    ```bash
    bash <(curl -s https://raw.githubusercontent.com/LoafHost/installer/main/install.sh)
    ```

3.  **Follow the on-screen prompts:**

    The installer will ask you a series of questions to configure your Loaf Panel instance, including:
    - Which components to install (Panel, Wings, or both).
    - Database credentials.
    - The domain name for the panel.
    - Whether to configure a firewall.
    - Whether to automatically set up an SSL certificate with Let's Encrypt.
    - Whether to install phpMyAdmin.

Once you answer the questions, the script will handle the rest. After the installation is complete, you can access your new Loaf Panel at the domain you specified.

## Uninstallation

To uninstall the Loaf Panel and its components, you can run the uninstaller script:

```bash
bash <(curl -s https://raw.githubusercontent.com/LoafHost/installer/main/uninstall.sh)
```

This will guide you through removing the panel, wings, and related files.

## Contributors ✨

Copyright (C) 2018 - 2025, Vilhelm Prytz, <vilhelm@prytznet.se>, and contributors!

- Created by [Vilhelm Prytz](https://github.com/vilhelmprytz)
- Maintained by [Linux123123](https://github.com/Linux123123)

Thanks to the Discord moderators [sam1370](https://github.com/sam1370), [Linux123123](https://github.com/Linux123123) and [sinjs](https://github.com/sinjs) for helping on the Discord server!
