# Comanda

**El agente olvida todo al cerrar la sesión.** Comanda es un método de trabajo
con agentes, empaquetado como plugin de Claude Code, que parte de eso: ninguna
sesión termina sin escribir de vuelta en el repo, y cada sesión arranca «como
si fuera el primer minuto del día»: lo que no está escrito no pasó. Por la
misma razón sirve para trabajar entre varios: si el estado está en archivos
para el agente de mañana, también está para el compañero de hoy.

Una comanda es el ticket de cocina: se toma la orden en palabras de la mesa,
el jefe de cocina la reparte por estación, cada cocinero trabaja en su tabla, y
el plato sale cuando el cliente lo prueba.

## Los cinco comandos

| Comando | Qué hace |
|---|---|
| `/comanda:buzon <texto>` | Anota en crudo lo que pidió el cliente, sin analizarlo. Diez segundos. |
| `/comanda:triage` | Vacía el buzón: cada entrada va a una de cinco puertas —ya, backlog, medir primero, preguntar, no—. |
| `/comanda:sprint abrir <tema>` | Abre un sprint corto, con techo de tareas, en su propio worktree y su rama. |
| `/comanda:next` | Después de `/clear`: arranca la siguiente tarea del sprint desde lo escrito. |
| `/comanda:sprint entregar` | El agente verifica y entrega; no cierra. |
| `/comanda:sprint cerrar [<tema>]` | Una persona revisa, funde y pone al día el ROADMAP, las decisiones y el CHANGELOG. |
| `/comanda:estado` | En qué va cada sprint, qué hay sin triar y qué le toca a quién. No cambia nada. |

## De dónde sale

No sigue una metodología al pie de la letra: es **Scrumban sin ceremonia**, y
cada pieza tiene un origen reconocible.

| Pieza | Origen |
|---|---|
| Buzón: capturar no es diagnosticar | GTD (David Allen): la bandeja de entrada |
| Triage con cinco puertas (ya, backlog, medir primero, preguntar, no) | GTD, paso de «aclarar»; el nombre, del triage de bugs. «Ya» ≈ regla de los dos minutos |
| Medir primero | el *spike* de XP |
| Sprint de 2–4 días contra un backlog global | Scrum, sin roles, dailies ni puntos |
| `entregar` ≠ `cerrar`; lo cierra el dueño del producto | Definición de Hecho y revisión del sprint de Scrum |
| Techo de tareas por sprint; «uno entregado en espera, nunca dos» | límites de WIP de Kanban |
| El plan de fase no siempre hace falta; se corta por dependencia | Shape Up (Basecamp): *shaping*, apetito fijo, recortar alcance |
| Registro de decisiones con id, «no se re-pregunta» | ADR (Michael Nygard), en versión ligera |
| CHANGELOG al que sólo se agregan entradas | Keep a Changelog |

Lo propio es la primera línea de este README: las metodologías clásicas
suponen un equipo que recuerda, y un agente no recuerda nada.

## Requisitos

- **git 2.31 o más**: `comanda-main` usa `rev-parse --path-format`.
- **bash**: `comanda-main` y las pruebas son guiones de bash.
- **`gh`**, sólo si «Cómo se funde a la principal» en `docs/COMANDA.md` es
  `PR`: lo usan `entregar` y `cerrar`.
- **Un remoto con la principal publicada, aunque se trabaje solo**: el buzón,
  las reservas, el triage y el cierre se publican ahí. Sin ella,
  `comanda-main` se niega y dice que hay que crearla.
- **Que la principal acepte push directo**: el push es el candado. Una
  principal que exige PR para todo push no está soportada; sí se puede
  proteger contra `--force` y contra borrarla. Si el remoto rechaza el push,
  `comanda-main` lo dice con el texto de git, sale con 1 y no descarta nada.
- **Probado sólo en Linux.**

## Instalar

En la raíz del proyecto:

```bash
claude plugin marketplace add nerthux/Comanda --scope project
claude plugin install comanda@comanda --scope project
```

Eso escribe `.claude/settings.json`; se commitea. Quien clone el proyecto y
confíe en la carpeta recibe el plugin.

## Usarlo en un proyecto

Cada proyecto tiene su `docs/COMANDA.md` —quiénes trabajan, el cliente, los
techos, la verificación, las migraciones, el worktree y sus reglas—. Los
comandos son los mismos en todos; lo propio de cada uno vive ahí.

