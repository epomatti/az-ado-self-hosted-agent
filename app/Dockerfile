# Credits: https://github.com/DonSchenck/path-to-kubernetes/tree/master

FROM python:3
ADD helloworld.py /
RUN pip install flask
RUN pip install flask_restful
EXPOSE 3333
CMD [ "python", "./helloworld.py"]