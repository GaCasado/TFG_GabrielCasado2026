-- Datos extraidos de MEMORIA_COMPETICION_INTERNA_1990-91.pdf
-- Revisado y corregido comparando fila a fila con el PDF (Secciones II, III, V y VII).
-- Criterios aplicados:
-- 1) anio = '1990-91'. Deportes y equipos en MAYUSCULAS sin tildes.
-- 2) categoria = 1 (1a Categoria / unica) o 2 (2a Categoria).
-- 3) puesto = -1 si descalificado (DQ); NULL si es un equipo de Colegio Mayor (CMU).
-- 4) puntos = NULL si DQ o CMU. Los puntos con asterisco/negativos del PDF se usan tal cual (ya incluyen penalizacion).
-- 5) En deportes con grupos + Liga de Ascenso (2a categoria): puesto/puntos de los equipos
--    clasificados a la Liga de Ascenso son los de esa liguilla final; el resto de equipos
--    mantienen su puesto/puntos del grupo de origen.
-- 6) asc_desc (fuente: Seccion VII "ASCENSOS Y DESCENSOS"):
--    - 1a categoria: -1 para TODOS los equipos descalificados de 1a, Y TAMBIEN para los
--      equipos NO descalificados que la Seccion VII lista explicitamente como
--      "Clasificado(s) en ultimo(s) lugar(es)" (descienden a 2a aunque no esten DQ).
--      El resto de equipos de 1a mantiene asc_desc = 0.
--    - 2a categoria: 1 = asciende a 1a (segun Seccion VII / "ASCIENDEN A 1a CATEGORIA");
--      0 = permanece o descalificado en 2a (no hay categoria inferior); un equipo de 2a
--      que ya tiene equipo propio en 1a no puede ascender (asc_desc=0) aunque haya
--      quedado primero, segun notas explicitas del PDF (ej. Balonmano m. Economicas,
--      Futbol Sala m. San Pablo CEU, Tenis m. Geografia e Historia).
-- 7) alfonso = posicion en el "PLAY-OFF FINAL - TROFEO ALFONSO XIII" de cada deporte/genero
--    (Seccion II, listado tras cada clasificacion final); -1 si no participa/no clasifica.
--    Los Colegios Mayores (CMU) que alcanzaron el Play-off/Fase Final de su propio deporte
--    (Seccion III) se han anadido como filas nuevas: puesto=NULL, puntos=NULL, categoria=1,
--    asc_desc=0, alfonso=posicion. Solo se cargaron los CMU con datos claramente legibles
--    en el PDF (10 deportes masculinos); el cuadro-resumen global del Trofeo Alfonso XIII
--    (pag. 56) no se transcribio celda a celda por su baja legibilidad (ver aviso final).
-- 8) No se ha cargado la liga interna separada de Colegios Mayores (Seccion II.c), salvo
--    para detectar su participacion en el Trofeo Alfonso XIII (punto 7).

START TRANSACTION;

INSERT INTO Clasificaciones
  (anio, deporte, equipo, genero, puesto, puntos, categoria, asc_desc, alfonso)
