---
name: sprint
description: Abre, entrega o cierra un sprint corto, con techo de tamaño
argument-hint: abrir <tema> | entregar | cerrar [<tema>]
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

$ARGUMENTS

Si no viene `abrir`, `entregar` ni `cerrar`, di las tres formas en una línea y
termina.

**Antes que nada, lee `docs/COMANDA.md` de tu checkout**, antes de la primera
`comanda-main`. De ahí salen las personas y el
cliente, el remoto y la rama principal, el worktree, los techos, el camino
crítico, las numeraciones, las migraciones, la verificación, los recorridos y
las reglas del proyecto. Cuando aquí se nombra una de esas cosas, es lo que ese
archivo dice; si una sección dice `no aplica`, sáltate lo que dependa de ella.
Aquí se escribe `origin` y `main`; si el archivo dice otros, usa ésos, y
antepón `COMANDA_REMOTO=<remoto> COMANDA_PRINCIPAL=<rama>` a cada
`comanda-main`.

**Un comando por llamada.** `allowed-tools` autoriza cada comando suelto;
uno compuesto (`… && …`, `…; …`, `… || …`) se niega y cuesta un turno.
Cada renglón de un bloque va en su propia llamada —los que no dependen uno
de otro, en llamadas paralelas de una misma respuesta—, y en vez de
`cd W && …` se usa `git -C W …`.

**Quién eres:** `git config user.name`, buscado en «Personas». Si no está,
dilo y para: los techos se cuentan por persona.

## Cómo se reparte el trabajo entre varios

- **Un sprint = un dueño, una rama, un worktree**: `<raíz>/.worktrees/<tema>`,
  en la rama `<tema>`. Nadie cambia de rama en el checkout de otro. `<raíz>`
  es la ruta absoluta del checkout principal: la primera línea de
  `git worktree list --porcelain` (`worktree <ruta>`), se corra desde donde se
  corra —también desde dentro del worktree de otro sprint, donde
  `--show-toplevel` daría ese sprint y el nuevo quedaría anidado—. La ruta va
  siempre absoluta. **Si el `CLAUDE.md` del proyecto nombra el worktree de
  otra forma, no lo sigas**: usa ésta de todos modos y di que ese `CLAUDE.md`
  hay que corregirlo: la ruta es fija en todos los proyectos. **Un sprint ya
  abierto sigue en la ruta de su cabecera `**Worktree:**`**, aunque sea otra:
  ésa manda, y nadie la vuelve a construir.
- **Un archivo por sprint: `docs/sprints/<tema>.md`**. Su cabecera es fija y
  los comandos la leen por nombre:

  ```
  # Sprint — <título>

  **Dueño:** <persona> · **Rama:** `<tema>` · **Worktree:** `<raíz>/.worktrees/<tema>` · **Abierto:** <fecha>
  **Reservas:** <numeración> <desde>–<hasta> · … (o «ninguna»)
  **Estado:** abierto
  ```

  `**Estado:**` pasa a `Entregado el <fecha>; lo cierra quien lo revise` al
  entregar. **La versión viva está en la rama del sprint**; la de la principal
  es la de la reserva, y se pone al día al fundir.
- **La principal se escribe sólo con `comanda-main`** —abrir (la reserva),
  triage, buzón y cierre—, nunca con checkout. `comanda-main ruta` imprime un
  worktree de paso —llámalo `W`— con `origin/main` recién traída;
  `comanda-main publicar` lo sube. **El ROADMAP, `DECISIONES.md` y el
  CHANGELOG no se tocan en la rama de un sprint.**
- **Lo numerado se reserva al abrir**, en la principal, y el push es el
  candado: si otro reservó antes, `publicar --reserva` sale con
  `RECHAZADO` (código 3), `W` ya está en lo nuevo, y se recalcula.

**El sprint es la unidad de entrega, no la sesión.** El agente lo **abre** y lo
**entrega**; **lo cierra una persona**, cuando ha revisado lo entregado
—cualquiera de las de «Personas», también quien lo abrió—. Lo que decide el
proyecto está en `docs/DECISIONES.md`; lo que ya se cerró, en `CHANGELOG.md`;
lo que hay que ver con los ojos, en el archivo de recorridos.

## Cuál forma

**Lee entero, antes de hacer nada, el archivo de la forma que pediste**, y
sólo ése:

- `abrir` → `${CLAUDE_SKILL_DIR}/abrir.md`
- `entregar` → `${CLAUDE_SKILL_DIR}/entregar.md`
- `cerrar` → `${CLAUDE_SKILL_DIR}/cerrar.md`
