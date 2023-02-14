FROM python:3.10.10-buster

EXPOSE 5000

WORKDIR /flaskr

RUN mkdir -pv app

COPY app/ app/

COPY pyproject.toml .

COPY .env .

RUN pip install -e .

RUN pip install -r app/requirements.txt

CMD [ "flask", "--app", "app", "--debug", "run", "--host=0.0.0.0"]