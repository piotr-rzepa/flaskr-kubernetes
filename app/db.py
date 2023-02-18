import click
import mysql.connector as mysql
from flask import current_app, g
from mysql.connector import errorcode


def get_db():
    """Connect to the application's configured database. The connection
    is unique for each request and will be reused if this is called
    again.
    """
    if "db" not in g:
        try:
            g.db = mysql.connect(
                host=current_app.config["DATABASE_HOST"],
                user=current_app.config["DATABASE_USER"],
                password=current_app.config["DATABASE_PASSWORD"],
                database=current_app.config["DATABASE_NAME"]
            )
            current_app.logger.info("Connection established with remote MySQL database {db} at {instance}:{port} as user {user}".format(
                instance=current_app.config["DATABASE_HOST"],
                port="3306",
                db=current_app.config["DATABASE_NAME"],
                user=current_app.config["DATABASE_USER"]
            ))
        except mysql.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                current_app.logger.error("Something is wrong with your user name or password")
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                current_app.logger.error("Database does not exist")
            else:
                current_app.logger.error(err)  
            raise SystemExit(1) from err      

    return g.db


def close_db(e=None):
    """If this request connected to the database, close the
    connection.
    """
    db = g.pop("db", None)

    if db is not None:
        db.close()
        current_app.logger.debug("Closing database connection.")


def init_db():
    """Clear existing data and create new tables."""
    db = get_db()

    with current_app.open_resource("../db/schema.sql") as f:
        db.cursor().execute(f.read().decode("utf8"))


@click.command("init-db")
def init_db_command():
    """Clear existing data and create new tables."""
    init_db()
    click.echo("Initialized the database.")


def init_app(app):
    """Register database functions with the Flask app. This is called by
    the application factory.
    """
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
