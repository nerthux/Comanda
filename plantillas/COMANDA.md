# Comanda — configuración de este proyecto

Los comandos de Comanda (`/comanda:buzon`, `/comanda:triage`,
`/comanda:sprint`, `/comanda:next`, `/comanda:estado`) son los mismos en todos
los proyectos. **Lo propio de éste vive aquí**: quién es quién, qué se numera,
cómo se verifica, qué se aplica y con qué techos. Cuando un comando dice *las
personas*, *el cliente*, *la verificación* o *las migraciones*, se refiere a lo que
diga este archivo.

Va en `docs/COMANDA.md`. Una sección que no aplica se deja con `no aplica`:
el comando se salta lo que dependa de ella. **No quites los títulos**: los
comandos los buscan por nombre.

## Personas

Quienes trabajan en el proyecto. **Todos hacen lo mismo**: capturan, hacen
triage, abren, trabajan, entregan, cierran y funden. El nombre de git dice
quién corre un comando (`git config user.name`), y con eso se cuentan los
techos por persona.

- <Nombre> — git: `<user.name>`
- <Nombre> — git: `<user.name>`

- **Camino crítico:** lo mueve <Nombre> — es el único que mete o saca pasos
  de esa tabla.
- **Cliente:** <cómo se le llama en los textos — «el despacho», «la tienda»…>
  — quien pide. Lo que pide entra al buzón con origen `<cliente>`.
- **Nombres del lado del cliente:** <Nombre, Nombre, …> — si una entrada del
  buzón nombra a alguno, el origen es `<cliente> (<nombre>)`.
- **Canal para preguntarle al cliente:** <WhatsApp, correo…> — las listas de
  preguntas se arman listas para pegar ahí.

## Ramas

- **Remoto:** `origin` — donde se ven todos. El buzón, las reservas, el
  triage y el cierre se publican ahí con `comanda-main`.
- **Principal:** `main` — **¿un push a la principal despliega?** Comanda publica
  ahí el buzón, las reservas y el triage. Si la CI despliega en cada push, que
  ignore los que sólo tocan documentos (`paths-ignore: ["docs/**", "**.md"]`
  en GitHub Actions), o cada entrada del buzón será un deploy.
- **Para lo de un commit sin sprint abierto:** `mantenimiento`
- **Cómo se funde a la principal:** `a mano` | `PR`

## Worktree

Cada sprint vive en su propio worktree, `<raíz>/.worktrees/<tema>` (`<raíz>`
es la ruta absoluta del checkout principal), en su propia rama; la pone
`/comanda:sprint abrir` y no se configura: es la misma en todos los proyectos.
Lo que no está en git (secretos, entornos, datos) no viaja solo: aquí va qué
correr, desde el worktree nuevo, para que quede listo. `<principal>` es la
ruta del checkout principal y `<tema>` el del sprint. O `nada`.

```bash
<comando>
```

**Recursos que no se pueden compartir** entre dos worktrees a la vez
(contenedores, puertos, bases locales) y cómo se separan: <p. ej. «el
contenedor de pruebas se llama `<proyecto>-<tema>`, con
`VARIABLE=<proyecto>-<tema>`»>. O `ninguno`.

## Techos

- **Tareas por sprint:** 5
- **Migraciones por sprint:** 2 — o `no aplica`
- **Duración de un sprint:** 2–4 días
- **Líneas de `docs/ROADMAP.md`:** 400
- **Entradas sin triar para sugerir `/comanda:triage`:** 8

## ROADMAP

- **Camino crítico:** <la sección, p. ej. `§3.0`> — o `no hay`. Mientras tenga
  pasos sin cerrar, el sprint que se abra es su siguiente paso.
- **Tramo de «medir primero»:** <la sección, p. ej. `§3.G`>
- **Las dos listas de §4:** «Bloquea al agente» y «Espera del <cliente>».

## Numeraciones

Lo que `docs/ROADMAP.md` §2 lleva al día. Cada renglón: qué es y el comando
que da el último número **de verdad** (el árbol manda sobre el documento).

- <migraciones>: `ls db/migrations | tail -1`
- <pruebas>: `ls db/tests/*.sql | tail -1`

## Migraciones

O `no aplica`. Si aplica:

- **Carpeta:** `db/migrations/`
- **Notas de cada una:** `db/README.md` — ahí se anota «aplicada el …».
- **Quién la aplica y cómo:** <p. ej. «el agente, con
  `scripts/aplicar_migracion.py`, primero en seco»>
- **Retroactiva** (toca datos que ya existen): <qué la acompaña — aviso al
  cliente, medición antes y después…>. El aviso lo redacta el agente y lo
  manda una de las personas, después de aplicar.

**Candados antes de aplicar una**: el método ya exige que la rama contenga
`<remoto>/<principal>` recién traída. Lo que el proyecto agregue —comandos
que tienen que salir bien antes de aplicar— va aquí. O `ninguno`.

```bash
<comando>
```

## Verificación

Los comandos que tienen que salir en verde para entregar un sprint, en orden.
`/comanda:sprint entregar` los corre todos; `/comanda:next` dice cuáles tocan
a la tarea antes de empezar.

```bash
<comando>
<comando>
```

## Recorridos

O `no aplica`. Lo que hay que ver con los ojos, en el navegador o donde sea.

- **Archivo:** `docs/RECORRIDOS.md` — tiene una línea «Última corrida».
- **Qué carpeta es «pantalla»:** `<webapp/>` — un sprint que la toque añade o
  cambia sus renglones en el archivo de recorridos.

## Reglas del proyecto

Lo que el método no sabe y el proyecto sí: una regla por renglón, con el id de
su decisión si la tiene. Los comandos las respetan como si estuvieran escritas
en ellos.

- <regla>
- <si hay repo hijo, en prosa; si no, quita el renglón:
  «`odoo/` es un repo hijo: el de Odoo.sh del cliente, clonado de `<url>`
  en `<raíz>/odoo`, aparte e ignorado, no submódulo. En cada sprint su
  worktree va dentro del del sprint, en la rama `<tema>`, con ruta absoluta,
  sacada de `<rama base, p. ej. staging>` y sin rastrearla: `git -C
  <raíz>/odoo fetch origin` y `git -C <raíz>/odoo worktree add --no-track
  <raíz>/.worktrees/<tema>/odoo -b <tema> origin/<rama base>`; el primer push,
  `push -u origin <tema>`. Fundir es <p. ej. un PR de
  `<tema>` contra `staging` en el repo del cliente, que funde una persona al
  cerrar el sprint>. Los comandos de Comanda no lo conocen: lo que haga
  falta, el agente lo lee aquí.»>
