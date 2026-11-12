# Homologación - TurnoSmart Campus

TurnoSmart Campus es un sistema para pedir y atender turnos en los servicios de una universidad.

Para correr el proyecto: `docker compose up -d --build`. La API queda en `http://localhost:8080`.

## Tablas de mi proyecto

| Rol | Tabla | Por qué |
|---|---|---|
| Catálogo | `servicio` | Agrupa todo: cada turno y cada empleado pertenece a un servicio. |
| Recurso | `empleado` | Son los que atienden los turnos dentro de cada servicio. |
| Transaccional | `atencion` y `turno` | Guardan cada turno y su atención, con fecha, hora de inicio y hora de fin. |
| Actor | `usuario` | Las personas que piden los turnos. |

## Endpoints

### 1. `/api/atenciones`
Muestra cada atención con sus datos listos para leer.
- Une atención, turno, servicio y usuario con `INNER JOIN`.
- Pone el nombre en mayúsculas (`UPPER`, `CONCAT`).
- Muestra el año y mes, y cuántos días han pasado (`DATE_FORMAT`, `DATEDIFF`).
- Calcula cuántos minutos se pasó o le sobraron frente al tiempo estimado.

### 2. `/api/metricas/servicios`
Dice cómo le fue a cada servicio.
- Une atención, turno y servicio, y agrupa por servicio (`GROUP BY`).
- Cuenta las atenciones y saca el total, el promedio, el máximo y el mínimo de minutos (`COUNT`, `SUM`, `AVG`, `MAX`, `MIN`).
- Solo muestra los servicios con 2 atenciones o más (`HAVING`).

### 3. `/api/ranking/atenciones`
Compara cada atención con las demás de su mismo servicio, sin perder ninguna fila.
- `DENSE_RANK`: el puesto de la atención dentro de su servicio, de la más larga a la más corta.
- `SUM ... OVER`: los minutos acumulados del servicio a lo largo de los días.
- El porcentaje que representa cada atención en el total de su servicio.

### 4. `/api/auditoria/atenciones`
Revisa si cada atención se hizo en el tiempo esperado.
- Usa la función `fn_clasificar_atencion`, que está en `init.sql`.
- Recibe lo que duró la atención y lo que debía durar, y responde: Rápida, A tiempo, Demorada, Crítica o En curso.

### 5. `/api/reporte`
Reporte de turnos que se puede filtrar por servicio, estado y fechas. Los filtros son opcionales.
- Agrupa por servicio y estado, y cuenta turnos, usuarios y prioritarios.
- Los filtros se pasan con `?` en el `PreparedStatement`, así no hay inyección SQL.
- Si un dato está mal responde 400, y si el servicio no existe responde 404.



