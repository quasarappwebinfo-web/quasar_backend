# Peso de la zona sobre la obra

Implementado. El `%` de cada zona se escribe en **Listado General Act. → Zonas**. No está fijo: Casa puede ser 70 y Zona social 30, o cualquier otro par que sume lo que el cliente quiera. Una zona sin `%` no suma al avance.

## Qué pidió el cliente

El capítulo y el subcapítulo no tienen zona. La zona la tiene solo la actividad. Si la actividad tiene zona, su avance suma únicamente ahí. Si es una actividad general y se deja sin zona, ese mismo avance entra en todas las zonas.

La zona sí tiene un porcentaje de la obra. En el ejemplo del cliente:

- Casa = 70 % de la obra
- Zona social = 30 % de la obra

El capítulo conserva su porcentaje, pero ese porcentaje se aplica **dentro de cada zona**, no una sola vez sobre la obra entera. Estructura vale 30 %. Como ya no pertenece a una zona, ese 30 % es:

- el 30 % del 70 % que vale la Casa
- y el 30 % del 30 % que vale la Zona social

## Cómo se calcula

```
avance del capítulo en esa zona
    = promedio de las actividades de ese capítulo que son de esa zona o que no tienen zona

avance de la zona
    = Σ (peso del capítulo / 100 × avance del capítulo en esa zona)

avance de la obra
    = Σ (peso de la zona / 100 × avance de la zona)
```

Es lo mismo escrito de una vez:

```
aporte a la obra
    = peso de la zona / 100
      × peso del capítulo / 100
      × avance del capítulo en esa zona
```

Con los números del cliente, si Estructura va al 100 % en la Casa y al 0 % en la Zona social:

- Casa: 70 × 30 × 100 / 10 000 = **21 puntos** de la obra
- Zona social: 30 × 30 × 0 / 10 000 = **0 puntos**

Si Estructura va al 100 % en las dos zonas, suma 21 + 9 = **30 puntos**. El 30 % del capítulo se conserva en la obra y se reparte según el peso de cada zona.

No se promedian las actividades de las dos zonas como si valieran lo mismo. Una actividad al 100 % en la Casa y otra al 0 % en la Zona social no son 50 %. El capítulo, mirado en la obra, va al 70 % (100 × 0,70 + 0 × 0,30) y aporta 21 puntos, no 15.

Dentro de una zona, las actividades del capítulo se reparten ese capítulo en partes iguales. Entran las de esa zona y las actividades generales que no tienen zona: esas últimas se cuentan otra vez en cada zona. Una actividad de la Casa no diluye el avance de Estructura en la Zona social.

Una actividad general sin zona suma su avance en todas las zonas. Una actividad creada solo en la obra, sin zona, no suma en ninguna.

Un capítulo sin `%` aporta 0 en todas las zonas. Una zona sin `%` aporta 0 a la obra. No se renormaliza: si los pesos no suman 100, el anillo no tiene por qué llegar a 100.

## Qué deja de tener zona

| Dónde | Hoy | Queda |
|---|---|---|
| Capítulo `task_chapters` | No tiene `zone_id`. `is_global` decide si el mismo avance se copia en todas las zonas | Sin zona y sin `is_global`. El mismo peso se mide aparte en cada zona, con las actividades de esa zona y las generales que no tienen zona |
| Subcapítulo `task_budget_activities` | Tiene `zone_id`, `chapter_weight_percent` y `zone_weight_percent` | Sin zona y sin esos pesos. Sigue siendo solo el grupo dentro del capítulo |
| Actividad del listado `task_templates` | Tiene `zone_id` | La conserva. Si queda vacía, su avance entra en todas las zonas |
| Actividad de la obra `tasks` | Tiene `zone_id` | Si salió de una actividad general, suma en la zona de esa actividad ahora. Si esa actividad no tiene zona, suma en todas. Una actividad creada solo en la obra, sin zona, no suma |

El peso vive en la zona de catálogo, `task_zones.weight_percent`, y se edita en el listado de zonas. Es el mismo para todas las obras.

## Qué se ve en la ficha

`GET /api/v1/operacion/tareas/cumplimiento?obraId=`

- `progressPercent`: el avance de la obra con la fórmula de arriba. Hoy es `peso del capítulo × avance del capítulo`, sin mirar la zona (`_house_progress`).
- `zones[]`: una fila por zona activa. Cada fila trae su `weightPercent`, su avance de zona y **todos** los capítulos activos. El `%` de un capítulo en esa fila sale de las actividades de esa zona y de las actividades generales que no tienen zona.
- `chapters[]`: si se sigue mostrando un capítulo suelto, su avance es el de ese capítulo dentro de cada zona, ponderado por el peso de la zona. No es el promedio de todas sus actividades juntas.

El anillo de la bitácora no cambia: sigue siendo el promedio simple de las actividades de ese periodo.

## Obra que ya venía empezada

`obra_chapter_openings` marca un capítulo al crear la obra (completado o a medias, para todas las zonas) y también después, desde la ficha, zona por zona. Completado deja esa zona en 100 % y no admite actividades nuevas ahí. En marcha admite actividades en esa zona; si trae un %, ese es el piso de esa zona. Lo que se complete después solo sube la zona de la actividad que se completa.

## Dónde está el cálculo de hoy

- `app/services/task_service.py`: `_chapters_from_tasks`, `_house_progress`, `house_progress_by_obra`, `_zone_board`, `obra_fulfillment`
- Modelos: `TaskChapter.weight_percent`, `TaskChapter.is_global`, `TaskZone` (sin peso), `TaskBudgetActivity.zone_id`
- Lo que la app pinta ahora: [tareas-frontend.md](./tareas-frontend.md), [task-pool-frontend.md](./task-pool-frontend.md), [obras-frontend.md](./obras-frontend.md)
