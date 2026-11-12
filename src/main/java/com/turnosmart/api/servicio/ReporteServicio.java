package com.turnosmart.api.servicio;

import com.turnosmart.api.datos.ReporteRepositorio;
import com.turnosmart.api.util.ErrorHttp;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import java.util.Set;

// Capa de servicio: valida los parámetros y llama al repositorio
public class ReporteServicio {

    private static final Set<String> ESTADOS =
            Set.of("Esperando", "Atendiendo", "Atendido", "Cancelado", "No asistio");

    private final ReporteRepositorio repositorio = new ReporteRepositorio();

    public List<Map<String, Object>> trazabilidad() throws SQLException {
        return repositorio.trazabilidad();
    }

    public List<Map<String, Object>> metricas() throws SQLException {
        return repositorio.metricasPorServicio();
    }

    public List<Map<String, Object>> ranking() throws SQLException {
        return repositorio.rankingAtenciones();
    }

    public List<Map<String, Object>> auditoria() throws SQLException {
        return repositorio.auditoriaAtenciones();
    }

    public List<Map<String, Object>> reporte(Map<String, String> p) throws SQLException {
        Integer servicio = null;
        if (p.containsKey("servicio")) {
            try {
                servicio = Integer.valueOf(p.get("servicio"));
            } catch (NumberFormatException e) {
                throw new ErrorHttp(400, "El parámetro 'servicio' debe ser un número.");
            }
            if (!repositorio.existeServicio(servicio)) {
                throw new ErrorHttp(404, "No existe el servicio " + servicio + ".");
            }
        }

        String estado = p.get("estado");
        if (estado != null && !ESTADOS.contains(estado)) {
            throw new ErrorHttp(400, "Estado no válido. Use: " + ESTADOS);
        }

        Date desde = fecha(p, "desde");
        Date hasta = fecha(p, "hasta");
        if (desde != null && hasta != null && desde.after(hasta)) {
            throw new ErrorHttp(400, "La fecha 'desde' no puede ser posterior a 'hasta'.");
        }

        return repositorio.reporte(servicio, estado, desde, hasta);
    }

    private Date fecha(Map<String, String> p, String nombre) {
        if (!p.containsKey(nombre)) {
            return null;
        }
        try {
            return Date.valueOf(LocalDate.parse(p.get(nombre)));
        } catch (DateTimeParseException e) {
            throw new ErrorHttp(400, "El parámetro '" + nombre + "' debe tener formato AAAA-MM-DD.");
        }
    }
}