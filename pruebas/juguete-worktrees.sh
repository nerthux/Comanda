#!/usr/bin/env bash
# Prueba de punta a punta del worktree del sprint en
# <raíz>/.worktrees/<tema>—: los skills de este checkout corridos con
# `claude -p --plugin-dir` sobre un repo de juguete con remoto --bare local,
# en una carpeta temporal. No toca ningún repo real.
#
#   bash pruebas/juguete-worktrees.sh
#   CONSERVAR=1 bash pruebas/juguete-worktrees.sh   # deja el temporal para mirar
#
# **Se corre a mano**, no en el CI ni en «Verificación»: gasta seis sesiones de
# `claude -p` (unos minutos) y necesita el CLI autenticado. Lo que dijo cada
# sesión queda en <temporal>/<paso>.txt; sus denegaciones, en <paso>.jsonl.
#
# Sale con 0 si todo pasa; si algo falla, dice qué y sale con 1.

# SC2015: «prueba && bien … || mal …» es a propósito: bien y mal siempre salen con 0.
# shellcheck disable=SC2015

set -uo pipefail

PLUGIN="${COMANDA_PLUGIN:-$(cd "$(dirname "$0")/.." && pwd)}"
T="$(mktemp -d)"
if [ -n "${CONSERVAR:-}" ]; then echo "temporal: $T"; else trap 'rm -rf "$T"' EXIT; fi
FALLAS=0

bien()  { echo "  ✔ $*"; }
mal()   { echo "  ✘ $*"; FALLAS=$((FALLAS + 1)); }
igual() { if [ "$1" = "$2" ]; then bien "$3"; else mal "$3 (esperaba «$2», salió «$1»)"; fi; }
git_()  { git -c user.name=Prueba -c user.email=prueba@local "$@"; }

# corre <paso> <carpeta> <persona> <prompt>: una sesión de claude -p, como
# <persona> en git, con los permisos por defecto (los de allowed-tools).
corre() {
    local paso="$1" dir="$2" persona="$3" prompt="$4" t0=$SECONDS negadas
    [ -d "$dir" ] || { mal "$paso: no existe $dir; no se corre"; return; }
    (cd "$dir" && GIT_CONFIG_COUNT=2 \
        GIT_CONFIG_KEY_0=user.name  GIT_CONFIG_VALUE_0="$persona" \
        GIT_CONFIG_KEY_1=user.email GIT_CONFIG_VALUE_1="$persona@local" \
        claude -p "$prompt" --plugin-dir "$PLUGIN" --permission-mode default \
            --output-format stream-json --verbose) >"$T/$paso.jsonl" 2>"$T/$paso.err"
    jq -rs '[.[] | select(.type == "result")][-1].result // ""' "$T/$paso.jsonl" >"$T/$paso.txt" 2>/dev/null
    negadas="$(jq -rs '[.[] | select(.type == "result")][-1] | if . == null then "sin resultado" else (.permission_denials | length) end' \
        "$T/$paso.jsonl" 2>/dev/null)"
    echo "  · $paso: $((SECONDS - t0)) s, ${negadas:-?} denegaciones"
    igual "${negadas:-?}" 0 "$paso corre sin permisos negados"
}

cd "$T" || exit 1
R="$T/juguete"
git init -q --bare -b main "$T/remoto.git"
git clone -q "$T/remoto.git" juguete 2>/dev/null
mkdir -p juguete/docs
cat >juguete/docs/COMANDA.md <<'EOF'
# Comanda — configuración de este proyecto

## Personas

- Uno — git: `Uno`
- Dos — git: `Dos`

- **Camino crítico:** lo mueve Uno.
- **Cliente:** la prueba — quien pide. Lo que pide entra al buzón con origen `prueba`.
- **Nombres del lado del cliente:** ninguno.
- **Canal para preguntarle al cliente:** no aplica.

## Ramas

- **Remoto:** `origin`
- **Principal:** `main` — un push no despliega nada.
- **Para lo de un commit sin sprint abierto:** `mantenimiento`
- **Cómo se funde a la principal:** `a mano`

