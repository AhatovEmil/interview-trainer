#!/bin/sh
# Ежедневная резервная копия базы.
#
# Копия, из которой ни разу не восстанавливались, копией не является — поэтому
# скрипт не только снимает дамп, но и проверяет, что он читается, и удаляет
# старые. Восстановление на живой базе он не делает: это осознанное действие
# человека, а не автоматика.
set -eu

INTERVAL="${INTERVAL_SECONDS:-86400}"
KEEP_DAYS="${KEEP_DAYS:-14}"
DIR=/backups

log() { echo "[backup] $(date -u '+%Y-%m-%d %H:%M:%S') $*"; }

while true; do
	stamp=$(date -u '+%Y%m%d-%H%M%S')
	file="$DIR/trainer-$stamp.sql.gz"

	log "снимаю дамп в $file"
	if pg_dump --no-owner --no-privileges | gzip -9 >"$file.partial"; then
		# Переименование в конце: файл с окончательным именем всегда целый,
		# даже если процесс убили на середине.
		mv "$file.partial" "$file"

		# Читается ли то, что получилось. Дамп, который не разжимается,
		# обнаруживать нужно сейчас, а не в момент аварии.
		if gzip -t "$file"; then
			log "готово, $(du -h "$file" | cut -f1)"
		else
			log "ОШИБКА: дамп не проходит проверку целостности"
			rm -f "$file"
		fi
	else
		log "ОШИБКА: pg_dump завершился неудачно"
		rm -f "$file.partial"
	fi

	log "удаляю копии старше $KEEP_DAYS дней"
	find "$DIR" -name 'trainer-*.sql.gz' -mtime "+$KEEP_DAYS" -delete

	sleep "$INTERVAL"
done
