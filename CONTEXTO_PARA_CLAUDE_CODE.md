# Contexto del proyecto — TFG UCM Deporte Universitario

## Descripción general

Proyecto de TFG de Ingeniería Informática. El objetivo es construir una base de datos con los resultados históricos de la competición interna universitaria de la UCM (Universidad Complutense de Madrid), extrayendo los datos de las "Memorias de Competición Interna" en PDF y volcándolos a ficheros SQL.

La carpeta raíz del proyecto es: `C:\Users\gabri\Desktop\UNIVERSIDAD\6º\TFG\Cuadernillos\`

Estructura:
```
Cuadernillos/
├── bd.sql                  # Definición del esquema (CREATE TABLE)
├── pdf/                    # PDFs originales fuente de datos
│   ├── MEMORIA_COMPETICION_INTERNA_1990-91.pdf
│   ├── MEMORIA_COMPETICION_INTERNA_1991-92.pdf
│   ├── ... (hasta 1998-99)
│   ├── MEMORIA_COMPETICION_INTERNA_2021-22.pdf
│   ├── MEMORIA_COMPETICION_INTERNA_2022-23.pdf
│   ├── MEMORIA_COMPETICION_INTERNA_2023-24.pdf
│   ├── MEMORIA_COMPETICION_INTERNA_TROFEO_RECTOR_2005-06.pdf
│   ├── ... (hasta 2018-19)
│   └── Convertidos/        # PDFs convertidos a texto (algunos años)
└── sql/                    # Un fichero SQL por año académico
    ├── clasificaciones_1990_91.sql
    ├── clasificaciones_1991_92.sql
    ├── ... (hasta 1998_99)
    ├── clasificaciones_2005_06_NULL.sql
    ├── clasificaciones_2006_07.sql
    ├── ... (hasta 2018_2019)
    ├── clasificaciones_2021_22.sql
    ├── clasificaciones_2022_23.sql
    └── clasificaciones_2023_24.sql   ← RECIÉN CREADO (verificado y correcto)
