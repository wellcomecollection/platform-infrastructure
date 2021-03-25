FROM python:3

WORKDIR /usr/local/bin

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY rewrite_tests.py .

ENTRYPOINT rewrite_tests.py