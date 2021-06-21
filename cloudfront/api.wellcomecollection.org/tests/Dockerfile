FROM public.ecr.aws/bitnami/python:3.9

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY rewrite_tests.py .

ENTRYPOINT ["python", "./rewrite_tests.py"]
