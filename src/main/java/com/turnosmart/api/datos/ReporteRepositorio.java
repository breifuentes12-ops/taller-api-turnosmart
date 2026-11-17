package com.turnosmart.api.datos;

import com.turnosmart.api.util.Json;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.Map;

//SQL nativo con PreparedStatement
public class ReporteRepositorio {

    // Endpoint 1: INNER JOIN + funciones escalares
    public List<Map<String, Object>> trazabilidad() throws SQLException {
        String sql = """
            SELECT a.id_atencion,
                   t.numero_turno,
                   UPPER(CONCAT(u.nombre, ' ', u.apellido))          AS usuario,
                   UPPER(s.nombre)                                   AS servicio,
                   DATE_FORMAT(t.fecha, '%Y-%m')                     AS anio_mes,
                   DATEDIFF(CURDATE(), t.fecha)                      AS dias_transcurridos,
                   TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin)  AS duracion_min,
                   s.tiempo_estimado_min                             AS estimado_min,
                   TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin) - s.tiempo_estimado_min AS diferencia_min
            FROM atencion a
            INNER JOIN turno t    ON t.id_turno = a.id_turno
            INNER JOIN servicio s ON s.id_servicio = t.id_servicio
            INNER JOIN usuario u  ON u.id_usuario = t.id_usuario
            ORDER BY t.fecha, a.hora_inicio
            """;
        return consultar(sql);
    }

    // Endpoint 2: INNER JOIN de 3 tablas + agregación + GROUP BY + HAVING
    public List<Map<String, Object>> metricasPorServicio() throws SQLException {
        String sql = """
            SELECT s.nombre                                                    AS servicio,
                   COUNT(*)                                                    AS total_atenciones,
                   SUM(TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin))           AS minutos_totales,
                   ROUND(AVG(TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin)), 1) AS promedio_min,
                   MAX(TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin))           AS maximo_min,
                   MIN(TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin))           AS minimo_min
            FROM atencion a
            INNER JOIN turno t    ON t.id_turno = a.id_turno
            INNER JOIN servicio s ON s.id_servicio = t.id_servicio
            WHERE a.hora_fin IS NOT NULL
            GROUP BY s.id_servicio, s.nombre
            HAVING COUNT(*) >= 2
            ORDER BY minutos_totales DESC
            """;
        return consultar(sql);
    }

    // Endpoint 3: INNER JOIN + funciones ventana (Recurso = ventanilla)
    public List<Map<String, Object>> rankingAtenciones() throws SQLException {
        String sql = """
            WITH base AS (
                SELECT s.id_servicio,
                       s.nombre AS servicio,
                       v.id_ventanilla,
                       v.numero AS ventanilla,
                       CONCAT(ue.nombre, ' ', ue.apellido) AS empleado,
                       t.numero_turno,
                       t.fecha,
                       a.hora_inicio,
                       TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin) AS duracion_min
                FROM atencion a
                INNER JOIN turno t      ON t.id_turno = a.id_turno
                INNER JOIN servicio s   ON s.id_servicio = t.id_servicio
                INNER JOIN ventanilla v ON v.id_ventanilla = a.id_ventanilla
                INNER JOIN empleado e   ON e.id_empleado = a.id_empleado
                INNER JOIN usuario ue   ON ue.id_usuario = e.id_usuario
                WHERE a.hora_fin IS NOT NULL
            )
            SELECT servicio,
                   ventanilla,
                   empleado,
                   numero_turno,
                   fecha,
                   duracion_min,
                   DENSE_RANK() OVER (PARTITION BY id_servicio ORDER BY duracion_min DESC) AS ranking,
                   SUM(duracion_min) OVER (PARTITION BY id_ventanilla ORDER BY fecha, hora_inicio) AS minutos_acumulados_ventanilla,
                   ROUND(duracion_min * 100 / SUM(duracion_min) OVER (PARTITION BY id_servicio), 1) AS porcentaje_servicio
            FROM base
            ORDER BY servicio, ranking
            """;
        return consultar(sql);
    }

    // Endpoint 4: INNER JOIN + función UDF del motor
    public List<Map<String, Object>> auditoriaAtenciones() throws SQLException {
        String sql = """
            SELECT t.numero_turno,
                   s.nombre                                          AS servicio,
                   CONCAT(ue.nombre, ' ', ue.apellido)               AS empleado,
                   TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin)  AS duracion_min,
                   s.tiempo_estimado_min                             AS estimado_min,
                   fn_clasificar_atencion(TIMESTAMPDIFF(MINUTE, a.hora_inicio, a.hora_fin),
                                          s.tiempo_estimado_min)     AS clasificacion
            FROM atencion a
            INNER JOIN turno t    ON t.id_turno = a.id_turno
            INNER JOIN servicio s ON s.id_servicio = t.id_servicio
            INNER JOIN empleado e ON e.id_empleado = a.id_empleado
            INNER JOIN usuario ue ON ue.id_usuario = e.id_usuario
            ORDER BY t.fecha, a.hora_inicio
            """;
        return consultar(sql);
    }

    // Endpoint 5: INNER JOIN múltiple + agregación + filtros opcionales con ?
    public List<Map<String, Object>> reporte(Integer servicio, String estado, Date desde, Date hasta)
            throws SQLException {
        String sql = """
            SELECT s.nombre                                  AS servicio,
                   UPPER(t.estado)                           AS estado,
                   COUNT(*)                                  AS total_turnos,
                   COUNT(DISTINCT u.id_usuario)              AS usuarios_distintos,
                   SUM(t.prioridad = 'Prioritario')          AS prioritarios,
                   DATE_FORMAT(MIN(t.fecha), '%d/%m/%Y')     AS primer_turno,
                   DATE_FORMAT(MAX(t.fecha), '%d/%m/%Y')     AS ultimo_turno
            FROM turno t
            INNER JOIN servicio s ON s.id_servicio = t.id_servicio
            INNER JOIN usuario u  ON u.id_usuario = t.id_usuario
            WHERE (? IS NULL OR t.id_servicio = ?)
              AND (? IS NULL OR t.estado = ?)
              AND (? IS NULL OR t.fecha >= ?)
              AND (? IS NULL OR t.fecha <= ?)
            GROUP BY s.nombre, t.estado
            ORDER BY s.nombre, t.estado
            """;
        try (Connection c = Conexion.abrir();
             PreparedStatement ps = c.prepareStatement(sql)) {
            Object[] filtros = {servicio, estado, desde, hasta};
            int i = 1;
            for (Object f : filtros) {        
                for (int k = 0; k < 2; k++, i++) {
                    if (f == null) {
                        ps.setNull(i, Types.NULL);
                    } else {
                        ps.setObject(i, f);
                    }
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                return Json.filas(rs);
            }
        }
    }

    public boolean existeServicio(int idServicio) throws SQLException {
        try (Connection c = Conexion.abrir();
             PreparedStatement ps = c.prepareStatement("SELECT 1 FROM servicio WHERE id_servicio = ?")) {
            ps.setInt(1, idServicio);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private List<Map<String, Object>> consultar(String sql) throws SQLException {
        try (Connection c = Conexion.abrir();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return Json.filas(rs);
        }
    }
}