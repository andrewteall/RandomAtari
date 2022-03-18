#include <stdio.h>
#include <string.h>

int durationList[8];
int durationIdx = 0;

int lookupDuration(int duration){
    int durationIndex = -1;
    for (int i=0; i < 8; i++){
        if (durationList[i] == duration){
            durationIndex = i;
            break;
        }
    }
    return durationIndex;
}

void insertDuration(int duration){
    if (durationIdx < 8 && lookupDuration(duration) == -1){
        durationList[durationIdx++] = duration;
    }
}

int main(int argc, char *argv[]) {
    if ((argc == 2 || argc == 3) && strcmp(argv[1], "--version") == 0) {
        printf("Track Generator for Atari 2600\n");    
    } else {
        int c, tmp1, tmp2;
        int note[8];
        int index = 0;
        FILE *trackFile = fopen(argv[1], "r");

        if (trackFile != NULL) {
            if (argc == 2 || (strcmp(argv[2], "-f0")) == 0) {
                while ((c = fgetc(trackFile)) && c != EOF) {
                    if (c != '$' && c != ','){                    
                        if (c >= '0' && c <= '9') {
                            c = c-'0';
                        }
                        if (c >= 'A' && c <= 'F') {
                            c = c-'A'+10;
                        }
                        note[index++] = c;
                        if (index == 8){
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
                            
                            index = 0;
                        }
                    }
                }
            }
            if (argc == 3 && (strcmp(argv[2], "-f1")) == 0) {
                tmp1 = 0;
                while ((c = fgetc(trackFile)) && c != EOF) {
                    if (c != ' ' ){
                        if (c >= '0' && c <= '9') {
                                c = c-'0';
                                note[index++] = c;
                                tmp1++;
                                // printf("%d ", c);
                        } else if (c == ',' || c == '\n') {
                            if (tmp1 == 2) {
                                note[index-2] = note[index-2]*10 + note[index-1];
                                index--;
                            }
                            tmp1 = 0;
                        }
                        // printf("%d / %d\n", tmp1, index);
                        if (index >= 4 && tmp1 != 2 && c != '\n' && c != ',') {
                            // printf("$%d,",note[0]); //v
                            // printf("$%d,",note[1]); //c
                            // printf("$%d,",note[2]); //f
                            // printf("$%d,",note[3]); //d

                            tmp1 = lookupDuration(note[3]) & 7;
                            tmp2 = note[2] << 3;
                            tmp1 = tmp2 | tmp1;
                            printf("$%x,",tmp1);


                            tmp1 = note[0] << 4;
                            tmp2 = note[1] & 15;
                            tmp1 = tmp2 | tmp1;
                            printf("$%x,",tmp1);
                            index = 0;
                        }
                    } else {
                        tmp1 = 0;
                    }       
                }
                // printf("$%d,",note[0]);
                // printf("$%d,",note[1]);
                // printf("$%d,",note[2]);
                // printf("$%d,",note[3]);
                tmp1 = lookupDuration(note[3]) & 7;
                tmp2 = note[2] << 3;
                tmp1 = tmp2 | tmp1;
                printf("$%x,",tmp1);


                tmp1 = note[0] << 4;
                tmp2 = note[1] & 15;
                tmp1 = tmp2 | tmp1;
                printf("$%x,$0,$0",tmp1);
            }
            
            // -f or Format 2 converts https://alienbill.com/2600/atari-riff-machine/ or batari basic output
            if (argc == 3 && (strcmp(argv[2], "-f2")) == 0) { 
                tmp1 = 0;
                int numLen = 0;
                char noteNums[3];
                int noteIdx = 0;
                int noteBuilder;
                while ((c = fgetc(trackFile)) && c != EOF) {
                    if (c != ' ' ){
                        if (c != ',' && c != '\n'){
                            noteNums[numLen++] = c - '0';
                            // printf("\nNoteNums: %d",noteNums[numLen-1]);
                        } else {
                            if (numLen != 0){
                                if (numLen == 3){
                                    noteBuilder = noteNums[0]*100;
                                    noteBuilder += noteNums[1]*10;
                                    noteBuilder += noteNums[2];
                                }
                                if (numLen == 2){
                                    noteBuilder += noteNums[0]*10;
                                    noteBuilder += noteNums[1];
                                } 
                                if (numLen == 1){
                                    noteBuilder += noteNums[0];
                                } 
                            }
                            note[noteIdx++] = noteBuilder;
                            noteBuilder = 0;
                            numLen = 0;
                            noteNums[0] = 0;
                            noteNums[1] = 0;
                            noteNums[2] = 0;
                        }
                    } 
                    if (noteIdx == 4){
                        noteIdx = 0;
                        insertDuration(note[3]);
                        // printf("\nDuration: %d\n",note[3]);
                        tmp1 = lookupDuration(note[3]) & 7;
                        tmp2 = note[2] << 3;
                        tmp1 = tmp2 | tmp1;
                        printf("$%x,",tmp1);

                        tmp1 = note[0] << 4;
                        tmp2 = note[1] & 15;
                        tmp1 = tmp2 | tmp1;
                        printf("$%x,",tmp1);
                    }
                }

                printf("\nNote Durations:\n");
                for(int i=0; i<8;i++){
                    printf(".byte $%x\n",durationList[i]);
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