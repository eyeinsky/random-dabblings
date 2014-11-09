#
# HTML
#

# html :: tag -> contents [-> attrs] -> html
html() { echo -ne "<$1 $3>$2</$1>"; }

# page :: head -> body -> html
page() { echo "<!DOCTYPE html>$(html html "$(html head "$1")$(html body "$2")")"; }

# notfound :: path -> html
notfound() {
   page "$(html title '404 Not Found')" \
        "$(html h1 'Not Found')
         $(html p "The requested URL /$1 was not found on this server")"
   }

