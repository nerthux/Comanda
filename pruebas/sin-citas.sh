#!/usr/bin/env bash
# Lo público no cita lo privado: ni decisiones (DEC-…), ni entradas del buzón
# de este repo (B-…), ni los nombres del lado del cliente. Quien instala el
# plugin no ve docs/, y una cita que no se puede leer no sirve.
#
#   bash pruebas/sin-citas.sh [ruta…]
#
# Sin rutas, revisa las del plugin. Los nombres del cliente salen de
# «Nombres del lado del cliente» en docs/COMANDA.md, para que este guion no los
# publique; sin ese archivo no se revisan. Sale con 0 si no hay citas; si las
# hay, dice dónde y sale con 1.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
YO="pruebas/$(basename "$0")"
[ "$#" -gt 0 ] || set -- .claude-plugin skills bin plantillas pruebas .github
FALLAS=0

bien() { echo "  ✔ $*"; }
mal()  { echo "  ✘ $*"; FALLAS=$((FALLAS + 1)); }

# Los B-ids que sí van: ejemplos del formato para el proyecto que instala, y
# datos de prueba. Por archivo, para que un B-007 citado en otro lado no pase.
permitidos() {
    case "$1" in
        skills/buzon/SKILL.md|skills/triage/SKILL.md) echo "B-001 B-007 B-009" ;;
        pruebas/comanda-main.sh)                      echo "B-001 B-002 B-003 B-100" ;;
    esac
}

# Sin acentos ni mayúsculas: «Semáforo» tiene que caer con «Semaforo».
llano() {
    sed 's/á/a/g; s/Á/a/g; s/é/e/g; s/É/e/g; s/í/i/g; s/Í/i/g; s/ó/o/g; s/Ó/o/g;
         s/ú/u/g; s/Ú/u/g; s/ü/u/g; s/Ü/u/g; s/ñ/n/g; s/Ñ/n/g' | tr '[:upper:]' '[:lower:]'
}

# Cada nombre entero y partido por sus jorobas (SemaforoDeRegil → Semaforo,
# Regil), con las piezas de cinco letras o más: el texto los escribe sueltos.
NOMBRES=()
if [ -f docs/COMANDA.md ]; then
    linea="$(grep -m1 'Nombres del lado del cliente:' docs/COMANDA.md)"
    linea="${linea#*:\*\*}"; linea="${linea%% —*}"
    IFS=',' read -ra lista <<< "$linea"
    for n in "${lista[@]}"; do
        n="$(echo "$n" | sed 's/^ *//; s/ *$//')"
        [ -n "$n" ] || continue
        NOMBRES+=("$(echo "$n" | llano)")
        # SC2001: ${n//…} no tiene retrorreferencias, y la joroba las pide.
        # shellcheck disable=SC2001
        for p in $(echo "$n" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g'); do
            [ "${#p}" -ge 5 ] && [ "$p" != "$n" ] && NOMBRES+=("$(echo "$p" | llano)")
        done
    done
    [ "${#NOMBRES[@]}" -gt 0 ] || echo "  · docs/COMANDA.md no dice nombres del lado del cliente: no se revisan"
else
    echo "  · sin docs/COMANDA.md: no se revisan los nombres del cliente"
fi

BUSCAR=()
for p in "${NOMBRES[@]}"; do BUSCAR+=(-e "$p"); done

ARCHIVOS=0
while IFS= read -r -d '' f; do
    f="${f#./}"
    [ "$f" = "$YO" ] && continue
    ARCHIVOS=$((ARCHIVOS + 1))
    while IFS=: read -r n t; do mal "$f:$n: $t"; done < <(grep -nE 'DEC-[0-9]' "$f")
    ok=" $(permitidos "$f") "
    while IFS=: read -r n id; do
        case "$ok" in *" $id "*) ;; *) mal "$f:$n: $id" ;; esac
    done < <(grep -noE 'B-[0-9]{3}' "$f")
    [ "${#BUSCAR[@]}" -gt 0 ] || continue
    while IFS=: read -r n _; do
        mal "$f:$n: $(sed -n "${n}p" "$f")"
    done < <(llano < "$f" | grep -nF "${BUSCAR[@]}")
done < <(find "$@" -type f -print0)

if [ "$FALLAS" -eq 0 ]; then
    bien "nada público cita lo privado ($ARCHIVOS archivos)"
    exit 0
fi
echo "$FALLAS citas a lo privado"
exit 1
