---
name: estado
description: En qué va cada sprint, qué hay sin triar y qué le toca a quién
argument-hint: (sin argumentos)
disable-model-invocation: true
allowed-tools: Bash, Read
---

Dime en qué va el proyecto. **No cambies nada**: ni un archivo, ni un commit, ni
una rama. Es el comando de "volví después de tres días y no sé dónde estaba".
Con varias personas, también es el de "¿en qué anda el otro?".

## Qué mirar

Todo de sólo lectura, y **del árbol, no de los documentos**. Los documentos
dicen lo que alguien anotó; el árbol dice lo que hay. Cuando discrepen, manda el
árbol y **dilo**: una discrepancia es el primer síntoma de que el roadmap se
está desfasando otra vez.

Lee primero `docs/COMANDA.md`: de ahí salen las personas, el remoto y la rama
principal (aquí `origin` y `main`), los techos, las numeraciones, las
migraciones, los recorridos y el camino crítico.

**Lo compartido se lee de `origin/main`, no de tu checkout**: tu checkout puede
estar en la rama de un sprint o atrasado. Primero `git fetch origin`, y luego
`git show origin/main:<archivo>` para el buzón, el ROADMAP y los sprints.

**Un comando por llamada.** `allowed-tools` autoriza cada comando suelto;
uno compuesto (`… && …`, `…; …`, `… || …`) se niega y cuesta un turno.
Cada renglón de un bloque va en su propia llamada —los que no dependen uno
de otro, en llamadas paralelas de una misma respuesta—, y en vez de
`cd W && …` se usa `git -C W …`.

```bash
git fetch origin
git status --short
git branch --show-current
git config user.name
git log --oneline -8
git rev-list --count HEAD..origin/main    # cuánto le falta a tu rama de main
git branch -r --no-merged origin/main     # ramas sin fundir, de todos
git worktree list
git ls-tree --name-only origin/main docs/sprints/
git ls-tree --name-only origin/main docs/archivo/
git ls-tree --name-only origin/main docs/SPRINT.md   # el del flujo viejo, en main
git ls-tree --name-only HEAD docs/SPRINT.md          # y en tu rama
git show origin/main:docs/ROADMAP.md | wc -l    # contra el techo
git show origin/main:docs/ROADMAP.md | grep -oE '^\- \*\*[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | uniq -c   # la edad de §4
date +%F
```

Y los de «Numeraciones» en `docs/COMANDA.md` sobre `origin/main` (la
numeración de verdad; si hace falta el árbol, léelo con `git show` o
`git ls-tree`), y la línea «Última corrida» del archivo de recorridos, si lo
hay.

**Cada sprint** de `origin/main:docs/sprints/`: la cabecera (dueño, rama,
reservas) de ahí, y **el estado y las tareas de su rama**
(`git show origin/<rama>:docs/sprints/<tema>.md`), que es la versión viva. Si
la rama no está en el remoto, dilo: su dueño no ha subido nada.

Y de `origin/main`: `docs/BUZON.md`, y `ROADMAP.md` §2, §3 y §4.

No corras la verificación: esto tiene que contestar rápido. Si quieres saber si
está verde, di con qué comando se comprueba.

## Qué contestar

Cinco bloques cortos, en este orden — el orden es el de "qué hago ahora":

1. **Dónde estás parado.** Quién eres (de «Personas»), rama, si hay cambios sin
   commitear, y el último commit con su fecha. Si estás en la rama de un
   sprint, cuál; si tu rama está atrás de `origin/main`, cuánto.
2. **Los sprints.** Uno por renglón, **los tuyos primero**: tema, dueño, cuántas
   tareas y en qué estado, y el último commit de su rama con su fecha; en los
   tuyos, también dónde está su worktree: la ruta de su `**Worktree:**`, tal
   cual, sin construirla. Si su
   estado dice **"Entregado el …"**, dilo así: está **entregado en espera**, y
   lo que sigue es que alguien lo revise y `/comanda:sprint cerrar <tema>`. Si
   no hay ninguno, dilo así: no hay sprint, y lo que sigue en el ROADMAP es el
   tramo X.
