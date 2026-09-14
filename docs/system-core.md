# SYSTEM CORE

## 1. Propósito del sistema

Este sistema es una plataforma de gestión integral de obras de construcción.

Su propósito principal es permitir que una empresa constructora pueda:

- Crear y administrar obras.
- Organizar trabajadores y cuadrillas.
- Planificar actividades de construcción.
- Utilizar un catálogo reutilizable de actividades constructivas.
- Estimar duración y recursos necesarios.
- Administrar dependencias entre actividades.
- Asignar trabajadores y cuadrillas.
- Obtener recomendaciones de distribución de recursos.
- Formalizar las planificaciones mediante firmas.
- Ejecutar y hacer seguimiento de las actividades.
- Registrar retrasos, reprogramaciones y sus motivos.
- Registrar instrucciones, comentarios y notas.
- Adjuntar evidencia fotográfica.
- Verificar actividades terminadas.
- Mantener trazabilidad completa de las decisiones y cambios.

El sistema debe permitir reconstruir posteriormente la historia de una actividad:

Qué se planeó → quién lo aprobó → quién lo ejecutó → qué ocurrió → qué cambió → por qué cambió → qué evidencia existe → quién verificó.


---

# 2. Principio fundamental

## El sistema recomienda, pero el responsable de la obra decide.

El sistema puede utilizar información histórica, plantillas, cantidades, rendimientos, disponibilidad de trabajadores, cuadrillas y dependencias para realizar recomendaciones.

Sin embargo:

- El sistema NO debe tomar decisiones operativas importantes automáticamente.
- El supervisor debe poder revisar las recomendaciones.
- El supervisor debe poder aceptar, modificar o rechazar una recomendación.
- Cuando el supervisor modifica una recomendación, debe conservarse la diferencia entre lo recomendado y lo aprobado.

Ejemplo:

La plantilla indica:

Fundir placa
- Cantidad base: 1.000 m²
- Duración base: 5 días
- 1 maestro
- 3 ayudantes

La obra necesita:

2.000 m²

El sistema puede recomendar:

- 10 días con la misma cuadrilla

o:

- 5 días con aproximadamente el doble de capacidad de personal.

El supervisor decide finalmente:

- 5 días
- 2 maestros
- 6 ayudantes

El sistema debe conservar:

RECOMENDADO:
5 días / 2 maestros / 6 ayudantes

APROBADO:
5 días / 2 maestros / 6 ayudantes

Posteriormente debe poder compararse contra:

REAL:
7 días / 2 maestros / 6 ayudantes


---

# 3. Conceptos principales

El sistema gira alrededor de los siguientes conceptos:

1. Personas
2. Usuarios
3. Trabajadores
4. Cuadrillas
5. Obras
6. Etapas de obra
7. Task Pool
8. Tareas
9. Planificaciones
10. Firmas
11. Ejecución
12. Evidencia
13. Auditoría


---

# 4. Personas, usuarios y trabajadores

## Person

Una persona representa una identidad física única.

La cédula/documento identifica a la persona.

Una persona puede tener diferentes roles dentro del sistema.

Ejemplo:

Una persona puede ser:

- Trabajador.
- Usuario del sistema.
- Líder de cuadrilla.

No se deben crear personas duplicadas solamente porque tengan diferentes funciones.

---

## User

Un usuario representa una persona que tiene acceso al sistema.

El usuario tiene:

- Credenciales.
- Rol.
- Permisos.
- Estado activo/inactivo.

No todas las personas necesitan ser usuarios.

---

## Worker

Un trabajador representa la participación laboral de una persona dentro de la operación de construcción.

Tiene:

- Cargo.
- Especialidad.
- Posible usuario vinculado.
- Estado activo/inactivo.

Un trabajador puede participar en diferentes obras a lo largo del tiempo.

La salida de una obra NO significa que el trabajador esté inactivo.

Por eso existen las asignaciones históricas a obras.


---

# 5. Cuadrillas

Una cuadrilla es un grupo de trabajadores que normalmente trabajan juntos.

Una cuadrilla puede tener:

- Nombre.
- Líder.
- Miembros.
- Obra actual.