## Worktree

nada

**Recursos que no se pueden compartir:** ninguno.

## Techos

- **Tareas por sprint:** 5
- **Migraciones por sprint:** no aplica
- **Duración de un sprint:** 2–4 días
- **Líneas de `docs/ROADMAP.md`:** 200
- **Entradas sin triar para sugerir `/comanda:triage`:** 8

## ROADMAP

- **Camino crítico:** no hay.
- **Tramo de «medir primero»:** no hay.
- **Las dos listas de §4:** «Bloquea al agente» y «Espera de la prueba».

## Numeraciones

no aplica

## Migraciones

no aplica

## Verificación

```bash
test -f README.md
```

## Recorridos

no aplica

## Reglas del proyecto

- Es un repo de juguete: nada se despliega.
EOF
cat >juguete/docs/ROADMAP.md <<'EOF'
# Roadmap — juguete

## 1. Estado verificado el 2026-09-23

Hay un README.

## 2. La numeración

No aplica.

## 3. La cola, en orden

### De paso

*(vacío)*

### A · Saludo — *sin plan, un sprint*

- **Escribir `saludo.txt`** con «hola».

### B · Despedida — *sin plan, un sprint*

- **Escribir `adios.txt`** con «adiós».

## 4. Lo que espera

### 4.1 Bloquea al agente

*(vacío)*

### 4.2 Espera de la prueba

*(vacío)*

## 5. Preguntas abiertas

*(ninguna)*
EOF
printf '# Buzón de entrada\n\n## Sin triar\n\n*(vacío)*\n' >juguete/docs/BUZON.md
printf '# Decisiones\n\n| Id | Fecha | Quién | Qué | Dónde | Por qué |\n|---|---|---|---|---|---|\n' \
    >juguete/docs/DECISIONES.md
printf '# Changelog\n\n' >juguete/CHANGELOG.md
echo "# Juguete" >juguete/README.md
git_ -C juguete add -A && git_ -C juguete commit -qm inicio && git -C juguete push -q origin main

echo "1) abrir desde el checkout"
corre 1-abrir-uno "$R" Uno "/comanda:sprint abrir uno — el tema se llama «uno» y va contra el tramo A de ROADMAP §3"
[ -d "$R/.worktrees/uno" ] && bien "el worktree está en <raíz>/.worktrees/uno" \
    || mal "no hay <raíz>/.worktrees/uno"
igual "$(git -C "$R/.worktrees/uno" branch --show-current 2>/dev/null)" "uno" "el worktree está en la rama uno"
git -C "$T/remoto.git" show main:docs/sprints/uno.md 2>/dev/null \
    | grep -qF "**Worktree:** \`$R/.worktrees/uno\`" \
    && bien "la cabecera lleva la ruta absoluta" || mal "la cabecera no lleva «$R/.worktrees/uno»"
igual "$(cat "$R/.worktrees/.gitignore" 2>/dev/null)" "*" ".worktrees/.gitignore ignora todo"
git -C "$T/remoto.git" rev-parse -q --verify refs/heads/uno >/dev/null && bien "la rama uno está subida" \
    || mal "la rama uno no está en el remoto"
igual "$(git -C "$R" status --porcelain)" "" "la raíz sigue limpia"

echo "2) abrir desde dentro de otro sprint: no se anida"
corre 2-abrir-dos "$R/.worktrees/uno" Dos "/comanda:sprint abrir dos — el tema se llama «dos» y va contra el tramo B de ROADMAP §3"
[ -d "$R/.worktrees/dos" ] && bien "el segundo está en <raíz>/.worktrees/dos" \
    || mal "no hay <raíz>/.worktrees/dos"
[ -e "$R/.worktrees/uno/.worktrees" ] && mal "quedó anidado en .worktrees/uno/.worktrees/" \
    || bien "no hay nada anidado en el primero"
igual "$(git -C "$R" status --porcelain)" "" "la raíz sigue limpia"

