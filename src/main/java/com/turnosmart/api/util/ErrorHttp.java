package com.turnosmart.api.util;

// Error que se responde al cliente con un código HTTP 
public class ErrorHttp extends RuntimeException {

    private final int estado;

    public ErrorHttp(int estado, String mensaje) {
        super(mensaje);
        this.estado = estado;
    }

    public int getEstado() {
        return estado;
    }
}