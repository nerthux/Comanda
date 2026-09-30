*Parte de `/comanda:sprint`. Lo común a las tres formas —`docs/COMANDA.md`, un comando por llamada, quién eres, la cabecera del archivo del sprint y `comanda-main`— está en `SKILL.md` y ya lo leíste.*

# `abrir <tema>`

**`abrir` sin `<tema>` toma el primer paso del camino crítico que no esté
cerrado**, si el proyecto tiene uno; no preguntes cuál.

## El techo — se verifica antes que nada

- **Máximo de tareas**, el de `docs/COMANDA.md`. Lo que entra "de paso"
  (abajo) no cuenta.
- **Máximo de migraciones**, el de `docs/COMANDA.md`. Cada retroactiva lleva lo
  que el proyecto diga que la acompaña —aviso al cliente, medición—: eso es lo
  que de verdad cuesta, no escribir el SQL.
- **Un tema, en la duración de `docs/COMANDA.md`.** Si el tema necesita siete
  fases, son dos sprints.
- **Por persona: un sprint abierto, y uno entregado en espera, nunca dos.** Los
  de los demás no cuentan.

Si lo que hay para meter no cabe, **no lo metas**: di qué sobra, propón el corte
por dependencia (qué necesita a qué) y deja el resto en el backlog. Un sprint
que no cabe se convierte en un plan permanente, y sus últimas fases se caen a
medio camino.

## Qué hacer

1. **Prepara la principal:** `comanda-main ruta` → `W`. Todo lo que sigue se
   lee de `W`, no de tu checkout: es lo último que publicó cualquiera. Y
   `git worktree list --porcelain` → `<raíz>`, la ruta de su primera línea
   (arriba, en `SKILL.md`): la necesitan la cabecera y el worktree.

   **Si `<raíz>` no es la del proyecto, para.** Lo es si tiene
   `docs/COMANDA.md` y no es la carpeta de un repo hijo: desde dentro de un
   hijo, esa primera línea es la del hijo. Mira el repo de arriba,
   `git -C <raíz>/.. worktree list --porcelain` → `<padre>` (si falla, no
   hay repo arriba y no es hijo); si `<padre>/docs/COMANDA.md` tiene en
   «Repos hijos» un renglón cuya carpeta, bajo `<padre>`, es `<raíz>`, es
   un hijo. En los dos casos, di que la sesión se abre en la raíz del
   proyecto y termina.

2. **Si el buzón (`W/docs/BUZON.md`) tiene entradas sin triar, para y di que
   primero va `/comanda:triage`.** Abrir un sprint sin vaciar el buzón es cómo
   se llega a tener cuatro planes.

3. **Los sprints que ya hay.** Lee la cabecera de cada `W/docs/sprints/*.md`, y
   su estado real de la rama (`git fetch origin` y
   `git show origin/<rama>:docs/sprints/<tema>.md`; si la rama no se ha subido,
   vale la de `W`).
   - **Tuyos:** si tienes uno **abierto**, para: di en qué va y ofrece
     `/comanda:sprint entregar`. Si tienes **dos entregados en espera**, para:
     primero hay que cerrar uno. Con uno en espera, sigue.
   - **De los demás:** si alguno trabaja el mismo tramo o las mismas tareas,
     dilo antes de cortar: dos sprints no se llevan la misma tarea.
   - Si ya existe `W/docs/sprints/<tema>.md`, el tema está tomado: pide otro
     nombre.
   - **El `docs/SPRINT.md` de antes:** `git -C W ls-tree --name-only HEAD
     docs/SPRINT.md` (la principal) y `git ls-tree --name-only HEAD
     docs/SPRINT.md` (tu rama). Si alguno lo imprime, dilo con la línea de
     `/comanda:estado`: «Hay un `docs/SPRINT.md` en `origin/main` (o en tu
     rama, o en las dos): es del flujo de antes y los comandos de Comanda no
     lo leen; qué hacer con él está en `plantillas/ADOPTAR.md` de Comanda,
     «El `docs/SPRINT.md` de antes».» Y léelo: si es el marcador de que no hay
     sprint abierto, o uno ya terminado, basta el aviso y sigue. **Si está
     abierto** —tareas sin terminar—, **no abras encima sin que la persona lo
     decida**: pregúntale con AskUserQuestion entre parar (para terminarlo o
     pasarlo a `docs/sprints/`, según la receta) y abrir de todos modos. Si no
     hay a quién preguntar, para.

