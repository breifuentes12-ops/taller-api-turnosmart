# Homologación - TurnoSmart Campus

TurnoSmart Campus es un sistema para pedir y atender turnos en los servicios de una universidad.

Para correr el proyecto: `docker compose up -d --build`. La API queda en `http://localhost:8080`.

## Tablas de mi proyecto

| Rol | Tabla | Por qué |
|---|---|---|
| Catálogo | `servicio` | Agrupa todo: cada turno y cada atención pertenece a un servicio. |
| Recurso | `ventanilla` | Es el puesto físico donde se atiende cada turno. |
| Transaccional | `atencion` y `turno` | Guardan cada turno y su atención, con fecha, hora de inicio y hora de fin. |
| Actor | `usuario` y `empleado` | El usuario pide el turno y el empleado lo atiende. |

## Endpoints

### 1. `/api/atenciones`
Muestra cada atención con sus datos listos para leer. Junta la atención con su turno, su servicio y el usuario, pone el nombre en mayúsculas, muestra el mes y los días que han pasado, y calcula cuántos minutos se pasó o le sobraron frente al tiempo estimado.

### 2. `/api/metricas/servicios`
Dice cómo le fue a cada servicio. Agrupa las atenciones por servicio y saca cuántas hubo, el total de minutos, el promedio, la más larga y la más corta. Solo muestra los servicios que tienen 2 atenciones o más.

### 3. `/api/ranking/atenciones`
Muestra cómo trabaja cada ventanilla sin juntar las filas: cada fila es una atención. Le da a cada atención un puesto dentro de su servicio, suma los minutos que va acumulando cada ventanilla día a día y muestra qué porcentaje del servicio representa esa atención. Usa funciones ventana (`DENSE_RANK` y `SUM ... OVER`).

### 4. `/api/auditoria/atenciones`
Revisa si cada atención se hizo en el tiempo esperado. Usa la función `fn_clasificar_atencion`, guardada en `init.sql`, que compara lo que duró la atención con lo que debía durar y responde Rápida, A tiempo, Demorada, Crítica o En curso.

### 5. `/api/reporte`
Reporte de turnos que se puede filtrar por servicio, estado y fechas, aunque ningún filtro es obligatorio. Por ejemplo: `/api/reporte?servicio=4&estado=Atendido`. Los filtros se envían de forma segura con `?`, así que no hay inyección SQL. Si un dato viene mal responde 400, y si el servicio no existe responde 404.