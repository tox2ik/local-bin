java -jar /home/jaroslav/tmp/src/hat/bin/hat.jar
while true;do  
read  -p "finished reading? " quit; 
[[ "$quit" == "yes" ]] && exit
done 