4. **¿Este tema necesita un plan de fase?** La cadena del proyecto es
   `diagnóstico (medir) → plan (decidir) → uno o varios sprints (hacer)`, y el
   eslabón de en medio no siempre hace falta. Necesita plan si se cumple
   **cualquiera** de estas cuatro:

   1. **Toca datos que ya existen** — una retroactiva. Hay que medir el impacto
      antes y avisar al cliente.
   2. **Hay decisiones que fijar** para no re-preguntarlas.
   3. **No cabe en un sprint** — más tareas o más migraciones que los techos.
      El plan es lo que mantiene el hilo de un sprint al siguiente.
   4. **Hay que medir antes de decidir** — entonces primero va un diagnóstico,
      y el plan sale de él.

   **Si no aplica ninguna, no escribas plan** y abre el sprint directo contra el
   ROADMAP. Si hace falta y **no existe**, para: di cuál de las cuatro lo
   disparó y ofrece escribirlo (en modo plan, como `docs/PLAN_<tema>.md`). **No
   abras el sprint a ciegas.** El ROADMAP §3 dice, en cada tramo, si tiene plan
   y cuántos sprints se le estiman. Empieza por ahí.

5. Junta los candidatos: lo de la lista **«De paso»** de `ROADMAP.md` §3 (lo
   que el triage mandó a la puerta **ya**) y lo que toque del tramo. **Mientras
   el camino crítico tenga pasos sin cerrar, el tramo es ése**: un tema que no
   sea su siguiente paso y no quepa en un commit no se abre; para y dilo. **Si
   hay plan, el sprint se lleva el trozo que quepa bajo el techo, no el plan
   entero.** El corte se hace por dependencia, no por número: donde una
   migración deja de ser requisito de la siguiente; **las retroactivas van
   juntas**, para que el cliente reciba un solo aviso; lo que no cabe se queda
   en el plan.

6. **Contrasta con `docs/DECISIONES.md`** antes de escribir una tarea: ahí está
   todo lo decidido, con su id, y no se re-pregunta. Un id que el plan, §5 o
   el buzón citen y no esté en la tabla se busca en
   `docs/archivo/DECISIONES_podadas_*.md`: lo podado sigue decidido. **Y
   aquí se contestan las preguntas abiertas del tema**: lee las filas de `ROADMAP.md` §5 que toquen
   al tema y házselas a quien abre con AskUserQuestion, agrupadas, **antes de
   cortar**:
   - **contestada** → pasa el mismo filtro que en `cerrar`: entra lo que
     decide —lo que decidió o confirmó quien contesta, o lo que ata fuera del
     sprint—; lo que sólo fija un detalle de cómo quedará el código, o anota
     un hecho, no sube: va al archivo del sprint. Lo que entra va a
     `W/docs/DECISIONES.md` con el siguiente `DEC-NNN`, la fecha y quién; si
     revierte o precisa una fila vigente, **la tacha** —«Revertida el <fecha>
     por DEC-NNN» o «Precisada el <fecha> por DEC-NNN»— y la nueva se escribe
     entera, para que se lea sola. El archivo del sprint y el plan de fase la
     **citan** por id; la fila **se borra** de §5. Va en el mismo commit de la
     reserva, y el push la protege igual;
   - **sin contestar** —la debe el cliente y no ha llegado— → la tarea que
     depende de ella **no entra al sprint** y la fila se queda en §5.

   Si nadie la sabe y hay que preguntarla, arma al final la lista para el
   cliente, lista para copiar al canal de `docs/COMANDA.md`. Las decisiones que
   se tomen **a media tarea** no se numeran todavía: van al archivo del sprint,
   en «Decisiones del sprint», como `D1`, `D2`…, con quién la tomó —«agente,
   corregible» si fue el agente— y si ata fuera del sprint, y **pasan por el
   filtro de `cerrar`**: sube lo que decide y lo demás va a su destino.

7. **Reserva la numeración**, de verdad y no de memoria. Para cada renglón de
   «Numeraciones» de `docs/COMANDA.md`, lo siguiente libre es el mayor entre
   lo que da su comando corrido **dentro de `W`** y el `hasta` de las
   `**Reservas:**` de todos los `W/docs/sprints/*.md`, más uno. Aparta lo que
   el sprint vaya a ocupar (las migraciones que se esperan, y sus pruebas) y
   escríbelo en la cabecera. Si no ocupa nada, «ninguna».

