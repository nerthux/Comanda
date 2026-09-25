# Adoptar Comanda en un proyecto que ya tiene su forma de trabajar

Lo que salió de adoptarlo en un proyecto que ya tenía su forma de trabajar.
Todo en una rama aparte, en su propio worktree, y fundido por una persona.

1. **¿Un push a la principal despliega?** Si sí, primero la CI: que ignore los
   push que sólo tocan documentos (`paths-ignore: ["docs/**", "**.md"]`). Si
   no, cada entrada del buzón despliega.
2. **Los documentos del proyecto pasan a los de Comanda, sin perder nada.** Las
   rutas del método no se configuran: son el método, y los comandos las
   buscan por nombre. Así:
   - el registro de decisiones → `docs/DECISIONES.md`, **conservando sus ids**
     (las nuevas serán `DEC-NNN`) y sus reglas propias en la cabecera;
   - la bitácora de lo hecho → `CHANGELOG.md`, tal cual;
   - lo abierto → `docs/ROADMAP.md` (§1 estado verificado —córrelo, no lo
     copies—, §2 numeración, §3 cola, §4 lo que espera a una persona, con
     fecha y dueño, §5 lo que falta decidir);
   - los planes cerrados → `docs/archivo/`, con una cabecera de histórico que
     diga qué los sustituye; el abierto → `docs/PLAN_<tema>.md`;
   - `docs/BUZON.md` y `docs/archivo/BUZON_descartados.md`, vacíos.
3. **`docs/COMANDA.md`** desde `plantillas/COMANDA.md`. Lo que el proyecto ya
   hacía y el método no sabe va a «Reglas del proyecto»: los comandos las
   respetan como si estuvieran escritas en ellos (por ejemplo: el supuesto
   por defecto en vez de preguntar, el prefijo `docs:` en los commits, la
   cuota limitada).
4. **Los comandos de «Worktree», probados**: monta un worktree con ellos y
   corre ahí la verificación completa. Un enlace a una carpeta ignorada con
   `carpeta/` en `.gitignore` sale como archivo nuevo: el patrón va sin barra.
   El worktree queda en `<raíz>/.worktrees/<tema>`, así que los comandos
   llegan al checkout con `<principal>`, no con `../`: desde ahí, `../` es
   `.worktrees/`.
5. **`.claude/settings.json`**: desde el worktree,
   `claude plugin marketplace add nerthux/Comanda --scope project` y
   `claude plugin install comanda@comanda --scope project`.
6. **`CLAUDE.md` del proyecto**: la sección de forma de trabajo pasa a contar
   el flujo de Comanda y a remitir a `docs/COMANDA.md`. Que no fije la ruta
   del worktree: la pone `/comanda:sprint abrir` en `<raíz>/.worktrees/<tema>`,
   igual para todos los proyectos; si ese `CLAUDE.md` dice otra, se corrige
   el `CLAUDE.md`.
7. **Las ramas en curso del método viejo** se funden como antes; el ROADMAP
   las anota en §3 para que no se pierdan.
8. **El `docs/SPRINT.md` de antes.** Los comandos de Comanda no lo leen: sólo
   avisan que está ahí y remiten a este paso.
   - **Si ya está cerrado** (el marcador de «no hay sprint», o uno terminado
     sin archivar): va a `docs/archivo/SPRINT_<tema>_<fecha de apertura>.md`
     con su cabecera de histórico; si es sólo el marcador, se borra. En ningún
     caso se queda `docs/SPRINT.md`.
   - **Si está abierto, tiene dos salidas:**
     - **Terminarlo con el flujo viejo**, si le queda poco: se entrega y se
       cierra como antes, y el cierre lo archiva como arriba y **borra
       `docs/SPRINT.md`** en vez de dejar el marcador. Mientras siga abierto,
       `/comanda:sprint abrir` no abre otro encima sin que la persona lo
       decida.
     - **Pasarlo a `docs/sprints/<tema>.md`**, si lo que falta se va a hacer
       con Comanda. `<tema>` es el nombre de su rama: los comandos encuentran
       el sprint por la rama. En la rama, `git mv docs/SPRINT.md
       docs/sprints/<tema>.md`, y el archivo toma la forma de uno de Comanda:
       la cabecera fija de `skills/sprint/SKILL.md` (`**Abierto:**`, su fecha
       original; `**Reservas:**`, lo que ya ocupa o «ninguna»), la tabla con
       los estados `pendiente`, `hecho` y `entregado`, y las secciones
       «Decisiones del sprint», «De paso» y «Lo que te toca a ti». Si la rama
       está sacada en el checkout principal, pásala a `<raíz>/.worktrees/<tema>`
       —`git -C <raíz> checkout main`, un `<raíz>/.worktrees/.gitignore` con
       `*` si no existe, y `git -C <raíz> worktree add
       <raíz>/.worktrees/<tema> <tema>`, sin `-b`: la rama ya existe— y ésa
       es la ruta de `**Worktree:**`. Luego publica en la principal la
       versión de la reserva: `comanda-main ruta` → `W`, copia el archivo a
       `W/docs/sprints/<tema>.md`, **quita `W/docs/SPRINT.md`** si la
       principal lo tiene —así lo ven `estado` y `abrir`— y `comanda-main
       publicar --reserva "<mensaje>"`. Por último, rebasa la rama sobre
       `origin/main` y súbela (`--force-with-lease` si ya estaba subida); si choca en el
       archivo del sprint, se queda el de la rama.
9. **Probar antes de fundir**, sin tocar el remoto real: un clon `--bare` en
   una carpeta temporal con la rama puesta como `main`, y ahí
   `/comanda:estado` y `/comanda:sprint abrir`.
