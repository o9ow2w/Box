#!/bin/bash
docker stop xfce-vnc-container
docker rm xfce-vnc-container


# Define the new Docker data directory
DOCKER_DATA_DIR="$HOME/docker-data"
DOCKERFILE_DIR="$HOME/todomundo"




# Create the new directory for Docker data
echo "Creating new Docker data directory at $DOCKER_DATA_DIR..."
mkdir -p "$DOCKER_DATA_DIR"




# Move existing Docker data to the new directory (if it exists)
if [ -d /var/lib/docker ]; then
   echo "Moving existing Docker data to $DOCKER_DATA_DIR..."
   sudo mv /var/lib/docker/* "$DOCKER_DATA_DIR/"
else
   echo "No existing Docker data found in /var/lib/docker."
fi




# Create or modify the Docker daemon configuration file
echo "Configuring Docker to use the new data directory..."
sudo bash -c "cat << EOF > /etc/docker/daemon.json
{
 \"data-root\": \"$DOCKER_DATA_DIR\"
}
EOF"




# Restart Docker service (if applicable)
if command -v service &> /dev/null; then
   echo "Restarting Docker service..."
   sudo service docker restart
else
   echo "Docker service management not available. Please restart Docker manually."
fi




# Verify the new Docker root directory
echo "Verifying the new Docker root directory..."
docker info | grep "Docker Root Dir"




# Create the Dockerfile directory
echo "Creating Dockerfile directory at $DOCKERFILE_DIR..."
mkdir -p "$DOCKERFILE_DIR"




# Create the Dockerfile in the specified directory
echo "Creating Dockerfile in $DOCKERFILE_DIR..."


cat << 'EOF' > "$DOCKERFILE_DIR/Dockerfile"
# Use the latest version of Debian as the base image
FROM debian:latest


# Set the environment to non-interactive
ENV DEBIAN_FRONTEND=noninteractive


# Update the system and install necessary packages
RUN apt-get update && apt-get install -y \
   xfce4 \
   xfce4-goodies \
   sudo \
   tightvncserver \
   xauth \
   x11-utils \
   wget \
   neofetch \
   vim \
   nano \
   htop \
   curl \
   git \
   novnc \
   websockify \
   dbus-x11 \
   firefox-esr \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*


# Create a user named "Paco" and add it to the sudo group
RUN useradd -m Paco && echo "Paco:Tete0909" | chpasswd && \
   usermod -aG sudo Paco


# Create the .vnc directory and set the password
RUN mkdir /home/Paco/.vnc && \
   echo "Tete0909" | vncpasswd -f > /home/Paco/.vnc/passwd && \
   chown -R Paco:Paco /home/Paco/.vnc && \
   chmod 600 /home/Paco/.vnc/passwd


# Create the Desktop directory
RUN mkdir -p /home/Paco/Desktop


# Create the startup file for VNC
RUN echo '#!/bin/sh\n' \
   'xrdb $HOME/.Xresources\n' \
   'startxfce4 &\n' \
   'setxkbmap es\n' \
   > /home/Paco/.vnc/xstartup && \
   chmod +x /home/Paco/.vnc/xstartup && \
   chown Paco:Paco /home/Paco/.vnc/xstartup


# Create a desktop entry for Firefox
RUN echo '[Desktop Entry]\n' \
   'Version=1.0\n' \
   'Name=Firefox\n' \
   'Comment=Navegador web\n' \
   'Exec=firefox\n' \
   'Icon=firefox\n' \
   'Terminal=false\n' \
   'Type=Application\n' \
   'Categories=Network;WebBrowser;\n' \
   > /home/Paco/Desktop/firefox.desktop && \
   chmod +x /home/Paco/Desktop/firefox.desktop && \
   chown Paco:Paco /home/Paco/Desktop/firefox.desktop


# Install LibreWolf
RUN apt-get update && apt-get install -y extrepo && \
   extrepo enable librewolf && \
   apt-get update && apt-get install -y librewolf


# Create a desktop entry for LibreWolf after installation
RUN echo '[Desktop Entry]\n' \
   'Version=1.0\n' \
   'Name=LibreWolf\n' \
   'Comment=Privacy-focused web browser\n' \
   'Exec=librewolf\n' \
   'Icon=librewolf\n' \
   'Terminal=false\n' \
   'Type=Application\n' \
   'Categories=Network;WebBrowser;\n' \
   > /home/Paco/Desktop/librewolf.desktop && \
   chmod +x /home/Paco/Desktop/librewolf.desktop && \
   chown Paco:Paco /home/Paco/Desktop/librewolf.desktop


# Expose ports for VNC and noVNC
EXPOSE 5901 8080


# Command to start D-Bus, the VNC server, and noVNC
CMD ["sh", "-c", "service dbus start && su - Paco -c 'vncserver :1 -geometry 1920x1080 -depth 24 && websockify --web /usr/share/novnc/ 8080 localhost:5901'"]
EOF


echo "Dockerfile created in $DOCKERFILE_DIR."




# Build the Docker image
echo "Building Docker image..."
docker build -t xfce-vnc "$DOCKERFILE_DIR"




# Run the Docker container
echo "Running Docker container..."
docker run -d -p 8080:8080 -p 5901:5901 --name xfce-vnc-container --security-opt seccomp=unconfined xfce-vnc




echo "Setup complete. The container is running."
echo ""
echo ""
echo ""
echo "Borrar Contenedor:"
echo ""
echo "docker stop xfce-vnc-container"
echo "docker rm xfce-vnc-container"
echo ""
echo ""
echo "Para pasar ficheros al docker:"
echo ""
echo "docker cp nombreRutaArchivo xfce-vnc-container:/home/Paco"
echo ""
echo ""
echo "Para pasar ficheros a la real:"
echo "docker cp xfce-vnc-container:/home/Paco/nombreArchivo rutaDestinoLocal"
echo ""
echo ""
echo "Acceder al contenedor:"
echo ""
echo "docker exec -it xfce-vnc-container /bin/bash"
echo ""
echo ""
