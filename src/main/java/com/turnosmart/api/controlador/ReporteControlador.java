package com.turnosmart.api.controlador;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.turnosmart.api.servicio.ReporteServicio;
import com.turnosmart.api.util.ErrorHttp;
import com.turnosmart.api.util.Json;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Capa controladora: recibe la petición HTTP y devuelve JSON
public class ReporteControlador implements HttpHandler {

    private final ReporteServicio servicio = new ReporteServicio();

    @Override
    public void handle(HttpExchange http) throws IOException {
        try {
            if (!"GET".equals(http.getRequestMethod())) {
                throw new ErrorHttp(405, "Solo se permite el método GET.");
            }
            Map<String, String> parametros = parametros(http.getRequestURI().getRawQuery());

            List<Map<String, Object>> datos = switch (http.getRequestURI().getPath()) {
                case "/api/atenciones"         -> servicio.trazabilidad();
                case "/api/metricas/servicios" -> servicio.metricas();
                case "/api/ranking/atenciones" -> servicio.ranking();
                case "/api/auditoria/atenciones" -> servicio.auditoria();
                case "/api/reporte"            -> servicio.reporte(parametros);
                default -> throw new ErrorHttp(404, "Ruta no encontrada.");
            };
            responder(http, 200, datos);

        } catch (ErrorHttp e) {
            responder(http, e.getEstado(), error(e.getEstado(), e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            responder(http, 500, error(500, "Error interno: " + e.getMessage()));
        }
    }

    private Map<String, Object> error(int estado, String mensaje) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("estado", estado);
        m.put("error", mensaje);
        return m;
    }

    private Map<String, String> parametros(String query) {
        Map<String, String> mapa = new HashMap<>();
        if (query == null || query.isBlank()) {
            return mapa;
        }
        for (String par : query.split("&")) {
            String[] kv = par.split("=", 2);
            String valor = kv.length > 1 ? URLDecoder.decode(kv[1], StandardCharsets.UTF_8) : "";
            if (!valor.isBlank()) {
                mapa.put(URLDecoder.decode(kv[0], StandardCharsets.UTF_8), valor);
            }
        }
        return mapa;
    }

    private void responder(HttpExchange http, int estado, Object cuerpo) throws IOException {
        byte[] bytes = Json.escribir(cuerpo).getBytes(StandardCharsets.UTF_8);
        http.getResponseHeaders().set("Content-Type", "application/json; charset=utf-8");
        http.sendResponseHeaders(estado, bytes.length);
        try (OutputStream os = http.getResponseBody()) {
            os.write(bytes);
        }
    }
}