FROM python:3.10.10-buster

WORKDIR /flaskr

ENV FLASK_RUN_HOST=0.0.0.0

RUN mkdir -pv app

COPY app/ app/

COPY pyproject.toml .

RUN pip install -e .

RUN pip install -r app/requirements.txt

EXPOSE 5000

CMD [ "flask", "--app", "app", "run"]