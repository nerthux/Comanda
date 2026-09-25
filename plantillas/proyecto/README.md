# <Cliente> — <Proyecto>

**Qué es:** <en una o dos frases, qué se le entrega al cliente y para qué>.
**Para quién:** <el cliente y quién lo usa de su lado>.

Este repo es el proyecto, no una aplicación: aquí vive todo lo que el
proyecto produce y decide, con código o sin él.

## Dónde está cada cosa

```
CLAUDE.md  README.md  CHANGELOG.md
docs/          el método (BUZON, ROADMAP, DECISIONES, COMANDA, sprints/, archivo/)
               y los papeles del proyecto, en subcarpetas si crecen
datos/         fuera de git; su README.md dice dónde viven de verdad
scripts/       lo que se escribe y no es una aplicación
entregables/   informes y presentaciones, si los hay
```

<Si hay código: `odoo/` o `app/`, qué es y, si es repo aparte, de dónde se
clona — lo demás está en `docs/COMANDA.md`, «Reglas del proyecto».>

## Cómo se trabaja

Con [Comanda](https://github.com/nerthux/Comanda): lo que llega va al buzón
(`/comanda:buzon`), se reparte (`/comanda:triage`), se trabaja en sprints
(`/comanda:sprint`, `/comanda:next`) y `/comanda:estado` dice en qué va. Lo
propio de este proyecto —quién es quién, cómo se verifica, las reglas— está
en `docs/COMANDA.md`; lo que sigue, en `docs/ROADMAP.md`.
