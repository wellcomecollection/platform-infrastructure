FROM python:3

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY rewrite_tests.py .

ENTRYPOINT ["python", "./rewrite_tests.py"]
