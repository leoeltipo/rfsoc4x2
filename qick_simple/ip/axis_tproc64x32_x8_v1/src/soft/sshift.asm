		// $1: periodic mode.
		regwi 0, $1, -2734;
		
		regwi 1, $1, 5; // i
LOOP:	condj 0, $1 > $0, @JMP0;
		math  0, $1, $0-$1;
		bitwi 0, $1, $1 >> 1;
		math  0, $1, $0-$1;
		condj 0, $0 == $0, @JMP1;
JMP0:	bitwi 0, $1, $1 >> 1;
JMP1:	loopnz 1, $1, @LOOP;

		end;

