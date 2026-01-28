// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>

int main() {
  const char *conninfo =
    "host=192.168.37.131 dbname=postgres user=tester password=tester";

  PGconn *conn = PQconnectdb(conninfo);
  PGresult *res = NULL;
  char *tpl = NULL;
  char *out = NULL;

  if (PQstatus(conn) == CONNECTION_OK) {
    res = PQexec(conn, "SELECT 'Hello World' AS greeting;");
    if (PQresultStatus(res) == PGRES_TUPLES_OK) {
      const char *greeting = PQgetvalue(res, 0, 0);

      FILE *f = fopen("template.html", "rb");
      if (f) {
        fseek(f, 0, SEEK_END);
        long size = ftell(f);
        rewind(f);

        tpl = malloc(size + 1);
        if (tpl) {
          fread(tpl, 1, size, f);
          tpl[size] = '\0';
          fclose(f);
          f = NULL;

          char *pos = strstr(tpl, "{{greeting}}");
          if (pos) {
            size_t before = pos - tpl;
            size_t newlen = before + strlen(greeting) + strlen(pos + strlen("{{greeting}}"));

            out = malloc(newlen + 1);
            if (out) {
              memcpy(out, tpl, before);
              memcpy(out + before, greeting, strlen(greeting));
              strcpy(out + before + strlen(greeting),
                     pos + strlen("{{greeting}}"));

              /* --- Output CGI response --- */
              printf("Content-Type: text/html\n\n");
              printf("%s", out);
            }
          }
        }
        if (f) fclose(f);
      }
    }
  }

  /* --- Cleanup --- */
  if (res) PQclear(res);
  if (conn) PQfinish(conn);
  if (tpl) free(tpl);
  if (out) free(out);

  return 0;
}
