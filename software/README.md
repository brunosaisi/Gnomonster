<div align="center">

# VEYE mipi IMX462 + Raspberry Pi 5 (building and installing driver on AstroArch) 

[**English**](#-english) • [**Português**](#-português)

</div>

---

## English

This repository is a quick guide/resource to building the `veyecam2m` driver on the Raspberry Pi 5 running **AstroArch** and creating a video pipeline from the VEYE driver to the **INDI** driver for astronomical autoguiding. There is probably a better way of doing it, but for now I'm just happy it works :) If you have any suggestions, feel free to make a pull request.

This README is a simplified version of the [official VEYE repository](https://github.com/veyeimaging/raspberrypi_v4l2) mixed with information available on the VEYE Wiki and other resources.

I still haven't made a GUI for the camera configuration module; you can control the camera via the `veye_mipi_i2c.sh` script in the `i2c_cmd` folder. I recommend you also build the read/write tools from source using the script inside `i2c_cmd/source`, or use the ones in the original VEYE repo—they are the same.

* Camera setup script commands are available on the [VEYE-MIPI-290/327 I2C Wiki](https://wiki.veye.cc/index.php/VEYE-MIPI-290/327_i2c/).

### Post-Installation
The `start_camera.sh` script must be run every time you boot the system to start the video pipeline. It calls the VEYE scripts for driver configuration and starts a **GStreamer + FFmpeg** video pipeline so the INDI V4L2 driver recognizes the sensor data stream.

---

### 🛠️ Building the Drivers Locally
The following operations are performed on the Raspberry Pi.  
Below is an example for the `veyecam2m` driver on **AstroArch `6.18.20-1-rpi`**.

#### 1. Prepare Environment
```bash
sudo pacman -S bc bison flex openssl make git ncurses
```

#### 2. Download Kernel Headers for the Local OS
```bash
sudo pacman -S linux-rpi-headers
```

#### 3. Download Driver Source Code from VEYE
```bash
git clone https://github.com/veyeimaging/raspberrypi_v4l2.git
```

#### 4. Confirm the OS/Kernel Version on Your Raspberry Pi
```bash
$ uname -a
Linux astroarch 6.18.20-1-rpi #1 SMP PREEMPT Wed Mar 25 15:09:28 UTC 2026 aarch64 GNU/Linux
```

#### 5. Patch VEYE Code to Kernel
```bash
git clone https://github.com/veyeimaging/raspberrypi_v4l2.git
```
* **Driver source code:** The camera driver path is `linux/drivers/media/i2c`. Copy the camera module drivers to this path.
* **Modify `Makefile` and `Kconfig`:** Edit the `Kconfig` and `Makefile` in the same path to add the corresponding camera driver.
* **DTS file:** The DTS file path is `linux/arch/arm/boot/dts/overlays`. Copy the `[camera]-overlay.dts` files to this path.
* **Modify DTS `Makefile`:** Edit the `Makefile` in the same path to add the corresponding DTS compilation option.

#### 6. Building the Kernel (for `.dtbo` generation)
Run `prepare.sh` and `build.sh` from [brunosaisi/pibuildkernel](https://github.com/brunosaisi/pibuildkernel).

> **Note:** The files in the adjacent folders already have their `Makefile` and `Kconfig` properly modified for this example, and the included `.dtbo` is what I got from compiling on my system. You can try using it, though I recommend building your own.

> ⚠️ **IMPORTANT:** **DO NOT install the built kernel.** You are building the kernel solely to generate the correct `.dtbo` file.

When placing the compiled driver and `.dtbo` files into the `/release/driver_bin/$(uname -r)` folder:
* Get the `.dtbo` from inside the built kernel's overlay directory (`/linux/arch/arm/boot/dts/overlays`).
* Get the compiled driver (generated using the `make` command) from `/raspberrypi_v4l2/driver_source/cam_drv_src/rpi-6.18.y`.

*Only the `.dtbo` will come from the compiled kernel. Compile the driver after compiling the DTS, making sure the `.dtbo` file is already inside the `/release/driver_bin/$(uname -r)` folder.*

#### 7. Compile Drivers
```bash
cd ~/raspberrypi_v4l2/driver_source/cam_drv_src/rpi-6.18.y
make
```
Done.

#### 8. Compile DTS
```bash
cd ~/raspberrypi_v4l2/driver_source/dts/rpi-6.18.y
./build_dtbo.sh
```
Done.

---

### 📦 Driver Installation
We have saved the code for V4L2 driver mode in this GitHub repository.

#### Download the Driver
```bash
wget https://github.com/veyeimaging/raspberrypi_v4l2/releases/latest/download/raspberrypi_v4l2.tgz
```

#### Install the Driver (Raspberry Pi 5)
```bash
tar -xzvf raspberrypi_v4l2.tgz
cd raspberrypi_v4l2/release/
chmod +x *
sudo ./install_driver_rpi5.sh veyecam2m
```
This will install both `CAM1` and `CAM0` overlays in `/boot/firmware/config.txt` (or `/boot/firm/config.txt`).

#### For Older Raspberry Pi Models
```bash
sudo ./install_driver.sh veyecam2m
```

---

### 🗑️ Uninstall the Driver
If you need to switch to using the camera via `veye_raspicam` software, or if you want to change to a driver for another camera module model, you must first uninstall the current driver:
```bash
sudo ./uninstall_driver.sh veyecam2m
```

#### Verify Video Device
```bash
ls /dev/video0
```
The device node should exist.

---

### 📚 References
* [VEYE Wiki - V4L2 Mode for Raspberry Pi](https://wiki.veye.cc/index.php/V4L2_mode_for_Raspberry_Pi#TCP_streaming)
* [VEYE Imaging Official GitHub Repository](https://github.com/veyeimaging/raspberrypi_v4l2)
* [Raspberry Pi Official Kernel Building Documentation](https://www.raspberrypi.org/documentation/linux/kernel/building.md)
* [VEYE Wiki - VEYE-MIPI-290/327 I2C Commands](https://wiki.veye.cc/index.php/VEYE-MIPI-290/327_i2c/)

[⬆️ Back to top](#veye-camera-driver--indi-pipeline-raspberry-pi-5--astroarch-)

---

## Português

Este repositório é um guia rápido/recurso para compilar o driver `veyecam2m` no Raspberry Pi 5 rodando **AstroArch** e criar um pipeline de vídeo do driver da VEYE para o driver **INDI** visando guiagem astronômica (*autoguiding*). Provavelmente existe uma maneira melhor de fazer isso, mas por enquanto estou feliz que funcione :) Se você tiver alguma sugestão, sinta-se à vontade para abrir um *pull request*.

Este README é uma versão simplificada do [repositório oficial da VEYE](https://github.com/veyeimaging/raspberrypi_v4l2) combinada com informações disponíveis na Wiki da VEYE e outras fontes.

Ainda não criei uma interface gráfica (GUI) para o módulo de configuração da câmera; você pode controlá-la através do script `veye_mipi_i2c.sh` na pasta `i2c_cmd`. Recomendo também compilar as ferramentas de leitura/escrita a partir do código-fonte usando o script dentro de `i2c_cmd/source`, ou usar as do repositório original da VEYE — são idênticas.

* Os comandos do script de configuração da câmera estão disponíveis na [Wiki VEYE-MIPI-290/327 I2C](https://wiki.veye.cc/index.php/VEYE-MIPI-290/327_i2c/).

### Pós-Instalação
O script `start_camera.sh` deve ser executado toda vez que você iniciar o sistema para ativar o pipeline de vídeo. Ele chama os scripts da VEYE para configurar o driver e inicia um pipeline de vídeo **GStreamer + FFmpeg** para que o driver INDI V4L2 reconheça o fluxo de dados do sensor.

---

### 🛠️ Compilando os Drivers Localmente
As operações a seguir são realizadas diretamente no Raspberry Pi.  
Abaixo está um exemplo para o driver `veyecam2m` no **AstroArch `6.18.20-1-rpi`**.

#### 1. Preparar o Ambiente
```bash
sudo pacman -S bc bison flex openssl make git ncurses
```

#### 2. Baixar os Kernel Headers do Sistema Local
```bash
sudo pacman -S linux-rpi-headers
```

#### 3. Baixar o Código-Fonte dos Drivers da VEYE
```bash
git clone https://github.com/veyeimaging/raspberrypi_v4l2.git
```

#### 4. Confirmar a Versão do Sistema/Kernel no seu Raspberry Pi
```bash
$ uname -a
Linux astroarch 6.18.20-1-rpi #1 SMP PREEMPT Wed Mar 25 15:09:28 UTC 2026 aarch64 GNU/Linux
```

#### 5. Aplicar o Patch da VEYE no Kernel
```bash
git clone https://github.com/veyeimaging/raspberrypi_v4l2.git
```
* **Código-fonte do driver:** O caminho do driver da câmera é `linux/drivers/media/i2c`. Copie os drivers do módulo da câmera para este diretório.
* **Modificar `Makefile` e `Kconfig`:** Edite os arquivos `Kconfig` e `Makefile` no mesmo diretório para adicionar o driver da câmera correspondente.
* **Arquivo DTS:** O caminho do arquivo DTS é `linux/arch/arm/boot/dts/overlays`. Copie os arquivos `[camera]-overlay.dts` para este diretório.
* **Modificar o `Makefile` do DTS:** Edite o `Makefile` no mesmo diretório para adicionar a opção de compilação do DTS correspondente.
* os arquivos dentro de software já estão corretamente modificados e compilados como exemplo. Voce pode tentar usar direto, mas recomendo que você baixe o repositório oficial e altere os arquivos e crie os diretórios indicados e compile da fonte. 


#### 6. Compilando o Kernel (para gerar o `.dtbo`)
Execute os scripts `prepare.sh` e `build.sh` de [brunosaisi/pibuildkernel](https://github.com/brunosaisi/pibuildkernel).

> **Nota:** Os arquivos nas pastas adjacentes já possuem seus `Makefile` e `Kconfig` devidamente modificados para este exemplo, e o `.dtbo` incluído é o que obtive ao compilar no meu sistema. Você pode tentar usá-lo, mas recomendo compilar o seu próprio.

> ⚠️ **IMPORTANTE:** **NÃO instale o kernel compilado.** Você está compilando o kernel apenas para gerar o arquivo `.dtbo` correto.

Ao mover o driver compilado e os arquivos `.dtbo` para a pasta `/release/driver_bin/$(uname -r)`:
* Pegue o `.dtbo` de dentro do diretório de overlays do kernel compilado (`/linux/arch/arm/boot/dts/overlays`).
* Pegue o driver compilado (gerado com o comando make) de /raspberrypi_v4l2/driver_source/cam_drv_src/rpi-6.18.y.
Apenas o .dtbo virá do kernel compilado. Compile o driver somente após compilar o DTS, certificando-se de que o arquivo .dtbo já esteja dentro da pasta /release/driver_bin/$(uname -r).

#### 7. Compilar os Drivers
```
bash cd ~/raspberrypi_v4l2/driver_source/cam_drv_src/rpi-6.18.y make 
```

#### 8. Compilar o DTS
```
bash cd ~/raspberrypi_v4l2/driver_source/dts/rpi-6.18.y ./build_dtbo.sh 
```

## 📦 Instalação do Driver
#### Baixar o Driver
bash wget https://github.com/veyeimaging/raspberrypi_v4l2/releases/latest/download/raspberrypi_v4l2.tgz 

#### Instalar o Driver (Raspberry Pi 5)
```
bash tar -xzvf raspberrypi_v4l2.tgz cd raspberrypi_v4l2/release/ chmod +x *
```
```
sudo ./install_driver_rpi5.sh veyecam2m
```
Isso instalará ambos os overlays (CAM1 e CAM0) no arquivo /boot/firmware/config.txt (ou /boot/firm/config.txt).

Para Modelos Antigos de Raspberry Pi
```
bash sudo ./install_driver.sh veyecam2m 
```

#### Listar o Dispositivo de Vídeo
```
bash ls /dev/video0 
```
O nó do dispositivo deve aparecer listado.

## 🗑️ Desinstalar o Driver
Se precisar voltar a usar a câmera pelo software veye_raspicam, ou se quiser trocar para o driver de outro modelo de módulo de câmera, você deve primeiro desinstalar o driver atual:
```
bash sudo ./uninstall_driver.sh veyecam2m 
```

📚 Referências

• Wiki VEYE - Modo V4L2 para Raspberry Pi
• Repositório Oficial VEYE Imaging no GitHub
• Documentação Oficial de Compilação de Kernel do Raspberry Pi
• Wiki VEYE - Comandos I2C VEYE-MIPI-290/327
⬆️ Voltar ao topo
