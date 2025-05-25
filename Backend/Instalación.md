Para poder tener el servidor y levantar el api hace falta instalar las siguientes dependencias, y se pueden usar dos comando si alguno de los dos no funciona:

* Opción 1: python -m pip install flask flask-sqlalchemy flask-cors psycopg2-binary python-dotenv
* Opción 2: pip install flask flask-sqlalchemy flask-cors psycopg2-binary python-dotenv

Una vez hecho esto debemos correr el api con el comando: python app.py

y listo, para probar la conexión solo es necesario colocar en el navegador el siguiente URL:

http://127.0.0.1:5000/api/test
