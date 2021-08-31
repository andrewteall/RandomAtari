all: formatTrack

.PHONY: all clean

formatTrack: formatTrack.c
	gcc -o $@ $< -lX11 -Wall

clean:
	rm -f formatTrack

debug:
	valgrind  -v --leak-check=full --track-origins=yes ./formatTrack testTrack