```

---

## Esquema de la base de datos (bd.sql)

```sql
CREATE TABLE Clasificaciones (
  anio      VARCHAR(9),
  deporte   VARCHAR(30),
  equipo    VARCHAR(30),
  genero    CHAR(1),       -- 'm' o 'f'
  puesto    INT,           -- -1 si descalificado
  puntos    INT,
  categoria INT,           -- 1=primera, 2=segunda; si única -> 1
  asc_desc  INT,           -- 1=ascenso, -1=descenso, 0=permanencia
  alfonso   INT,           -- posición Trofeo Alfonso XIII; -1=no clasifica
  PRIMARY KEY (anio, deporte, equipo, genero, categoria)
);
```

---

## Convenciones de datos (CRÍTICO — leer con atención)

### Nombres de deportes (sin tilde, siempre así):
`BALONCESTO`, `BALONMANO`, `FUTBOL 11`, `FUTBOL 7`, `FUTBOL SALA`, `RUGBY`, `VOLEIBOL`

### Nombres de equipos: sin tildes ni caracteres especiales
- `MATEMATICAS`, `FISICAS`, `QUIMICAS`, `BIOLOGICAS`, `GEOLOGICAS`
- `ESTADISTICA`, `INFORMATICA`, `FILOSOFIA`, `FILOLOGIA`, `PSICOLOGIA`
- `POLITICAS`, `ECONOMICAS`, `GEOGRAFÍA E HISTORIA` → `GEOGRAFIA E HISTORIA`
- `OPTICA Y OPTOMETRIA`, `ODONTOLOGIA`, `VETERINARIA`, `FARMACIA`, `MEDICINA`
- `C. INFORMACION`, `C. JURIDICAS`, `C.U.N.E.F.`, `DOCUMENTACION`
- `COMERCIO Y TURISMO`, `BELLAS ARTES`, `EDUCACION`, `DERECHO`
- `CARDENAL CISNEROS`, `F.E.F.P.`, `ISDE`, `PERSONAL`
- CMUs: `CMU ELIAS AHUJA`, `CMU SAN AGUSTIN`, `CMU MARA`, `CMU ISABEL DE ESPANA`
- `CMU SANTA M DE EUROPA`, `CMU MENDEL`, `CMU CHAMINADE`, `CMU PIO XII`
- `CMU MONCLOA`, `CMU XIMENEZ DE CISNEROS`

### Reglas de los campos:

**puesto:**
- Valor normal: posición final (1, 2, 3...)
- `-1` = descalificado (DQ)
- `NULL` = equipo CMU (Colegio Mayor Universitario)
- En deportes con **Fase Final del Trofeo Rector**: puesto = resultado de la Fase Final (no la liga). Equipos sin Fase Final mantienen su posición de liga a continuación (5º, 6º...).

**puntos:**
- Puntos de liga (temporada regular)
- `NULL` si descalificado O si es CMU
- Los puntos con asterisco en el PDF (ej: `9*`, `-3*`) significan que ya tienen penalización aplicada → usar el valor tal cual

**categoria:**
- `1` = primera categoría (o única si no hay segunda)
- `2` = segunda categoría

**asc_desc:**
- `1` = asciende a primera (solo aplica en equipos de segunda)
- `-1` = desciende/eliminado de primera; también para DQ de primera (quedan fuera de la siguiente edición)
- `0` = permanece igual
- DQ de segunda → `0` (no hay categoría inferior)
- Equipos ya en primera que también tienen equipo en segunda → el de segunda NO puede ascender, `asc_desc=0`
- Deportes de categoría única → todos `0` excepto DQ → `-1`

**alfonso:**
- `1`, `2`, `3`, `4` = posición en el Trofeo Alfonso XIII
- `-1` = no participó / no clasifica
- CMUs: solo tienen valor distinto de `-1` si participaron en Alfonso XIII
- `NULL` implícito en la convención: campo siempre presente, nunca NULL

**CMU teams:**
- `puesto = NULL`
- `puntos = NULL`
- `categoria = 1`
- `asc_desc = 0`
- `alfonso = 1/2/3/4` si participaron en Trofeo Alfonso XIII, `-1` si no

### Formato del fichero SQL:
```sql
-- Datos extraidos de MEMORIA_COMPETICION_INTERNA_YYYY-YY.pdf
-- Liga separada de Colegios Mayores excluida; Colegios Mayores incluidos cuando aparecen en Trofeo Alfonso XIII.
-- En las fases finales del Trofeo Rector, el puesto corresponde a la fase final; los puntos corresponden a la liga/clasificacion previa.
START TRANSACTION;
INSERT INTO Clasificaciones (anio, deporte, equipo, genero, puesto, puntos, categoria, asc_desc, alfonso) VALUES
('YYYY-YY', 'DEPORTE', 'EQUIPO', 'f', 1, 18, 1, 0, 2),
...
('YYYY-YY', 'DEPORTE', 'EQUIPO', 'm', -1, NULL, 1, -1, -1);
COMMIT;
```

### Deportes con múltiples grupos en 2ª categoría:
Los puestos se mantienen **por grupo** (puede haber equipos con puesto=1 en grupos distintos). Esto es coherente con el formato de 2021-22 y 2022-23. El ascenso (`asc_desc=1`) se asigna a los equipos que efectivamente suben (primeros de grupo, o ganadores de Fase Final si la hay).

---

## Estado actual del trabajo

_Última actualización: 2026-08-16._

### 🎉 PROYECTO COMPLETO: 26/26 años revisados y verificados

Los 26 ficheros de `sql/` han sido revisados contra su PDF original y corregidos según la convención de este documento. **Verificación final ejecutada**: los 26 ficheros cargan en SQLite sin errores de sintaxis, sin violaciones de PRIMARY KEY, sin filas de descalificados con `puntos` no-NULL, y sin filas de CMU con `puesto`/`puntos` no-NULL. Total: **7.479 filas** en la tabla `Clasificaciones`.

Filas por año: 1990-91=367, 1991-92=419, 1992-93=469, 1993-94=269, 1994-95=280, 1995-96=276, 1996-97=285, 1997-98=292, 1998-99=295, 2005-06=213, 2006-07=243, 2007-08=239, 2008-09=241, 2009-10=281, 2010-11=281, 2011-12=300, 2012-13=285, 2013-14=316, 2014-15=307, 2015-16=308, 2016-17=301, 2017-18=291, 2018-19=256, 2021-22=213, 2022-23=219, 2023-24=233.

Lo que sigue es el detalle de qué se corrigió en cada año, útil como referencia si en el futuro se encuentra alguna discrepancia y hay que rastrear qué criterio se aplicó.

### Detalle de correcciones por año:
- **1990-91**: revisado a fondo (346→367 filas). Corregido bug sistemático de `asc_desc` en 1ª categoría (el borrador ponía 0 a todos, incluidos DQ; corregido a -1 según la sección VII "Ascensos y Descensos", que también señala varios no-DQ que descienden por quedar últimos). Añadidas 20 filas de CMU del Trofeo Alfonso XIII. Limitación conocida: una matriz de puntuación manuscrita del Alfonso XIII (pág. 56) no se pudo transcribir con fiabilidad; se usaron en su lugar las páginas de clasificación por deporte.
- **1991-92**: revisado a fondo (401→419 filas). `alfonso` reconciliado contra la clasificación final real (no las listas de "clasificados"). 18 filas CMU nuevas añadidas. Se localizó y usó la Sección XII "Ascensos y Descensos" (páginas 115-129): la regla real de ascenso de 2ª es "ascienden los dos primeros de cada grupo, salvo que su facultad ya tenga equipo en 1ª", no "solo el campeón". Corregido también `asc_desc` de DQ en los 8 deportes de Categoría Única (debe ser -1, no 0). Duda abierta sin bloquear: "Pablo Montesinos", "Domingo de Soto", "Maria Diaz Jimenez", "Escuni", "Fomento" podrían ser CMU pero el PDF no los marca explícitamente, se dejaron sin prefijo CMU.
- **1994-95**: revisado a fondo (280 filas). `asc_desc` de ascensos corregido cruzando vacantes reales (nº de DQ en 1ª) con el resultado real de la Liga de Ascenso — el borrador marcaba como ascenso a todos los top-2 de grupo, lo cual era incorrecto. CMUs del Trofeo Alfonso XIII corregidas a puesto/puntos NULL. Dudas documentadas en la cabecera del propio fichero: Rugby m. y Voleibol m. tenían una vacante en 1ª pero no se localizó liga de ascenso para ellos en el PDF; Voleibol f. se marcó ascenso de forma tentativa.
- **2005-06**: revisado a fondo (188→213 filas). Se descubrió que este año SÍ tiene Fase Final real del Trofeo Rector que reordena el `puesto` respecto a la liga (el borrador no la aplicaba). Rescatados casi todos los `puntos` que estaban en NULL por ilegibilidad del escaneado original (de ahí el sufijo `_NULL` del nombre de fichero, que se ha conservado). Añadidos equipos y CMUs que faltaban.
- **2008-09**: revisado a fondo (241 filas, sin casos dudosos). Corregidos: `puntos=NULL` en descalificados (antes 0, ~33 filas), 3 errores puntuales de puntos, 2 de `alfonso`, 9 reordenamientos de `puesto` por Fase Final del Trofeo Rector, `asc_desc=-1` en DQ de deportes de categoría única (Rugby, Voleibol m.).
- **2014-15**: revisado a fondo (307 filas). Corregido bug de puntos de RUGBY masculino (todos estaban a 0), 2 puntos de Voleibol f. 2ª, 5 reordenamientos de `puesto` por Fase Final, formato CMU y nombres de deporte/equipo. `alfonso` ya estaba correcto, no requirió cambios.
- **2015-16**: extraído desde cero (308 filas). **Importante**: el fichero `clasificaciones_2015_2016.sql` estaba corrupto — era una copia accidental byte-idéntica de `clasificaciones_2014_2015.sql` con el año cambiado (bug de copia/pega en algún momento anterior). Reconstruido íntegramente desde su propio PDF. Hallazgos propios de este año: en Baloncesto f. ascendieron los 4 equipos de la liguilla de ascenso (no solo 2) por la norma de mínimo 10 equipos en 1ª; en Futbol Sala f. ascendió el 3º de la liguilla (DOCUMENTACION) porque el 1º (MEDICINA) ya tenía equipo en 1ª. Duda menor: el equipo "I.E.B." no tiene expansión clara en el documento, se mantuvo tal cual.
- **2021-22, 2022-23, 2023-24**: revisados/creados en sesiones anteriores (ver ficheros, son la referencia de formato).
- **1992-93**: revisado a fondo (491 filas). Corregidos ~24 valores de `alfonso` invertidos/erróneos, y el bug estructural de `asc_desc` en 2ª categoría (el borrador ascendía a todos los cabezas de grupo; ahora ascienden solo los equipos reales según la Liga de Ascenso y las vacantes por DQ en 1ª). Añadidas 19 filas CMU nuevas del Trofeo Alfonso XIII.
- **1993-94**: revisado a fondo (269 filas). Puestos/puntos de 1ª y 2ª categoría ya eran correctos en el borrador, sin cambios. Añadidas 12 filas CMU del Trofeo Alfonso XIII que el borrador excluía deliberadamente. Corregidas 8 celdas de `asc_desc` en 2ª categoría (equipos que ascendían en el borrador pero cuya facultad ya tenía equipo en 1ª). Caso dudoso documentado en la cabecera del propio fichero: por qué dos equipos concretos de Futbol Sala m no ascendieron pese a ganar su liga de ascenso, sin bloqueo obvio de "ya en 1ª".
- **2006-07**: revisado a fondo (243 filas). Corregidos: `asc_desc` de varios DQ en 1ª (con una excepción documentada: Balonmano m NO sigue la regla general porque ese deporte no tiene 2ª categoría y los DQ se reincorporan al año siguiente), `alfonso` de Baloncesto/Voleibol f., reordenamientos de `puesto` por Fase Final en 7 deportes, un punto mal transcrito (-2 en vez de 2), y 2 filas CMU nuevas. Caso dudoso: Voleibol m 2ª categoría (BELLAS ARTES, BIOLOGICAS) no tiene página de clasificación localizable en el PDF; se mantiene `asc_desc=1` para ambos (confirmado por la sección de Ascensos/Descensos) pero `puesto`/`puntos` quedan sin poder verificarse visualmente.
- **2009-10**: revisado a fondo (281 filas). Corregidos: `puntos=NULL` en 32 filas DQ (antes 0), `asc_desc=-1` en 3 DQ de deportes de categoría única, 22 reordenamientos de `puesto` por Fase Final. `alfonso` ya estaba correcto. Sin verificar exhaustivamente línea a línea: puestos/puntos de liga de las secciones 1-3 y 6 (se confió en el borrador original para esa parte).
- **1995-96**: revisado a fondo (276 filas). Corregidos "RONCALLI"→"RONCALI", `alfonso` de Voleibol m, y `asc_desc` en los 4 deportes de 2ª con Liga de Ascenso real más los 3 deportes de grupo único donde el campeón asciende automáticamente (Rugby m, Voleibol m, Futbol Sala f). Cabecera y formato (`START TRANSACTION;`/`COMMIT;`) normalizados.
- **2007-08**: revisado a fondo (239 filas: 237+2 DQ nuevas). Aplicados 7 reordenamientos de `puesto` por Fase Final, 1 corrección de `asc_desc` (Futbol/ECONOMICAS/m confirmado como ascendido), y 2 filas DQ que faltaban por completo (Baloncesto m 2ª grupo C). `alfonso` y `puntos` ya estaban correctos.
- **1996-97**: revisado a fondo (285 filas). Corregidos: BALONMANO m QUIMICAS puntos 6→4, "RONCALLI"→"RONCALI", 2 filas DQ añadidas, y el bug estructural completo de `asc_desc` en los 8 deportes con 2ª categoría (asciende quien gana la Liga de Ascenso real entre campeones de grupo, nunca un equipo cuya facultad ya está en 1ª) más 9 casos de equipos NO descalificados que descienden por quedar últimos en 1ª (antes en 0, corregidos a -1). Sin casos dudosos.
- **1997-98**: revisado a fondo (292 filas). El borrador ya era muy preciso; única corrección: añadida 1 fila CMU (CMU XIMENEZ DE CISNEROS) que faltaba en el Trofeo Alfonso XIII de Rugby m. Formato normalizado. Sin casos dudosos.
- **1998-99**: revisado a fondo (295 filas). El borrador ya tenía correctos casi todos los valores; única corrección: 9 filas CMU del Trofeo Alfonso XIII tenían puesto/puntos del propio mini-torneo en vez de NULL/NULL, corregidas. Sin casos dudosos.
- **2010-11**: revisado a fondo (281 filas). Corregidos: `puntos=NULL` en 33 DQ (antes 0), 18 filas CMU con puesto/puntos numéricos corregidas a NULL/NULL, 6 reordenamientos de `puesto` por Fase Final, `asc_desc=-1` en DQ de Rugby m y Voleibol m (categoría única). Caso documentado no bloqueante: una página de "clasificados a liga de ascenso" de Voleibol f. parece un error de imprenta del propio PDF (reutiliza una lista de otro deporte), no afectó al resultado porque la sección de Ascensos/Descensos lo confirmó por otra vía.
- **2011-12**: revisado a fondo (300 filas). Corregidos: `puntos=NULL` en 42 DQ, 7 errores puntuales de puntos (signo/valor mal transcrito), 22 reordenamientos de `puesto` por Fase Final, 7 correcciones de `asc_desc`, 18 filas CMU corregidas a NULL/NULL. **Limitaciones documentadas en la cabecera del propio fichero** (páginas faltantes en el escaneado original, no se inventó ningún valor): falta 1 DQ de Rugby m 1ª, 2 DQ de Baloncesto f 1ª, pequeño desajuste en Voleibol f 2ª, y la página de Ascensos/Descensos específica de Voleibol f 1ª no está en el PDF (se aplicó la regla general en su lugar).
- **2012-13** (`clasificaciones_2012_2013_corregido.sql`): revisado a fondo (285 filas). Corregidos: `puntos=NULL` en ~40 DQ, 18 filas CMU a NULL/NULL con nombres normalizados, 7 deportes con reordenamiento de `puesto` por Fase Final, grupo C completo de Baloncesto 2ª masculino añadido (8 filas que faltaban por completo), `asc_desc` corregido en varios DQ de categoría única y en las 4 DQ de Baloncesto 1ª femenino. Caso documentado no bloqueante: una lista de "clasificados a liga de ascenso" de Futbol Sala 2ª masculino no coincide con los equipos reales de esa clasificación (parece error de imprenta del PDF), no afectó al resultado.
- **2013-14**: revisado a fondo (316 filas, sin añadir/quitar equipos). Corregidos: `puntos=NULL` en 40 DQ, 18 CMU a NULL/NULL, nombres normalizados (incluye `FUTBOL`→`FUTBOL 11`, `FUTBOL SIETE`→`FUTBOL 7`), 17 reordenamientos de `puesto` por Fase Final (4 deportes sin fase final real ese año, sin tocar), 6 DQ de categoría única corregidos a -1. Resto de `asc_desc` ya era correcto, verificado exhaustivamente. Anomalía documentada no bloqueante: el PDF menciona un descenso de "FILOSOFIA" en Baloncesto femenino que no tiene fila en el dataset de ese deporte — posible error de plantilla del propio documento, no se creó fila fantasma.
- **1995-96**: revisado a fondo (276 filas). Corregidos "RONCALLI"→"RONCALI", `alfonso` de Voleibol m, y `asc_desc` en los 4 deportes de 2ª con Liga de Ascenso real más los 3 deportes de grupo único donde el campeón asciende automáticamente (Rugby m, Voleibol m, Futbol Sala f). Cabecera y formato (`START TRANSACTION;`/`COMMIT;`) normalizados.
- **2007-08**: revisado a fondo (239 filas: 237+2 DQ nuevas). Aplicados 7 reordenamientos de `puesto` por Fase Final, 1 corrección de `asc_desc` (Futbol/ECONOMICAS/m confirmado como ascendido), y 2 filas DQ que faltaban por completo (Baloncesto m 2ª grupo C). `alfonso` y `puntos` ya estaban correctos.
- **1996-97**: revisado a fondo (285 filas). Corregidos: BALONMANO m QUIMICAS puntos 6→4, "RONCALLI"→"RONCALI", 2 filas DQ añadidas, y el bug estructural completo de `asc_desc` en los 8 deportes con 2ª categoría (asciende quien gana la Liga de Ascenso real entre campeones de grupo, nunca un equipo cuya facultad ya está en 1ª) más 9 casos de equipos NO descalificados que descienden por quedar últimos en 1ª (antes en 0, corregidos a -1). Sin casos dudosos.
- **1997-98**: revisado a fondo (292 filas). El borrador ya era muy preciso; única corrección: añadida 1 fila CMU (CMU XIMENEZ DE CISNEROS) que faltaba en el Trofeo Alfonso XIII de Rugby m. Formato normalizado. Sin casos dudosos.
- **1998-99**: revisado a fondo (295 filas). El borrador ya tenía correctos casi todos los valores; única corrección: 9 filas CMU del Trofeo Alfonso XIII tenían puesto/puntos del propio mini-torneo en vez de NULL/NULL, corregidas. Sin casos dudosos.
- **2010-11**: revisado a fondo (281 filas). Corregidos: `puntos=NULL` en 33 DQ (antes 0), 18 filas CMU con puesto/puntos numéricos corregidas a NULL/NULL, 6 reordenamientos de `puesto` por Fase Final, `asc_desc=-1` en DQ de Rugby m y Voleibol m (categoría única). Caso documentado no bloqueante: una página de "clasificados a liga de ascenso" de Voleibol f. parece un error de imprenta del propio PDF (reutiliza una lista de otro deporte), no afectó al resultado porque la sección de Ascensos/Descensos lo confirmó por otra vía.
- **2016-17**: revisado a fondo (301 filas, sin añadir/quitar equipos). Corregidos: `puntos=NULL` en 45 DQ, 18 CMU a NULL/NULL, 3 puntos mal transcritos, 7 deportes con reordenamiento de `puesto` por Fase Final, 11 DQ de categoría única corregidos a -1. Verificado (sin cambio, ya correcto) un caso complejo de ascensos en Baloncesto f y Futbol Sala f donde el ganador de la liga de ascenso no asciende por ya tener equipo en 1ª. Duda documentada no bloqueante: el orden impreso del Alfonso XIII de Futbol Sala m no es estrictamente descendente por puntos, se conservó el orden del PDF sin poder verificar el criterio de desempate.
- **2017-18**: revisado a fondo (289→291 filas). Corregidos: `puntos=NULL` en ~60 DQ, 18 CMU a NULL/NULL con nombres normalizados, nombres de deporte (`FUTBOL`→`FUTBOL 11`, `FUTBOL SIETE`→`FUTBOL 7`), 7 DQ de categoría única a -1, 8 deportes con reordenamiento de `puesto` por Fase Final, 2 filas DQ añadidas que faltaban, 1 error de transcripción de puntos corregido. Sin páginas ilegibles, sin dudas sin resolver.
- **2018-19**: revisado a fondo (256 filas). Corregidos: `puntos=NULL` en 40 DQ, 18 CMU a NULL/NULL, reordenamiento de `puesto` por Fase Final en 7 deportes, 4 DQ de categoría única a -1, corrección de nombre "RONCALLI"→"RONCALI". `alfonso` y el resto de `asc_desc` ya eran correctos, verificados exhaustivamente contra la sección 11 completa. Sin dudas pendientes.

---

## Tarea de verificación rápida (referencia, ya ejecutada con éxito el 2026-08-16)

Script usado para la verificación final global — útil como referencia si se vuelve a tocar algún fichero en el futuro:

```python
import sqlite3, os, glob

