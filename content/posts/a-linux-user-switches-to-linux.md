+++
date = '2025-09-19T09:32:04+03:00'
draft = false
title = 'My Switch to Linux'
+++

For years I always admired how Linux is so good when it comes to development. And last week my parents bought me a laptop so I decided to install Linux on it. So here's how it went:

# Laptop Specs

I know everybody is going to ask me this so here's a fastfetch


```
             .',;::::;,'.                 jonah@fedora
         .';:cccccccccccc:;,.             ------------
      .;cccccccccccccccccccccc;.          OS: Fedora Linux 42 (KDE Plasma Desktop Edition) x86_64
    .:cccccccccccccccccccccccccc:.        Host: Victus by HP Gaming Laptop 15-fb3xxx
  .;ccccccccccccc;.:dddl:.;ccccccc;.      Kernel: Linux 6.16.7-200.fc42.x86_64
 .:ccccccccccccc;OWMKOOXMWd;ccccccc:.     Uptime: 2 hours, 23 mins
.:ccccccccccccc;KMMc;cc;xMMc;ccccccc:.    Packages: 3159 (rpm), 5 (flatpak)
,cccccccccccccc;MMM.;cc;;WW:;cccccccc,    Shell: bash 5.2.37
:cccccccccccccc;MMM.;cccccccccccccccc:    Display (CMN1560): 1920x1080 @ 144 Hz (as 1671x940) in 16]
:ccccccc;oxOOOo;MMM000k.;cccccccccccc:    DE: KDE Plasma 6.4.4
cccccc;0MMKxdd:;MMMkddc.;cccccccccccc;    WM: KWin (Wayland)
ccccc;XMO';cccc;MMM.;cccccccccccccccc'    WM Theme: Breeze
ccccc;MMo;ccccc;MMW.;ccccccccccccccc;     Theme: Breeze (Dark) [Qt], Breeze [GTK3]
ccccc;0MNc.ccc.xMMd;ccccccccccccccc;      Icons: breeze-dark [Qt], breeze-dark [GTK3/4]
cccccc;dNMWXXXWM0:;cccccccccccccc:,       Font: Noto Sans (10pt) [Qt], Noto Sans (10pt) [GTK3/4]
cccccccc;.:odl:.;cccccccccccccc:,.        Cursor: breeze (24px)
ccccccccccccccccccccccccccccc:'.          Terminal: konsole 25.8.0
:ccccccccccccccccccccccc:;,..             CPU: AMD Ryzen 5 8645HS (12) @ 5.02 GHz
 ':cccccccccccccccc::;,.                  GPU 1: AMD Radeon RX 6500M [Discrete]
                                          GPU 2: AMD Radeon 760M Graphics [Integrated]
                                          Memory: 6.25 GiB / 14.87 GiB (42%)
                                          Swap: 0 B / 8.00 GiB (0%)
                                          Disk (/): 49.58 GiB / 475.35 GiB (10%) - btrfs
                                          Local IP (wlo1): 192.168.1.108/24
                                          Battery (Primary): 100% [AC Connected]
                                          Locale: en_US.UTF-8

```

# Choosing a distribution

While choosing a distribution I was thinking in between Mint and Fedora because they are very user friendly (even though I used NixOS in a virtual machine before) and had a less chance to break my system but since Fedora had more up-to-date packages I decided to use Fedora KDE Edition.

# The Desktop Experience

First thing I did after installing Fedora was installing [hw-probe](https://github.com/linuxhw/hw-probe) and running it to check if there are any drivers missing so I can install them before starting to Linux. But I didn't have to install anything because everything was working out of the box.

It was my first time using KDE and I like to tell that it was very good. In the first days of using KDE I struggled finding some basic programs like Process Manager and KWrite but in a few days I got used to it and using KDE was very nice. I wish Windows had this stable desktop environment. I also tried using window managers like dwl and Sway but it was very hard to customize them because I couldn't find documentation about configuration files for my own setup so I gave up and kept using KDE. Not really related but while web browsing I noticed some of the web pages were shaking a little. I don't know why it happens but I think it's a Wayland issue rather than a driver issue.

Also installing programs were a lot easier in Linux than installing in Windows. I didn't have to find EXE files everywhere around the internet and I didn't have to shut down my system to upgrade the system dependencies.

# DPI Bypassing

Because I was born in a country with a corrupt government I had to install a DPI bypassing tool to access Discord. For those who don't know what DPI means it stands for "Deep Packet Inspection" and is used by governments who wants to block sites from being accessed. And DPI bypassing tools are programs which allow you to bypass the DPI being made by the government. Anyways, I tried using ByeDPI first but it didn't work out so I decided to use Zapret and followed a random guide but that didn't go pretty well too. I lost almost all of my hope and I tried using Zapret with Stubby and that time it worked like a charm.

# Gaming

The only games I really played is Roblox and Minecraft. Roblox doesn't have native Linux support so I had to use [Sober](https://sober.vinegarhq.org/) to play Roblox and Roblox ran buttery smooth. For Minecraft it was already being supported natively on Linux so I installed Prism Launcher and installed "Simply Optimized" for more FPS and Minecraft ran very great too.

# Video Editing

And here's the most annoying part. I tried installing Davinci Resolve because I heard that its a very good video editor but it didn't go well. When I opened Davinci Resolve it didn't come with h264 and h265 codecs and the reason why it didn't come with them is because I was using open source drivers so I had to uninstall it and use Shotcut instead. Shotcut was having bugs that affected user experience as well, like when I tried to insert a text to a video and start typing Shotcut thought I was running keyboard shortcuts and it did random stuff. But at least they had h264 and h265 codecs so I can actually do video editing. I might switch from Shotcut to Kdenlive later.

# Running Windows Apps

I wanted to run Windows apps on linux and for this case I wanted to use Synthesizer V Studio on Linux. A friend of mine had failed to run it but I still wanted to try it out. I installed Bottles and run Synthesizer V on it. Aside from a few annoying bugs that didn't really affect user experience it was still a very stable experience.

I also wanted to run Visual Studio because I know they will require me to use Virtual Studio in college. I saw no one being able to install it on Linux so I installed Tiny10 on a virtual machine and installed Visual Studio. The virtual machine was a bit stuttering but there's nothing really I can do about it.

# Conclusion

Aside from a few annoyances and a few people insulting me because I use Fedora instead of Arch, it was pretty fun to use Linux. I don't think I will ever switch from Linux to Windows.