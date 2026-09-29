# Registro de decisiones

**Qué es:** el único lugar donde se lee qué ya se decidió sobre <Proyecto>.
Una línea por decisión: id, fecha, quién, la decisión en una frase, dónde
aplica y dónde está el porqué. **Lo que está aquí no se re-pregunta.**

**Cómo se lee:**

- **Las nuevas van `DEC-NNN`**, correlativas, y sólo nacen aquí.
- **Qué entra:** lo que decidió o confirmó una persona, o lo que ata fuera
  del sprint: lo que otro sprint, un plan o el cliente podría contradecir sin
  enterarse, como una convención o un contrato entre frentes. Lo demás no
  entra, pero tiene destino: el detalle de código se queda en el archivo del
  sprint, un hecho —un borrado, una reparación, una carga— va a la fila del
  sprint en `CHANGELOG.md` y una lección, a «Reglas del proyecto» de
  `docs/COMANDA.md`.
- **Una decisión que se revierte o se precisa no se borra:** se tacha
  —«Revertida el <fecha> por DEC-NNN» o «Precisada el <fecha> por
  DEC-NNN»— y la nueva se escribe entera, con la regla completa: una fila
  vigente nunca exige leer otra.
- **Quién:** el nombre de quien la tomó —una persona de `docs/COMANDA.md` o el
  cliente—; «agente» es una que el agente tomó para poder avanzar y una
  persona puede corregir.
- **Aplica en:** el archivo, el entregable o el paso donde la decisión está
  escrita o espera a estarlo.
- **Porqué:** dónde está razonada. Una decisión de un sprint (`D1`, `D2`…)
  se cita con su tema —`<tema> D3`, nunca «D3» a secas—: fuera de su archivo,
  la letra sola choca con otras.

| Id | Fecha | Quién | Decisión | Aplica en | Porqué |
|---|---|---|---|---|---|