Hay dos caminos, y los dos son una receta para que la siga el agente:

- **Adoptar**: el proyecto ya existe y tiene su forma de trabajar (su
  roadmap, su registro de decisiones) → `plantillas/ADOPTAR.md`.
- **Arrancar**: no hay más que lo que se le propuso al cliente →
  `plantillas/ARRANCAR.md`, que copia el esqueleto `plantillas/proyecto/`.

Las plantillas están en este repo y en la copia instalada,
`~/.claude/plugins/cache/comanda/comanda/<versión>/`.

El repo es el proyecto, no la aplicación: los documentos, los datos y el
código viven juntos, y el código, si lo hay, en su carpeta.

```
docs/            el método (BUZON, ROADMAP, DECISIONES, COMANDA, sprints/) y los papeles del proyecto
datos/           fuera de git; su README.md dice dónde viven   ·   scripts/   ·   entregables/ si los hay
odoo/  o  app/   sólo si hay código; un repo hijo va aparte e ignorado, declarado en prosa en docs/COMANDA.md
.worktrees/      un sprint por carpeta, que crea /comanda:sprint abrir; excluida de git
```

**Si un push a la principal despliega**, que la CI ignore los push de sólo
documentos, o cada entrada del buzón será un deploy (ver
`plantillas/ADOPTAR.md`).

## En equipo

- **Un sprint = un dueño, una rama, un worktree** (`<raíz>/.worktrees/<tema>`,
  dentro del checkout y excluido de git: el proyecto entero queda en una
  carpeta), y un
  archivo, `docs/sprints/<tema>.md`. Nadie le cambia la rama a otro.
- **La rama principal se escribe sólo con `comanda-main`** (`bin/`): el
  buzón, las reservas, el triage y el cierre se publican con push desde un
  worktree de paso, sin tocar el checkout de nadie. Si otro publicó antes, el
  push se rechaza y el número se recalcula: el push es el candado.
- **Todos hacen lo mismo**: capturan, hacen triage, abren, trabajan, entregan,
  cierran y funden. Los techos se cuentan por persona.

## Actualizar

El plugin instalado es una copia. Cada versión nueva sube en
`.claude-plugin/plugin.json`, y cada quien, en cada proyecto:

```bash
claude plugin update comanda@comanda --scope project
```

y reinicia Claude Code. Qué cambió en cada versión está en `CHANGELOG.md`.

## Desarrollar

```bash
claude plugin validate .claude-plugin/plugin.json   # el manifiesto del plugin
bash -n bin/comanda-main                     # la sintaxis
bash pruebas/comanda-main.sh                 # el candado, con dos clones y un remoto local
bash pruebas/sin-citas.sh                    # nada público cita lo privado
shellcheck bin/comanda-main pruebas/comanda-main.sh pruebas/sin-citas.sh pruebas/juguete-worktrees.sh
claude --plugin-dir /ruta/a/Comanda          # probar un cambio sin instalarlo
```

`validate` lleva la ruta del manifiesto y no `.`: con `marketplace.json` en
la misma carpeta, `.` valida sólo el marketplace. El CI corre todo esto en
cada push y PR, menos `validate`. `bash pruebas/juguete-worktrees.sh` prueba
los skills de punta a punta en un repo de juguete; se corre a mano, porque
abre varias sesiones de `claude -p`.

Con `--plugin-dir`, el `bin/` que va primero en el `PATH` es el del plugin
instalado: si el cambio toca `bin/`, antepón `PATH=/ruta/a/Comanda/bin:$PATH`.
Un cambio a un comando se prueba en un repo de juguete y en un proyecto de
verdad, en una rama aparte, antes de darlo por bueno.

## Qué hay aquí

```
.claude-plugin/   plugin.json y marketplace.json
.github/          el CI: la verificación en cada push y PR
skills/           los cinco comandos
bin/comanda-main  escribir en la principal sin tocar el checkout de nadie
plantillas/       COMANDA.md (la configuración), ADOPTAR.md, ARRANCAR.md y
                  proyecto/ (el esqueleto que copia ARRANCAR.md)
pruebas/          las pruebas de comanda-main y la del repo de juguete
CHANGELOG.md      lo que cambió en cada versión
LICENSE           MIT
```

## Licencia

MIT; ver `LICENSE`.