La cuadrilla puede utilizarse como recurso recomendado por el Task Pool o como recurso real asignado a una tarea.

La pertenencia de un trabajador a una cuadrilla debe mantener historial mediante:

crew_members

Por lo tanto:

entrar a una cuadrilla ≠ ser trabajador activo

salir de una cuadrilla ≠ trabajador inactivo


---

# 6. Obras

Una obra es el principal contexto operativo del sistema.

Una obra puede tener:

- Datos generales.
- Ubicación.
- Tipo de venta.
- Cliente.
- Etapa actual.
- Historial de etapas.
- Trabajadores.
- Cuadrillas.
- Documentos.
- Tareas.
- Planificaciones.

Una obra para venta puede existir sin comprador.

Por eso el cliente no debe ser obligatorio al crear una obra.


---

# 7. Task Pool

## Concepto fundamental

El Task Pool es una biblioteca reutilizable de conocimiento constructivo.

No contiene tareas reales de una obra.

Contiene definiciones de actividades que pueden reutilizarse en múltiples obras.

Ejemplos:

- Fundir placa.
- Levantar muro.
- Instalar enchape.
- Pintar paredes.
- Instalar puertas.
- Construir cimentación.

El objetivo es evitar que cada supervisor tenga que crear manualmente desde cero las mismas actividades en cada obra.


---

# 8. Categorías del Task Pool

Las tareas del Task Pool deben organizarse mediante categorías.

Ejemplos:

- Preliminares.
- Movimiento de tierras.
- Cimentación.
- Estructura.
- Mampostería.
- Instalaciones.
- Cubierta.
- Acabados.
- Exteriores.
- Entrega.

Las categorías son importantes tanto para la organización del sistema como para la experiencia de usuario.

Una actividad pertenece a una categoría.


---

# 9. Versiones del Task Pool

Una plantilla puede evolucionar con el tiempo.

Por ejemplo:

Fundir placa

Versión 1:
- 1.000 m²
- 5 días
- 1 maestro
- 3 ayudantes

Versión 2:
- 1.000 m²
- 4 días
- 1 maestro
- 4 ayudantes

La versión 2 no debe modificar históricamente la versión 1.

Las versiones publicadas deben considerarse inmutables.

Si cambia una regla importante:

NO modificar la versión publicada.

CREAR una nueva versión.


---

# 10. Qué contiene una versión del Task Pool

Una versión puede definir:

- Nombre.
- Descripción.
- Cantidad base.
- Duración base.
- Unidad de medida.
- Cargos necesarios.
- Cantidad recomendada por cargo.
- Cuadrillas preferidas.
- Subtareas.
- Dependencias.
- Reglas de ejecución.

Esto convierte el Task Pool en mucho más que un catálogo.

Es una representación estructurada del conocimiento operativo de construcción.


---

# 11. Rendimiento y cantidades

El sistema debe poder utilizar cantidades para generar recomendaciones.

Ejemplo:

Plantilla:

Fundir placa

Base:

1.000 m² → 5 días

Obra:

2.000 m²

El sistema puede calcular inicialmente:

2.000 / 1.000 = 2

Por lo tanto:

5 × 2 = 10 días

con la misma capacidad de trabajo.

Sin embargo, este cálculo es una estimación.

El supervisor puede modificarlo.

El sistema debe diferenciar:

- Cantidad de referencia.
- Rendimiento estimado.
- Duración recomendada.
- Duración aprobada.
- Duración real.


---

# 12. Tareas

Una tarea es una instancia concreta de una actividad dentro de una obra.

Ejemplo:

Task Pool:

Fundir placa

↓

Obra:

Casa 103

↓

Tarea:

Fundir placa - Casa 103

↓

Cantidad:

2.000 m²

↓

Fecha:

10 - 19 septiembre


Una tarea puede tener:

- Obra.
- Plantilla de origen.
- Versión de plantilla.
- Cantidad.
- Unidad.
- Fechas.
- Duración estimada.
- Duración aprobada.
- Trabajadores.
- Cuadrilla.
- Subtareas.
- Dependencias.
- Estado.
- Comentarios.
- Instrucciones.
- Fotos.
- Retrasos.
- Reprogramaciones.


---

# 13. Estados de una tarea

