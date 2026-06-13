# OverlayLeve

Overlay simples para Windows que mostra uso de CPU, GPU, RAM e FPS em uma janela sempre no topo.

Ele foi feito para ser leve, sem instalador e sem dependencias obrigatorias. O overlay e click-through por padrao, entao fica por cima da tela sem roubar clique.

## Recursos

- CPU total em porcentagem.
- GPU 3D via contadores nativos do Windows.
- RAM usada em porcentagem e GB.
- FPS via arquivo simples ou CSV do PresentMon.
- Janela sempre no topo.
- Modo invisivel para iniciar sem terminal.
- Scripts de iniciar, parar e criar atalho.

## Como usar

Abra:

```text
scripts\IniciarOverlay.vbs
```

Para fechar:

```text
scripts\PararOverlay.bat
```

Para testar vendo erros no terminal:

```text
scripts\IniciarOverlayDebug.bat
```

Para criar um atalho no Desktop:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\CriarAtalhoDesktop.ps1"
```

## Teste rapido

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tests\SmokeTest.ps1"
```

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

- `-X` e `-Y`: posicao inicial.
- `-IntervalMs`: intervalo de atualizacao.
- `-Opacity`: opacidade do fundo.
- `-NoClickThrough`: permite clicar/selecionar a janela do overlay.
- `-FpsFile`: arquivo texto usado como fonte simples de FPS.
- `-PresentMonCsv`: CSV do PresentMon usado como fonte de FPS.

## Estrutura

```text
OverlayLeve/
  src/OverlayLeve.ps1
  scripts/IniciarOverlay.vbs
  scripts/IniciarOverlayDebug.bat
  scripts/PararOverlay.bat
  scripts/CriarAtalhoDesktop.ps1
  scripts/BaixarPresentMon.ps1
  scripts/IniciarComPresentMon.ps1
  docs/presentmon.md
  examples/overlay_fps.txt
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

## Licenca

MIT.
