package com.turnosmart.api.datos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Conexion {

    private static final String URL = "jdbc:mysql://" + variable("DB_HOST") + ":" + variable("DB_PORT")
            + "/" + variable("DB_NAME") + "?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

    private Conexion() {
    }

    public static Connection abrir() throws SQLException {
        return DriverManager.getConnection(URL, variable("DB_USER"), variable("DB_PASSWORD"));
    }

    private static String variable(String nombre) {
        String valor = System.getenv(nombre);
        if (valor == null) {
            throw new IllegalStateException("Falta la variable de entorno " + nombre);
        }
        return valor;
    }
}