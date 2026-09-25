#!/usr/bin/env bash
# Pruebas de bin/comanda-main: dos clones contra un remoto --bare local, en una
# carpeta temporal que se borra al terminar. No toca ningún repo real.
#
#   bash pruebas/comanda-main.sh
#
# Sale con 0 si todo pasa; si algo falla, dice qué y sale con 1.

# SC2015: «prueba && bien … || mal …» es a propósito: bien y mal siempre salen con 0.
# shellcheck disable=SC2015

set -uo pipefail

CM="${COMANDA_MAIN:-$(cd "$(dirname "$0")/.." && pwd)/bin/comanda-main}"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
FALLAS=0

bien()  { echo "  ✔ $*"; }
mal()   { echo "  ✘ $*"; FALLAS=$((FALLAS + 1)); }
igual() { if [ "$1" = "$2" ]; then bien "$3"; else mal "$3 (esperaba «$2», salió «$1»)"; fi; }
en()    { local d="$1"; shift; (cd "$T/$d" && "$@"); }
# Una ruta vacía haría escribir en / : si ruta falla, se aborta todo.
ruta()  { local w; w="$(en "$1" "$CM" ruta)" && [ -n "$w" ] && [ -d "$w" ] \
              || { echo "  ✘ ruta falló en $1; se aborta el resto" >&2; exit 1; }
          echo "$w"; }

git_() { git -c user.name=Prueba -c user.email=prueba@local "$@"; }

cd "$T" || exit 1
git init -q --bare -b main remoto.git
git clone -q remoto.git semilla 2>/dev/null
mkdir -p semilla/docs
printf '# Buzón\n\n## Sin triar\n\nB-001\n' > semilla/docs/BUZON.md
echo a > semilla/otro.txt
git_ -C semilla add -A && git_ -C semilla commit -qm inicio && git -C semilla push -q origin main
for q in gabriel alex; do
    git clone -q remoto.git "$q" 2>/dev/null
    git -C "$q" config user.name "$q"; git -C "$q" config user.email "$q@local"
done
git -C gabriel checkout -qb sprint-x

echo "1) ruta no toca el checkout de nadie"
WG="$(ruta gabriel)" || exit 1; WA="$(ruta alex)" || exit 1
igual "$WG" "$T/gabriel/.comanda-main" "el worktree de paso va dentro del checkout"
igual "$(git -C gabriel branch --show-current)" "sprint-x" "la rama del checkout no cambia"
igual "$(git -C gabriel status --porcelain)" "" "el checkout sigue limpio (.comanda-main excluido)"

echo "2) dos reservas del mismo id: una pasa, la otra sale con 3"
echo "B-002 gabriel" >> "$WG/docs/BUZON.md"; echo "B-002 alex" >> "$WA/docs/BUZON.md"
en gabriel "$CM" publicar --reserva "B-002 gabriel" >/dev/null; igual "$?" 0 "la primera publica"
[ -e "$WG" ] && mal "el worktree de paso sigue ahí tras publicar" || bien "el worktree de paso se borra al publicar"
en alex "$CM" publicar --reserva "B-002 alex" >/dev/null; igual "$?" 3 "la segunda sale RECHAZADO (3)"
igual "$(tail -1 "$WA/docs/BUZON.md")" "B-002 gabriel" "tras el rechazo, el worktree ya está en lo nuevo"
echo "B-003 alex" >> "$WA/docs/BUZON.md"
en alex "$CM" publicar --reserva "B-003 alex" >/dev/null; igual "$?" 0 "recalculada, la reserva entra"

echo "3) publicar sobre archivos distintos: entran los dos"
WG="$(ruta gabriel)" || exit 1; WA="$(ruta alex)" || exit 1
echo b >> "$WG/otro.txt"; echo n > "$WA/triage.txt"
en gabriel "$CM" publicar "otro" >/dev/null; igual "$?" 0 "el primero publica"
en alex "$CM" publicar "triage" >/dev/null; igual "$?" 0 "el segundo rebasa y publica"
igual "$(git -C remoto.git show main:triage.txt)" "n" "los dos cambios están en main"

