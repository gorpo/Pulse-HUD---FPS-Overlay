# Pulse HUD - FPS Overlay

![Pulse HUD - FPS Overlay logo](assets/logo-256.png)

Overlay simples para Windows que mostra uso de CPU, GPU, RAM e FPS em uma janela sempre no topo.

Ele foi feito para ser leve, sem instalador e sem dependencias obrigatorias. O overlay e arrastavel por padrao, tem icone na bandeja do Windows e pode ser personalizado por painel grafico.

## Recursos

- CPU total em porcentagem e clock em GHz.
- GPU 3D em porcentagem e uso de memoria dedicada quando o Windows disponibiliza esse contador.
- RAM usada em porcentagem e GB.
- FPS via arquivo simples ou CSV do PresentMon.
- Janela sempre no topo.
- Modo invisivel para iniciar sem terminal.
- Hotkey para mostrar/ocultar.
- Modo somente bandeja/barra do Windows.
- Painel grafico de configuracao.
- Scripts de iniciar, configurar, parar e criar atalho.

## Como usar

Abra:

```text
bin\PulseHUD.exe
```

Para fechar:

```text
scripts\PararOverlay.bat
```

Para testar vendo erros no terminal:

```text
scripts\IniciarOverlayDebug.bat
```

Para configurar visual, tamanho, transparencia, hotkey e inicializacao com Windows:

```text
bin\PulseHUDConfig.exe
```

Para criar um atalho no Desktop:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\CriarAtalhoDesktop.ps1"
```

## Instalar e desinstalar

Para instalar no Windows como aplicativo do usuario atual:

```text
bin\PulseHUDInstall.exe
```

O instalador copia o app para:

```text
%LOCALAPPDATA%\Programs\Pulse HUD - FPS Overlay
```

Ele tambem cria atalhos no Menu Iniciar e registra o app em:

```text
Configuracoes > Aplicativos > Aplicativos instalados
```

Para desinstalar:

```text
bin\PulseHUDUninstall.exe
```

Ou use o proprio Windows em `Aplicativos instalados`.

## Teste rapido

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\SmokeTest.ps1"
```

## Como mudar as coisas

O jeito mais facil e abrir:

```text
bin\PulseHUDConfig.exe
```

O painel salva tudo em:

```text
config\settings.json
```

Voce tambem pode editar esse JSON manualmente. Campos principais:

| Campo | O que muda | Exemplo |
| --- | --- | --- |
| `AppName` | Nome da janela, bandeja e atalhos | `Pulse HUD - FPS Overlay` |
| `Mode` | `Overlay` mostra na tela; `Taskbar` deixa o status na bandeja | `Overlay` |
| `X`, `Y` | Posicao inicial do overlay | `20`, `20` |
| `Width`, `Height` | Tamanho da janela | `238`, `116` |
| `IntervalMs` | Tempo de atualizacao em ms | `1000` |
| `BackgroundColor` | Cor do fundo em HEX | `#0D0F12` |
| `TextColor` | Cor dos valores | `#FFFFFF` |
| `LabelColor` | Cor de FPS/CPU/GPU/RAM | `#DCDCDC` |
| `AccentColor` | Cor da borda | `#7DD3FC` |
| `Opacity` | Transparencia do fundo, de `0` a `1` | `0.86` |
| `FontSize` | Tamanho dos numeros | `16` |
| `LabelFontSize` | Tamanho dos rotulos | `12` |
| `ClickThrough` | `true` deixa clicar atraves do overlay; `false` permite arrastar | `false` |
| `ShowInTaskbar` | Mostra ou oculta na barra de tarefas | `false` |
| `StartWithWindows` | Cria/remove atalho na inicializacao do Windows | `false` |
| `ToggleHotkey` | Atalho global para ocultar/mostrar | `Ctrl+Alt+O` |
| `FpsFile` | Arquivo texto para FPS externo | `%TEMP%\overlay_fps.txt` |
| `PresentMonCsv` | CSV do PresentMon para FPS real | `.runtime\presentmon.csv` |

Depois de salvar pelo painel, o overlay aplica as mudancas sozinho em ate 1 segundo. Se voce editar o JSON manualmente, mantenha strings entre aspas e cores no formato `#RRGGBB`.

## Modo overlay, barra e hotkey

