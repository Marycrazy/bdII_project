import psycopg, os

# Conexão à BD
def get_connection():
    # Vercel connection string
    return psycopg.connect(os.environ.get("CONNECTION_STRING"))

    # Local connection string - run with "python -m api.index" from the root folder
    # return psycopg.connect(
    #     host="localhost",
    #     dbname="bdii",
    #     user="postgres"
    #     # password="IF NEEDED"
    # )