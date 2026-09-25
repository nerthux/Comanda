# Arrancar un proyecto desde cero con Comanda

Para un proyecto que todavía no existe: no hay repo, ni roadmap, ni
decisiones, sólo lo que se le propuso al cliente. Si el proyecto ya existe y
tiene su forma de trabajar, es `ADOPTAR.md`.

Es una receta más un esqueleto, no un script —se hace una vez por
proyecto—: los pasos están aquí y los archivos, en `plantillas/proyecto/`. Todo se copia **desde `plantillas/`**
—un clon de Comanda o la copia instalada en
`~/.claude/plugins/cache/comanda/comanda/<versión>/`—, no de memoria:
`<Comanda>` es esa carpeta.

## La forma de un proyecto

El repo es el proyecto, no la aplicación: el estado —buzón, roadmap,
decisiones, sprints— es del proyecto, y muchos proyectos no llevan código.

```
~/Projects/<Cliente>-<Proyecto>/     ← un repo git: el proyecto; aquí vive Comanda
├── CLAUDE.md  README.md  CHANGELOG.md
├── .claude/settings.json            ← el plugin, declarado en el proyecto
├── docs/                            ← el método (nombres fijos) y los papeles del
│                                       proyecto, en subcarpetas si crecen
├── datos/                           ← fuera de git; su README.md dice dónde viven
├── scripts/                         ← lo que se escribe y no es una aplicación
├── entregables/                     ← informes y presentaciones, si los hay
├── odoo/  o  app/                   ← sólo si hay código (paso 4)
└── .worktrees/<tema>/               ← un sprint; lo crea /comanda:sprint abrir
```

Un proyecto sin código es esto sin `odoo/` ni `app/`, y nada más cambia.

## Los pasos

1. **La carpeta y el repo.** `~/Projects/<Cliente>-<Proyecto>`, y ahí
   `git init -b main`. Crea el remoto vacío (privado: lleva cosas del
   cliente) y `git remote add origin <url>`.
2. **Copiar el esqueleto:**

   ```bash
   cp -r <Comanda>/plantillas/proyecto/. .
   cp <Comanda>/plantillas/COMANDA.md docs/COMANDA.md
   ```

   `docs/COMANDA.md` no vive en el esqueleto: se copia de la plantilla para
   que no haya dos versiones que se desfasen.
3. **Llenar `docs/COMANDA.md`**: las personas y quién mueve el camino
   crítico, el cliente, sus nombres y el canal para preguntarle, el remoto y
   la principal, el worktree, los techos y las reglas del proyecto. Una
   sección que no aplica dice `no aplica` —la verificación, mientras no haya
   nada que correr— y **no se quitan los títulos**. `datos/` no está en git,
   así que no llega al worktree de un sprint: si un sprint los va a usar,
   «Worktree» dice cómo llegan ahí.
4. **Si hay código, ¿repo hijo o carpeta?** Es **repo hijo** cuando otro
   dicta su forma: Odoo.sh (la raíz de su repo es la de los módulos y las
   ramas son entornos), un GitHub del cliente, una CI que despliega al push.
   Es **`app/`, carpeta del mismo repo**, cuando el código es del proyecto y
   nadie lo despliega desde git. Un repo hijo:
   - va aparte e ignorado, **no como submódulo**: descomenta su línea en
     `.gitignore` y clónalo en `odoo/`;
   - se declara **en prosa**, en «Reglas del proyecto» de `docs/COMANDA.md`:
     de dónde se clona, cómo se llama su rama por sprint y qué es fundir. Los
     comandos todavía no saben de repos hijos: lo que haga falta lo lee el
     agente de ahí;
   - en cada sprint, su worktree va dentro del del sprint, en la rama del
     sprint y **con ruta absoluta** (con una relativa, desde `odoo/`, cae en
     `odoo/.worktrees/…`), sacada de la rama base recién traída y sin
     rastrearla (si no, `<tema>` queda siguiendo a la base y un `pull` la
     trae); el primer push le pone su upstream:

     ```bash
     git -C <raíz>/odoo fetch origin
     git -C <raíz>/odoo worktree add --no-track <raíz>/.worktrees/<tema>/odoo -b <tema> origin/<base>
     git -C <raíz>/.worktrees/<tema>/odoo push -u origin <tema>
     ```

   Con el código aparte, el buzón y las reservas que se publican en la
   principal del proyecto no disparan despliegues.
5. **`README.md`, `CLAUDE.md` y `datos/README.md`**, llenos: qué es el
   proyecto y para quién, dónde está cada cosa, y dónde viven los datos de
   verdad. `CLAUDE.md` se queda corto y no fija la ruta del worktree: la
   pone `/comanda:sprint abrir` y es la misma en todos los proyectos.
6. **El primer `docs/ROADMAP.md`.** Sin proyecto no hay
   buzón ni medición: lo único que existe es lo que se le vendió al cliente.
   - §3, **desde la propuesta**: un tramo por entregable, sin plan;
   - el camino crítico, si lo hay, lo escribe quien dice «Camino crítico» en
     `docs/COMANDA.md`, y la sección va en «ROADMAP» de ese archivo;
   - §1 dice «sin verificar todavía» hasta que algo se pueda correr.
7. **Declarar el plugin**, para que le llegue a quien clone el proyecto:

   ```bash
   claude plugin marketplace add nerthux/Comanda --scope project
   claude plugin install comanda@comanda --scope project
   ```

   Escribe `.claude/settings.json`, que se commitea.
8. **El primer commit y el push de la principal.** Antes, `git status`: no
   deben salir `datos/` ni el repo hijo. Luego

   ```bash
   git add -A
   git commit -m "Arranque del proyecto con Comanda"
   git push -u origin main
   ```

   Sin la principal en el remoto, `comanda-main` se niega, y con él el
   buzón, las reservas y el triage.
9. **El primer sprint, sin buzón**: `/comanda:sprint abrir` contra el §3 del
   paso 6. El buzón está vacío y no hay nada que triar; el sprint queda en
   `<raíz>/.worktrees/<tema>`. Si hay repo hijo, `abrir` lee «Reglas del
   proyecto» y suele montar su worktree; comprueba que esté, en la rama
   `<tema>`, y si no, móntalo como dice el paso 4. Ahí, `/clear` y
   `/comanda:next`.
