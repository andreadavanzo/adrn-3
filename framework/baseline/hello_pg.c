#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

int main() {
    // PostgreSQL connection string
    const char *conninfo = "host=192.168.37.131 dbname=postgres user=tester password=tester";

    // Connect to the database
    PGconn *conn = PQconnectdb(conninfo);

    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s\n", PQerrorMessage(conn));
        PQfinish(conn);
        return 1;
    }

    // Execute the simple query
    PGresult *res = PQexec(conn, "SELECT 'hello world' AS greeting;");

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s\n", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        return 1;
    }

    // Print the result
    printf("Content-Type: text/plain\n\n"); // Required for CGI
    printf("%s\n", PQgetvalue(res, 0, 0));

    // Cleanup
    PQclear(res);
    PQfinish(conn);

    return 0;
}
