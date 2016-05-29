#!/usr/bin/python

import numpy
import sys

out = sys.argv[1]
f1 = sys.argv[2]
f2 = sys.argv[3]

A = []
B = []
with open(f1, "r") as left:
	for x in left.readlines()[1:]:
		A.append( map(lambda a: int(a), x.strip().split(' ')) )

with open(f2, "r") as right:
	for x in right.readlines()[1:]:
		B.append( map(lambda a: int(a), x.strip().split(' ')) )

rows = zip(*B)

r = len(B)
c = len(rows)

print r, ' ', c

result = []
temp = []


for i in range(0, len(A)):
	temp = []
	for j in range(0, len(rows)):
		temp.append( numpy.dot(A[i],rows[j]) )
	result.append(temp)

with open(out, "w") as output:
	for i in range(0, len(result)):
		x = ' '.join( map(lambda a: str(a), result[i]) )
		output.write(x + " \n")