3. **El buzón.** Cuántas entradas sin triar y de qué van, en media línea cada
   una. Si llegan al umbral de `docs/COMANDA.md`, di que toca
   `/comanda:triage`.
4. **Lo que le toca a quién.** De los archivos de sprint y de `ROADMAP.md` §4,
   en sus dos listas: lo que **bloquea al agente** primero, lo que **espera del
   cliente** después, cada renglón con su dueño. Es lo que bloquea al agente,
   así que va antes que lo que puede hacer el agente. **Dilo en llano:** qué
   es, qué hay que hacer y qué destraba, en una o dos líneas. Nunca un id, una
   cifra o un número de registro a secas —«las 111 sin pista», «el 37882»—:
   quien lee esto no estuvo en la sesión. Si el renglón de §4 viene críptico,
   explícalo tú y di que hay que reescribirlo. **Explicar no es inventar**:
   qué es, qué hay que hacer y qué destraba salen de lo escrito —el renglón,
   el archivo del sprint, el plan, el buzón, las decisiones—. Si el porqué no
   está en ninguno, di «no está escrito por qué» y que el renglón hay que
   completarlo; no lo deduzcas.
5. **Lo siguiente.** El primer paso del camino crítico que no esté cerrado, si
   el proyecto tiene uno, y qué le falta para abrirse. No es un juicio: es leer
   la tabla. Sólo si no hay camino crítico o está entero cerrado, recomienda.

## Lo que tienes que decir aunque no te lo pregunten

- **La numeración libre real**, si no coincide con `ROADMAP.md` §2 más las
  reservas de los sprints abiertos. **Dos reservas que se pisan** son un error:
  dilo primero.
- **Una rama sin fundir** que lleve días, o **una rama de sprint sin commits
  desde hace días**.
- **Una tarea que lleva dos sprints sin cerrar.** O está mal cortada, o está
  bloqueada por algo que nadie ha nombrado.
- **Una migración escrita y sin aplicar**, si el proyecto tiene migraciones. Es
  lo que más silenciosamente desincroniza el repo de la base.
- **Un sprint entregado en espera** de que alguien lo cierre, y cuántos días
  lleva así. Por persona: con uno se puede abrir el siguiente; con dos, no.
- **Worktrees de sprints que ya se cerraron**, en `git worktree list` de esta
  máquina: se reconocen por la **rama**, no por la ruta —uno de
  `<raíz>/.worktrees/` o uno viejo de `../<carpeta>-<tema>`—. Cualquiera que
  no sea el checkout principal ni un `.comanda-main/`, cuya rama no tenga
  archivo en `origin/main:docs/sprints/` y sí un
  `docs/archivo/SPRINT_<rama>_*.md`, es de un sprint cerrado: nómbralo con
  su ruta. Y un **`.comanda-main/` que se quedó** (un triage, una reserva o un
  cierre a medias): hay que publicarlo o descartarlo.
- **Un `docs/SPRINT.md` del flujo viejo**, si alguno de los dos `ls-tree` de
  `docs/SPRINT.md` lo imprime. Una línea, con esta forma —es la que repiten
  `next` y `sprint abrir`—: «Hay un `docs/SPRINT.md` en `origin/main` (o en
  tu rama, o en las dos): es del flujo de antes y los comandos de Comanda no
  lo leen; qué hacer con él está en `plantillas/ADOPTAR.md` de Comanda, «El
  `docs/SPRINT.md` de antes».» Si no está en ninguna, no digas nada.
- **Los renglones de §4 con más de siete días**: cada uno empieza con su fecha
  de entrada; compárala con `date +%F` y nombra los que pasen de siete, con su
  dueño. Es el cuello de botella real del proyecto: lo que sólo puede hacer una
  persona o el cliente.
- **El tamaño del ROADMAP** contra su techo: si pasa, dilo y di qué sección
  creció. Si no pasa pero está a menos de 20 líneas, avísalo también.
- **La última corrida de recorridos**, si el proyecto los tiene y es anterior
  al último push a la rama principal que tocó la carpeta de pantallas (o
  "nunca"): lo desplegado no se ha visto.

Termina en una frase: qué es lo siguiente para quien lo pregunta. Sin lista.
