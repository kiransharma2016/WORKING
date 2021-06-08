#!/bin/python3

import math
import os
import random
import re
import sys

def conditional(N):
    if (N % 2 !=0)  or  (N > 5 and N< 21):
        print("Weird")
    else:
        print("Not Weird")
#return 0
if __name__ == '__main__':
    N = int(input().strip())
conditional(N) 