VALUES
  -- ===================== 1a CATEGORIA =====================
  -- AJEDREZ (m)
  ('1990-91', 'AJEDREZ', 'DERECHO', 'm', 1, 3, 1, 0, 1),
  ('1990-91', 'AJEDREZ', 'FILOLOGIA', 'm', 2, 1, 1, 0, 2),
  ('1990-91', 'AJEDREZ', 'ECONOMICAS', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'AJEDREZ', 'MATEMATICAS', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'AJEDREZ', 'C.C. EDUCACION', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'AJEDREZ', 'QUIMICAS', 'm', -1, NULL, 1, -1, -1),

  -- BALONCESTO (m)
  ('1990-91', 'BALONCESTO', 'CARDENAL CISNEROS', 'm', 1, 18, 1, 0, 1),
  ('1990-91', 'BALONCESTO', 'SAN PABLO CEU', 'm', 2, 14, 1, 0, 2),
  ('1990-91', 'BALONCESTO', 'MATEMATICAS', 'm', 3, 12, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'FISICAS', 'm', 4, 10, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.C. INFORMACION', 'm', 5, 10, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'GEOLOGICAS', 'm', 6, 8, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'GEOGRAFIA E HISTORIA', 'm', 7, 8, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'QUIMICAS', 'm', 8, 4, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'POLITICAS', 'm', 9, 2, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'OPTICA Y OPTOMETRIA', 'm', 10, 2, 1, -1, -1),
  ('1990-91', 'BALONCESTO', 'DERECHO', 'm', -1, NULL, 1, -1, -1),

  -- BALONCESTO (f)
  ('1990-91', 'BALONCESTO', 'C.C. INFORMACION', 'f', 1, 16, 1, 0, 1),
  ('1990-91', 'BALONCESTO', 'ECONOMICAS', 'f', 2, 14, 1, 0, 2),
  ('1990-91', 'BALONCESTO', 'SAN PABLO CEU', 'f', 3, 14, 1, 0, 3),
  ('1990-91', 'BALONCESTO', 'GEOLOGICAS', 'f', 4, 10, 1, 0, 4),
  ('1990-91', 'BALONCESTO', 'C.C. EDUCACION', 'f', 5, 8, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'MATEMATICAS', 'f', 6, 6, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'GEOGRAFIA E HISTORIA', 'f', 7, 6, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'VETERINARIA', 'f', 8, 6, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'DERECHO', 'f', 9, 2, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'FILOLOGIA', 'f', 10, 0, 1, 0, -1),
  ('1990-91', 'BALONCESTO', 'POLITICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'BALONCESTO', 'CARDENAL CISNEROS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'BALONCESTO', 'BELLAS ARTES', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'BALONCESTO', 'FISICAS', 'f', -1, NULL, 1, -1, -1),

  -- BALONMANO (m)
  ('1990-91', 'BALONMANO', 'SAN PABLO CEU', 'm', 1, 19, 1, 0, 1),
  ('1990-91', 'BALONMANO', 'ECONOMICAS', 'm', 2, 19, 1, 0, 2),
  ('1990-91', 'BALONMANO', 'MATEMATICAS', 'm', 3, 15, 1, 0, -1),
  ('1990-91', 'BALONMANO', 'FISICAS', 'm', 4, 14, 1, 0, -1),
  ('1990-91', 'BALONMANO', 'DERECHO', 'm', 5, 10, 1, 0, -1),
  ('1990-91', 'BALONMANO', 'C.C. INFORMACION', 'm', 6, 2, 1, 0, -1),
  ('1990-91', 'BALONMANO', 'FARMACIA', 'm', 7, 0, 1, -1, -1),
  ('1990-91', 'BALONMANO', 'POLITICAS', 'm', -1, NULL, 1, -1, -1),

  -- BALONMANO (f)
  ('1990-91', 'BALONMANO', 'ECONOMICAS', 'f', 1, 8, 1, 0, 1),
  ('1990-91', 'BALONMANO', 'C.C. INFORMACION', 'f', 2, 2, 1, 0, 2),
  ('1990-91', 'BALONMANO', 'FISICAS', 'f', 3, 0, 1, 0, 3),
  ('1990-91', 'BALONMANO', 'DERECHO', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'BALONMANO', 'C.M. MIGUEL ANTONIO CARO', 'f', -1, NULL, 1, -1, -1),

  -- FRONTENIS (m) -- puesto = resultado 2a Fase (finalistas) o puesto de grupo (resto)
  ('1990-91', 'FRONTENIS', 'PERSONAL', 'm', 1, 6, 1, 0, 1),
  ('1990-91', 'FRONTENIS', 'FISICAS', 'm', 2, 4, 1, 0, 2),
  ('1990-91', 'FRONTENIS', 'BIOLOGICAS', 'm', 3, 2, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'ESTADISTICA', 'm', 4, 0, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'VETERINARIA', 'm', 3, 4, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'MATEMATICAS', 'm', 4, 2, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'C.C. INFORMACION', 'm', 5, -2, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'C.C. EDUCACION', 'm', 3, 2, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'PSICOLOGIA', 'm', 4, 2, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'GEOGRAFIA E HISTORIA', 'm', 5, 0, 1, 0, -1),
  ('1990-91', 'FRONTENIS', 'OPTICA Y OPTOMETRIA', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'FRONTENIS', 'DERECHO', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'FRONTENIS', 'QUIMICAS', 'm', -1, NULL, 1, -1, -1),

  -- FUTBOL 11 (m)
  ('1990-91', 'FUTBOL 11', 'VETERINARIA', 'm', 1, 22, 1, 0, 1),
  ('1990-91', 'FUTBOL 11', 'ECONOMICAS', 'm', 2, 21, 1, 0, 2),
  ('1990-91', 'FUTBOL 11', 'DERECHO', 'm', 3, 20, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'MATEMATICAS', 'm', 4, 20, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'SAN PABLO CEU', 'm', 5, 18, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'FILOLOGIA', 'm', 6, 14, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'GEOGRAFIA E HISTORIA', 'm', 7, 13, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'C.C. EDUCACION', 'm', 8, 10, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'PERSONAL', 'm', 9, 10, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'C.C. INFORMACION', 'm', 10, 8, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'GEOLOGICAS', 'm', 11, 7, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'MEDICINA', 'm', 12, 7, 1, 0, -1),
  ('1990-91', 'FUTBOL 11', 'QUIMICAS', 'm', 13, 6, 1, -1, -1),
  ('1990-91', 'FUTBOL 11', 'UNIVERSIDAD SAN LUIS', 'm', 14, 2, 1, -1, -1),

  -- FUTBOL SALA (m)
  ('1990-91', 'FUTBOL SALA', 'GEOGRAFIA E HISTORIA', 'm', 1, 16, 1, 0, 1),
  ('1990-91', 'FUTBOL SALA', 'FISICAS', 'm', 2, 15, 1, 0, 2),
  ('1990-91', 'FUTBOL SALA', 'SAN PABLO CEU', 'm', 3, 12, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'FILOLOGIA', 'm', 4, 9, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'VETERINARIA', 'm', 5, 8, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'DERECHO', 'm', 6, 7, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'PSICOLOGIA', 'm', 7, 5, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'QUIMICAS', 'm', 8, 5, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'GEOLOGICAS', 'm', 9, 3, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'MATEMATICAS', 'm', 10, 2, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'POLITICAS', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'FUTBOL SALA', 'FARMACIA', 'm', -1, NULL, 1, -1, -1),

  -- FUTBOL SALA (f)
  ('1990-91', 'FUTBOL SALA', 'ECONOMICAS', 'f', 1, 20, 1, 0, 1),
  ('1990-91', 'FUTBOL SALA', 'DERECHO', 'f', 2, 17, 1, 0, 2),
  ('1990-91', 'FUTBOL SALA', 'C.C. INFORMACION', 'f', 3, 16, 1, 0, 3),
  ('1990-91', 'FUTBOL SALA', 'FISICAS', 'f', 4, 10, 1, 0, 4),
  ('1990-91', 'FUTBOL SALA', 'GEOGRAFIA E HISTORIA', 'f', 5, 10, 1, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'FILOLOGIA', 'f', 6, 7, 1, -1, -1),
  ('1990-91', 'FUTBOL SALA', 'MATEMATICAS', 'f', 7, 0, 1, -1, -1),

  -- RUGBY (m)
  ('1990-91', 'RUGBY', 'VETERINARIA', 'm', 1, 21, 1, 0, 1),
  ('1990-91', 'RUGBY', 'GEOLOGICAS', 'm', 2, 18, 1, 0, 2),
  ('1990-91', 'RUGBY', 'FISICAS', 'm', 3, 18, 1, 0, -1),
  ('1990-91', 'RUGBY', 'MATEMATICAS', 'm', 4, 14, 1, 0, -1),
  ('1990-91', 'RUGBY', 'QUIMICAS', 'm', 5, 12, 1, 0, -1),
  ('1990-91', 'RUGBY', 'ECONOMICAS', 'm', 6, 11, 1, 0, -1),
  ('1990-91', 'RUGBY', 'DERECHO', 'm', 7, 10, 1, 0, -1),
  ('1990-91', 'RUGBY', 'SAN PABLO CEU', 'm', 8, 10, 1, 0, -1),
  ('1990-91', 'RUGBY', 'C.C. INFORMACION', 'm', 9, 7, 1, 0, -1),
  ('1990-91', 'RUGBY', 'GEOGRAFIA E HISTORIA', 'm', 10, 7, 1, 0, -1),
  ('1990-91', 'RUGBY', 'POLITICAS', 'm', 11, 0, 1, 0, -1),
  ('1990-91', 'RUGBY', 'FARMACIA', 'm', 12, -2, 1, 0, -1),
  ('1990-91', 'RUGBY', 'OPTICA Y OPTOMETRIA', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'RUGBY', 'ODONTOLOGIA', 'm', -1, NULL, 1, -1, -1),

  -- TENIS (m)
  ('1990-91', 'TENIS', 'SAN PABLO CEU', 'm', 1, 12, 1, 0, 1),
  ('1990-91', 'TENIS', 'ECONOMICAS', 'm', 2, 6, 1, 0, 2),
  ('1990-91', 'TENIS', 'C.C. INFORMACION', 'm', 3, 6, 1, 0, -1),
  ('1990-91', 'TENIS', 'GEOGRAFIA E HISTORIA', 'm', 4, 4, 1, 0, -1),
  ('1990-91', 'TENIS', 'C.C. EDUCACION', 'm', 5, 3, 1, 0, -1),
  ('1990-91', 'TENIS', 'GEOLOGICAS', 'm', 5, 3, 1, 0, -1),
  ('1990-91', 'TENIS', 'PERSONAL', 'm', 6, 0, 1, 0, -1),
  ('1990-91', 'TENIS', 'FISICAS', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'DERECHO', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'ODONTOLOGIA', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'MATEMATICAS', 'm', -1, NULL, 1, -1, -1),

  -- TENIS (f) -- Grupo A y Grupo B, cada uno con su Play-off Alfonso XIII propio
  ('1990-91', 'TENIS', 'SAN PABLO CEU', 'f', 1, 4, 1, 0, 1),
  ('1990-91', 'TENIS', 'C.M. NUESTRA SRA. DE AFRICA', 'f', 2, 4, 1, 0, 2),
  ('1990-91', 'TENIS', 'CARDENAL CISNEROS', 'f', 3, 2, 1, 0, -1),
  ('1990-91', 'TENIS', 'DERECHO', 'f', 4, -2, 1, 0, -1),
  ('1990-91', 'TENIS', 'GEOGRAFIA E HISTORIA', 'f', 1, 6, 1, 0, 1),
  ('1990-91', 'TENIS', 'MARIA DIAZ JIMENEZ', 'f', 2, 4, 1, 0, 2),
  ('1990-91', 'TENIS', 'FILOLOGIA', 'f', 3, 2, 1, 0, -1),
  ('1990-91', 'TENIS', 'FARMACIA', 'f', 4, -2, 1, 0, -1),
  ('1990-91', 'TENIS', 'C.C. INFORMACION', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'MATEMATICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'GEOLOGICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'VETERINARIA', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'BIOLOGICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'ESTADISTICA', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'POLITICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'C.M. MIGUEL ANTONIO CARO', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'ECONOMICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'E. BUSINESS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'FISICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'C.C. EDUCACION', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'PSICOLOGIA', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS', 'C.M. BLANCA DE CASTILLA', 'f', -1, NULL, 1, -1, -1),

  -- TENIS DE MESA (m)
  ('1990-91', 'TENIS DE MESA', 'DERECHO', 'm', 1, 14, 1, 0, 1),
  ('1990-91', 'TENIS DE MESA', 'GEOLOGICAS', 'm', 2, 12, 1, 0, 2),
  ('1990-91', 'TENIS DE MESA', 'POLITICAS', 'm', 3, 10, 1, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'VETERINARIA', 'm', 4, 10, 1, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'FISICAS', 'm', 5, 8, 1, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'C.C. EDUCACION', 'm', 6, 8, 1, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'ODONTOLOGIA', 'm', 7, 8, 1, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'PSICOLOGIA', 'm', 8, 0, 1, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'C.C. INFORMACION', 'm', 9, -2, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'ECONOMICAS', 'm', -1, NULL, 1, -1, -1),

  -- TENIS DE MESA (f)
  ('1990-91', 'TENIS DE MESA', 'C.M. NUESTRA SRA. DE AFRICA', 'f', 1, 6, 1, 0, 1),
  ('1990-91', 'TENIS DE MESA', 'C.M. MIGUEL ANTONIO CARO', 'f', 2, 4, 1, 0, 2),
  ('1990-91', 'TENIS DE MESA', 'FILOLOGIA', 'f', 3, 2, 1, 0, 3),
  ('1990-91', 'TENIS DE MESA', 'FISICAS', 'f', 4, -2, 1, 0, 4),
  ('1990-91', 'TENIS DE MESA', 'C.C. INFORMACION', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'ECONOMICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'DERECHO', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'C.C. EDUCACION', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'PSICOLOGIA', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'MATEMATICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'POLITICAS', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'TENIS DE MESA', 'GEOLOGICAS', 'f', -1, NULL, 1, -1, -1),

  -- VOLEIBOL (m)
  ('1990-91', 'VOLEIBOL', 'POLITICAS', 'm', 1, 10, 1, 0, 1),
  ('1990-91', 'VOLEIBOL', 'FISICAS', 'm', 2, 8, 1, 0, 2),
  ('1990-91', 'VOLEIBOL', 'ECONOMICAS', 'm', 3, 6, 1, 0, -1),
  ('1990-91', 'VOLEIBOL', 'SAN PABLO CEU', 'm', 4, 4, 1, 0, -1),
  ('1990-91', 'VOLEIBOL', 'FARMACIA', 'm', 5, 2, 1, 0, -1),
  ('1990-91', 'VOLEIBOL', 'MATEMATICAS', 'm', 6, -2, 1, 0, -1),
  ('1990-91', 'VOLEIBOL', 'C.C. INFORMACION', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'VOLEIBOL', 'GEOGRAFIA E HISTORIA', 'm', -1, NULL, 1, -1, -1),
  ('1990-91', 'VOLEIBOL', 'FILOLOGIA', 'm', -1, NULL, 1, -1, -1),

  -- VOLEIBOL (f)
  ('1990-91', 'VOLEIBOL', 'VETERINARIA', 'f', 1, 10, 1, 0, 1),
  ('1990-91', 'VOLEIBOL', 'ECONOMICAS', 'f', 2, 8, 1, 0, 2),
  ('1990-91', 'VOLEIBOL', 'FISICAS', 'f', 3, 6, 1, 0, 3),
  ('1990-91', 'VOLEIBOL', 'POLITICAS', 'f', 4, 4, 1, 0, 4),
  ('1990-91', 'VOLEIBOL', 'DERECHO', 'f', 5, 2, 1, 0, -1),
  ('1990-91', 'VOLEIBOL', 'SAN PABLO CEU', 'f', 6, 0, 1, 0, -1),
  ('1990-91', 'VOLEIBOL', 'C.C. INFORMACION', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'VOLEIBOL', 'FILOLOGIA', 'f', -1, NULL, 1, -1, -1),
  ('1990-91', 'VOLEIBOL', 'C.M. MIGUEL ANTONIO CARO', 'f', -1, NULL, 1, -1, -1),

  -- ============= COLEGIOS MAYORES (CMU) EN TROFEO ALFONSO XIII =============
  -- Filas anadidas por participacion detectada en la Seccion III (Play-off/Fase Final
  -- propia de C.C. Mayores). Solo hay competicion masculina de CMU este curso.
  ('1990-91', 'AJEDREZ', 'C.M. COVARRUBIAS', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'AJEDREZ', 'C.M. ELIAS AHUJA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'BALONCESTO', 'C.M. ANTONIO DE NEBRIJA', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'BALONCESTO', 'C.M. ELIAS AHUJA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'BALONMANO', 'C.M. SAN PABLO', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'BALONMANO', 'C.M. MARQUES DE LA ENSENADA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'FRONTENIS', 'C.M. NUESTRA SRA. DE AFRICA', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'FRONTENIS', 'C.M. MARQUES DE LA ENSENADA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'FUTBOL 11', 'C.M. E. PUBLICA', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'FUTBOL 11', 'C.M. SANTA MARIA DE EUROPA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'FUTBOL SALA', 'C.M. S.J. EVANGELISTA', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'FUTBOL SALA', 'C.M. ALCALA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'RUGBY', 'C.M. XIMENEZ DE CISNEROS', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'RUGBY', 'C.M. LA SALLE', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'TENIS', 'C.M. XIMENEZ DE CISNEROS', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'TENIS', 'C.M. SANTA MARIA DE EUROPA', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'TENIS DE MESA', 'C.M. NUESTRA SRA. DE AFRICA', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'TENIS DE MESA', 'C.M. GUADALUPE', 'm', NULL, NULL, 1, 0, 2),
  ('1990-91', 'VOLEIBOL', 'C.M. LA SALLE', 'm', NULL, NULL, 1, 0, 1),
  ('1990-91', 'VOLEIBOL', 'C.M. ELIAS AHUJA', 'm', NULL, NULL, 1, 0, 2),

  -- ===================== 2a CATEGORIA =====================
  -- AJEDREZ (m) - Grupo A: solo Geografia e Historia no descalificada; Grupo B suspendido (todos DQ)
  ('1990-91', 'AJEDREZ', 'GEOGRAFIA E HISTORIA', 'm', 1, -2, 2, 1, -1),
  ('1990-91', 'AJEDREZ', 'FARMACIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'MATEMATICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'QUIMICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'VETERINARIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'GEOLOGICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'MARIA DIAZ JIMENEZ', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'C.C. INFORMACION', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'ODONTOLOGIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'DERECHO', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'FISICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'BIOLOGICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'PSICOLOGIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'AJEDREZ', 'FILOLOGIA', 'm', -1, NULL, 2, 0, -1),

  -- BALONCESTO (m) - Liga de Ascenso + grupos
  ('1990-91', 'BALONCESTO', 'MARIA DIAZ JIMENEZ', 'm', 1, 10, 2, 1, -1),
  ('1990-91', 'BALONCESTO', 'VETERINARIA', 'm', 2, 8, 2, 1, -1),
  ('1990-91', 'BALONCESTO', 'FARMACIA', 'm', 3, 6, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'PSICOLOGIA', 'm', 4, 4, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'MEDICINA', 'm', 5, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'UNIVERSIDAD SAN LUIS', 'm', 6, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'SAN PABLO CEU', 'm', 3, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'DOMINGO DE SOTO', 'm', 4, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'MEDICINA DEPORTIVA', 'm', 3, 4, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'FILOLOGIA', 'm', 4, 2, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.C. INFORMACION', 'm', 5, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'DERECHO', 'm', 3, 4, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'EMPRESARIALES', 'm', 4, 2, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'FILOSOFIA Y LETRAS', 'm', 5, 2, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'GEOGRAFIA E HISTORIA', 'm', 6, -2, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'MATEMATICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'ECONOMICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'E. BUSINESS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'FISICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'POLITICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'GEOLOGICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'CARDENAL CISNEROS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.C. EDUCACION', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'ESTADISTICA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'FOMENTO C.E.', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'QUIMICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'BIOLOGICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'BELLAS ARTES', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'PABLO MONTESINO', 'm', -1, NULL, 2, 0, -1),

  -- BALONCESTO (f) - Liga de Ascenso + grupos
  ('1990-91', 'BALONCESTO', 'MEDICINA DEPORTIVA', 'f', 1, 4, 2, 1, -1),
  ('1990-91', 'BALONCESTO', 'FARMACIA', 'f', 2, 2, 2, 1, -1),
  ('1990-91', 'BALONCESTO', 'MEDICINA', 'f', 3, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'QUIMICAS', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'BIOLOGICAS', 'f', 3, 8, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'PSICOLOGIA', 'f', 4, 4, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'ESTADISTICA', 'f', 5, 4, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.C. INFORMACION', 'f', 6, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.M. BLANCA DE CASTILLA', 'f', 7, -2, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'OPTICA Y OPTOMETRIA', 'f', 3, 0, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'CARDENAL CISNEROS', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'FILOLOGIA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.M. NUESTRA SRA. DE AFRICA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'SAN PABLO CEU', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'ECONOMICAS', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'E. BUSINESS', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'GEOGRAFIA E HISTORIA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'MARIA DIAZ JIMENEZ', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'DERECHO', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONCESTO', 'C.M. MIGUEL ANTONIO CARO', 'f', -1, NULL, 2, 0, -1),

  -- BALONMANO (m)
  ('1990-91', 'BALONMANO', 'CARDENAL CISNEROS', 'm', 1, 2, 2, 1, -1),
  ('1990-91', 'BALONMANO', 'ECONOMICAS', 'm', 2, -2, 2, 0, -1),
  ('1990-91', 'BALONMANO', 'FILOLOGIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONMANO', 'OPTICA Y OPTOMETRIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONMANO', 'GEOGRAFIA E HISTORIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONMANO', 'C.C. INFORMACION', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'BALONMANO', 'ODONTOLOGIA', 'm', -1, NULL, 2, 0, -1),

  -- FUTBOL 11 (m) - Liga de Ascenso + grupos
  ('1990-91', 'FUTBOL 11', 'FISICAS', 'm', 1, 9, 2, 1, -1),
  ('1990-91', 'FUTBOL 11', 'POLITICAS', 'm', 2, 7, 2, 1, -1),
  ('1990-91', 'FUTBOL 11', 'ECONOMICAS', 'm', 3, 5, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'DERECHO', 'm', 4, 3, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'OPTICA Y OPTOMETRIA', 'm', 5, 3, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'SAN PABLO CEU', 'm', 6, 1, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'MEDICINA DEPORTIVA', 'm', 6, -1, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'FILOLOGIA', 'm', 3, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'C.C. INFORMACION', 'm', 4, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'ESTADISTICA', 'm', 5, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'DOMINGO DE SOTO', 'm', 6, 3, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'EMPRESARIALES', 'm', 7, 0, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'VETERINARIA', 'm', 3, 9, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'ODONTOLOGIA', 'm', 4, 9, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'QUIMICAS', 'm', 5, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'GEOLOGICAS', 'm', 6, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'BIOLOGICAS', 'm', 7, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'CARDENAL CISNEROS', 'm', 8, 0, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'FARMACIA', 'm', 3, 6, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'MATEMATICAS', 'm', 4, 3, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'FILOSOFIA Y LETRAS', 'm', 5, 0, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'MARIA DIAZ JIMENEZ', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'E. BUSINESS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'PSICOLOGIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'BELLAS ARTES', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL 11', 'MEDICINA', 'm', -1, NULL, 2, 0, -1),

  -- FUTBOL SALA (m) - Liga de Ascenso + grupos
  ('1990-91', 'FUTBOL SALA', 'SAN PABLO CEU', 'm', 1, 8, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'C.C. INFORMACION', 'm', 2, 6, 2, 1, -1),
  ('1990-91', 'FUTBOL SALA', 'FILOSOFIA Y LETRAS', 'm', 3, 2, 2, 1, -1),
  ('1990-91', 'FUTBOL SALA', 'ECONOMICAS', 'm', 4, 0, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'OPTICA Y OPTOMETRIA', 'm', 5, -2, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'MEDICINA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'CARDENAL CISNEROS', 'm', 3, 2, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'FISICAS', 'm', 4, 2, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'DERECHO', 'm', 3, 10, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'ODONTOLOGIA', 'm', 4, 9, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'MEDICINA DEPORTIVA', 'm', 5, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'EMPRESARIALES', 'm', 6, 3, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'C.C. EDUCACION', 'm', 7, 1, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'MARIA DIAZ JIMENEZ', 'm', 8, -2, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'ESTADISTICA', 'm', 3, 4, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'FILOLOGIA', 'm', 4, 0, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'UNIVERSIDAD SAN LUIS', 'm', 5, 0, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'GEOGRAFIA E HISTORIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'MATEMATICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'GEOLOGICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'FARMACIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'POLITICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'PABLO MONTESINO', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'FOMENTO C.E.', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'QUIMICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'E. BUSINESS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'DOMINGO DE SOTO', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'FUTBOL SALA', 'BIOLOGICAS', 'm', -1, NULL, 2, 0, -1),

  -- TENIS (m) - Liga de Ascenso + grupos
  ('1990-91', 'TENIS', 'MEDICINA', 'm', 2, 2, 2, 1, -1),
  ('1990-91', 'TENIS', 'POLITICAS', 'm', 3, 2, 2, 1, -1),
  ('1990-91', 'TENIS', 'GEOGRAFIA E HISTORIA', 'm', 1, 2, 2, 0, -1),
  ('1990-91', 'TENIS', 'QUIMICAS', 'm', 3, 6, 2, 0, -1),
  ('1990-91', 'TENIS', 'SAN PABLO CEU', 'm', 4, 4, 2, 0, -1),
  ('1990-91', 'TENIS', 'BIOLOGICAS', 'm', 5, 0, 2, 0, -1),
  ('1990-91', 'TENIS', 'C.C. INFORMACION', 'm', 6, -2, 2, 0, -1),
  ('1990-91', 'TENIS', 'FILOLOGIA', 'm', 2, 0, 2, 0, -1),
  ('1990-91', 'TENIS', 'CARDENAL CISNEROS', 'm', 3, -2, 2, 0, -1),
  ('1990-91', 'TENIS', 'FARMACIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS', 'MARIA DIAZ JIMENEZ', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS', 'ECONOMICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS', 'E. BUSINESS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS', 'MEDICINA DEPORTIVA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS', 'VETERINARIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS', 'PSICOLOGIA', 'm', -1, NULL, 2, 0, -1),

  -- TENIS DE MESA (m) - 2a CATEGORIA
  ('1990-91', 'TENIS DE MESA', 'FILOLOGIA', 'm', 1, 6, 2, 1, -1),
  ('1990-91', 'TENIS DE MESA', 'CARDENAL CISNEROS', 'm', 2, 2, 2, 1, -1),
  ('1990-91', 'TENIS DE MESA', 'GEOGRAFIA E HISTORIA', 'm', 3, 2, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'BIOLOGICAS', 'm', 4, 0, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'ECONOMICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'ESTADISTICA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'MATEMATICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'FARMACIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'FISICAS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'OPTICA Y OPTOMETRIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'MARIA DIAZ JIMENEZ', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'TENIS DE MESA', 'POLITICAS', 'm', -1, NULL, 2, 0, -1),

  -- VOLEIBOL (m) - 2a CATEGORIA
  ('1990-91', 'VOLEIBOL', 'QUIMICAS', 'm', 1, 2, 2, 1, -1),
  ('1990-91', 'VOLEIBOL', 'ODONTOLOGIA', 'm', 2, -2, 2, 1, -1),
  ('1990-91', 'VOLEIBOL', 'C.C. INFORMACION', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'CARDENAL CISNEROS', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'VETERINARIA', 'm', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'DERECHO', 'm', -1, NULL, 2, 0, -1),

  -- VOLEIBOL (f) - 2a CATEGORIA
  ('1990-91', 'VOLEIBOL', 'QUIMICAS', 'f', 1, 2, 2, 1, -1),
  ('1990-91', 'VOLEIBOL', 'MEDICINA', 'f', 2, 2, 2, 1, -1),
  ('1990-91', 'VOLEIBOL', 'BIOLOGICAS', 'f', 3, -2, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'C.M. NUESTRA SRA. DE AFRICA', 'f', 3, -2, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'ODONTOLOGIA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'E. BUSINESS', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'CARDENAL CISNEROS', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'GEOGRAFIA E HISTORIA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'C.M. J.L. VIVES', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'PSICOLOGIA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'FILOLOGIA', 'f', -1, NULL, 2, 0, -1),
  ('1990-91', 'VOLEIBOL', 'C.M. BLANCA DE CASTILLA', 'f', -1, NULL, 2, 0, -1);

COMMIT;
