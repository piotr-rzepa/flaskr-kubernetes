from flask import (Blueprint, current_app, flash, g, redirect, render_template,
                   request, url_for)
from werkzeug.exceptions import abort

from app.auth import login_required
from app.db import get_db

bp = Blueprint("blog", __name__)


@bp.route("/")
def index():
    """Show all the posts, most recent first."""
    current_app.logger.debug("Handling request to / route.")
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("USE flaskr")
    query = ("SELECT p.id, title, body, created, author_id, username"
        " FROM post p JOIN user u ON p.author_id = u.id"
        " ORDER BY created DESC")
    cursor.execute(
        query
    )
    return render_template("blog/index.html", posts=cursor.fetchall())


def get_post(id, check_author=True):
    """Get a post and its author by id.

    Checks that the id exists and optionally that the current user is
    the author.

    :param id: id of post to get
    :param check_author: require the current user to be the author
    :return: the post with author information
    :raise 404: if a post with the given id doesn't exist
    :raise 403: if the current user isn't the author
    """
    query = ("SELECT p.id, title, body, created, author_id, username"
            " FROM post p JOIN user u ON p.author_id = u.id"
            " WHERE p.id = %s")
    cursor = get_db().cursor(dictionary=True)
    cursor.execute(query, (id,))
    post = cursor.fetchone()

    if post is None:
        abort(404, f"Post id {id} doesn't exist.")

    if check_author and post["author_id"] != g.user["id"]:
        abort(403)

    return post


@bp.route("/create", methods=("GET", "POST"))
@login_required
def create():
    """Create a new post for the current user."""
    current_app.logger.debug("Handling {req_type} request to /create route.".format(req_type=request.method))
    if request.method == "POST":
        title = request.form["title"]
        body = request.form["body"]
        error = None

        if not title:
            error = "Title is required."

        if error is not None:
            flash(error)
        else:
            db = get_db()
            cursor = db.cursor()
            cursor.execute(
                "INSERT INTO post (title, body, author_id) VALUES (%s, %s, %s)",
                (title, body, g.user["id"]),
            )
            db.commit()
            return redirect(url_for("blog.index"))

    return render_template("blog/create.html")


@bp.route("/<int:id>/update", methods=("GET", "POST"))
@login_required
def update(id):
    """Update a post if the current user is the author."""
    current_app.logger.debug("Handling {req_type} request to /{id}/update route.".format(req_type=request.method, id=id))
    post = get_post(id)

    if request.method == "POST":
        title = request.form["title"]
        body = request.form["body"]
        error = None

        if not title:
            error = "Title is required."

        if error is not None:
            flash(error)
        else:
            db = get_db()
            cursor = db.cursor()
            cursor.execute(
                "UPDATE post SET title = %s, body = %s WHERE id = %s", (title, body, id)
            )
            db.commit()
            return redirect(url_for("blog.index"))

    return render_template("blog/update.html", post=post)


@bp.route("/<int:id>/delete", methods=("POST",))
@login_required
def delete(id):
    """Delete a post.

    Ensures that the post exists and that the logged in user is the
    author of the post.
    """
    current_app.logger.debug("Handling {req_type} request to /{id}/delete route.".format(req_type=request.method, id=id))
    get_post(id)
    db = get_db()
    cursor = db.cursor()
    cursor.execute("DELETE FROM post WHERE id = %s", (id,))
    db.commit()
    return redirect(url_for("blog.index"))
