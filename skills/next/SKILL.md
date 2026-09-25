---
name: next
description: Arranca la siguiente tarea del sprint, con el contexto recién limpio
argument-hint: (sin argumentos) | <número de tarea>
disable-model-invocation: true
allowed-tools: Bash(git config user.name), Bash(git fetch:*), Bash(git show:*), Bash(git ls-tree:*), Bash(git merge-base:*), Bash(git log:*)
---

$ARGUMENTS

Esto se teclea **justo después de `/clear`**: la sesión anterior ya se fue y
hay que volver a montar el contexto de la tarea que sigue, sin arrastrar el de
la anterior. Un comando no puede limpiar por su cuenta —`/clear` lo teclea
quien está trabajando—, así que **aquí se empieza como si fuera el primer
minuto del día**: no supongas nada de lo que se habló antes; lo que no esté
escrito en el archivo del sprint o en el plan, no pasó.

**No es `/comanda:estado`.** `/comanda:estado` cuenta en qué vas; esto
**arranca trabajo**. Tampoco es `/comanda:sprint abrir`: el sprint ya está
abierto y su techo ya se verificó.

## Qué mirar, en este orden

Todo de sólo lectura y barato; no corras la verificación todavía.

**Un comando por llamada.** `allowed-tools` autoriza cada comando suelto;
uno compuesto (`… && …`, `…; …`, `… || …`) se niega y cuesta un turno.
Cada renglón de un bloque va en su propia llamada —los que no dependen uno
de otro, en llamadas paralelas de una misma respuesta—, y en vez de
`cd W && …` se usa `git -C W …`.

```bash
git branch --show-current
git status --short
git log --oneline -5
git config user.name
date +%F
```

Aquí se escribe `origin` y `main`: son el remoto y la principal de «Ramas» en
`docs/COMANDA.md`. Si dice otros, usa ésos —en el `fetch`, el buzón, el
rebase, el push de la rama y el candado— y antepón `COMANDA_REMOTO=<remoto>
COMANDA_PRINCIPAL=<rama>` a cada `comanda-main`. Si no hay `docs/COMANDA.md`,
son `origin` y `main`.

**El `docs/SPRINT.md` de antes**, antes de buscar tarea:

```bash
git fetch origin
git ls-tree --name-only origin/main docs/SPRINT.md
git ls-tree --name-only HEAD docs/SPRINT.md
```

Si alguno de los dos `ls-tree` lo imprime, dilo con la línea de
`/comanda:estado`: «Hay un `docs/SPRINT.md` en `origin/main` (o en tu rama, o
en las dos): es del flujo de antes y los comandos de Comanda no lo leen; qué
hacer con él está en `plantillas/ADOPTAR.md` de Comanda, «El `docs/SPRINT.md`
de antes».» Y **sigue**: no frena a `next`. Si estás en la rama de ese sprint
viejo, eso explica por qué abajo no aparece el tuyo. Si no está en ninguna, no
digas nada.

**Tu sprint** es el `docs/sprints/*.md` cuya `**Rama:**` es la rama en que
estás parado. Si no hay ninguno —estás en la principal, o en una rama que no
es de un sprint—, no arranques nada: lista los sprints abiertos de quien corre
el comando (su `git config user.name` en «Personas» de `docs/COMANDA.md`,
contra el `**Dueño:**` de cada cabecera en `origin/main`, tras un
`git fetch origin`), di la ruta de su `**Worktree:**` tal como la dice la
cabecera —no la construyas: un sprint abierto antes sigue en la suya— y que
ahí se abre la sesión. Si no tiene ninguno, toca **`/comanda:sprint abrir`**.

Lee, completos: `docs/COMANDA.md` (las personas, el worktree, las
migraciones, la verificación y las reglas del proyecto), el archivo del sprint
(la cabecera con sus reservas, la tabla de tareas, el detalle de la tarea que
toca, «Decisiones del sprint», «Lo que te toca a ti» y «De paso») y **el plan
de fase que cite su cabecera**, si lo hay. De `docs/DECISIONES.md` lee sólo las
decisiones que el sprint cita por id: **lo que está ahí no se re-pregunta**.

Si algo del árbol discrepa con lo anotado —la rama no es la del sprint, hay
cambios sin commitear, la migración que el sprint dice entregada no está en la
carpeta de migraciones— **dilo antes de arrancar y para**. Una discrepancia se
aclara antes, no a media tarea.

## Cuál es la tarea

- **Sin argumento:** la **primera tarea de la tabla que no esté `hecho` ni
  `entregado`**, de arriba abajo. Si la línea «Lo que sigue» del sprint dice
  otra, manda la tabla, pero **dilo en una línea**.
- **Con un número** (`/comanda:next 4`): ésa, aunque haya pendientes antes. Si
  ya estaba `hecho`, dilo y pregunta antes de rehacerla.
