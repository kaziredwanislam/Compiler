yacc -d -y 2005108.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 2005108.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ -w -c -o icg.o 2005108ICG_classFile.cpp
g++ -w -c -o mainstub.o 2005108.cpp || true
g++ y.o l.o icg.o mainstub.o -lfl -o 2005108
echo 'All ready, running'
./2005108 ForLoop.txt