conn = sqlite3.connect(':memory:')
conn.execute('''CREATE TABLE Clasificaciones (
  anio TEXT, deporte TEXT, equipo TEXT, genero TEXT,
  puesto INT, puntos INT, categoria INT, asc_desc INT, alfonso INT,
  PRIMARY KEY (anio, deporte, equipo, genero, categoria)
)''')

sql_dir = r'C:\Users\gabri\Desktop\UNIVERSIDAD\6º\TFG\Cuadernillos\sql'
errors = []
for f in sorted(glob.glob(os.path.join(sql_dir, '*.sql'))):
    content = open(f, encoding='utf-8').read()
    # Strip MySQL-specific syntax not supported by SQLite
    content = content.replace('START TRANSACTION;', 'BEGIN;')
    # Remove ON DUPLICATE KEY UPDATE if present
    import re
    content = re.sub(r'ON DUPLICATE KEY UPDATE.*?;', ';', content, flags=re.DOTALL)
    try:
        conn.executescript(content)
        print(f'OK: {os.path.basename(f)}')
    except Exception as e:
        errors.append((os.path.basename(f), str(e)))
        print(f'ERROR: {os.path.basename(f)} -> {e}')

print(f'\n{len(errors)} errores encontrados')
conn.close()
```

---

## Metodología de revisión de un fichero SQL existente

Para cada año pendiente:
1. Abrir el PDF correspondiente en `pdf/`
2. Comparar el SQL existente con los datos del PDF página a página
3. Verificar: nombres de equipos (sin tildes), puntos exactos, puestos, asc_desc, alfonso
4. Casos especiales a vigilar:
   - Puntos con asterisco → ya incluyen penalización, usar valor mostrado
   - Equipos descalificados → `puesto=-1, puntos=NULL`
   - Diferencia liga vs Fase Final → `puesto` = resultado Fase Final, `puntos` = liga
   - CMUs → `puesto=NULL, puntos=NULL, asc_desc=0`
   - Equipos que están tanto en 1ª como en 2ª → dos filas con `categoria=1` y `categoria=2`

---

## Nota sobre los PDFs de años 90 y Trofeo Rector

Los PDFs de 1990-91 a 1998-99 son escaneados (imagen), no texto nativo.

**Corrección importante (confirmada 2026-08-15)**: los PDFs de 2005-06 a 2018-19 ("Trofeo Rector") **también son imágenes escaneadas sin ninguna capa de texto**, no texto nativo extraíble como se pensaba antes. Verificado con PyMuPDF (`fitz`) extrayendo 0 caracteres de texto en todos los años probados (2005-06, 2006-07, 2007-08, 2008-09, 2015-16, 2017-18, 2018-19). No pierdas tiempo con `pypdf`/`pdfplumber` en estos PDFs.

**Problema técnico de renderizado en este entorno**: la herramienta Read normalmente convierte páginas de PDF a imagen usando `pdftoppm` (poppler), pero **`pdftoppm` no está instalado en esta máquina** — Read fallará con "pdftoppm is not installed" en cualquier PDF. Solución: renderizar las páginas manualmente a PNG con PyMuPDF (paquete `pymupdf`, instalado globalmente vía pip, se importa como `fitz`) y luego usar Read sobre los PNG resultantes:

```python
import fitz
doc = fitz.open(r"pdf/NOMBRE_DEL_PDF.pdf")
zoom = 2.0
mat = fitz.Matrix(zoom, zoom)
for i in range(START-1, END):  # 0-indexed
    pix = doc[i].get_pixmap(matrix=mat)
    pix.save(f"OUT_DIR/page_{i+1:03d}.png")
