# Changelog

Lo que cambió en cada versión del plugin. **Lo más nuevo va arriba.** El
formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
las versiones, [SemVer](https://semver.org/lang/es/).

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
