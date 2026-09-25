*Parte de `/comanda:sprint`. Lo común a las tres formas —`docs/COMANDA.md`, un comando por llamada, quién eres, la cabecera del archivo del sprint y `comanda-main`— está en `SKILL.md` y ya lo leíste.*

# `entregar`

Lo hace el agente, **en el worktree del sprint**, cuando todas las tareas están
hechas o entregadas. Tu sprint es el `docs/sprints/*.md` cuya `**Rama:**` es la
rama en que estás; si no hay ninguno, dilo y para. **No toca el ROADMAP** ni
archiva nada: eso es de `cerrar`.

1. **Verifica antes de escribir nada:** corre, en orden, los comandos de
   «Verificación» en `docs/COMANDA.md` —con los recursos separados que diga
   «Worktree», para no pisar los de otro sprint—, y además

   ```bash
   git fetch origin
   git log --oneline origin/main..HEAD | wc -l
   git merge-base --is-ancestor origin/main HEAD
   ```

   (el último sale con código distinto de 0 si la rama no tiene lo último de
   main).

   **Si algo sale rojo, el sprint no se entrega:** dilo y para. Si la rama no
   tiene lo último de la principal, dilo: quien cierre lo va a fundir, y
   conviene rebasar antes. Las cifras van al archivo del sprint, en una sección
   "Verificación al entregar", y son las que `cerrar` copiará a `ROADMAP.md`
   §1.

2. **Cada tarea con su estado real**: `hecho` (verificado y sin nada que espere
   a una persona) o `entregado` (le falta ver en el navegador, avisar o fundir;
   si la migración la aplica el agente según `docs/COMANDA.md`, aplicarla ya no
   cuenta aquí). Una `pendiente` o `en curso` no se entrega: o se termina, o se
   dice por qué no y se propone qué hacer con ella.

3. **"Lo que te toca a ti" al día**, con todo lo que hay que hacer para poder
   cerrar: aplicar tal migración, correr tal recorrido, mandar tal aviso. Si el
   sprint entregó pantalla, **añade o cambia sus renglones en el archivo de
   recorridos** —no dejes una lista en el archivo del sprint—.

4. **Las notas de migraciones** de `docs/COMANDA.md` con la nota de cada
   migración, si hubo. **Lo que salió en el camino y no se hizo va al buzón**
   como lo hace `/comanda:buzon`: `comanda-main ruta`, el siguiente id dentro
   de `W`, la entrada literal en `W/docs/BUZON.md`, y
   `comanda-main publicar --reserva "Buzón: …"`.

5. En la cabecera del archivo del sprint: **`**Estado:** Entregado el <fecha>;
   lo cierra quien lo revise`**. Commitea y **sube la rama**
   (`git push origin <tema>`).

6. Si «Cómo se funde» es `PR`, abre el PR con el resumen:
   `gh pr create --base main --head <tema> --title "Sprint <tema>" --body …`.

## Al terminar

Qué quedó `hecho` y qué `entregado`, la verificación con sus cifras, y la lista
exacta de lo que hay que hacer para cerrar. Si una tarea se quedó a medias dos
sprints seguidos, **dilo**: o está mal cortada, o está bloqueada por algo que
nadie ha nombrado.
