FROM ubuntu:20.04
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

RUN apt-get install wget -y

EXPOSE 5901

RUN apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common
RUN apt-get install -y --no-install-recommends xorg lxde ocl-icd-opencl-dev nano dbus-x11 exiftool
RUN apt-get install -y xterm

#! Manually download PTGui Pro and save it next to the Dockerfile, e.g. `wget https://ptgui.com/downloads/122000/reg/linux/pro/116409/e1a55657f24570834be1ea9778f51ee6f467067031b2b9376f7289ca63b93b2d/PTGui_Pro_12.20.tar.gz`
ADD PTGui_Pro_12.20.tar.gz /ptgui/

# Add desktop shortcuts
RUN echo "[Desktop Entry]\nVersion=1.0\nName=PTGui\nExec=/ptgui/PTGui\nTerminal=false\nType=Application\n" > /usr/share/applications/PTGui.desktop
RUN mkdir ~/Desktop
RUN echo "[Desktop Entry]\nType=Link\nName=PTGui\nURL=/usr/share/applications/PTGui.desktop\n" > ~/Desktop/PTGui.desktop
# and link folders for easier access (adapt if you use different data paths)
RUN ln -s /work ~/Desktop/work
RUN ln -s /projects ~/Desktop/projects

# Install RawTherapee
RUN cd /root/Desktop/ && wget -qN https://rawtherapee.com/shared/builds/linux/RawTherapee_5.9.AppImage
RUN chmod +x ~/Desktop/RawTherapee_*.AppImage
RUN ~/Desktop/RawTherapee_*.AppImage --appimage-extract
RUN ln -s /squashfs-root/usr/bin/rawtherapee-cli /usr/bin/rawtherapee-cli

# Add the PTGui config file and the activation ticket
#! First, comment the following lines, build the image `docker build -t docker-gui .` and run it, connect via VNC, run PTGui and activate with your license as usual, then copy the activation ticket file from /root/.PTGui/reg.dat outside the container and stop the container.
#! Save the activation ticket file next to this Dockerfile and prepend it with "*your machine hostname*_". Then un-comment the following lines and and rebuild the image with the name "docker-gui-reg".
#! This is to avoid manual activation whenever a new container is created by `docker run`. Do all this on the machine(s) you intend to use PTGui on since the activation ticket is not transferrable, and make sure to NOT exceed the number of machines your license is valid for.
ARG hostname
COPY ${hostname}_reg.dat /root/.PTGui/reg.dat
COPY Configuration.xml /root/.PTGui/

# hack: allow running the container as a non-root user
RUN chmod -R a+rwx ~
ENV HOME=/root
ENV APPIMAGE_EXTRACT_AND_RUN=1

#! No authentication; make sure it is not openly accessible on a machine reachable by untrusted users (e.g. publish the port only locally via `docker run ... -p 127.0.0.1:5901:5901 ...`)
CMD ["/usr/bin/vncserver", "-fg", "-SecurityTypes", "None", "-geometry", "1280x800"]