echo "4) la misma línea: CONFLICTO (4), nada roto, descartar deja limpio"
WG="$(ruta gabriel)" || exit 1; WA="$(ruta alex)" || exit 1
sed -i 's/^B-001$/B-001 G/' "$WG/docs/BUZON.md"; sed -i 's/^B-001$/B-001 A/' "$WA/docs/BUZON.md"
en gabriel "$CM" publicar "G" >/dev/null
en alex "$CM" publicar "A" >/dev/null; igual "$?" 4 "sale CONFLICTO (4)"
en alex "$CM" ruta >/dev/null 2>&1; igual "$?" 2 "ruta se niega con lo no publicado (2)"
en alex "$CM" descartar >/dev/null
[ -e "$WA" ] && mal "descartar no borró el worktree" || bien "descartar borra el worktree"
en alex "$CM" ruta >/dev/null; igual "$?" 0 "después, ruta funciona"
en alex "$CM" descartar >/dev/null
git -C remoto.git show main:docs/BUZON.md | grep -q '^B-001 G$' && bien "main tiene lo que se publicó primero" \
    || mal "main no tiene lo que se publicó primero"

echo "5) desde el worktree de un sprint, un cierre --no-ff con publicación ajena en medio"
git -C gabriel worktree add -q -b tema-y ../gabriel-tema-y origin/main
echo y > gabriel-tema-y/y.txt
git -C gabriel-tema-y add y.txt && git -C gabriel-tema-y commit -qm "tarea y"
git -C gabriel-tema-y push -q origin tema-y 2>/dev/null
W="$(ruta gabriel-tema-y)" || exit 1
igual "$W" "$T/gabriel-tema-y/.comanda-main" "desde un worktree de sprint, el de paso va en ese worktree"
git -C "$W" merge -q --no-ff origin/tema-y -m "fundir tema-y"
echo c >> "$W/CHANGELOG.md"
WA="$(ruta alex)" || exit 1; echo z > "$WA/z.txt"; en alex "$CM" publicar "en medio" >/dev/null
en gabriel-tema-y "$CM" publicar "Cierre" >/dev/null; igual "$?" 0 "el cierre rebasa y publica"
padres="$(git -C remoto.git log --merges --format=%p -1 main | wc -w)"
igual "$padres" 2 "el merge sobrevive al rebase"

echo "6) sin remoto, se niega"
git init -q sinremoto
en sinremoto "$CM" ruta >/dev/null 2>&1; igual "$?" 1 "sale con 1"

echo "7) publicar con la shell dentro del worktree de paso"
WG="$(ruta gabriel)" || exit 1; echo d > "$WG/dentro.txt"
en gabriel/.comanda-main "$CM" publicar "desde dentro" >/dev/null 2>&1; igual "$?" 0 "sale con 0"
igual "$(git -C remoto.git show main:dentro.txt 2>/dev/null)" "d" "y sí publicó"

echo "8) un remoto con URL relativa"
git clone -q remoto.git relativo 2>/dev/null && git -C relativo remote set-url origin ../remoto.git
git -C relativo config user.name relativo; git -C relativo config user.email relativo@local
W="$(ruta relativo)" || exit 1; echo r > "$W/relativo.txt"
en relativo "$CM" publicar "relativo" >/dev/null 2>&1; igual "$?" 0 "publica"
igual "$(git -C remoto.git show main:relativo.txt 2>/dev/null)" "r" "y llega al remoto"

echo "9) un marcador de conflicto no se publica"
W="$(ruta gabriel)" || exit 1; printf '<<<<<<< HEAD\nx\n=======\ny\n>>>>>>> otro\n' > "$W/marcas.txt"
en gabriel "$CM" publicar "con marcador" >/dev/null 2>&1; igual "$?" 1 "sale con 1"
git -C remoto.git show main:marcas.txt >/dev/null 2>&1 && mal "el marcador llegó a main" || bien "main no lo tiene"
[ -e "$W/.git" ] && bien "el worktree se queda para arreglarlo" || mal "el worktree se borró"
printf 'x  \ny\n' > "$W/marcas.txt"
en gabriel "$CM" publicar "arreglado" >/dev/null 2>&1; igual "$?" 0 "arreglado (y con espacios finales de markdown), publica"

echo "10) un subrayado setext de siete = sí se publica"
W="$(ruta gabriel)" || exit 1; printf 'Título\n=======\n' > "$W/setext.txt"
en gabriel "$CM" publicar "setext" >/dev/null 2>&1; igual "$?" 0 "sale con 0"
igual "$(git -C remoto.git show main:setext.txt 2>/dev/null | tail -1)" "=======" "y main lo tiene"

