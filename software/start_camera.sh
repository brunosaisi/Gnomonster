#!/bin/bash

# 1. Inicializa o driver
/home/astronaut/raspberrypi_v4l2/rpi5_scripts/find_entity.sh

# 2. Configura a câmera
/home/astronaut/raspberrypi_v4l2/rpi5_scripts/media_setting_rpi5.sh veyecam2m -fmt UYVY -w 1920 -h 1080

# 3. Cria o loopback (aqui ele vai pedir sua senha no terminal)
sudo modprobe v4l2loopback video_nr=9,10

# Espera 2 segundos para o sistema reconhecer os novos /dev/video9 e 10
sleep 2

# 5. Inicia o FFMPEG em uma NOVA JANELA do Konsole (em paralelo)
konsole -e bash -c "ffmpeg -f v4l2 -i /dev/video9 -f v4l2 -codec:v rawvideo /dev/video10; exec bash" &

# 4. Inicia o GStreamer na JANELA ATUAL
gst-launch-1.0 v4l2src device=/dev/video0 ! "video/x-raw,format=(string)UYVY, width=(int)1920, height=(int)1080" ! videoconvert ! v4l2sink device=/dev/video9