echo "3) next: desde el worktree arranca; desde el checkout manda al worktree"
antes="$(git -C "$R/.worktrees/uno" rev-parse HEAD)"
corre 3-next-worktree "$R/.worktrees/uno" Uno "/comanda:next"
igual "$(git -C "$R/.worktrees/uno" rev-parse HEAD)" "$antes" "next no commiteó"
igual "$(git -C "$R/.worktrees/uno" status --porcelain)" "" "next no dejó cambios"
corre 3-next-checkout "$R" Uno "/comanda:next"
grep -qF "$R/.worktrees/uno" "$T/3-next-checkout.txt" && bien "next nombra la ruta de la cabecera" \
    || mal "next no nombra «$R/.worktrees/uno»"

echo "4) cerrar desde dentro del worktree que se quita"
corre 4-cerrar-uno "$R/.worktrees/uno" Uno \
    "/comanda:sprint cerrar uno — lo cierro yo, Uno; lo que haya pendiente regresa al backlog"
git -C "$T/remoto.git" ls-tree --name-only main docs/archivo/ 2>/dev/null | grep -q 'SPRINT_uno_' \
    && bien "el sprint quedó archivado en main" || mal "no hay docs/archivo/SPRINT_uno_* en main"
[ -e "$R/.worktrees/uno" ] && mal "el worktree de uno sigue ahí" || bien "el worktree de uno se quitó"
igual "$(git -C "$R" branch --list uno)" "" "la rama local uno se borró"

echo "5) cerrar un sprint abierto con la ruta vieja (../<carpeta>-<tema>, 0.2.x)"
git -C "$R" pull -q --ff-only origin main
mkdir -p "$R/docs/sprints"
cat >"$R/docs/sprints/viejo.md" <<'EOF'
# Sprint — Abierto con la ruta vieja

**Dueño:** Uno · **Rama:** `viejo` · **Worktree:** `../juguete-viejo` · **Abierto:** 2026-09-20
**Reservas:** ninguna
**Estado:** Entregado el 2026-09-21; lo cierra quien lo revise

**Tema:** abierto con Comanda 0.2.x, cuando el worktree iba en `../<carpeta>-<tema>`.

## Las tareas

| # | Tarea | Dónde | Estado |
|---|---|---|---|
| 1 | Escribir `viejo.txt` | `viejo.txt` | hecho |

## Decisiones del sprint

*(ninguna)*

## De paso

*(nada)*

## Lo que te toca a ti

*(nada)*
EOF
git_ -C "$R" add docs/sprints/viejo.md && git_ -C "$R" commit -qm "Sprint viejo: abre y reserva nada" \
    && git -C "$R" push -q origin main
git -C "$R" worktree add -q ../juguete-viejo -b viejo origin/main
echo viejo >"$T/juguete-viejo/viejo.txt"
git_ -C "$T/juguete-viejo" add viejo.txt && git_ -C "$T/juguete-viejo" commit -qm "viejo.txt"
git -C "$R" push -q origin viejo
corre 5-cerrar-viejo "$R" Uno "/comanda:sprint cerrar viejo — lo cierro yo, Uno; lo reviso y está bien"
[ -e "$T/juguete-viejo" ] && mal "../juguete-viejo sigue ahí" || bien "../juguete-viejo se quitó"
git -C "$T/remoto.git" show main:viejo.txt >/dev/null 2>&1 && bien "viejo.txt llegó a main" \
    || mal "viejo.txt no llegó a main"

echo "6) al final"
igual "$(git -C "$R" status --porcelain)" "" "la raíz sigue limpia"
igual "$(git -C "$R" worktree list --porcelain | grep '^worktree ' | grep -v '/.comanda-main$' | sed "s|^worktree $T/||")" \
    "$(printf 'juguete\njuguete/.worktrees/dos')" "quedan el checkout y dos"

echo
if [ "$FALLAS" -eq 0 ]; then echo "Todo en verde."; else echo "$FALLAS fallas."; exit 1; fi
