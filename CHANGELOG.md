# Changelog

Lo que cambió en cada versión del plugin. **Lo más nuevo va arriba.** El
formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
las versiones, [SemVer](https://semver.org/lang/es/).

## [0.7.0] — 2026-09-29

### Agregado

- **La sección «Repos hijos» de `docs/COMANDA.md`.** Un repo aparte dentro
  del proyecto (`odoo/`, `app/`) se declara en un renglón de forma fija
  —carpeta, clon, base, cuándo se monta y quién lo funde— en lugar de en
  prosa, y los comandos lo leen de ahí. Sin hijo, `no aplica`. `ARRANCAR`,
  `ADOPTAR`, el esqueleto y el README apuntan a ella.
- **`pruebas/juguete-hijos.sh`**: prueba de punta a punta, con `claude -p`,
  un proyecto con tres repos hijos; se corre a mano, como el otro juguete.

### Cambiado

- **`/comanda:sprint abrir` monta cada repo hijo** según su renglón: en la
  rama del sprint si alguna tarea nombra su carpeta, sin rama si sólo se
  monta siempre; lo clona si falta. Para si se corre desde dentro de un
  hijo, o si la raíz no tiene `docs/COMANDA.md`, y dice que la sesión se
  abre en la raíz del proyecto.
- **`/comanda:sprint entregar` y `/comanda:next` no rebasan si el rebase
  toca un repo hijo**: si algún commit del rango toca su carpeta en el repo
  del proyecto, paran y dicen cuál, porque reaplicarlo borraría los archivos
  del worktree del hijo sin avisar.
- **`/comanda:sprint cerrar` funde y limpia el repo hijo**, antes que el
  proyecto: lo funde si lo funde el agente —preguntando antes cuando fundir
  despliega—, o comprueba que una persona ya lo fundió; si algo falla, para
  antes de publicar. Quita el worktree del hijo antes que el del sprint y
  borra su rama, local y remota, sólo si ya está en su base. Una rama del
  hijo que nunca se subió y no tiene nada fuera de su base no lo frena. La
  fila del CHANGELOG cita el commit del hijo.
- Los comandos de «Worktree» corren como `cd <ruta> && <comando>` en la
  misma llamada, la única excepción a un comando por llamada.

## [0.6.0] — 2026-09-29

### Agregado

- **`plantillas/PODAR.md`: la receta para podar un registro de decisiones
  que ya existe.** Aplica a cada fila el filtro de qué entra; lo que no
  pasa —y lo ya tachado— se muda a
  `docs/archivo/DECISIONES_podadas_<fecha>.md` con su id y su texto, y el
  registro deja un párrafo con el rango y el enlace. Una cadena de
  «precisa» se funde en una sola fila. La corre el agente con una persona
  delante: propone la lista y la persona la aprueba antes de mover nada.
  No se borra ni se reusa ningún id.

### Cambiado

- **`/comanda:next`, `/comanda:sprint abrir` y `/comanda:triage` buscan en
  el archivo de podadas un id que no está en el registro**: lo podado
  sigue decidido y no se vuelve a preguntar.

## [0.5.0] — 2026-09-28

### Cambiado

- **`/comanda:sprint cerrar` sube al registro sólo lo que decide.** Cada
  decisión del sprint pasa por un filtro: sube lo que decidió o confirmó
  una persona, o lo que ata fuera del sprint; el detalle se queda en el
  archivo del sprint y un hecho va a la fila del CHANGELOG. Quien cierra ve
  la lista con el destino propuesto de cada una y la corrige antes de que se
  escriba nada; aprobar la lista no confirma las decisiones del agente. Una
  decisión que precisa a otra la tacha, y el archivo del sprint anota el
  destino de cada una.
- **`cerrar` propone como regla lo que se corrigió más de una vez** en el
  sprint, con su renglón para «Reglas del proyecto»; entra sólo si quien
  cierra lo aprueba.
- **`/comanda:next` y `/comanda:sprint abrir` escriben cada decisión de
  sprint con quién la tomó y si ata fuera del sprint**, y fuera de su
  archivo la citan con su tema (`<tema> D3`).
- **La plantilla del registro dice qué entra**, que precisar tacha igual
  que revertir, y cómo se cita una decisión de sprint.

### Corregido

- **`cerrar` no quita el worktree en el que está parada la sesión**: la
  sesión no puede salir de esa carpeta y cada comando fallaría después. Deja
  los comandos, con las rutas puestas, para correrlos desde la raíz.

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
