containsElement () {
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

arr=("hello" "there")

containsElement "hello" "${arr[@]}" 
echo $?
containsElement "no" "${arr[@]}"
echo $?
containsElement "there" "${arr[@]}"
echo $?
