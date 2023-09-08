FROM python:slim

COPY Pipfile .
COPY Pipfile.lock .

RUN pip install pipenv && pipenv install --system

COPY . .

EXPOSE 80

CMD ["python", "app.py"]