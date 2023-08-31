FROM python:slim

COPY Pipfile .
COPY Pipfile.lock .

RUN pip install pipenv && pipenv install --system

COPY . .

CMD ["python", "app.py"]