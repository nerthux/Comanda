#!/usr/bin/env bash
# Prueba de punta a punta de los repos hijos: los skills de este checkout
# corridos con `claude -p --plugin-dir` sobre un proyecto de juguete con tres
# hijos, cada uno con su remoto --bare local, en una carpeta temporal. No
# toca ningún repo real.
#
#   bash pruebas/juguete-hijos.sh
#   CONSERVAR=1 bash pruebas/juguete-hijos.sh   # deja el temporal para mirar
#
# Los hijos: a/ lo funde el agente y se monta si el sprint lo cambia; b/ lo
# funde una persona a mano y se monta siempre; c/ no está clonado (abrir lo
# clona) y el sprint lo nombra pero no le commitea nada.
#
# **Se corre a mano**, no en el CI ni en «Verificación»: gasta cuatro sesiones
# de `claude -p` (unos minutos) y necesita el CLI autenticado. Lo que dijo
# cada sesión queda en <temporal>/<paso>.txt; sus denegaciones, en <paso>.jsonl.
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
# AskUserQuestion no cuenta: en -p no hay quien conteste.
corre() {
    local paso="$1" dir="$2" persona="$3" prompt="$4" t0=$SECONDS negadas
    [ -d "$dir" ] || { mal "$paso: no existe $dir; no se corre"; return; }
    (cd "$dir" && GIT_CONFIG_COUNT=2 \
        GIT_CONFIG_KEY_0=user.name  GIT_CONFIG_VALUE_0="$persona" \
        GIT_CONFIG_KEY_1=user.email GIT_CONFIG_VALUE_1="$persona@local" \
        claude -p "$prompt" --plugin-dir "$PLUGIN" --permission-mode default \
            --output-format stream-json --verbose) >"$T/$paso.jsonl" 2>"$T/$paso.err"
    jq -rs '[.[] | select(.type == "result")][-1].result // ""' "$T/$paso.jsonl" >"$T/$paso.txt" 2>/dev/null
    negadas="$(jq -rs '[.[] | select(.type == "result")][-1] | if . == null then "sin resultado"
        else ([.permission_denials[] | select(.tool_name != "AskUserQuestion")] | length) end' \
        "$T/$paso.jsonl" 2>/dev/null)"
    echo "  · $paso: $((SECONDS - t0)) s, ${negadas:-?} denegaciones"
    igual "${negadas:-?}" 0 "$paso corre sin permisos negados"
}

# worktrees <repo>: cuántos worktrees tiene, sin contar .comanda-main/.
worktrees() { git -C "$1" worktree list --porcelain | grep '^worktree ' | grep -vc '/.comanda-main$'; }

cd "$T" || exit 1
R="$T/juguete"
W="$R/.worktrees/uno"

for h in a b c; do
    git init -q --bare -b main "$T/$h.git"
    git clone -q "$T/$h.git" "$T/semilla-$h" 2>/dev/null
    echo "# Hijo $h" >"$T/semilla-$h/README.md"
    git_ -C "$T/semilla-$h" add -A && git_ -C "$T/semilla-$h" commit -qm inicio \
        && git -C "$T/semilla-$h" push -q origin main
    rm -rf "$T/semilla-$h"
done

git init -q --bare -b main "$T/remoto.git"
git clone -q "$T/remoto.git" juguete 2>/dev/null
mkdir -p juguete/docs
cat >juguete/docs/COMANDA.md <<EOF
# Comanda — configuración de este proyecto

## Personas