```

## Estructura de las memorias (para localizar las secciones relevantes)

**Años 90 (1990-91 a 1998-99)**: numeración en números romanos. Buscar el índice (normalmente página 2) para: II = Clasificaciones finales 1ª/2ª categoría y C.C. Mayores; III = Clasificación final Trofeo Alfonso XIII; V = Equipos inscritos y descalificados; **VII = Ascensos y Descensos, fuente autoritativa de la columna `asc_desc`** (un DQ de 1ª categoría lleva asc_desc=-1, nunca 0; también puede haber equipos NO descalificados que descienden por quedar últimos, esta sección lo dice explícitamente). La numeración/nombre exacto de cada sección puede variar ligeramente de un año a otro (a veces romanos, a veces arábigos tipo "2.1"–"2.10"), verificar siempre en el índice de cada PDF concreto.

**Trofeo Rector (2005-06 a 2018-19)**: numeración arábiga 1-11. 2 = Clasificaciones finales 1ª categoría; 3 = Clasificaciones finales 2ª categoría; 4 = Trofeo Alfonso XIII; 5 = Trofeo Rector/Fase Final (ver regla de `puesto` más abajo); 6 = Ligas de Ascenso; **11 = Ascensos y Descensos, fuente autoritativa de `asc_desc`**.

**Regla de la Fase Final del Trofeo Rector** (sección 5, solo aplica a esta etapa): la columna `puesto` refleja el resultado de la fase final para los equipos que llegaron a ella (no la posición de liga); los equipos que no llegaron mantienen su posición de liga a continuación. La columna `puntos` SIEMPRE es la de liga (temporada regular), nunca cambia por el resultado de la fase final.

**Bug recurrente detectado en la etapa Trofeo Rector**: es muy común que los ficheros SQL de borrador tengan `puntos=0` en vez de `puntos=NULL` para los equipos descalificados. Confirmarlo y corregirlo en cada año de esta etapa que se revise (ya corregido en 2008-09 y 2014-15).

---

## Fichero de referencia para convenciones

El fichero `clasificaciones_2022_23.sql` es el más fiable como referencia de formato y nombres. El `clasificaciones_2023_24.sql` (recién creado) también es correcto y más completo (tiene más deportes con 2ª categoría).

---

## Resumen para empezar rápido

```
Proyecto: base de datos competición interna UCM
Carpeta:  C:\Users\gabri\Desktop\UNIVERSIDAD\6º\TFG\Cuadernillos\
PDFs:     pdf/ (fuente de verdad)
SQLs:     sql/ (uno por año, ya existen borradores para todos)

PROYECTO COMPLETO: 26/26 años revisados, corregidos y verificados (2026-08-16).
Verificación final con SQLite: OK, 0 errores, 7.479 filas totales en Clasificaciones.

Si en el futuro se detecta alguna discrepancia en algún año, consulta el
"Detalle de correcciones por año" más arriba en este documento antes de
volver a analizar el PDF desde cero — puede que el criterio ya esté documentado.

Referencia de formato: sql/clasificaciones_2022_23.sql
```