Una tarea puede tener únicamente uno de estos estados actuales:

1. scheduled
2. in_progress
3. completed
4. verified
5. rescheduled

En la interfaz pueden mostrarse como:

- Programada
- En progreso
- Completada
- Verificada
- Reprogramada

El estado actual se almacena en `tasks`.

Los cambios de estado se registran en `task_status_history`.


---

# 14. Reprogramaciones

Una tarea puede ser reprogramada varias veces.

Ejemplo:

10 - 12 septiembre

↓

Reprogramada por lluvia

↓

12 - 15 septiembre

↓

Reprogramada por falta de material

↓

15 - 18 septiembre

Cada cambio debe conservar:

- Fecha anterior.
- Nueva fecha.
- Motivo.
- Usuario responsable.
- Fecha y hora del cambio.

Nunca se debe sobrescribir únicamente la fecha anterior sin conservar el historial.


---

# 15. Retrasos

Un retraso representa tiempo perdido durante la ejecución.

Una tarea puede tener múltiples retrasos.

Ejemplo:

Tarea:

Fundir placa

Retraso 1:
- 2 días
- Lluvia

Retraso 2:
- 1 día
- Falta de concreto

El sistema debe poder determinar posteriormente:

Tiempo planificado
vs.
Tiempo perdido
vs.
Tiempo real.


---

# 16. Dependencias

Las dependencias representan relaciones lógicas entre actividades.

Ejemplo:

Estuco
↓
Pintura

Pintar paredes no debería comenzar antes de que el estuco esté terminado.

Las dependencias pueden existir:

- En el Task Pool.
- Entre tareas concretas de una obra.

El Task Pool define la regla general.

Las tareas concretas representan la aplicación de esa regla.

Ejemplo:

Task Pool:

Pintar paredes
depende de
Estucar paredes

Obra Casa 103:

Pintar paredes Casa 103
depende de
Estucar paredes Casa 103


---

# 17. Dependencias inteligentes

Las dependencias deben utilizarse para ayudar al supervisor a planificar.

Si una tarea requiere que otra esté terminada y esta condición no se cumple, el sistema debe:

- Advertir al supervisor.
- Indicar qué tarea está bloqueando.
- Mostrar el motivo.
- Evitar el inicio cuando la dependencia esté configurada como bloqueante.

El sistema no debe ocultar el problema ni resolverlo silenciosamente.


---

# 18. Excepciones a las dependencias

Una dependencia del Task Pool puede no aplicar a una obra específica.

Por ejemplo:

El Task Pool establece:

Pintar paredes
→ requiere lijado.

Pero una determinada obra puede utilizar otro sistema de acabado.

El supervisor puede modificar la dependencia para esa tarea concreta.

Esta modificación debe:

- Tener motivo.
- Identificar quién la realizó.
- Mantener la regla original.
- No modificar el Task Pool global.

Por lo tanto:

REGLA GLOBAL ≠ EXCEPCIÓN LOCAL


---

# 19. Subtareas

Las tareas pueden contener subtareas.

Ejemplo:

Fundir placa

1. Revisar acero.
2. Revisar instalaciones.
3. Revisar formaleta.
4. Coordinar concreto.
5. Fundir.
6. Realizar curado.

El Task Pool puede definir subtareas estándar.

Al crear una tarea real, estas pueden convertirse en tareas hijas.

Las subtareas utilizan:

parent_task_id


---

# 20. Planificación

La planificación representa un periodo de trabajo que se desea ejecutar.

Ejemplo:

Planificación semanal

09/09/2026 → 14/09/2026

Obra:

Casa 103

Incluye:

- 12 tareas.
- 8 trabajadores.
- 2 cuadrillas.

La planificación responde:

¿Qué vamos a hacer?

¿Cuándo?

¿Con qué recursos?

¿Quién participa?


---

# 21. Planificación vs tarea

Una tarea puede existir sin estar incluida en una planificación.

Una planificación agrupa tareas que se desean ejecutar durante un periodo determinado.

Por lo tanto:

TASK = actividad

WORK PLAN = compromiso operativo de ejecutar un conjunto de actividades durante un periodo


---

# 22. Versiones de planificación

Una planificación puede cambiar.

