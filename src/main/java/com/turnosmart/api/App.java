package com.turnosmart.api;

import com.sun.net.httpserver.HttpServer;
import com.turnosmart.api.controlador.ReporteControlador;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;

public class App {

    public static void main(String[] args) throws Exception {
        HttpServer servidor = HttpServer.create(new InetSocketAddress(8080), 0);
        servidor.createContext("/", new ReporteControlador());
        servidor.setExecutor(Executors.newFixedThreadPool(8));
        servidor.start();
        System.out.println("API TurnoSmart escuchando en el puerto 8080");
    }
}