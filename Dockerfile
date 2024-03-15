FROM ubuntu:20.04
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install wget -y

EXPOSE 5901

RUN apt-get install -y --no-install-recommends tigervnc-standalone-server tigervnc-common

RUN apt-get install -y --no-install-recommends xorg lxde ocl-icd-opencl-dev nano dbus-x11 exiftool
RUN apt-get install -y xterm

# download a trial version for testing
#RUN wget -qO- https://www.ptgui.com/downloads/120200/trial/linux/pro/18738/725c819925672aeaa9159bab86d18627cdb5149d0bfd90dc2b81d68937bcf5bb/PTGui_Pro_12.2_trial.tar.gz | tar xz

# or add a manually downloaded one
#ADD PTGui_Pro_12.2_trial.tar.gz /ptgui/
#RUN cd /ptgui && ls && tar xf /ptgui/PTGui*.tar.gz && rm PTGui*.tar.gz

# or a full version
#wget https://www.ptgui.com/downloads/120300/reg/linux/pro/112640/54da770e3c6598e600a0aafee9ba331f8c6a8d04c1322ccd634a7b83cd485308/PTGui_Pro_12.3.tar.gz
#ADD PTGui_Pro_12.3.tar.gz /ptgui/

# or a newer one (used for SkyGAN auto_processed_20230405_1727 dataset)
#wget https://ptgui.com/downloads/122000/reg/linux/pro/116409/e1a55657f24570834be1ea9778f51ee6f467067031b2b9376f7289ca63b93b2d/PTGui_Pro_12.20.tar.gz
# add if downloaded manually
ADD PTGui_Pro_12.20.tar.gz /ptgui/

# VNC server setup (unused)
#mkdir /root/.vnc
#RUN mkdir ~/.vnc
# run PTGui instead of the desktop environment
#RUN echo /ptgui/PTGui >> ~/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# set a password (overridden with "-SecurityTypes None" due to permission issues)
#RUN echo "put_something_secure_here" | vncpasswd -f >> ~/.vnc/passwd
#RUN chmod 600 ~/.vnc/passwd

# make desktop entries
RUN echo "[Desktop Entry]\nVersion=1.0\nName=PTGui\nExec=/ptgui/PTGui\nTerminal=false\nType=Application\n" > /usr/share/applications/PTGui.desktop

RUN mkdir ~/Desktop
RUN echo "[Desktop Entry]\nType=Link\nName=PTGui\nURL=/usr/share/applications/PTGui.desktop\n" > ~/Desktop/PTGui.desktop

RUN ln -s /work ~/Desktop/work
RUN ln -s /projects ~/Desktop/projects

RUN cd /root/Desktop/ && wget -qN https://rawtherapee.com/shared/builds/linux/RawTherapee_5.9.AppImage
RUN chmod +x ~/Desktop/RawTherapee_*.AppImage
RUN ~/Desktop/RawTherapee_*.AppImage --appimage-extract
RUN ln -s /squashfs-root/usr/bin/rawtherapee-cli /usr/bin/rawtherapee-cli

# add the license file and configuration into the container
ARG hostname
COPY ${hostname}_reg.dat /root/.PTGui/reg.dat
COPY Configuration.xml /root/.PTGui/

# hack: allow running the container as a non-root user
RUN chmod -R a+rwx ~
ENV HOME=/root
ENV APPIMAGE_EXTRACT_AND_RUN=1

#RUN chmod 777 ~ ~/.vnc ~/.vnc/passwd

#CMD ["/usr/bin/vncserver", "-fg", "-geometry", "1280x800"]
CMD ["/usr/bin/vncserver", "-fg", "-SecurityTypes", "None", "-geometry", "1280x800"]
# TODO: re-enable auth (remove "-SecurityTypes None") and set a password if working on a publicly-accessible machine
