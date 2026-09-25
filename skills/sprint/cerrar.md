*Parte de `/comanda:sprint`. Lo común a las tres formas —`docs/COMANDA.md`, un comando por llamada, quién eres, la cabecera del archivo del sprint y `comanda-main`— está en `SKILL.md` y ya lo leíste.*

# `cerrar [<tema>]`

Lo corre cualquiera de las personas, desde cualquier checkout. **Sin `<tema>`:**
si estás en la rama de un sprint, ése; si no, lista los entregados en espera
(de `origin/main:docs/sprints/`, con su estado de la rama) y pregunta cuál.

Sólo cuando quien cierra confirma lo entregado: aplicado, visto en el
navegador, avisado al cliente. Si no lo ha confirmado, pregúntale qué de "Lo
que te toca a ti" ya hizo y qué difiere; **lo diferido va a `ROADMAP.md` §4
con fecha de entrada y dueño**, y con eso el sprint sí cierra.

1. **Funde**, según «Cómo se funde» en `docs/COMANDA.md`:
   - `PR` → `gh pr merge <tema> --merge` (si no hay PR, ábrelo antes). Después,
     `comanda-main ruta` → `W`, que ya trae lo fundido.
   - `a mano` → `git fetch origin`, `comanda-main ruta` → `W`, y
     `git -C W merge --no-ff origin/<tema> -m "Sprint <tema>: fundir"`.

   Si el merge choca **sólo en bitácoras de sólo agregar** (las notas de
   migraciones, el buzón), se quedan las dos entradas, en orden de fecha, y
   sigues. Si choca en otra cosa, **para**: `git -C W merge --abort`, y di qué
   choca; lo arregla el dueño del sprint rebasando su rama.

   Todo lo que sigue es dentro de `W`, con el archivo del sprint ya en su
   versión final: `W/docs/sprints/<tema>.md`.

2. **Mide el ROADMAP antes de tocarlo** y guarda la cifra:
   ```bash
   wc -l W/docs/ROADMAP.md
   ```

3. **Reparte las tareas por su estado real:**
   - `hecho`, y lo `entregado` que quien cierra confirmó → **una fila en
     `CHANGELOG.md`** (al final; sólo se apende) con lo que dejó el sprint y
     dónde está su bitácora. Si hubo migración, se comprueba que esté anotada
     en sus notas. En `ROADMAP.md` §3, el tramo conserva sólo lo abierto y
     **una línea** por lo cerrado, con enlace al CHANGELOG; los renglones de
     «De paso» que el sprint hizo se borran;
   - `entregado` que se difiere → `ROADMAP.md` §4, en la lista que le toque
     (las dos de `docs/COMANDA.md`: *bloquea al agente* o *espera del
     cliente*), con fecha y dueño;
   - `pendiente` o `en curso` → **regresan al backlog**, a §3. No se arrastran.

4. **Lo que quedó de "Lo que te toca a ti"** se copia a §4 con fecha y dueño,
   **en el mismo formato** (título en llano, qué es, qué hacer, qué destraba);
   lo que ya se hizo, se borra. **Lo tachado de §4 se borra**, no se deja.

5. Refresca `ROADMAP.md`: §1 con la verificación de `entregar` (o repítela si
   pasó tiempo) y la fecha de hoy; **§2 con la numeración real** —los comandos
   de «Numeraciones» dentro de `W`; lo reservado y no ocupado se libera con el
   cierre—; §3 con lo que cambió de tramo. Las mediciones del sprint
   (dry-runs, conteos) **se quedan en el archivo del sprint**, no en el
   ROADMAP ni en el plan.

6. **`docs/DECISIONES.md`:** las «Decisiones del sprint» (`D1`, `D2`…) entran
   con su `DEC-NNN`, y en el archivo del sprint se anota a cuál pasó cada una.
   Una que se revirtió se tacha con la fecha y el id de la que la sustituye.

7. **El plan de fase, si el sprint salió de uno:** ¿le quedan sprints? Anota
   el estado y deja el tramo abierto diciendo cuántos faltan. ¿Fue el último?
   Archívalo en `docs/archivo/` con su cabecera de qué lo sustituye, baja a §3
   lo que quedara vivo, y cierra el tramo.

8. Archiva el sprint:
   `git -C W mv docs/sprints/<tema>.md docs/archivo/SPRINT_<tema>_<fecha de apertura>.md`,
   con una cabecera que diga qué se cerró, qué regresó al backlog y quién lo
   cerró.

9. Si el sprint dejó una pregunta para el cliente, va a §5 **con quién la
   contesta**.

10. **Mide el ROADMAP otra vez.** Tiene que ser **menor o igual que al empezar
    y menor que el techo de `docs/COMANDA.md`**. Si creció, **el cierre
    para**: di qué sección creció y qué se debió archivar —lo cerrado al
    CHANGELOG, las mediciones al archivo del sprint, lo decidido al registro—
    y arréglalo antes de publicar.

11. **Publica**, con el resumen en el cuerpo del commit —en el mismo
    argumento que el título, tras una línea en blanco, como en el triage; un
    segundo argumento es error—:

    ```bash
    comanda-main publicar "Cierre del sprint <tema>

    <el resumen>"
    ```

    Si sale `CONFLICTO`, alguien publicó en la principal
    algo que choca: tu cierre sigue en `W`; di qué choca y propón resolverlo
    (`git -C W rebase origin/main`, arreglar, publicar). No lo descartes.

12. **Limpia:** borra la rama del remoto (`git push origin --delete <tema>`,
    si el PR no la borró). **El worktree del sprint es la ruta de su cabecera
    `**Worktree:**`**, tal cual —en `W/docs/archivo/`, tras el paso 8—, no
    una que construyas: un sprint abierto con 0.2.x dice
    `../<carpeta>-<tema>` y cierra ahí, aunque hoy la ruta sea otra. Si esa
    ruta sale en `git worktree list` —está en esta máquina— y está limpio, quítalo
    desde la raíz, `<raíz>` la primera línea de
    `git worktree list --porcelain`:

    ```bash
    git -C <raíz> worktree remove <la ruta de **Worktree:**>
    ```

    Desde la raíz porque la ruta vieja es relativa al checkout principal, y
    porque así no importa estar parado dentro del worktree que se quita.
    Después, la rama local, sólo si ya está entera en la principal:

    ```bash
    git fetch origin && git merge-base --is-ancestor <tema> origin/main \
        && git branch -D <tema>
    ```

    `-D` y no `-d`: el merge se hizo en `W` o en el PR, y `-d` compara contra
    el checkout donde estás, que sigue atrás, así que se niega siempre. Si la
    comprobación falla, **no la borres**: la rama tiene algo que no llegó a la
    principal (un commit sin subir); di cuál y que lo decida su dueño. Si el
    worktree es de otra persona, dile que lo quite en la suya.

## Al terminar

Qué se cerró, qué se difirió a §4 y con qué fecha, qué regresó al backlog y por
qué, qué decisiones recibieron número, y las dos cifras del ROADMAP (antes y
después).