- **Si todas están `hecho` o `entregado`:** no inventes trabajo ni te adelantes
  al ROADMAP. Di cuál es el caso y termina:
  - falta la verificación o algún archivo al día → toca
    **`/comanda:sprint entregar`**;
  - ya está entregado, esperando revisión → **lo cierra una persona** con
    `/comanda:sprint cerrar <tema>`, y mientras tanto quien lo abrió puede
    abrir el siguiente con **uno** en espera, nunca con dos.
- Si el buzón de `origin/main` tiene entradas sin triar, **menciónalo en media
  línea y sigue**:
  un sprint ya abierto no se detiene por el buzón (eso sólo frena
  `/comanda:sprint abrir`).

## Antes de escribir una sola línea

1. **Entra en modo plan** —es la regla para cada tarea— y contrasta con §2 y
   §4 del plan de fase antes de proponer nada.
2. Comprueba contra el árbol lo que la tarea vaya a tocar: si hay migración, la
   carpeta de migraciones, las de pruebas y sus notas mandan sobre cualquier
   documento. **Los números que usa el sprint son los de sus `**Reservas:**`**,
   no «el más alto + 1»: otro sprint puede estar ocupando el siguiente en su
   rama. Si hace falta uno más de lo reservado, resérvalo como lo hace
   `/comanda:sprint abrir` (`comanda-main ruta` con el remoto de «Ramas», el
   siguiente libre contando las reservas de todos, la cabecera del sprint
   **en `W`** al día, `comanda-main publicar --reserva`). Ese `publicar`
   movió la principal y tu rama ya no la contiene —el candado de migración
   fallaría—: **rebasa** (`git fetch origin`, `git rebase origin/main`), que
   de paso trae la nueva línea de reservas a tu archivo del sprint, y si la
   rama ya estaba subida, `git push --force-with-lease origin <tema>`. Si el
   rebase choca en el archivo del sprint, se queda el de la rama —es el
   vivo— con la línea nueva de reservas. Con cambios sin commitear no se
   rebasa: hazlo al commitear la tarea, antes del candado y del push.
3. Di **qué vas a verificar y con qué comando** —de «Verificación» en
   `docs/COMANDA.md`, los que toquen a la tarea, con los recursos separados
   que diga «Worktree»— antes de empezar, no después.

## Qué contestar al arrancar

Cinco líneas, no más, y luego el plan:

1. **La tarea:** número, título y de qué va, en una línea.
2. **Dónde estás:** rama, si el árbol está limpio, último commit.
3. **Qué la rige:** el plan de fase y las decisiones que cita, por id.
4. **Qué la bloquea, si algo** —de «Lo que te toca a ti»—. Si la tarea depende
   de algo que le toca a una persona (desplegar, cargar datos, fundir una rama),
   **dilo antes de planear**: quizá toca la siguiente.
5. **Cómo se comprueba** que quedó bien.

## Cuando termines

La tarea no está lista hasta que esté **escrita de vuelta**, en este orden:
el archivo del sprint (el estado de la tarea, y en «Decisiones del sprint» lo
que se decidió, como `D1`, `D2`…), las notas de migraciones (si hubo
migración) y el archivo de recorridos (si cambió una pantalla). **El ROADMAP,
`DECISIONES.md` y el CHANGELOG no se tocan en la rama del sprint**: los pone al
día quien cierre. Un commit por tarea, en español y con el porqué en el
cuerpo, **y se sube la rama** (`git push origin <tema>`): así el otro ve en qué
vas.

**El porqué no se inventa.** El del cuerpo del commit y el de cada `D1`,
`D2`… sale de algo escrito —el archivo del sprint, el plan, una decisión, el
buzón—, de algo que una persona dijo en esta sesión o de lo que mediste en la
tarea. Si no lo hay, **pregunta antes de commitear**; si no hay a quién
preguntar (una corrida sin persona), escribe «el porqué no quedó escrito» en
vez de uno que suene bien. Un commit subido no se corrige.

**Sin tocar producción**, salvo lo que «Migraciones» en `docs/COMANDA.md` diga
que aplica el agente. Antes de aplicar una, **el candado**:

```bash
git fetch origin
git merge-base --is-ancestor origin/main HEAD
```

Si el segundo sale con código distinto de 0, la rama no tiene lo último de
la principal —quizá otro sprint ya aplicó y fundió una migración—: **para**,
di qué le falta y propón rebasar antes. Luego los «Candados» del proyecto, si
los hay. Después la aplicas como ahí se dice y anotas «aplicada el …» en sus
notas y en el archivo del sprint.
El aviso al cliente va después y lo manda una persona.

Y lo que aparezca a media tarea **se captura, no se hace**: va al buzón como
lo hace `/comanda:buzon` (`comanda-main ruta` con el remoto de «Ramas», el
siguiente id dentro de `W`, la entrada literal, `comanda-main publicar
--reserva`) y sigues con lo tuyo, salvo que te bloquee.
