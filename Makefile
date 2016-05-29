CC=nvcc
FLAGS= -arch=sm_20 -Xcompiler -fopenmp -lm -g
MATRIX = matrix
BIGMATRIX = bigMatrix
HUGEMATRIX = hugeMatrix

$(MATRIX):
	$(CC) matrix.cu $(FLAGS) -o $(MATRIX) 

$(BIGMATRIX):
	$(CC) bigMatrix.cu $(FLAGS) -o $(BIGMATRIX)

$(HUGEMATRIX): lib.h
	$(CC) hugeMatrix.cu $(FLAGS) -o $(HUGEMATRIX)

runMat:
	./matrix A2 B2 #matA matB

runBig:
	./bigMatrix A3 B3

runHuge:
	./hugeMatrix A3 B3

redo:
	make cleanHuge && make hugeMatrix && make runHuge

cleanMat:
	rm -f matrix

cleanBig:
	rm -f bigMatrix

cleanHuge:
	rm -f hugeMatrix


