---
name: buzon
description: Anota en crudo lo que pidió el cliente, sin trabajarlo
argument-hint: <lo que te dijeron — una línea, o varias pegadas>
disable-model-invocation: true
allowed-tools: Bash(comanda-main:*), Bash(COMANDA_REMOTO=*), Bash(COMANDA_PRINCIPAL=*), Bash(grep:*), Bash(date:*), Bash(git status:*), Bash(git log:*), Read, Edit
---

Captura esto en el buzón:

$ARGUMENTS

## La regla que manda sobre todas

**No analices. No propongas. No preguntes. No abras ningún otro archivo**
—salvo `docs/COMANDA.md`, de donde salen el cliente y sus nombres—.

Esto tiene que correr en diez segundos o deja de usarse, y ése es justo el
problema que el buzón vino a resolver. Si el texto te parece un bug grave, una
mala idea, un duplicado de algo que ya está en el ROADMAP o algo que sabes
arreglar en dos líneas — **da igual: anótalo y ya**. Eso se resuelve en
`/comanda:triage`, no aquí.

La única excepción: si `$ARGUMENTS` viene vacío, dilo en una línea y termina.

## Dónde se escribe

**El buzón vive en la rama principal, y ahí se escribe siempre**, estés en la
rama que estés: así lo ven todos y el triage no tiene que esperar a que se
funda nada. No se toca tu checkout ni tu rama.

**Primero lee `docs/COMANDA.md` de tu checkout** —no el de `W`, que todavía
no existe—: «Ramas» dice el remoto y la rama principal, y «Personas» el
cliente. Si dice otro remoto u otra rama principal que `origin` y `main`,
**desde la primera llamada** antepón `COMANDA_REMOTO=<remoto>
COMANDA_PRINCIPAL=<rama>` a cada `comanda-main`. Si no hay
`docs/COMANDA.md`, son `origin` y `main`.

Luego se escribe en un worktree de paso que prepara el plugin:

```bash
comanda-main ruta
```

Imprime una ruta —llámala `W`—: ahí está la rama principal recién traída del
remoto. Si sale con error, di el mensaje en una línea y para: no anotes en tu
rama como plan B.

**Un comando por llamada.** `allowed-tools` autoriza cada comando suelto;
uno compuesto (`… && …`, `…; …`, `… || …`) se niega y cuesta un turno.
Cada renglón de un bloque va en su propia llamada —los que no dependen uno
de otro, en llamadas paralelas de una misma respuesta—, y en vez de
`cd W && …` se usa `git -C W …`.

## Qué hacer

1. **El id siguiente** es el más alto que exista **más uno**, con tres dígitos
   (`B-007`). Los ids **no se reusan**, ni los de las entradas ya triadas o
   descartadas. Cuenta sólo el **encabezado** de cada entrada, no cualquier
   `B-` que aparezca en un texto: una entrada, el ROADMAP o `TODO.md` pueden
   citar el id de otro proyecto, y eso inflaría la numeración. Búscalo,
   **dentro de `W`**, en los dos archivos que llevan encabezados:

   ```bash
   grep -ho '^### B-[0-9]\{3\}' W/docs/BUZON.md W/docs/archivo/BUZON_descartados.md
   ```

   Sin `sort` ni `tail`: `allowed-tools` autoriza `grep` suelto, y una
   tubería se niega. El más alto lo sacas tú de la salida; un archivo que no
   exista sólo agrega una línea de error, que se ignora. Los ejemplos de los
   documentos usan `B-0NN`, que no casa con el patrón, así que no estorban.

   Una entrada ya triada no queda en ninguno de los dos —acaba en el
   ROADMAP, en el CHANGELOG o en `docs/archivo/`—, pero el asunto de cada
   `publicar` del buzón cita sus ids y el último es el más alto. Así
   que busca también el último, con el remoto y la principal de «Ramas»:

   ```bash
   git log -1 --format=%s --grep='^Buzón:' origin/main
   ```

   Éste va **desde tu checkout, sin `-C`**: `comanda-main ruta` acaba de
   traer `origin/main`, y `W` está justo en esa punta, así que es lo mismo
   y `allowed-tools` sólo autoriza `git log` suelto.

   El id siguiente es el más alto de los dos **más uno**. Si ninguno devuelve
   nada, empieza en `B-001`.

2. **Una entrada por línea no vacía** de `$ARGUMENTS`. Es deliberado: la ráfaga
   de una sesión de pruebas se pega de golpe y sale repartida en entradas
   sueltas, que es como se tiene que triar. Un texto de una sola línea es una
   sola entrada, aunque sea largo.

3. La fecha es la de hoy (`date +%F`), no la que aparezca en el texto.

4. **El origen** se deduce, sin preguntar. El *cliente* y sus nombres son los
   de `docs/COMANDA.md`, «Personas»:
   - un nombre del lado del cliente en el texto → `<cliente> (<nombre>)`;
   - si la línea empieza con `medición:` o `hallazgo:` → `medición`, y ese
     prefijo no se copia al cuerpo;
   - si habla de lo que se ve en los datos, en una hoja de cálculo o en una
     consulta, sin que nadie lo haya pedido → `medición`;
   - en cualquier otro caso → `<cliente>`, a secas.

   Si le atinaste mal, se corrige en el triage en una línea. **No preguntes.**

5. **El cuerpo va literal.** Corrige sólo la ortografía evidente. No lo
   traduzcas a lenguaje técnico, no lo resumas, no le agregues el nombre de la
   tabla ni del componente que crees que toca. Las palabras del cliente son el
   dato — son las que dejan ver, en el triage, que dos peticiones distintas eran
   la misma cosa, o que una pedía algo que nadie modeló.

6. Añádelas al final de la sección `## Sin triar` de **`W/docs/BUZON.md`**, en
   el formato que el propio archivo documenta. Si está el marcador `*(vacío)*`,
   quítalo.

7. Publica:

   ```bash
   comanda-main publicar --reserva "Buzón: <las primeras palabras de la primera entrada>  (B-007…B-009)"
   ```

   En español, sin cuerpo. Es una anotación, no un cambio: no merece párrafo.
   - `PUBLICADO` → listo; el worktree de paso ya se borró.
   - `RECHAZADO` (sale con 3) → alguien anotó o reservó antes. `W` ya está en
     lo nuevo y tus entradas se descartaron: **vuelve al paso 1** —el id se
     recalcula— y reescríbelas. Hasta tres veces; a la tercera, dilo y para.

## Al terminar

Una línea: cuántas entraron, con qué ids, y cuántas hay ya sin triar en total.
Si llegan al umbral de «Techos» en `docs/COMANDA.md` (8 si no dice), agrega
una segunda línea sugiriendo `/comanda:triage` — no lo corras tú.