- Uno — git: \`Uno\`
- Dos — git: \`Dos\`

- **Camino crítico:** lo mueve Uno.
- **Cliente:** la prueba — quien pide. Lo que pide entra al buzón con origen \`prueba\`.
- **Nombres del lado del cliente:** ninguno.
- **Canal para preguntarle al cliente:** no aplica.

## Ramas

- **Remoto:** \`origin\`
- **Principal:** \`main\` — un push no despliega nada.
- **Para lo de un commit sin sprint abierto:** \`mantenimiento\`
- **Cómo se funde a la principal:** \`a mano\`

## Worktree

nada

**Recursos que no se pueden compartir:** ninguno.

## Repos hijos

- **\`a/\`** · clon: \`$T/a.git\` · base: \`main\`
  · se monta: si el sprint lo cambia · funde: el agente al cerrar
- **\`b/\`** · clon: \`$T/b.git\` · base: \`main\`
  · se monta: siempre · funde: una persona, a mano
- **\`c/\`** · clon: \`$T/c.git\` · base: \`main\`
  · se monta: si el sprint lo cambia · funde: el agente al cerrar

## Techos

- **Tareas por sprint:** 5
- **Migraciones por sprint:** no aplica
- **Duración de un sprint:** 2–4 días
- **Líneas de \`docs/ROADMAP.md\`:** 200
- **Entradas sin triar para sugerir \`/comanda:triage\`:** 8

## ROADMAP

- **Camino crítico:** no hay.
- **Tramo de «medir primero»:** no hay.
- **Las dos listas de §4:** «Bloquea al agente» y «Espera de la prueba».

## Numeraciones

no aplica

## Migraciones

no aplica

## Verificación

\`\`\`bash
test -f README.md
\`\`\`

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

### A · Los hijos — *sin plan, un sprint*

- **Escribir `a/hola.txt`** con «hola», en el hijo `a/`.
- **Escribir `b/hola.txt`** con «hola», en el hijo `b/`.
- **Revisar `c/README.md`** en el hijo `c/`; si está bien, no se cambia.

## 4. Lo que espera

### 4.1 Bloquea al agente

*(vacío)*

### 4.2 Espera de la prueba

*(vacío)*

## 5. Preguntas abiertas

*(ninguna)*
EOF
cat >juguete/docs/BUZON.md <<'EOF'
# Buzón de entrada

## Formato

### B-0NN · 2026-09-23 · prueba

Lo que pasó, literal.

---

## Sin triar

*(vacío)*
EOF
printf '# Decisiones\n\n| Id | Fecha | Quién | Qué | Dónde | Por qué |\n|---|---|---|---|---|---|\n' \
    >juguete/docs/DECISIONES.md
printf '# Changelog\n\n' >juguete/CHANGELOG.md
echo "# Juguete" >juguete/README.md
printf 'a/\nb/\nc/\n' >juguete/.gitignore
git_ -C juguete add -A && git_ -C juguete commit -qm inicio && git -C juguete push -q origin main
git clone -q "$T/a.git" "$R/a" 2>/dev/null
git clone -q "$T/b.git" "$R/b" 2>/dev/null

echo "1) abrir desde dentro del hijo a/: para"
corre 1-abrir-en-hijo "$R/a" Uno "/comanda:sprint abrir uno — el tema se llama «uno» y va contra el tramo A de ROADMAP §3"
[ -e "$R/.worktrees" ] && mal "se creó <raíz>/.worktrees" || bien "no hay <raíz>/.worktrees"
[ -e "$R/a/.worktrees" ] && mal "se creó a/.worktrees" || bien "no hay a/.worktrees"
igual "$(worktrees "$R/a")" 1 "el clon de a/ no tiene worktrees nuevos"
igual "$(git -C "$R/a" status --porcelain)" "" "el clon de a/ sigue limpio"
igual "$(git -C "$T/remoto.git" ls-tree --name-only main docs/sprints/ 2>/dev/null)" "" "no se publicó ningún sprint"

echo "2) abrir desde la raíz: monta los tres hijos"
corre 2-abrir "$R" Uno "/comanda:sprint abrir uno — el tema se llama «uno» y va contra el tramo A de ROADMAP §3"
igual "$(git -C "$W" branch --show-current 2>/dev/null)" "uno" "el worktree del sprint está en la rama uno"
igual "$(git -C "$R/c" rev-parse --show-toplevel 2>/dev/null)" "$R/c" "abrir clonó c/ como repo aparte"
for h in a b c; do
    igual "$(git -C "$W/$h" branch --show-current 2>/dev/null)" "uno" "$h/ está montado en la rama uno"
    igual "$(git -C "$W/$h" rev-parse --git-common-dir 2>/dev/null)" "$R/$h/.git" "$h/ es worktree de su clon"
    git -C "$T/$h.git" rev-parse -q --verify refs/heads/uno >/dev/null \
        && mal "la rama uno de $h/ ya se subió" || bien "la rama uno de $h/ no se subió"
done
sprint="$(git -C "$T/remoto.git" show main:docs/sprints/uno.md 2>/dev/null)"
for h in a b c; do
    grep -qF "$h/" <<<"$sprint" && bien "el archivo del sprint nombra $h/" || mal "el archivo del sprint no nombra $h/"
done
igual "$(git -C "$R" status --porcelain)" "" "la raíz sigue limpia"

echo "3) el trabajo del sprint (a mano): a/ y b/ cambian, c/ no"
for h in a b; do
    echo hola >"$W/$h/hola.txt"
    git_ -C "$W/$h" add hola.txt && git_ -C "$W/$h" commit -qm "hola.txt" \
        && git -C "$W/$h" push -q -u origin uno 2>/dev/null
done
sed -i -E 's/\| *(pendiente|en curso) *\|$/| hecho |/' "$W/docs/sprints/uno.md"
git_ -C "$W" commit -qam "Sprint uno: las tareas" && git -C "$R" push -q origin uno

echo "4) un commit en la principal que toca a/"
git clone -q "$T/remoto.git" "$T/otro" 2>/dev/null
mkdir -p "$T/otro/a" && echo nota >"$T/otro/a/NOTA.txt"
git_ -C "$T/otro" add -f a/NOTA.txt && git_ -C "$T/otro" commit -qm "Anota a/ en el proyecto" \
    && git -C "$T/otro" push -q origin main

echo "5) entregar: no rebasa sobre un commit que toca a/"
antes="$(git -C "$W" rev-parse HEAD)"
corre 5-entregar "$W" Uno "/comanda:sprint entregar"
igual "$(git -C "$W" rev-parse HEAD)" "$antes" "la rama uno no se movió"
igual "$(git -C "$T/remoto.git" rev-parse uno)" "$antes" "la rama uno del remoto no se movió"
[ -f "$W/a/hola.txt" ] && bien "a/hola.txt sigue en el worktree del hijo" || mal "se perdió a/hola.txt"
grep -q 'Entregado' <(sed -n '1,10p' "$W/docs/sprints/uno.md") \
    && mal "el sprint dice Entregado" || bien "el sprint no se entregó"
grep -qF 'a/' "$T/5-entregar.txt" && bien "entregar nombra a/" || mal "entregar no nombra a/"

echo "6) lo que hacen las personas: entregar a mano y fundir b/"
sed -i -E '1,10s/\*\*Estado:\*\* [^·]*/**Estado:** Entregado el 2026-09-29; lo cierra quien lo revise/' "$W/docs/sprints/uno.md"
git_ -C "$W" commit -qam "Sprint uno: entregado" && git -C "$R" push -q origin uno
git clone -q "$T/b.git" "$T/b-persona" 2>/dev/null
git_ -C "$T/b-persona" merge -q --no-ff origin/uno -m "Fundir uno" && git -C "$T/b-persona" push -q origin main
b_main="$(git -C "$T/b.git" rev-parse main)"
b_uno="$(git -C "$T/b.git" rev-parse --short=7 uno)"

echo "7) cerrar desde dentro del worktree del sprint"
corre 7-cerrar "$W" Uno \
    "/comanda:sprint cerrar uno — lo cierro yo, Uno; lo reviso y está bien. No hay D-n ni hubo lecciones."
a_main="$(git -C "$T/a.git" rev-parse --short=7 main)"
git -C "$T/a.git" show main:hola.txt >/dev/null 2>&1 && bien "a/hola.txt llegó a la main de a/" \
    || mal "a/hola.txt no llegó a la main de a/"
igual "$(git -C "$T/a.git" rev-list --parents -n1 main | wc -w)" 3 "la punta de a/ es un merge"
igual "$(git -C "$T/b.git" rev-parse main)" "$b_main" "la main de b/ sigue en el merge de la persona"
for h in a b c; do
    igual "$(worktrees "$R/$h")" 1 "el worktree de $h/ se quitó"
    igual "$(git -C "$R/$h" branch --list uno)" "" "la rama local uno de $h/ se borró"
    git -C "$T/$h.git" rev-parse -q --verify refs/heads/uno >/dev/null \
        && mal "la rama uno sigue en el remoto de $h/" || bien "la rama uno no está en el remoto de $h/"
done
igual "$(git -C "$R/a" status --porcelain --branch | head -1)" "## main...origin/main" "el clon de a/ quedó en main, al día"
git -C "$T/remoto.git" ls-tree --name-only main docs/archivo/ 2>/dev/null | grep -q 'SPRINT_uno_' \
    && bien "el sprint quedó archivado en main" || mal "no hay docs/archivo/SPRINT_uno_* en main"
cl="$(git -C "$T/remoto.git" show main:CHANGELOG.md 2>/dev/null)"
grep -qF "$a_main" <<<"$cl" && bien "el CHANGELOG cita el merge de a/ ($a_main)" \
    || mal "el CHANGELOG no cita el merge de a/ ($a_main)"
grep -qF "$b_uno" <<<"$cl" && bien "el CHANGELOG cita la punta de uno en b/ ($b_uno)" \
    || mal "el CHANGELOG no cita la punta de uno en b/ ($b_uno)"
[ -d "$W" ] && bien "el worktree del sprint sigue: la sesión estaba dentro" || mal "se quitó el worktree donde estaba la sesión"
grep -qF "worktree remove" "$T/7-cerrar.txt" && bien "cerrar deja los comandos del worktree del sprint" \
    || mal "cerrar no deja los comandos del worktree del sprint"

echo "8) al final"
igual "$(git -C "$R" status --porcelain)" "" "la raíz sigue limpia"

echo
if [ "$FALLAS" -eq 0 ]; then echo "Todo en verde."; else echo "$FALLAS fallas."; exit 1; fi
