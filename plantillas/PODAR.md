# Podar un registro de decisiones que ya existe

Un registro que creció con detalles de código, hechos y cadenas de
«precisa» se lee entero en cada `triage` y cada `abrir`. Esta receta lo
adelgaza sin perder nada: lo que no pasa el filtro de «Qué entra» se muda a
un archivo aparte, con su id y su texto, y sigue decidido. La corre el
agente con una persona delante: el agente propone y la persona aprueba
**antes de mover una sola fila**.

1. **Dónde se hace.** En la rama de un sprint que la lleve como tarea.
   Como el registro no se toca en la rama del sprint, ahí quedan la lista
   aprobada, el archivo de podadas y el texto del párrafo del paso 7; el
   registro lo edita quien cierre, en la principal, con esa lista. Anótalo
   en «Lo que te toca a ti». Sin sprint, todo va en la rama de lo de un
   commit, y se funde como ella.
2. **Medir antes.** Cuenta las filas de `docs/DECISIONES.md` y arma en el
   archivo del sprint una tabla, una fila por decisión: id, quién, propuesta
   (`queda` o `muda`), motivo y una nota. Compara con `diff` los ids y el
   «Quién» de tu tabla contra los del registro: una fila que falta o está mal
   copiada es una decisión que se pierde.
3. **El filtro, en este orden**; la primera regla que aplica, manda:
   1. **Tachada** —revertida, sustituida o precisada— → **se muda**,
      aunque sea de una persona: la que la sustituye se lee sola, y en el
      registro no aporta nada.
   2. **De una persona** → **se queda**. Si parece un hecho o un detalle,
      señálalo en la nota: lo decide la persona, no el filtro.
   3. **Del agente, pero una persona la confirmó por escrito** (lo dice su
      porqué) → se queda, como si fuera de persona. Señálala también.
   4. **Del agente, y ata fuera del sprint** → **se queda**. Ata afuera cuando
      es un formato, una ruta o un contrato entre comandos, o entre la
      herramienta y los proyectos, que otro sprint podría contradecir sin
      ver el código que lo cumple.
   5. **Del agente, y no ata** → **se muda**, con uno de estos motivos:
      *detalle* (cómo quedó un paso, un guion o una prueba; lo dice un solo
      archivo, que sigue ahí), *hecho* (algo que se hizo una vez) o
      *lección* (una corrección que se repitió). Si la lección no está ya en
      «Reglas del proyecto» de `docs/COMANDA.md`, propón el renglón, como en
      `cerrar`.
4. **Las cadenas de «precisa» que no se tacharon.** Busca las filas
   vigentes que ajustan, precisan, confirman o sustituyen a otra vigente: su
   texto la nombra (`grep -n 'DEC-' docs/DECISIONES.md` y leer el porqué).
   Una cadena se funde en su **última fila**, reescrita entera con la regla
   completa, y las anteriores se mudan con el motivo «fundida en DEC-NNN».
   Reescribir es cambiar la redacción, no la regla: si fundir obliga a
   decidir algo, es una pregunta para la persona. Si la primera ya trae el
   texto de las demás, propón que se quede ésa; lo decide la persona. Si
   una fila del medio es de una persona y la última no, dilo.
5. **Enséñale a la persona, antes de mover nada**:
   - los números: cuántas se quedan (de persona, del agente que ata,
     confirmadas) y cuántas se mudan (detalle, hecho, lección, tachada,
     fundida), cuántas cadenas hay y cuánto baja el registro;
   - **lo que el filtro no decide solo**, en una lista numerada: las de
     persona que parecen hecho o detalle, las confirmadas en el porqué, las
     cadenas donde propones algo distinto de fundir en la última;
   - la tabla fila por fila del paso 2.

   Pregúntale con AskUserQuestion si va así. Lo que corrija, manda. Aprobar
   la lista no confirma las decisiones del agente: una del agente se queda
   sólo si ata afuera o si la persona dice que la hace suya. Anota en el
   archivo del sprint la lista aprobada, con quién la aprobó y cuándo.
6. **Mudar.** Crea `docs/archivo/DECISIONES_podadas_<fecha>.md`, con la
   fecha de la poda:

   ```markdown
   # Decisiones podadas el <fecha>

   Filas que salieron de `docs/DECISIONES.md` en la poda del <fecha>
   (sprint `<tema>`). **Siguen decididas y no se re-preguntan**: salieron
   porque no hace falta leerlas en cada sesión, no porque dejaran de valer.
   Un id que no está en el registro se busca aquí.

   | Id | Fecha | Quién | Decisión | Aplica en | Porqué | Se mudó por |
   |---|---|---|---|---|---|---|
   ```

   Cada fila va con su id y su texto tal cual, más el motivo: `tachada`,
   `detalle`, `hecho`, `lección` o `fundida en DEC-NNN`. **No se borra ni se
   reusa ningún id.** Si ya hay un archivo de podadas de otra fecha, éste es
   otro; no se funden.
7. **El párrafo en el registro**, justo encima de la tabla, en lugar de las
   filas mudadas:

   ```markdown
   **Podadas el <fecha>:** N filas entre DEC-NNN y DEC-MMM se mudaron a
   [`docs/archivo/DECISIONES_podadas_<fecha>.md`](archivo/DECISIONES_podadas_<fecha>.md);
   un id que no esté en la tabla se busca ahí.
   ```

   DEC-NNN y DEC-MMM son el id más bajo y el más alto de lo mudado. Así el
   id más alto que se haya usado sigue escrito en el registro, y el
   siguiente `DEC-NNN` no repite uno podado. En una segunda poda se agrega
   otro párrafo; el de antes no se toca. Las filas fundidas se reescriben
   en su lugar.
8. **Medir después**: filas antes y después, y que cada id de la tabla del
   paso 2 esté en el registro o en el archivo de podadas, en uno solo
   (`grep -c`). Anótalo en el archivo del sprint.
