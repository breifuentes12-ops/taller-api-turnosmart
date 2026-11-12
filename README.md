# API REST TurnoSmart Campus

Microservicio REST en Java conectado a MySQL con Docker Compose.

## Cómo ejecutarlo

    docker compose up -d --build

La API queda en http://localhost:8080

## Endpoints

| URL | Qué hace |
|---|---|
| `/api/atenciones` | Atenciones con datos formateados |
| `/api/metricas/servicios` | Métricas por servicio |
| `/api/ranking/atenciones` | Ranking con funciones ventana |
| `/api/auditoria/atenciones` | Clasificación con la función UDF |
| `/api/reporte?servicio=&estado=&desde=&hasta=` | Reporte con filtros opcionales |

Las pruebas están en `requests.http` y la explicación en `HOMOLOGACION.md`.