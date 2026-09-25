---
name: triage
description: Vacía el buzón repartiendo cada entrada por una de cinco puertas
argument-hint: (sin argumentos)
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

Vacía el buzón con quien lo corre delante —cualquiera de las personas de
`docs/COMANDA.md` puede hacerlo—. Al terminar, el buzón queda vacío y cada
entrada tiene destino.

## Dónde se trabaja

**El triage escribe en la rama principal**: el buzón, el ROADMAP, `TODO.md`,
los descartados. Son archivos con dueño de fase —sólo el triage y el cierre de
un sprint los tocan—, y se escriben siempre sobre la principal, nunca en la
rama de un sprint.

**Antes de la primera `comanda-main`, lee «Ramas» en el `docs/COMANDA.md` de
tu checkout** —`W` todavía no existe—. Si dice otro remoto u otra rama
principal que `origin` y `main`, desde la primera llamada antepón
`COMANDA_REMOTO=<remoto> COMANDA_PRINCIPAL=<rama>` a cada `comanda-main`. Si
no hay `docs/COMANDA.md`, son `origin` y `main`.

No cambies tu checkout ni tu rama: trabaja en el worktree de paso del plugin,

```bash
comanda-main ruta
```

que imprime una ruta —llámala `W`— con la rama principal recién traída. **Todo
lo demás que leas y escribas, de aquí en adelante, es dentro de `W`.** Si sale
con código 2, hay un triage o un cierre a medias en ese worktree: dilo y para;
no lo descartes tú.

**Un comando por llamada.** `allowed-tools` autoriza cada comando suelto;
uno compuesto (`… && …`, `…; …`, `… || …`) se niega y cuesta un turno.
Cada renglón de un bloque va en su propia llamada —los que no dependen uno
de otro, en llamadas paralelas de una misma respuesta—, y en vez de
`cd W && …` se usa `git -C W …`.

## Antes de empezar

Lee `docs/COMANDA.md` —las personas y el cliente, los techos, el camino
crítico, el tramo de «medir primero» y las reglas del proyecto—. Luego
`docs/BUZON.md`, `docs/ROADMAP.md` §3 y §5, y la cabecera de cada
`docs/sprints/*.md` —qué sprints están abiertos y de quién—. Necesitas saber
qué hay ya en la cola para no mandar al backlog algo que ya está ahí con otro
nombre.

Si el buzón está vacío, dilo en una línea y termina.

## Las cinco puertas

| Puerta | Cuándo | A dónde va |
|---|---|---|
| **Ya** | bug chico, sin decisiones que esperar, cabe en un commit | **sin ceremonia**: a la lista **«De paso»** al principio de `ROADMAP.md` §3 (créala si no existe), un renglón con su id. De ahí lo toma quien tenga un sprint abierto, como commit suelto que no cuenta como tarea, o se hace en la rama de mantenimiento. Si no cabe en un commit, no es "ya": es backlog |
| **Backlog** | se sabe qué es y más o menos cuánto cuesta | `ROADMAP.md` §3, al tramo que le toca — marcando **"necesita plan"** si aplica (ver abajo) |
| **Medir primero** | no se sabe el tamaño, ni si el problema existe de verdad | el tramo de «medir primero» del ROADMAP **y** una entrada en `TODO.md` con la pregunta que hay que contestar |
| **Preguntar** | falta una decisión que no es tuya | `ROADMAP.md` §5, diciendo **quién** la debe contestar |
| **No** | se descarta | `docs/archivo/BUZON_descartados.md`, **con el motivo escrito** |

**La quinta puerta no es opcional.** Lo que se descarta sin dejar rastro, el
cliente lo vuelve a pedir en tres semanas y se vuelve a diagnosticar desde
cero. El motivo se escribe aunque sea obvio hoy.

**Nada entra al camino crítico por triage**, si el proyecto tiene uno: lo
demás va a su tramo. Sólo quien diga «Camino crítico» en `docs/COMANDA.md` mete
o saca pasos de esa tabla.

**Lo que va al backlog se marca si necesita plan de fase**, para que el sprint
no se entere tarde. Necesita plan si se cumple cualquiera de estas cuatro —son
las mismas que verifica `/comanda:sprint abrir`:

1. **toca datos que ya existen** (retroactiva);
2. **hay decisiones que fijar** para no re-preguntarlas;
3. **no cabe en un sprint** (más tareas o más migraciones que los techos de
   `docs/COMANDA.md`);
4. **hay que medir antes de decidir** — entonces primero va el diagnóstico.

