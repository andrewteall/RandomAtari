#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc == 2 && strcmp(argv[1], "--version") == 0) {
        printf("Track Generator for Atari 2600\n");    
    } else {
        int c, tmp1, tmp2;
        int note[8];
        int counter = 0;
        FILE *trackFile = fopen(argv[1], "r");

        if (trackFile != NULL) {
            while ((c = fgetc(trackFile)) && c != EOF) {
                if (c != '$' && c != ','){                    
                    if (c >= '0' && c <= '9') {
                        c = c-'0';
                    }
                    if (c >= 'A' && c <= 'F') {
                        c = c-'A'+10;
                    }
                    note[counter++] = c;
                    if (counter == 8){
                        tmp1 = note[0] * 16 + note[1];
                        tmp2 = note[2] * 16 + note[3];

                        tmp1 = tmp1 & 7;
                        tmp2 = tmp2 << 3;
                        tmp1 = tmp2 | tmp1;
                        printf("$%x,",tmp1);

                        tmp1 = note[4] * 16 + note[5];
                        tmp2 = note[6] * 16 + note[7];

                        tmp1 = tmp1 << 4;
                        tmp2 = tmp2 & 15;
                        tmp1 = tmp2 | tmp1;
                        printf("$%x,",tmp1);
                        
                        counter = 0;
                    }
                }
            }
        } else {
            printf("Unable to Open Track File");
            return 1;
        }
        fclose(trackFile);
        
        }
    return 0;
}