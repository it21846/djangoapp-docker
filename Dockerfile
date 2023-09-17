FROM python:3.10-slim
WORKDIR /app
COPY ./requirements.txt ./
RUN pip install -r requirements.txt
COPY ./djangoapp ./
RUN python3 manage.py collectstatic --noinput
EXPOSE 8000/tcp
CMD ["gunicorn", "djangoapp.wsgi:application", "--bind", "0.0.0.0:8000"]