8. Escribe **`W/docs/sprints/<tema>.md`** (crea `docs/sprints/` si no existe):
   la cabecera de arriba, con `**Worktree:**` escrito entero
   (`<raíz>/.worktrees/<tema>`, absoluto); el tema; **el plan del que sale y qué trozo se
   lleva** (o "sin plan" y por qué); la tabla de tareas; cuántas migraciones se
   esperan; qué repos hijos cambia y cuáles sólo monta (paso 10), si
   «Repos hijos» no dice `no aplica`; «Decisiones del sprint», vacía; una sección **"De paso"** vacía; y
   **"Lo que te toca a ti"** —aplicar, avisar, cargar, desplegar, y la última
   corrida de recorridos si el sprint toca pantallas—. Esa sección es la mitad
   del valor del archivo, y **se escribe para quien no estuvo en la sesión**:
   título en llano, qué es, *qué hacer* y *qué destraba*; los ids al final,
   nunca como sujeto.

9. **Publica la reserva:**

   ```bash
   comanda-main publicar --reserva "Sprint <tema>: abre y reserva <lo reservado>"
   ```

   Si sale `RECHAZADO`, alguien publicó antes y lo tuyo se descartó: `W` ya
   está en lo nuevo. Vuelve al paso 3 (quizá ya hay un sprint que choca), y
   recalcula los números, los `DEC-NNN` y el archivo antes de reintentar.

10. **El worktree del sprint**, en `<raíz>/.worktrees/<tema>` (paso 1),
    sacado de lo que acabas de publicar. Primero que git no lo vea desde la
    raíz: si no existe `<raíz>/.worktrees/.gitignore`, créalo con Write con
    una sola línea, `*`. No en `.git/info/exclude`: Claude Code niega
    escribir dentro de `.git/`, con Edit y con Bash. Luego, con el remoto y
    la principal de «Ramas»:

    ```bash
    git fetch origin
    ```

    ```bash
    git worktree add <raíz>/.worktrees/<tema> -b <tema> origin/main
    ```

    **Con la ruta absoluta**, nunca `.worktrees/<tema>` a secas: relativa,
    corrida desde dentro de otro sprint, queda anidada en el suyo.

    **Los repos hijos**, si «Repos hijos» no dice `no aplica`, antes que los
    comandos de «Worktree», que suelen instalar sus dependencias. Por cada
    renglón, el clon es `<raíz>/<carpeta>`: si no existe, `git clone <clon>
    <raíz>/<carpeta>`; si existe y `git -C <raíz>/<carpeta> rev-parse
    --show-toplevel` no da esa misma ruta, no es un repo aparte: para y
    dilo. Con su remoto `origin` y la `<base>` del renglón, `git -C
    <raíz>/<carpeta> fetch origin`, y luego:

    - **El sprint lo cambia** —alguna tarea nombra su carpeta en «Dónde»—:
      su worktree va en la rama del sprint, sin rastrear la base:

      ```bash
      git -C <raíz>/<carpeta> worktree add --no-track <raíz>/.worktrees/<tema>/<carpeta> -b <tema> origin/<base>
      ```

      No la subas todavía: se sube con su primer commit, `push -u origin
      <tema>`.
    - **No lo cambia y se monta `siempre`**: sin rama, para que al cerrar
      no haya nada que fundir:

      ```bash
      git -C <raíz>/<carpeta> worktree add --detach <raíz>/.worktrees/<tema>/<carpeta> origin/<base>
      ```

    - **No lo cambia y se monta `si el sprint lo cambia`**: nada.

    Después corre, en el worktree nuevo, los comandos de «Worktree» de
    `docs/COMANDA.md` (`<principal>` es `<raíz>`, `<tema>` el del sprint),
    cada uno como `cd <raíz>/.worktrees/<tema> && <comando>`, en la misma
    llamada: la sesión no sale de su carpeta. Y sube la rama `<tema>` del
    proyecto desde la raíz, no desde el worktree —un remoto con URL relativa
    (`../repo.git`) sólo apunta bien desde ahí—: `git -C <raíz> push -u
    origin <tema>`.

## "De paso" y la rama de mantenimiento

**Lo de un commit entra sin ceremonia.** Un renglón de «De paso» del ROADMAP
lo toma quien tenga un sprint abierto: entra en la rama de su sprint como
commit suelto, listado en su archivo bajo "De paso" **sin contar como tarea**,
y el renglón del ROADMAP se borra al cerrar ese sprint. Si nadie tiene sprint
abierto, va en la rama de mantenimiento de `docs/COMANDA.md` —en su propio
worktree, como un sprint sin tareas— y se funde cuando alguien lo pida. El
techo de tareas no lo cuenta; el de "cabe en un commit" sí se respeta: si
crece, es una tarea y se dice.

## Al terminar

El tema, las tareas con su orden, lo reservado, qué repos hijos quedaron
montados y en qué rama, la primera que conviene atacar y por qué, y **dónde
seguir**: la ruta de `**Worktree:**`, y que ahí se abre una
sesión nueva y se teclea `/comanda:next`.
