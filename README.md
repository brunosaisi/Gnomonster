# Gnomonster: Astrophotography Instrumentation & Automation 🌌🔭

Gnomon: do grego significa relógio solar, uma ferramenta rudimentar para acompanhamento dos astros.
Ster: sufixo germânico que indica quem faz alguma coisa. De forma que Gnomonster é "quem faz gnomon".

O Gnomonster é um ecossistema de instrumentação para astronomia e astrofotografia amadora de baixo custo e código aberto voltado para automatizar hardware astronômico analógico e contornar imperfeições na mecânicas da montagem.

O projeto combina engenharia mecânica de precisão (CAD/impressão 3D), compilação do Kernel Linux embarcado no Raspberry Pi 5, automação de firmware em microcontroladores e pipelines de vídeo em tempo real para viabilizar astrofotografia de céu profundo com GoTo, guiagem responsiva e controle remoto via wifi.

---

## 🏗️ Arquitetura do Sistema e Contribuições Técnicas

### 1. Engenharia Mecânica e Óptica (CAD & Prototipagem)
Para mitigar folgas axiais, atritos e reflexões internas que destroem a relação sinal-ruído das imagens, o projeto envolveu desenvolvimento mecânico sob medida:
* **Restauração da Montagem EQ3:** Modelagem e usinagem/impressão de buchas internas e suportes customizados para acoplamento de rolamentos nos fusos infinitos, eliminando o *backlash* mecânico.
* **Defletores Internos (OTA):** Modelagem computacional e impressão 3D (PLA) de defletores internos cônicos para o tubo óptico (refrautor dubleto 70mm f7), otimizados para reter reflexões espúrias e maximizar o contraste estelar (comprovação empírica documentada no repositório).
* **Suportes Estruturais:** Anéis de fixação para o tubo principal e luneta de guiagem com sistema de engate rápido integrado para o padrão de trilhos *Vixen* e sapata para alinhamento laser.

### 2. Linux Embarcado e Pesquisa de Baixo Nível (Raspberry Pi 5 & VEYE MIPI)
A migração para a arquitetura do Raspberry Pi 5 introduziu barreiras severas de compatibilidade de hardware devido às mudanças drásticas no subsistema de câmera (mudança para subsistema *RP1* e *libcamera*). 
* **Customização de Kernel:** Realização de engenharia reversa e pesquisa bibliográfica avançada baseada nos repositórios da VEYE para adaptar o driver do sensor IMX462 ao Raspberry Pi 5.
* **Compilação de Device Trees (.dtbo):** Processo manual de compilação e injeção do overlay de árvore de dispositivos (`dtbo`) diretamente na partição de boot do **Astroarch (Arch Linux ARM)**, permitindo que a interface MIPI-CSI reconhecesse nativamente o módulo de visão industrial. *(O passo a passo e os binários corrigidos estão disponíveis na pasta `/embedded-software/kernel-compilation`)*.

### 3. Pipeline de Vídeo em Tempo Real (Shell Script / GStreamer / FFmpeg)
Os drivers nativos fornecidos pelo fabricante não eram integrados ao ecossistema astronômico Linux. A solução foi desenvolver um script em **Shell (Bash)** que cria uma ponte lógica de dados em tempo real:
* **Ingestão:** Captura o fluxo digital bruto vindo do barramento MIPI-CSI via **GStreamer**.
* **Transcodificação Dinâmica:** O feed é tunado por comandos **FFmpeg** em linha de comando, permitindo o controle exato do tempo de exposição contínua do sensor (frames de até 1s) para mitigar ruidos térmicos.
* **Emulação V4L2:** Injeta o fluxo processado em um dispositivo de vídeo em loopback simulado (`/dev/videoX` via Video4Linux2), tornando o feed do sensor industrial 100% legível e compatível com o módulo de guiagem autônoma do **Ekos (PHD2 Engine)**.

### 4. Orquestração de Firmware Astronômico (OnStepX)
* Integração da placa controladora de motores de passo **FYSETC E4** ao ecossistema por meio do firmware open-source **OnStepX**.
* Calibração fina dos passos por arcosegundo baseada na redução mecânica das coroas da EQ3, permitindo comandos responsivos de micro-correções enviados via protocolo de sockets de rede distribuída **INDI**.

---

## 📉 Viabilidade Econômica (Preços Praticados no Brasil em novembro de 2026)

O projeto Gnomonster foi desenvolvido sob a filosofia de computação aberta e quebra de *vendor lock-in*. Ao extrair o potencial máximo de hardwares genéricos de prateleira por meio de Linux Embarcado, automação de firmware e pipelines customizadas, o sistema entrega **maior poder computacional e recursos equivalentes por uma fração do custo comercial nacionalizado**:

| Componente / Recurso    | Ecossistema Comercial Proprietário (ZWO / Sky-Watcher)| Solução Gnomonster (Arquitetura Aberta)   |
| :---------------------- | :---------------------------------------------------- | :-------------------------------------    |
| **Computação Central**  | R$ 9.439,00 [ZWO ASIAIR Plus 4GB RAM]                 | R$ 1.044,90 [Raspberry Pi 5 8GB RAM]      |
| **Armazenamento**       | (256GB eMMC proprietário soldado)                     | R$   250,00 [SSD NVMe 128GB + NVMe HAT]   |
| **Sensor de Guiagem**   | R$ 2.100,00 [Câmera ZWO Equivalente IMX462]           | R$   498,00 [Módulo VEYE MIPI IMX462]     |
| **Placa Controladora**  | (Inclusa na placa-mãe interna da montagem GOTO)       | R$   280,00 [Placa FYSETC E4 (OnStepX)]   |
| **Motores de Passo**    | (Inclusos nos blocos selados de fábrica)              | R$   160,00 [Par de Motores NEMA 17 400P] |
| **Estrutura / Montagem**| R$ 6.599,00 [Montagem Equatorial EQ3 Pro GOTO]        | R$   500,00 [Montagem EQ3 genérica Usada] |
| **Licenciamento**       | Proprietário Trancado (Apenas dispositivos ZWO)       | 100% Open-Source (INDI Core Protocol)     |
| **CUSTO TOTAL**         | **~ R$ 18.138,00**                                    | **~ R$ 2.732,90**                         |

### 🚀 Diferencial de Engenharia:
* **Redução de Custo de ~85%:** A engenharia reversa e a montagem do ecossistema open-source geraram uma economia real de mais de R$ 15.000,00 em comparação ao hardware proprietário nacionalizado.
* **Performance Computacional Superior:** O processador ARM Cortex-A76 (RPi5) de última geração com 8GB de RAM executa o pipeline em tempo real via GStreamer e FFmpeg sem qualquer travamento, superando os hubs comerciais baseados em microarquiteturas legadas.

---

## 🧰 Referências a Projetos Upstream Utilizados
Para evitar a replicação desnecessária de código, este repositório consome e integra as seguintes soluções estáveis da comunidade open-source (links e instruções de espelhamento na pasta `/embedded-software/`):
* [OnStepX](https://onstep.groups.io/g/main/wiki/32747) - Firmware de automação de montagens robóticas.
* [Astroarch Linux](https://github.com/devDucks/astroarch) - Distribuição Linux embarcada de alta performance baseada em Arch Linux para ARM64.
* [VEYE Imaging RPi Camera](https://github.com/veyeimaging/raspberrypi_v4l2) - Repositório oficial da Veye para v4l2

## 📄 Licença
Este projeto está sob a licença Própria - veja o arquivo [LICENSE](LICENSE) para detalhes.
