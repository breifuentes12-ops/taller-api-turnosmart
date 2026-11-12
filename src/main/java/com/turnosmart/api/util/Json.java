package com.turnosmart.api.util;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class Json {

    private Json() {
    }

  
    public static List<Map<String, Object>> filas(ResultSet rs) throws SQLException {
        List<Map<String, Object>> lista = new ArrayList<>();
        ResultSetMetaData meta = rs.getMetaData();
        while (rs.next()) {
            Map<String, Object> fila = new LinkedHashMap<>();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                fila.put(meta.getColumnLabel(i), rs.getObject(i));
            }
            lista.add(fila);
        }
        return lista;
    }

    public static String escribir(Object valor) {
        if (valor == null) {
            return "null";
        }
        if (valor instanceof Number || valor instanceof Boolean) {
            return valor.toString();
        }
        if (valor instanceof Map<?, ?> mapa) {
            StringBuilder sb = new StringBuilder("{");
            for (Map.Entry<?, ?> e : mapa.entrySet()) {
                if (sb.length() > 1) {
                    sb.append(",");
                }
                sb.append(texto(e.getKey().toString())).append(":").append(escribir(e.getValue()));
            }
            return sb.append("}").toString();
        }
        if (valor instanceof List<?> lista) {
            StringBuilder sb = new StringBuilder("[");
            for (Object o : lista) {
                if (sb.length() > 1) {
                    sb.append(",");
                }
                sb.append(escribir(o));
            }
            return sb.append("]").toString();
        }
        return texto(valor.toString());
    }

    private static String texto(String s) {
        StringBuilder sb = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"' -> sb.append("\\\"");
                case '\\' -> sb.append("\\\\");
                case '\n' -> sb.append("\\n");
                case '\r' -> sb.append("\\r");
                case '\t' -> sb.append("\\t");
                default -> sb.append(c < 0x20 ? String.format("\\u%04x", (int) c) : c);
            }
        }
        return sb.append("\"").toString();
    }
}