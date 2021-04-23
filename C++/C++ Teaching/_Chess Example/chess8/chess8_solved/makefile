#
#
# tells how to create programs

CC = c++

chess: chess.o piece.o rook.o knight.o bishop.o queen.o king.o
	$(CC) main.cpp chess.o piece.o rook.o knight.o bishop.o queen.o king.o -o chess

chess.o: chess.cpp chess.hpp
	$(CC) -c chess.cpp
	
piece.o: piece.cpp piece.hpp
	$(CC) -c piece.cpp
	
rook.o: rook.cpp rook.hpp
	$(CC) -c rook.cpp
	
knight.o: knight.cpp knight.hpp
	$(CC) -c knight.cpp

bishop.o: bishop.cpp bishop.hpp
	$(CC) -c bishop.cpp

queen.o: queen.cpp queen.hpp
	$(CC) -c queen.cpp

king.o: king.cpp king.hpp
	$(CC) -c king.cpp
	
clean:
	rm chess
	rm chess.o
	rm piece.o
	rm rook.o	
	rm knight.o
	rm bishop.o
	rm queen.o
	rm king.o