Aquí sólo se **marca**; el plan no se escribe en el triage. Marcar de más no
cuesta nada, y marcar de menos hace que una retroactiva se descubra a medio
sprint.

## Cómo se tría

Una entrada a la vez, en orden de id.

1. **Propón una puerta, con su razón en una frase.** No la apliques todavía.
   La razón es lo que te van a corregir si te equivocaste, así que di en
   qué te basaste: lo que ya existe en el ROADMAP, lo que mide un diagnóstico,
   o lo que la entrada no alcanza a decir.

2. **Di también lo que la entrada no dice.** Una petición en las palabras del
   cliente casi siempre esconde una decisión: "que se pueda filtrar por
   asistente" no dice si el filtro respeta lo que cada quien tiene permiso de
   ver, y eso cambia el tamaño. Nombrar el hueco es la mitad del triage; con
   hueco grande, la puerta suele ser **preguntar** o **medir primero**, no
   **backlog**.

3. **Busca si ya está.** Antes de mandar algo al backlog, compruébalo contra
   §3 del ROADMAP y contra `TODO.md`. Dos peticiones distintas del cliente
   pueden ser la misma cosa; si lo son, dilo y fúndelas en una, citando los dos
   ids.

4. **Agrupa con AskUserQuestion.** No hagas una pregunta por entrada: junta las
   que comparten decisión y pregunta una vez. Cuando tu propuesta sea clara y la
   razón sólida, preséntala como la primera opción.

Reglas al repartir:

- **Nada se inventa.** Si la entrada no alcanza para escribir un renglón de
  backlog honesto, la puerta es **preguntar**, no adivinar.
- **Las preguntas de detalle no se hacen aquí.** Las que salen al repartir
  —qué campos, qué tipos cuentan, con qué se empata— van a `ROADMAP.md` §5 con
  su tramo y con quién las contesta, y se contestan en `/comanda:sprint
  abrir`, cuando el tramo se va a trabajar. En el triage sólo se pregunta lo que
  hace falta para **elegir la puerta**.
- **No diagnostiques aquí.** El triage decide *a dónde va*, no *cómo se
  arregla*. Si una entrada pide medición, se anota la pregunta en `TODO.md` y se
  acabó; medir es trabajo de sprint.
- **Respeta las decisiones ya tomadas** — están todas en
  `docs/DECISIONES.md`, con su id. Si una entrada contradice una, dilo y cita
  el id: puede ser que el cliente cambió de opinión, y eso se pregunta; si se
  revierte, la fila del registro se tacha con la fecha y la nueva la sustituye.
- **La puerta "ya" no cuenta contra el techo de tareas**, porque entra "de
  paso"; pero **sí respeta el de "cabe en un commit"**. Si al mirarla crece, va
  al backlog, aunque sea chica.

## Al repartir

- Los renglones que escribas en el ROADMAP van **en el estilo del documento**:
  qué es, qué lo bloquea, y la cifra medida si la hay. Cita el id del buzón
  entre paréntesis al final, así: `(B-007)`. **El ROADMAP tiene techo de
  líneas** (el de `docs/COMANDA.md`): si el triage lo pasa, di cuánto y qué
  sección creció; no se cierra nada aquí para hacer sitio, pero se avisa.
- Cada entrada descartada se copia entera a `docs/archivo/BUZON_descartados.md`
  —id, fecha, origen y cuerpo— y debajo, el motivo y la fecha de la decisión.
- Vacía la sección `## Sin triar` y déjale su marcador `*(vacío)*`.

## Al cerrar

Publica, con el reparto en el cuerpo del commit:

```bash
comanda-main publicar "Triage del buzón: <n> entradas repartidas

<id> → <puerta>: <la razón, en una línea>
..."
```

- `PUBLICADO` → listo.
- `CONFLICTO` (sale con 4) → alguien publicó en la principal, mientras
  triabas, algo que choca con lo tuyo —casi siempre, una entrada nueva en el
  buzón—. Tu trabajo sigue en `W`, sin publicar. **No lo descartes:** di qué
  archivos chocan y propón resolverlo (traer lo nuevo con
  `git -C W rebase origin/main`, arreglar el choque —las entradas nuevas se
  quedan en «Sin triar»— y publicar otra vez).

Después, un resumen corto: cuántas por cada puerta, qué
quedó listo para el sprint que se va a abrir, y cuántas preguntas quedaron en
§5 y de qué tramos. **No armes la lista para el cliente aquí:** esa lista sale
de `/comanda:sprint abrir`, con las preguntas del tramo que se va a trabajar.
