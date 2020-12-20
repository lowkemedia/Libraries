#
#
# tells how to create programs

CC = c++

chess: chess.o piece.o
	$(CC) main.cpp chess.o piece.o -o chess

chess.o: chess.cpp chess.hpp
	$(CC) -c chess.cpp
	
piece.o: piece.cpp piece.hpp
	$(CC) -c piece.cpp

clean:
	rm chess
	rm chess.o
	rm piece.o