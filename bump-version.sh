#!/usr/bin/env bash
# Поднять версию приложения. Формат версии: МАЖОРНАЯ.МИНОРНАЯ.ПАТЧ (например 0.0.1)
#   ./bump-version.sh patch   — исправление ошибок:        0.0.1 → 0.0.2
#   ./bump-version.sh minor   — новая функция:             0.0.2 → 0.1.0
#   ./bump-version.sh major   — крупное изменение:         0.1.0 → 1.0.0
#   ./bump-version.sh 1.4.2   — задать версию явно
# Меняет номер в sw.js и index.html. После выкладки телефоны увидят плашку «Доступна новая версия».
set -euo pipefail
cd "$(dirname "$0")"
OLD=$(sed -n "s/^const VERSION='\(.*\)';/\1/p" sw.js)
ARG="${1:-}"
IFS=. read -r MA MI PA <<< "$OLD"
case "$ARG" in
  patch) NEW="$MA.$MI.$((PA+1))" ;;
  minor) NEW="$MA.$((MI+1)).0" ;;
  major) NEW="$((MA+1)).0.0" ;;
  "") echo "Текущая версия: $OLD"; sed -n '2,6p' "$0" | sed 's/^# //'; exit 1 ;;
  *) NEW="$ARG" ;;
esac
if [[ ! "$NEW" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "Версия должна быть вида 0.0.1"; exit 1; fi
if [[ "$NEW" == "$OLD" ]]; then echo "Версия уже $OLD"; exit 1; fi
sed -i.bak "s/^const VERSION='.*';/const VERSION='$NEW';/" sw.js
sed -i.bak "s/^const APP_VERSION='.*';/const APP_VERSION='$NEW';/" index.html
rm -f sw.js.bak index.html.bak
grep -q "^const VERSION='$NEW';" sw.js && grep -q "^const APP_VERSION='$NEW';" index.html
echo "Версия: $OLD → $NEW"
