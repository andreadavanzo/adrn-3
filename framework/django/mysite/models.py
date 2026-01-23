from django.db import connection

class Greeting:
    """
    Execute the hello world SQL query
    """

    @staticmethod
    def fetch() -> str:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 'hello world' AS greeting;")
            row = cursor.fetchone()
            return row[0] if row else "error"