Ejemplo:

Planificación #25

Versión 1:
- 12 tareas
- Firmada

Luego:

Se agrega una tarea.

Esto genera:

Planificación #25
Versión 2:
- 13 tareas
- Pendiente de firma

La versión anterior permanece intacta.


---

# 23. Regla fundamental de las firmas

Una firma representa la aprobación de una versión específica de una planificación.

La firma NO representa simplemente:

"Estoy de acuerdo con esta obra."

Representa:

"Apruebo esta planificación específica, con estas tareas, cantidades, fechas y condiciones."


---

# 24. Snapshot de planificación

Cuando una planificación se firma, debe existir una fotografía histórica de lo que fue aprobado.

Por eso `work_plan_tasks` almacena snapshots de información crítica.

Ejemplo:

Tarea:

Fundir placa

Cantidad aprobada:

2.000 m²

Fecha:

10 - 19 septiembre

Duración:

10 días

Estos datos deben seguir siendo recuperables aunque posteriormente la tarea original cambie.


---

# 25. Firmantes

Una planificación puede requerir múltiples firmantes.

Ejemplo:

Planificación semanal:

Supervisor ✓

Maestro ✓

Responsable ✓

Cada firmante debe tener su propio registro.

Debe poder conocerse:

- Quién debía firmar.
- Si firmó.
- Cuándo firmó.
- Si rechazó.
- Cuándo rechazó.
- Motivo del rechazo.


---

# 26. Firma

Una firma debe registrar como mínimo:

- Persona/usuario que firmó.
- Planificación/version específica.
- Fecha.
- Hora.
- Tipo de firma.
- Evidencia/referencia de la firma.

La firma debe quedar asociada a la identidad del usuario autenticado.

Nunca se deben almacenar contraseñas, tokens ni credenciales dentro de los datos de firma.


---

# 27. Quién hizo firmar

El sistema debe registrar quién inició o solicitó el proceso de firma.

Ejemplo:

Planificación creada por:

Carlos

Solicitada para firma por:

Carlos

Firmantes:

Pedro - 7:42 AM
Juan - 7:48 AM
Carlos - 7:51 AM

Esto permite saber quién puso en marcha formalmente el proceso de aprobación.


---

# 28. Eventos de firma

El sistema debe mantener eventos relacionados con la firma.

Ejemplos:

- requested
- viewed
- signed
- rejected
- cancelled

Esto permite saber no solamente quién firmó, sino también cómo evolucionó el proceso.


---

# 29. Firma y modificaciones

Una versión completamente firmada no debe modificarse.

Si cambia algo relevante:

Debe generarse una nueva versión.

Ejemplo:

V1:
Firmada

↓

Cambio de fecha

↓

V2:
Pendiente de firma

Esto protege la integridad histórica del sistema.


---

# 30. Ejecución

La planificación representa lo que se acordó hacer.

La tarea representa lo que realmente ocurre.

El sistema debe poder comparar:

PLANIFICADO
vs.
APROBADO
vs.
REAL


Ejemplo:

Planificado:
5 días

Aprobado:
6 días

Real:
8 días

El sistema debe poder explicar posteriormente por qué ocurrió la diferencia.


---

# 31. Evidencia

Las tareas pueden tener múltiples fotografías.

Las fotografías sirven como evidencia de:

- Inicio.
- Progreso.
- Finalización.
- Problemas.
- Daños.
- Calidad.
- Cambios.
- Situaciones especiales.

Una tarea puede tener muchas fotografías.

Las fotografías deben registrar:

- Archivo.
- Descripción.
- Fecha/hora cuando esté disponible.
- Usuario que la cargó.


---

# 32. Comentarios e instrucciones

Una tarea puede contener:

- Comentarios.
- Notas.
- Instrucciones.

Las instrucciones representan comunicación operativa.

Ejemplo:

"Antes de fundir verificar nuevamente las instalaciones eléctricas."

Debe quedar registrado:

- Quién escribió la instrucción.
- Cuándo.
- Sobre qué tarea.
- Contenido.


---

# 33. Recursos

El sistema distingue entre:

RECURSO RECOMENDADO

y

RECURSO APROBADO / ASIGNADO

