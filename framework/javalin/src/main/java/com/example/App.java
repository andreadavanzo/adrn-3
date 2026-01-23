// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

package com.example;

import io.javalin.Javalin;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class App {

  // PostgreSQL connection settings
  private static final String DB_URL = "jdbc:postgresql://192.168.37.131:5432/postgres";
  private static final String DB_USER = "tester";
  private static final String DB_PASS = "tester";

  public static void main(String[] args) {
    Javalin app = Javalin.create().start(7000);

    app.get("/", ctx -> {
      Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
      PreparedStatement stmt = conn.prepareStatement("SELECT 'hello world' AS greeting;");
      ResultSet rs = stmt.executeQuery();
      rs.next();  // will throw if no row
      String message = rs.getString("greeting");

      rs.close();
      stmt.close();
      conn.close();

      ctx.result(message);
    });
  }
}