- Para arrastar, deixe `ClickThrough` como `false` e arraste qualquer ponto do overlay.
- Para jogar sem o mouse bater no overlay, marque `ClickThrough` como `true`.
- Para ocultar/mostrar rapidamente, use a hotkey configurada em `ToggleHotkey`.
- Para usar como os overlays que ficam na barra/bandeja do Windows, mude `Mode` para `Taskbar`.
- O icone da bandeja tem menu com `Mostrar/Ocultar`, `Configurar` e `Sair`.

## FPS

CPU, RAM e GPU funcionam direto pelo Windows.

FPS real de jogos precisa de uma fonte externa, porque o Windows nao entrega FPS universal de qualquer jogo para scripts simples. O OverlayLeve aceita duas fontes:

1. Arquivo texto em `%TEMP%\overlay_fps.txt` com um numero de FPS.
2. CSV do PresentMon usando o parametro `-PresentMonCsv`.

Exemplo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File ".\src\OverlayLeve.ps1" -PresentMonCsv "C:\caminho\presentmon.csv"
```

Mais detalhes em [docs/presentmon.md](docs/presentmon.md).

Para baixar o PresentMon automaticamente:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\BaixarPresentMon.ps1"
```

Para iniciar o overlay junto com uma captura do PresentMon:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\IniciarComPresentMon.ps1" -ProcessName "nome-do-jogo.exe"
```

## Configuracao

Exemplo mudando posicao e atualizacao:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File ".\src\OverlayLeve.ps1" -X 40 -Y 60 -IntervalMs 500
```

Parametros uteis:

- `-FpsFile`: arquivo texto usado como fonte simples de FPS.
- `-PresentMonCsv`: CSV do PresentMon usado como fonte de FPS.

As demais opcoes ficam em `config\settings.json` e podem ser editadas pelo painel.

## Personalizacao

O painel permite ajustar:

- Nome exibido.
- Modo `Overlay` ou `Taskbar`.
- Largura, altura e intervalo de atualizacao.
- Cor de fundo, texto, rotulos e acento.
- Transparencia.
- Tamanho do texto e dos rotulos.
- Hotkey para mostrar/ocultar, por padrao `Ctrl+Alt+O`.
- Click-through.
- Mostrar ou nao na barra de tarefas.
- Iniciar com o Windows.

## Logo e icones

Os assets da logo ficam em:

```text
assets\logo.png
assets\logo-256.png
assets\logo-128.png
assets\logo-64.png
assets\logo-32.png
assets\logo.ico
```

O `logo.ico` e usado nos atalhos e no icone da bandeja quando disponivel.

## Estrutura

```text
OverlayLeve/
  assets/logo.png
  assets/logo.ico
  bin/PulseHUD.exe
  bin/PulseHUDConfig.exe
  bin/PulseHUDInstall.exe
  bin/PulseHUDUninstall.exe
  config/settings.json
  src/OverlayLeve.ps1
  src/ConfigurarOverlay.ps1
  src/Launcher.cs
  scripts/IniciarOverlay.vbs
  scripts/ConfigurarOverlay.vbs
  scripts/IniciarOverlayDebug.bat
  scripts/Instalar.ps1
  scripts/Desinstalar.ps1
  scripts/CompilarExecutaveis.ps1
  scripts/PararOverlay.bat
  scripts/CriarAtalhoDesktop.ps1
  scripts/BaixarPresentMon.ps1
  scripts/IniciarComPresentMon.ps1
  docs/presentmon.md
  examples/overlay_fps.txt
  tools/PresentMon.exe
  tests/SmokeTest.ps1
```

## Requisitos

- Windows 10 ou 11.
- Windows PowerShell 5.1.
- Para GPU: contador `GPU Engine` disponivel no Windows.
- Para FPS real: PresentMon ou outro processo escrevendo FPS em arquivo.

## Subir no GitHub

Depois de criar um repositorio vazio no GitHub:

```powershell
git remote add origin https://github.com/seu-usuario/OverlayLeve.git
git branch -M main
git push -u origin main
```

## Release

Para gerar um ZIP local:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\CriarReleaseZip.ps1"
```

O arquivo fica em:

```text
release\Pulse-HUD-FPS-Overlay.zip
```

O release pode incluir esse ZIP se ele continuar pequeno. O projeto tambem pode ser usado direto clonando o repositorio.

## Licenca

MIT.