El Task Pool puede decir:

1 maestro
3 ayudantes

El sistema puede calcular:

2 maestros
6 ayudantes

Pero el supervisor puede decidir:

1 maestro
5 ayudantes

La decisión final pertenece al responsable de la obra.


---

# 34. Disponibilidad de trabajadores

El sistema debe utilizar las asignaciones de trabajadores a obras y las asignaciones de tareas para ayudar a determinar disponibilidad.

Antes de recomendar un trabajador, debe comprobarse si:

- Está activo.
- Está asignado a la obra.
- Ya está comprometido con otra tarea durante el periodo.
- Pertenece a una cuadrilla compatible.
- Tiene el cargo/especialidad requerido.

El sistema debe recomendar trabajadores disponibles.

No debe reasignarlos automáticamente sin aprobación.


---

# 35. Auditoría

Las acciones importantes deben ser trazables.

El sistema debe poder responder:

¿Quién hizo el cambio?

¿Cuándo?

¿Qué cambió?

¿Qué valor tenía antes?

¿Qué valor tiene ahora?

¿Por qué?

La tabla `audit_log` sirve como mecanismo general de auditoría.

Los historiales específicos de tareas y firmas complementan esta auditoría.


---

# 36. Regla de no destrucción histórica

El sistema debe priorizar la preservación de información histórica.

No se deben eliminar registros históricos importantes simplemente porque ya no estén activos.

Preferir:

is_active = false

o:

status = archived

o:

registro histórico

antes que borrar información que pueda ser necesaria para reconstruir lo ocurrido.


---

# 37. Separación entre catálogo y operación

Esta separación es fundamental.

CATÁLOGO:

task_templates
task_template_versions
task_template_positions
task_template_subtasks
task_template_dependencies

OPERACIÓN:

tasks
task_assignments
task_dependencies
task_comments
task_photos
task_delay_events
task_reschedules

PLANIFICACIÓN:

work_plans
work_plan_versions
work_plan_tasks
work_plan_signers
work_plan_signatures
work_plan_signature_events


Nunca se debe utilizar una tarea real para almacenar reglas globales del Task Pool.


---

# 38. Flujo principal del sistema

El flujo operativo principal es:

OBRA
↓
Seleccionar actividades del Task Pool
↓
Definir cantidades
↓
Calcular recomendaciones
↓
Revisar disponibilidad de recursos
↓
Supervisor ajusta y aprueba
↓
Crear planificación
↓
Asignar tareas y recursos
↓
Enviar a firma
↓
Firmas
↓
Planificación aprobada
↓
Ejecución
↓
Seguimiento
↓
Evidencia
↓
Completada
↓
Verificación
↓
Análisis de resultados


---

# 39. Filosofía del sistema

El sistema debe funcionar como un asistente operativo para el responsable de la obra.

No debe reemplazar su criterio.

Debe:

- Reducir trabajo administrativo.
- Reutilizar conocimiento.
- Detectar conflictos.
- Detectar dependencias.
- Detectar falta de recursos.
- Recomendar soluciones.
- Mantener evidencia.
- Formalizar decisiones.
- Facilitar seguimiento.
- Crear trazabilidad.

La inteligencia del sistema debe estar orientada a:

"ayudar al supervisor a tomar mejores decisiones"

y no a:

"tomar decisiones sin supervisión."


---

# 40. Regla de oro

Toda actividad importante debe poder responder estas preguntas:

1. ¿Qué se debía hacer?
2. ¿En qué obra?
3. ¿Cuándo?
4. ¿Con qué cantidad?
5. ¿Con qué recursos?
6. ¿Quién lo aprobó?
7. ¿Quién firmó?
8. ¿Cuándo firmó?
9. ¿Quién solicitó la firma?
10. ¿Quién lo ejecutó?
11. ¿Qué ocurrió?
12. ¿Hubo retrasos?
13. ¿Por qué?
14. ¿Se reprogramó?
15. ¿Quién hizo el cambio?
16. ¿Qué evidencia existe?
17. ¿Quién verificó?
18. ¿Cuál fue el resultado real?

Si el sistema puede responder estas preguntas de forma confiable,
la información necesaria para reconstruir la historia de la obra está disponible.
