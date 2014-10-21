cttext() { echo -n "Content-Type: text/$1; charset=utf8"; }
ct() { echo -n "Content-Type: $1"; }
ce() { echo -n "Content-Encoding: $1"; }

code() {
   echo "$1" "$(
      case $1 in
         200 ) echo OK;;
         404 ) echo Not found;;
      esac
      )"
   }

headers() { echo -n -e "HTTP/1.1 $@\n\n"; }

urle() {
   local ret=$(echo -n "$1" | od -A n -t x1)
   echo ${ret// /\%}
   }


urld() { 
   echo "$1" | echo -ne "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
   }

#
# HTML
#

# html :: tag -> contents [-> attrs] -> html
html() { echo "<$1 $3>$2</$1>"; }

# page :: head -> body -> html
page() { echo "<!DOCTYPE html>$(html html "$(html head "$1")$(html body "$2")")"; }

# notfound :: path -> html
notfound() {
   page "$(html title '404 Not Found')" \
        "$(html h1 'Not Found')
         $(html p "The requested URL /$1 was not found on this server")"
   }



list() { # uses bash file globber in for, then -d condition in adding suffix '/'
   html ul "$(
      for f in $1/*; do
         if [ -d "$f" ]; then s=/; else s=''; fi
         f=${f##*/} # drop everything until last /
         html li "$(html a "$f$s" "href='$f$s'")"
      done
      )"
   }
list2() { # uses ls -1F to add slash, strips other classifiers
   html ul "$(
      for f in $(ls -1F "$1" | tr -d '*=>@|'); do # ls -F adds '*/=>@|', we want only /
         html li "$(html a "$f" "href=$f")"
      done
      )"
   }

getpath() {
   if [[ "$2" == '/' ]]; then
      echo '.'
   else
      urld "${2#/}"
   fi
   }

ext2mime() {
   ext=${1##*.}
   case "$ext" in
      html | xhtml | htm )
         echo "$(cttext html)" ;;
      txt | tex | md )
         echo "$(cttext plain)" ;;
      pdf ) 
         echo $(ct application/pdf);;
      gz | zip | bz2 | 7z )
         echo "Content-Type: application/octet-stream" ;;
      * )
         echo "$(ct plain)" ;;
   esac
   }