echo "11) un argumento de más no se ignora: el cuerpo va en el mismo"
W="$(ruta gabriel)" || exit 1; echo m > "$W/cuerpo.txt"
en gabriel "$CM" publicar "título" "cuerpo" >/dev/null 2>&1; igual "$?" 1 "con dos argumentos sale con 1"
git -C remoto.git show main:cuerpo.txt >/dev/null 2>&1 && mal "llegó a main sin cuerpo" || bien "main no lo tiene"
[ -e "$W/.git" ] && bien "el worktree se queda" || mal "el worktree se borró"
en gabriel "$CM" publicar $'título\n\ncuerpo' >/dev/null 2>&1; igual "$?" 0 "en un solo argumento, publica"
igual "$(git -C remoto.git log -1 --format=%b main)" "cuerpo" "y el commit lleva el cuerpo"

echo "12) un remoto sin la principal"
git init -q --bare -b main vacio.git
git clone -q vacio.git sinmain 2>/dev/null
err="$(en sinmain "$CM" ruta 2>&1 >/dev/null)"; igual "$?" 1 "ruta sale con 1"
grep -q "no tiene la rama 'main'" <<<"$err" && bien "y dice que falta la principal" \
    || mal "no dice que falta la principal: «$err»"
[ -e "$T/sinmain/.comanda-main" ] && mal "quedó un .comanda-main" || bien "no deja worktree de paso"

echo "13) una carrera con git en español"
es() { local d="$1"; shift; (cd "$T/$d" && LANG=en_US.UTF-8 LANGUAGE=es "$@"); }
if ! es gabriel git status 2>/dev/null | grep -q "En la rama"; then
    echo "  – se salta: git no traduce al español en esta máquina"
else
    WG="$(ruta gabriel)" || exit 1; WA="$(ruta alex)" || exit 1
    echo "B-100 gabriel" >> "$WG/docs/BUZON.md"; echo "B-100 alex" >> "$WA/docs/BUZON.md"
    es gabriel "$CM" publicar --reserva "B-100 gabriel" >/dev/null; igual "$?" 0 "la primera publica"
    es alex "$CM" publicar --reserva "B-100 alex" >/dev/null 2>&1; igual "$?" 3 "la segunda sale RECHAZADO (3), no como otro fallo"
    en alex "$CM" descartar >/dev/null 2>&1
fi

echo "14) una principal que rechaza el push no es una carrera"
git init -q --bare -b main protegido.git
git clone -q protegido.git prot 2>/dev/null
git -C prot config user.name prot; git -C prot config user.email prot@local
mkdir -p prot/docs; printf '# Buzón\n\n## Sin triar\n\nB-001\n' > prot/docs/BUZON.md
git -C prot add -A && git -C prot commit -qm inicio && git -C prot push -q origin main 2>/dev/null
# El hook entra después de sembrar main: rechaza todo push, como una principal protegida.
printf '#!/bin/sh\necho "principal protegida" >&2\nexit 1\n' > protegido.git/hooks/pre-receive
chmod +x protegido.git/hooks/pre-receive
W="$(ruta prot)" || exit 1; echo "B-002 prot" >> "$W/docs/BUZON.md"
err="$(en prot "$CM" publicar --reserva "B-002 prot" 2>&1 >/dev/null)"; igual "$?" 1 "con --reserva sale con 1, no RECHAZADO (3)"
grep -q "principal protegida" <<<"$err" && bien "y muestra el texto de git" || mal "no muestra el texto de git: «$err»"
grep -q "no fue una carrera" <<<"$err" && bien "y dice que no fue una carrera" || mal "no dice que no fue una carrera: «$err»"
igual "$(tail -1 "$W/docs/BUZON.md")" "B-002 prot" "lo anotado no se descartó"
err="$(en prot "$CM" publicar "B-002 prot" 2>&1 >/dev/null)"; igual "$?" 1 "sin --reserva también sale con 1"
grep -q "tres intentos" <<<"$err" && mal "sin --reserva dio tres vueltas" || bien "y no da tres vueltas"
[ -e "$W/.git" ] && bien "el worktree se queda" || mal "el worktree se borró"
en prot "$CM" descartar >/dev/null
[ -e "$W" ] && mal "descartar no borró el worktree" || bien "descartar deja limpio"

echo
if [ "$FALLAS" -eq 0 ]; then echo "Todo pasa."; else echo "$FALLAS fallas."; exit 1; fi
