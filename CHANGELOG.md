# Changelog

Lo que cambió en cada versión del plugin. **Lo más nuevo va arriba.** El
formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
las versiones, [SemVer](https://semver.org/lang/es/).

## [0.4.2] — 2026-09-25

### Corregido

- **`/comanda:buzon` saca el id siguiente de los encabezados de las
  entradas**, en el buzón y en los descartados, más el último asunto
  `Buzón:` de la principal; ya no de cualquier `B-` que aparezca en el
  ROADMAP o en `TODO.md`. Un id de otro proyecto citado ahí inflaba la
  numeración.
- **`pruebas/sin-citas.sh` sin rutas revisa también `README.md` y
  `CHANGELOG.md`** del plugin, que son públicos igual; antes había que
  pasárselos a mano.

## [0.4.1] — 2026-09-25

### Corregido

- **`comanda-main publicar` ya no confunde un rechazo del remoto con una
  carrera.** Si el remoto rechaza el push (un hook, una principal
  protegida) y la principal no avanzó, muestra el texto de git, dice que no
  fue una carrera, sale con 1 y no descarta lo anotado, con o sin
  `--reserva`. `RECHAZADO` (3) vuelve a ser siempre una carrera.
- **Dos errores con mensaje propio**: un remoto al que no se llega sale con
  1 y dice el remoto y la URL (antes, el 128 de git); un `.comanda-main/`
  podado a mano, sin su `.git`, sale con 1 y manda a `comanda-main
  descartar` (antes, «already exists»).
- **`/comanda:next` tiene permiso para su primer bloque** (`git branch
  --show-current`, `git status`, `date`): ya no lo pide en cada arranque.
- **`/comanda:buzon` y `sprint cerrar` sin tuberías**: cada comando en su
  propia llamada, como la regla que ellos mismos declaran.

### Añadido

- **«Requisitos» en el README**: git 2.31 o más, bash, `gh` sólo si se
  funde por PR, un remoto con la principal publicada, y que la principal
  acepte push directo (se puede proteger contra `--force` y borrado).
  Probado sólo en Linux.
- **El manifiesto** trae licencia, repositorio, página y palabras clave.
- **Tres casos de prueba** nuevos en `pruebas/comanda-main.sh` (16 en
  total), y `shellcheck` a `pruebas/juguete-worktrees.sh` en el CI.

### Cambiado

- **`claude plugin validate` con la ruta del manifiesto** en «Desarrollar»:
  con `marketplace.json` en la misma carpeta, `.` sólo valida el
  marketplace.

## [0.4.0] — 2026-09-24

Primera versión pública.

### Qué trae

- **Los cinco comandos**: `/comanda:buzon`, `/comanda:triage`,
  `/comanda:sprint` (`abrir`, `entregar` y `cerrar`), `/comanda:next` y
  `/comanda:estado`.
- **`bin/comanda-main`**: escribe en la rama principal desde un worktree de
  paso, sin tocar el checkout de nadie, con el push como candado.
- **Un sprint por worktree**, en `<raíz>/.worktrees/<tema>/`, con su rama y su
  archivo en `docs/sprints/`.
- **Las plantillas**: `COMANDA.md` (la configuración de cada proyecto), la
  receta para adoptar Comanda en un proyecto que ya existe (`ADOPTAR.md`) y la
  de arrancar uno desde cero con el esqueleto `proyecto/` (`ARRANCAR.md`),
  incluido el aviso de un `docs/SPRINT.md` del flujo de antes.
- **Las pruebas** de `comanda-main` con dos clones y un remoto local, la del
  repo de juguete, y el CI que corre la verificación en cada push y PR.
